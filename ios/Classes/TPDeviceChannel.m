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

//MARK: - TPDeviceChannel

@interface TPDeviceChannel ()

@property (readwrite) MTRDeviceController* chipController;

@end

@implementation TPDeviceChannel

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPDeviceChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPDeviceChannel* instance = [[TPDeviceChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    if (self = [super init]) {
        _chipController = InitializeMTR();
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
    else if ([@"getDiscoverDevice" isEqualToString:call.method]) {
        [self getDiscoverDevice:result];
    }
    else if ([@"getDeviceList" isEqualToString:call.method]) {
        [self getDeviceList:result];
    }
    else if ([@"unpairDeviceById" isEqualToString:call.method]) {
        NSDictionary* args = call.arguments;
        [self unpairDeviceById:(NSString*)args[@"deviceId"] andFlutterResult:result];
    }
    else if ([@"getSetupPayloadFromQRCodeString" isEqualToString:call.method]) {
        NSDictionary* args = call.arguments;
        [self getSetupPayloadFromQRCodeString:(NSString*)args[@"qrCode"] andFlutterResult:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)getDiscoverDevice:(FlutterResult)result {
    [_chipController discoverCommissionableNodes];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray* ipAddressList = [NSMutableArray array];
            for (int i = 0; i <= 10; i++) {
                MTRDiscoverDevice* device = [strongSelf.chipController getDiscoveredDevice:i];
                if (device != NULL) {
                    [ipAddressList addObject:[device convertToDict]];
                }
            }
            
            result(ipAddressList);
        }
    });
}

- (void)getDeviceList:(FlutterResult)result
{
    uint64_t nextDeviceID = MTRGetNextAvailableDeviceID();
    NSMutableArray* deviceList = [NSMutableArray new];
    for (uint64_t i = 0; i < nextDeviceID; i++) {
        if (MTRIsDevicePaired(i)) {
            [deviceList addObject:[@(i) stringValue]];
        }
    }
    
    result(deviceList);
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

@end
