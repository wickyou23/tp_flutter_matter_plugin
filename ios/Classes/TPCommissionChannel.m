//
//  TPCommissionChannel.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 17/10/2022.
//

#import <TPMatter/Matter.h>

#import "TPCommissionChannel.h"
#import "DefaultsUtils.h"
#import "TPChannelConstant.h"
#import "TPDevice.h"
#import "ExtentionHelper.h"

#define EXAMPLE_VENDOR_TAG_IP 1
#define MAX_IP_LEN 46
#define EXAMPLE_VENDOR_ID 0xFFF1

NSString* const CommissionErrorKey = @"CommissionErrorKey";
NSString* const CommissionDeviceAttestationFailedKey = @"CommissionDeviceAttestationFailedKey";
NSString* const CommissionSuccessKey = @"CommissionSuccessKey";
NSString* const CompletetedCommissionKey = @"CompletetedCommissionKey";

@interface MTRDeviceController (ToDoRemove)

/**
 * TODO: Temporary until PairingDelegate is fixed to clearly communicate this
 * information to consumers.
 * This should be migrated over to the proper pairing delegate path
 */
- (BOOL)_deviceBeingCommissionedOverBLE:(uint64_t)deviceId;

@end

@interface TPCommissionChannel () <MTRDeviceControllerDelegate, MTRDeviceAttestationDelegate>

@property (readwrite) MTRDeviceController* chipController;
@property (nonatomic, copy, nullable) FlutterEventSink eventSink;
@property (nonatomic, strong) MTRSetupPayload* setupPayload;
@property (nonatomic, strong) NSData* dataset;

@end

@implementation TPCommissionChannel {
    dispatch_queue_t comissionQueue;
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPCommissionChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPCommissionChannel* instance = [[TPCommissionChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* event = [FlutterEventChannel eventChannelWithName:TPCommissionEventChannelDomain
                                                           binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (instancetype)init {
    if (self = [super init]) {
        comissionQueue = dispatch_queue_create("com.csa.matter.commission", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t callbackQueue = dispatch_queue_create("com.csa.matter.commission.callback", DISPATCH_QUEUE_SERIAL);
        _chipController = InitializeMTR();
        [_chipController setDeviceControllerDelegate:self queue:callbackQueue];
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"startOnNetworkCommissionByQRCode" isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* address = args[@"address"];
        NSString* qrCode = args[@"qrCode"];
        
        result(@([self startOnNetworkCommissionByQRCode:qrCode andAddress:address]));
    }
    else if ([@"startThreadCommission" isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* datasetHex = args[@"dataset"];
        _dataset = [datasetHex dataFromHexString];
        
        NSString* qrCode = args[@"qrCode"];
        result(@([self startThreadCommission]));
    }
    else if ([@"startCommissionByQRCode" isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* qrCode = args[@"qrCode"];
        result(@([self startCommissionByQRCode:qrCode]));
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)startOnNetworkCommissionByQRCode:(NSString*)qrCode andAddress:(NSString*)address
{
    if ([address length] == 0 || [qrCode length] == 0) {
        NSLog(@"Address, discriminator, or pincode was empty");
        return NO;
    }
    
    NSError* error = NULL;
    MTRSetupPayload* payload = [MTRSetupPayload setupPayloadWithOnboardingPayload:qrCode error:&error];
    if (error != NULL) {
        NSLog(@"[Error] MTRSetupPayload: %@", [error localizedDescription]);
        return NO;
    }
    else {
        NSLog(@"MTRSetupPayload: %@", payload);
    }
    
    return [self startOnNetworkCommission:address
                         andDiscriminator:[payload.discriminator stringValue]
                               andPincode:[payload.setupPasscode stringValue]];
}

- (BOOL)startOnNetworkCommission:(NSString*)address andDiscriminator:(NSString*)discriminator andPincode:(NSString*)pincode
{
    if ([address length] == 0 || [discriminator length] == 0 || [pincode length] == 0) {
        NSLog(@"Address, discriminator, or pincode was empty");
        return NO;
    }
    
    [self restartMatterStack];
    
    NSError* error = NULL;
    uint16_t port = 5540;
    uint64_t deviceId = MTRGetNextAvailableDeviceID() + arc4random_uniform(50);
    if ([_chipController pairDevice:deviceId
                            address:address
                               port:port
                       setupPINCode:[pincode intValue]
                      discriminator:[discriminator intValue]
                              error:&error])
    {
        deviceId++;
        MTRSetNextAvailableDeviceID(deviceId);
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)startThreadCommission {
    if (_dataset == NULL) {
        [self sendErrorEventSink:@"Cannot found dataset"];
        return NO;
    }
    
    NSError * error = NULL;
    MTRCommissioningParameters * params = [[MTRCommissioningParameters alloc] init];
    params.threadOperationalDataset = _dataset;
    params.failSafeExpiryTimeout = @600;
    
    uint64_t deviceId = MTRGetLastPairedDeviceId();
    if (![_chipController commissionNodeWithID:@(deviceId) commissioningParams:params error:&error]) {
        NSLog(@"Failed to commission Device %llu, with error %@", deviceId, error);
        [self sendErrorEventSink:[error localizedDescription]];
        return NO;
    }
    
    return YES;
}

- (BOOL)startCommissionByQRCode:(NSString*)qrcode {
    NSError * error;
    _setupPayload = [MTRSetupPayload setupPayloadWithOnboardingPayload:qrcode error:&error];
    [self parseOptionalData:_setupPayload];
    return [self handleRendezVous:_setupPayload rawPayload:qrcode];
}

- (void)parseOptionalData:(MTRSetupPayload *)payload
{
    NSLog(@"Payload vendorID %@", payload.vendorID);
    BOOL isSameVendorID = [payload.vendorID isEqualToNumber:[NSNumber numberWithInt:EXAMPLE_VENDOR_ID]];
    if (!isSameVendorID) {
        return;
    }
    
    NSArray * optionalInfo = [payload getAllOptionalVendorData:nil];
    for (MTROptionalQRCodeInfo * info in optionalInfo) {
        NSNumber * tag = info.tag;
        if (!tag) {
            continue;
        }
        
        BOOL isTypeString = (info.infoType == MTROptionalQRCodeInfoTypeString);
        if (!isTypeString) {
            return;
        }
        
        NSString * infoValue = info.stringValue;
        switch (tag.unsignedCharValue) {
            case EXAMPLE_VENDOR_TAG_IP:
                if ([infoValue length] > MAX_IP_LEN) {
                    NSLog(@"Unexpected IP String... %@", infoValue);
                }
                break;
        }
    }
}

- (BOOL)handleRendezVous:(MTRSetupPayload *)payload rawPayload:(NSString *)rawPayload
{
    if (payload.discoveryCapabilities == MTRDiscoveryCapabilitiesUnknown) {
        NSLog(@"Rendezvous Default");
        return [self handleRendezVousDefault:rawPayload];
    }
    
    // Avoid SoftAP if we have other options.
    if ((payload.discoveryCapabilities & MTRDiscoveryCapabilitiesOnNetwork)
        || (payload.discoveryCapabilities & MTRDiscoveryCapabilitiesBLE)) {
        NSLog(@"Rendezvous Default");
        return [self handleRendezVousDefault:rawPayload];
    }
    
    if (payload.discoveryCapabilities & MTRDiscoveryCapabilitiesSoftAP) {
        NSLog(@"Rendezvous Wi-Fi");
        //        [self handleRendezVousWiFi:[self getNetworkName:payload.discriminator]];
        return NO;
    }
    
    // Just fall back on the default.
    NSLog(@"Rendezvous Default");
    return [self handleRendezVousDefault:rawPayload];
}

- (BOOL)handleRendezVousDefault:(NSString *)payload
{
    NSError * error;
    uint64_t deviceID = MTRGetNextAvailableDeviceID() + arc4random_uniform(50);
    
    [self restartMatterStack];
    
    __auto_type * setupPayload = [MTRSetupPayload setupPayloadWithOnboardingPayload:payload error:&error];
    if (setupPayload == nil) {
        NSLog(@"Could not parse setup payload: %@", [error localizedDescription]);
        return NO;
    }
    
    if ([self.chipController setupCommissioningSessionWithPayload:setupPayload newNodeID:@(deviceID) error:&error]) {
        deviceID++;
        MTRSetNextAvailableDeviceID(deviceID);
        return YES;
    } else {
        NSLog(@"Could not start commissioning session setup: %@", [error localizedDescription]);
        return NO;
    }
}

- (void)restartMatterStack
{
    _chipController = MTRRestartController(self.chipController);
    dispatch_queue_t callbackQueue = dispatch_queue_create("com.csa.matter.commission.callback", DISPATCH_QUEUE_SERIAL);
    [_chipController setDeviceControllerDelegate:self queue:callbackQueue];
}

//MARK: - EventSink

- (void)sendEventSink:(id _Nullable)event {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(event);
}

- (void)sendErrorEventSink:(NSString*)message {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(@{CommissionErrorKey: @{@"errorMessage": message}});
}

- (void)sendCommissionSuccessEventSink:(id _Nullable)event {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(@{CommissionSuccessKey: event});
}

- (void)sendCompletetedCommissionEventSink:(id _Nullable)event {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(@{CompletetedCommissionKey: event});
}

//MARK: - MTRDeviceControllerDelegate

- (void)controller:(MTRDeviceController *)controller commissioningSessionEstablishmentDone:(NSError * _Nullable)error
{
    if (error != nil) {
        NSLog(@"Got pairing error back %@", error);
        [self sendErrorEventSink:[error localizedDescription]];
    } else {
        uint64_t deviceId = MTRGetLastPairedDeviceId();
        if ([_chipController respondsToSelector:@selector(_deviceBeingCommissionedOverBLE:)] &&
            [_chipController _deviceBeingCommissionedOverBLE:deviceId]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startThreadCommission];
            });
        } else {
            MTRCommissioningParameters * params = [[MTRCommissioningParameters alloc] init];
            params.deviceAttestationDelegate = self;
            params.failSafeExpiryTimeout = @600;
            NSError * error;
            if (![controller commissionNodeWithID:@(deviceId) commissioningParams:params error:&error]) {
                NSLog(@"Failed to commission Device %llu, with error %@", deviceId, error);
                [self sendErrorEventSink:[error localizedDescription]];
            }
        }
    }
}

- (void)controller:(MTRDeviceController *)controller commissioningComplete:(NSError * _Nullable)error
{
    if (error != nil) {
        NSString* errorMessage = [NSString stringWithFormat:@"[ERROR] commissioningComplete: %@", error];
        NSLog(@"%@", errorMessage);
        [self sendErrorEventSink:errorMessage];
        return;
    }
    
    // track this device
    uint64_t deviceId = MTRGetLastPairedDeviceId();
    MTRSetDevicePaired(deviceId, YES);
    [self setVendorIDOnAccessory];
    _dataset = NULL;
}

- (void)setVendorIDOnAccessory
{
    NSLog(@"Call to setVendorIDOnAccessory");
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDevice(^(MTRBaseDevice * _Nullable device, NSError * _Nullable error) {
        if (device == NULL) {
            NSLog(@"Status: Failed to establish a connection with the device");
            [self sendCommissionSuccessEventSink: @{@"message": @"Status: Failed to establish a connection with the device"}];
            return;
        }
        
        MTRDeviceResponseHandler readAttributeCompletion = ^(NSArray<NSDictionary<NSString *,id> *> * _Nullable values, NSError * _Nullable error) {
            typeof(self) strongSelf = weakSelf;
            NSMutableDictionary* metadata = [NSMutableDictionary dictionary];
            for (NSMutableDictionary *mainDict in values) {
                MTRAttributePath* attributePath = [mainDict objectForKey:MTRAttributePathKey];
                NSMutableDictionary* endpointMetadata = [metadata objectForKey:[attributePath.endpoint stringValue]];
                if (endpointMetadata == NULL) {
                    NSMutableArray* attributeIds = [NSMutableArray arrayWithObject:attributePath.attribute];
                    NSMutableDictionary* initMetadata = [NSMutableDictionary dictionaryWithDictionary:@{
                        @"clusters": [NSMutableDictionary dictionaryWithDictionary:@{
                            [attributePath.cluster stringValue]: attributeIds
                        }]
                    }];
                    
                    [metadata setObject:initMetadata forKey:[attributePath.endpoint stringValue]];
                }
                else {
                    NSMutableDictionary* clustersDict = [endpointMetadata objectForKey:@"clusters"];
                    NSMutableArray* attributeIds = clustersDict[attributePath.cluster];
                    if (attributeIds == NULL) {
                        [clustersDict setObject:[NSMutableArray arrayWithObject:attributePath.attribute]
                                         forKey:[attributePath.cluster stringValue]];
                    }
                    else {
                        [attributeIds addObject:attributePath.attribute];
                    }
                }
            }
            
            NSLog(@"[Comission][attributePath]: %ld", values.count);
            if (metadata.count == 0) {
                NSLog(@"Device endpoints not found");
                [self sendCommissionSuccessEventSink: @{@"message": @"Device endpoints not found"}];
                return;
            }
            
            [strongSelf getDeviceTypeWithBaseDevice:device andMetadata:metadata];
        };
        
        typeof(self) strongSelf = weakSelf;
        [device readAttributePathWithEndpointID:NULL
                                      clusterID:NULL
                                    attributeID:NULL
                                         params:NULL
                                          queue:strongSelf->comissionQueue
                                     completion:readAttributeCompletion];
    });
    
    if (!isConnected) {
        NSLog(@"Status: Failed to trigger the connection with the device");
        [self sendCommissionSuccessEventSink:@{@"message": @"Status: Failed to trigger the connection with the device"}];
    }
}

- (void)getDeviceTypeWithBaseDevice:(MTRBaseDevice*)device andMetadata:(NSDictionary*)metadata {
    __block TPDevice* tpDevice;
    __block NSError* anyError;
    __block NSMutableArray* subDevices = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t deviceTypeQueue = dispatch_queue_create("com.csa.matter.commission.getDeviceType", DISPATCH_QUEUE_CONCURRENT);
    NSMutableArray* tmpEndpoints = [NSMutableArray arrayWithArray:metadata.allKeys];
    void (^handleFailed)(void) = ^{
        typeof(self) strongSelf = weakSelf;
        if (tmpEndpoints.count != 0) {
            return;
        }
        
        if (!tpDevice) {
            [strongSelf sendCompletetedCommissionEventSink:@{
                @"message": @"Status: Waiting for connection with the device",
                @"data": [tpDevice convertToDict]
            }];
        }
        else {
            [strongSelf sendCommissionSuccessEventSink: @{@"message": @"Status: Waiting for connection with the device"}];
        }
    };
    
    NSArray* allEnpoints = [tmpEndpoints sortedArrayUsingComparator:^NSComparisonResult(NSString* _Nonnull obj1, NSString* _Nonnull obj2) {
        if ([obj2 intValue] < [obj1 intValue]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    [allEnpoints enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        typeof(self) strongSelf = weakSelf;
        if (anyError != NULL) {
            [strongSelf sendCommissionSuccessEventSink: @{@"message": @"Status: Waiting for connection with the device"}];
            *stop = YES;
            return;
        }
        
        if ([obj intValue] == 0) {
            NSLog(@"Skip endpoint 0");
            [tmpEndpoints removeObject:obj];
            handleFailed();
            return;
        }
        
        NSDictionary* clusters = metadata[obj][@"clusters"];
        if (![clusters objectForKey:[@(MTRClusterIDTypeDescriptorID) stringValue]]) {
            NSLog(@"No cluster descriptor for endpoint %@", obj);
            [tmpEndpoints removeObject:obj];
            handleFailed();
            return;
        }
        
        MTRBaseClusterDescriptor* descriptor = [[MTRBaseClusterDescriptor alloc] initWithDevice:device
                                                                                       endpoint:@([obj integerValue])
                                                                                          queue:deviceTypeQueue];
        
        __block NSArray* bindingClusterIds = [NSArray array];
        dispatch_semaphore_t sema = dispatch_semaphore_create(idx);
        [descriptor readAttributeClientListWithCompletion:^(NSArray * _Nullable value, NSError * _Nullable error) {
            bindingClusterIds = value;
            dispatch_semaphore_signal(sema);
        }];
        
        [descriptor readAttributeDeviceTypeListWithCompletion:^(NSArray * _Nullable value, NSError * _Nullable error) {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            anyError = error;
            if (error != NULL) {
                handleFailed();
                return;
            }
            
            typeof(self) strongSelf = weakSelf;
            uint64_t lastId = MTRGetLastPairedDeviceId();
            NSMutableDictionary* deviceMetadata = [NSMutableDictionary dictionaryWithDictionary:[metadata objectForKey:obj]];
            [deviceMetadata setValue:bindingClusterIds forKey:@"bindingClusterIds"];
            
            MTRDescriptorClusterDeviceTypeStruct* deviceTypeStruct = (MTRDescriptorClusterDeviceTypeStruct*)[value firstObject];
            [tmpEndpoints removeObject:obj];
            if (tmpEndpoints.count == 0) {
                if (tpDevice == NULL) {
                    tpDevice = [[TPDevice alloc] initWithDeviceId:[@(lastId) stringValue]
                                                    andDeviceType:[deviceTypeStruct.type longLongValue]
                                                      andEndpoint:@([obj integerValue])
                                                      andMetadata:deviceMetadata];
                }
                else {
                    TPDevice* subDevice = [[TPDevice alloc] initWithDeviceId:[@(lastId) stringValue]
                                                               andDeviceType:[deviceTypeStruct.type longLongValue]
                                                                 andEndpoint:@([obj integerValue])
                                                                 andMetadata:deviceMetadata];
                    [subDevices addObject:subDevice];
                }
                
                [tpDevice addSubDevices:subDevices];
                [strongSelf sendCompletetedCommissionEventSink:@{
                    @"message": @"Status: Waiting for connection with the device",
                    @"data": [tpDevice convertToDict]
                }];
            }
            else {
                if (tpDevice == NULL) {
                    tpDevice = [[TPDevice alloc] initWithDeviceId:[@(lastId) stringValue]
                                                    andDeviceType:[deviceTypeStruct.type longLongValue]
                                                      andEndpoint:@([obj integerValue])
                                                      andMetadata:deviceMetadata];
                }
                else {
                    TPDevice* subDevice = [[TPDevice alloc] initWithDeviceId:[@(lastId) stringValue]
                                                               andDeviceType:[deviceTypeStruct.type longLongValue]
                                                                 andEndpoint:@([obj integerValue])
                                                                 andMetadata:deviceMetadata];
                    [subDevices addObject:subDevice];
                }
            }
        }];
    }];
}

//MARK: - MTRDeviceAttestationDelegate

- (void)deviceAttestationFailedForController:(MTRDeviceController *)controller device:(void *)device error:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        typeof(self) strongSelf = weakSelf;
        if (strongSelf == NULL) {
            return;
        }
        
        NSError* attestationError;
        [strongSelf.chipController continueCommissioningDevice:device
                                      ignoreAttestationFailure:YES
                                                         error:&attestationError];
        if (attestationError != NULL) {
            [self sendErrorEventSink:[attestationError localizedDescription]];
        }
    });
}

//MARK: - FlutterStreamHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = NULL;
    return NULL;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return NULL;
}

@end
