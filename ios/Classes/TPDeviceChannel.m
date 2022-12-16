//
//  TPDeviceChannel.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 17/10/2022.
//

#import "TPDeviceChannel.h"
#import "DefaultsUtils.h"
#import "TPChannelConstant.h"
#import <TPMatter/Matter.h>
#import "ExtentionHelper.h"
#import "TPDeviceChannelHelper.h"
#import "TPMethodConstant.h"

//MARK: - TPDeviceChannel

@implementation TPDeviceChannel {
    dispatch_queue_t deviceChannelQueue;
    MTRDeviceController* chipController;
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPDeviceChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPDeviceChannel* instance = [[TPDeviceChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    if (self = [super init]) {
        chipController = InitializeMTR();
        deviceChannelQueue = dispatch_queue_create("com.device.channel.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([TPMethodGetPlatformVersion isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
    else if ([TPMethodGetDiscoverDevice isEqualToString:call.method]) {
        [self getDiscoverDevice:result];
    }
    else if ([TPMethodGetDeviceList isEqualToString:call.method]) {
        [self getDeviceListWithResult:result];
    }
    else if ([TPMethodUnpairDeviceById isEqualToString:call.method]) {
        NSDictionary* args = call.arguments;
        [self unpairDeviceById:(NSString*)args[@"deviceId"] andFlutterResult:result];
    }
    else if ([TPMethodGetSetupPayloadFromQRCodeString isEqualToString:call.method]) {
        NSDictionary* args = call.arguments;
        [self getSetupPayloadFromQRCodeString:(NSString*)args[@"qrCode"]
                             andFlutterResult:result];
    }
    else if ([TPMethodSaveBindingWithDeviceId isEqual:call.method]) {
        NSDictionary* args = call.arguments;
        [self saveBindingWithDeviceId:(NSString*)args[@"deviceId"]
                    andDeviceEndpoint:(NSNumber*)args[@"endpoint"]
                    andBindingDevices:(NSArray*)args[@"bindingDevices"]
                            andResult:result];
    }
    else if ([TPMethodReadBindingDatasWithDeviceId isEqual:call.method]) {
        NSDictionary* args = call.arguments;
        [self readBindingDatasWithDeviceId:(NSString*)args[@"deviceId"]
                         andDeviceEndpoint:(NSNumber*)args[@"endpoint"]
                                 andResult:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)getDiscoverDevice:(FlutterResult)result {
    [chipController discoverCommissionableNodes];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray* ipAddressList = [NSMutableArray array];
            for (int i = 0; i <= 10; i++) {
                MTRDiscoverDevice* device = [strongSelf->chipController getDiscoveredDevice:i];
                if (device != NULL) {
                    [ipAddressList addObject:[device convertToDict]];
                }
            }
            
            result(ipAddressList);
        }
    });
}

- (void)getDeviceListWithResult:(FlutterResult)result
{
    result([self getDeviceList]);
}

- (NSArray*)getDeviceList {
    uint64_t nextDeviceID = MTRGetNextAvailableDeviceID();
    NSMutableArray* deviceList = [NSMutableArray new];
    for (uint64_t i = 0; i < nextDeviceID; i++) {
        if (MTRIsDevicePaired(i)) {
            [deviceList addObject:[@(i) stringValue]];
        }
    }
    
    return deviceList;
}

- (void)unpairDeviceById:(NSString*)deviceId andFlutterResult:(FlutterResult)result {
    uint64_t nodeId;
    NSScanner *scanner = [[NSScanner alloc] initWithString:deviceId];
    [scanner scanUnsignedLongLong:&nodeId];
    
    if (MTRIsDevicePaired(nodeId)) {
        MTRUnpairDeviceWithID(nodeId);
        result(@(TRUE));
    }
    else {
        result(@(FALSE));
    }
}

- (void)getSetupPayloadFromQRCodeString:(NSString*)qrCode andFlutterResult:(FlutterResult)result {
    if ([qrCode length] == 0) {
        result([FlutterError errorWithCode:@"INVALID_PRAMETERS"
                                   message:@"QRCode was empty"
                                   details:NULL]);
        return;
    }
    
    NSError* error = NULL;
    MTRSetupPayload* payload = [MTRSetupPayload setupPayloadWithOnboardingPayload:qrCode error:&error];
    if (error != NULL) {
        result([FlutterError errorWithCode:@"INVALID_REQUEST"
                                   message:[NSString stringWithFormat:@"[Error] MTRSetupPayload: %@", [error localizedDescription]]
                                   details:NULL]);
    }
    else {
        NSLog(@"MTRSetupPayload: %@", payload);
        result([payload convertToDict]);
    }
}

- (void)readBindingDatasWithDeviceId:(NSString*)deviceId andDeviceEndpoint:(NSNumber*)endpoint andResult:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId integerValue], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        void (^verifyEndpointCompletion)(NSNumber* _Nullable, NSError* _Nullable) = ^(NSNumber* _Nullable endpointVerified, NSError* _Nullable endpointError) {
            typeof(self) strongSelf = weakSelf;
            if (endpointError != NULL) {
                NSLog(@"[Binding][Read][ERROR]: %@", [endpointError localizedDescription]);
                [TPDeviceChannelHelper sendErrorResult:result
                                           andDeviceId:deviceId
                                              andError:endpointError
                                            andMessage:[NSString stringWithFormat:@"[Binding][Read][ERROR] Status: %@", [endpointError localizedDescription]]];
                return;
            }
            
            MTRBaseClusterBinding* binding = [[MTRBaseClusterBinding alloc] initWithDevice:chipDevice
                                                                                  endpoint:endpointVerified
                                                                                     queue:strongSelf->deviceChannelQueue];
            [binding readAttributeBindingWithParams:NULL completion:^(NSArray * _Nullable value, NSError * _Nullable error) {
                NSMutableArray* bindindDatas = [NSMutableArray array];
                for (MTRBindingClusterTargetStruct* item in value) {
                    [bindindDatas addObject:@{
                        @"node": item.node,
                        @"endpoint": item.endpoint,
                        @"cluster": item.cluster,
                        @"fabricIndex": @(1)
                    }];
                }
                
                [TPDeviceChannelHelper sendSuccessResult:result
                                             andDeviceId:deviceId
                                                 andData:bindindDatas];
            }];
        };
        
        if (chipDevice != NULL) {
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:endpoint
                                                  andClusterId:@(MTRClusterIDTypeBindingID)
                                            andDeviceConnected:chipDevice
                                                      andQueue:strongSelf->deviceChannelQueue
                                                 andCompletion:verifyEndpointCompletion];
        }
        else {
            NSLog(@"[Binding][Read][ERROR]: %@", [error localizedDescription]);
            [TPDeviceChannelHelper sendErrorResult:result
                                       andDeviceId:deviceId
                                          andError:error
                                        andMessage:[NSString stringWithFormat:@"[Binding][Read][ERROR] Status: %@", [error localizedDescription]]];
        }
    });
    
    if (!isConnected) {
        NSLog(@"[Binding][Read][ERROR]: Device is not connected");
        [TPDeviceChannelHelper sendErrorResult:result
                                   andDeviceId:deviceId
                                      andError:[[NSError alloc] initWithDomain:@"CONNECT_FAILED" code:-1 userInfo:NULL]
                                    andMessage:[NSString stringWithFormat:@"[Binding][Read][ERROR]: Device is not connected"]];
    }
}

- (void)saveBindingWithDeviceId:(NSString*)deviceId
              andDeviceEndpoint:(NSNumber*)endpoint
              andBindingDevices:(NSArray*)devices
                      andResult:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [self writeACLDataWithDeviceId:deviceId andBindingDevices:devices andCompletion:^(NSError * _Nullable aclError) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (aclError != NULL) {
            [TPDeviceChannelHelper sendErrorResult:result
                                       andDeviceId:deviceId
                                          andError:aclError
                                        andMessage:[NSString stringWithFormat:@"[ACL] Status: %@", [aclError localizedDescription]]];
            return;
        }
        
        
        [strongSelf writeBindingDatasWithDeviceId:deviceId
                                andDeviceEndpoint:endpoint
                                andBindingDevices:devices
                                        andResult:result];
    }];
}
- (void)writeACLDataWithDeviceId:(NSString *)deviceId andBindingDevices:(NSArray*)bindingDevices andCompletion:(void(^)(NSError* _Nullable))completion {
    if (bindingDevices.count == 0) {
        completion(NULL);
        return;
    }
    
    NSMutableArray* tmpBindingDevices = [NSMutableArray arrayWithArray:bindingDevices];
    NSDictionary* dictDevice = [tmpBindingDevices firstObject];
    NSNumber* bindingDeviceId = (NSNumber*)dictDevice[@"node"];
    NSNumber* bindingDeviceEndpoint = (NSNumber*)dictDevice[@"endpoint"];
    [tmpBindingDevices removeObjectAtIndex:0];
    
    __block NSNumber* trueEndpoint = bindingDeviceEndpoint;
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDeviceWithID([bindingDeviceId integerValue], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        void (^readAttributeACLCompletion)(NSArray * _Nullable, NSError * _Nullable) = ^(NSArray * _Nullable value, NSError * _Nullable aclError) {
            typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            if (aclError != NULL) {
                completion(aclError);
                return;
            }
            
            BOOL found = NO;
            BOOL found112233 = NO;
            NSMutableSet* deviceList = [NSMutableSet setWithArray:[strongSelf getDeviceList]];
            [deviceList addObject:@(0xE6C4175A4E0A08B)];
            [deviceList addObject:@(112233)];
            NSPredicate* filterPredicate = [NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [deviceList containsObject:((MTRAccessControlClusterAccessControlEntry*)evaluatedObject).subjects.firstObject];
            }];
            
            NSArray* filterValues = [value filteredArrayUsingPredicate:filterPredicate];
            for (MTRAccessControlClusterAccessControlEntry* item in filterValues) {
                if ([item.subjects containsObject:@([deviceId toUInt64])]) {
                    found = YES;
                }
                
                if ([item.subjects containsObject:@(112233)]) {
                    found112233 = YES;
                }
            }
            
            NSMutableArray* newEntries = [NSMutableArray array];
            if (!found) {
                MTRAccessControlClusterAccessControlEntry* newEntry = [[MTRAccessControlClusterAccessControlEntry alloc] init];
                newEntry.fabricIndex = @(1);
                newEntry.privilege = @(5);
                newEntry.authMode = @(2);
                newEntry.subjects = @[@([deviceId toUInt64])];
                newEntry.targets = NULL;
                [newEntries addObject:newEntry];
            }
            
            if (!found112233) {
                MTRAccessControlClusterAccessControlEntry* newEntry = [[MTRAccessControlClusterAccessControlEntry alloc] init];
                newEntry.fabricIndex = @(1);
                newEntry.privilege = @(5);
                newEntry.authMode = @(2);
                newEntry.subjects = @[@(112233)];
                newEntry.targets = NULL;
                [newEntries addObject:newEntry];
            }
            
            if (newEntries.count != 0) {
                MTRBaseClusterAccessControl *accessControl = [[MTRBaseClusterAccessControl alloc] initWithDevice:chipDevice
                                                                                                        endpoint:trueEndpoint
                                                                                                           queue:strongSelf->deviceChannelQueue];
                NSMutableArray* oldEntries = [NSMutableArray arrayWithArray:[filterValues copy]];
                [oldEntries addObjectsFromArray:newEntries];
                [accessControl writeAttributeACLWithValue:oldEntries completion:^(NSError * _Nullable writeACLError) {
                    typeof(self) strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }
                    
                    if (writeACLError != NULL) {
                        NSLog(@"[ACL][ERROR]: %@", [writeACLError localizedDescription]);
                        completion(writeACLError);
                        return;
                    }
                    
                    [strongSelf writeACLDataWithDeviceId:deviceId
                                       andBindingDevices:tmpBindingDevices
                                           andCompletion:completion];
                }];
            }
            else {
                [strongSelf writeACLDataWithDeviceId:deviceId
                                   andBindingDevices:tmpBindingDevices
                                       andCompletion:completion];
            }
        };
        
        void (^verifyEndpointCompletion)(NSNumber* _Nullable, NSError* _Nullable) = ^(NSNumber* _Nullable endpointVerified, NSError* _Nullable endpointError) {
            typeof(self) strongSelf = weakSelf;
            if (endpointError != NULL) {
                NSLog(@"[ACL][ERROR]: %@", [endpointError localizedDescription]);
                completion(endpointError);
                return;
            }
            
            
            trueEndpoint = endpointVerified;
            MTRBaseClusterAccessControl *accessControl = [[MTRBaseClusterAccessControl alloc] initWithDevice:chipDevice
                                                                                                    endpoint:trueEndpoint
                                                                                                       queue:strongSelf->deviceChannelQueue];
            [accessControl readAttributeACLWithParams:NULL completion:readAttributeACLCompletion];
        };
        
        if (chipDevice != NULL) {
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:bindingDeviceEndpoint
                                                  andClusterId:@(MTRClusterIDTypeAccessControlID)
                                            andDeviceConnected:chipDevice
                                                      andQueue:strongSelf->deviceChannelQueue
                                                 andCompletion:verifyEndpointCompletion];
        }
        else {
            NSLog(@"[ACL][ERROR]: %@", [error localizedDescription]);
            completion(error);
        }
    });
    
    if (!isConnected) {
        NSLog(@"[ACL][ERROR]:  Device is not connected");
        completion([[NSError alloc] initWithDomain:@"CONNECT_FAILED" code:-1 userInfo:NULL]);
    }
}

- (void)writeBindingDatasWithDeviceId:(NSString*)deviceId
                    andDeviceEndpoint:(NSNumber*)endpoint
                    andBindingDevices:(NSArray*)devices
                            andResult:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        void (^verifyEndpointCompletion)(NSNumber* _Nullable, NSError* _Nullable) = ^(NSNumber* _Nullable trueEndpoint, NSError* _Nullable endpointError) {
            typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            if (endpointError != NULL) {
                [TPDeviceChannelHelper sendErrorResult:result
                                           andDeviceId:deviceId
                                              andError:endpointError
                                            andMessage:@"[Binding] Status: failed"];
                return;
            }
            
            MTRBaseClusterBinding* binding = [[MTRBaseClusterBinding alloc] initWithDevice:chipDevice
                                                                                  endpoint:trueEndpoint
                                                                                     queue:strongSelf->deviceChannelQueue];
            NSMutableArray* bindingDatas = [NSMutableArray array];
            for (NSDictionary* device in devices) {
                MTRBindingClusterTargetStruct* entry = [[MTRBindingClusterTargetStruct alloc] init];
                entry.fabricIndex = @(1);
                entry.node = (NSNumber*)device[@"node"];
                entry.endpoint = (NSNumber*)device[@"endpoint"];
                entry.cluster = (NSNumber*)device[@"cluster"];
                [bindingDatas addObject:entry];
            }
            
            [binding writeAttributeBindingWithValue:bindingDatas completion:^(NSError * _Nullable bindingError) {
                if (endpointError != NULL) {
                    [TPDeviceChannelHelper sendErrorResult:result
                                               andDeviceId:deviceId
                                                  andError:endpointError
                                                andMessage:@"[Binding] Status: failed"];
                    return;
                }
                
                [TPDeviceChannelHelper sendSuccessResult:result
                                             andDeviceId:deviceId
                                                 andData:devices];
            }];
        };
        
        if (chipDevice != NULL) {
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:endpoint
                                                  andClusterId:@(MTRClusterIDTypeBindingID)
                                            andDeviceConnected:chipDevice
                                                      andQueue:strongSelf->deviceChannelQueue
                                                 andCompletion:verifyEndpointCompletion];
        }
        else {
            [TPDeviceChannelHelper sendErrorResult:result
                                       andDeviceId:deviceId
                                          andError:error
                                        andMessage:@"[Binding] Failed to establish a connection with the device"];
        }
    });
    
    if (!isConnected) {
        [TPDeviceChannelHelper sendErrorResult:result
                                   andDeviceId:deviceId
                                      andError:NULL
                                    andMessage:@"[Binding] Device is not connected"];
    }
}

@end
