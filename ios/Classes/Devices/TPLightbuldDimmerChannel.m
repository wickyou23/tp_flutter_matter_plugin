//
//  TPLightbuldDevice.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 25/10/2022.
//

#import "TPLightbuldDimmerChannel.h"
#import <TPMatter/Matter.h>
#import "TPChannelConstant.h"
#import "DefaultsUtils.h"
#import "ExtentionHelper.h"
#import "TPDeviceChannelHelper.h"

NSString* const ControlErrorKey = @"ControlErrorKey";
NSString* const ControlSuccessKey = @"ControlSuccessKey";
NSString* const ReportEventKey = @"ReportEventKey";
NSString* const ReportErrorEventKey = @"ReportErrorEventKey";

NSString* const methodTurnOnName = @"turnON";
NSString* const methodTurnOffName = @"turnOFF";
NSString* const methodLevelControlName = @"controlLevel";
NSString* const methodSubscribeName = @"subscribeWithDeviceId";
NSString* const methodControlTemperatureColorName = @"controlTemperatureColor";
NSString* const methodcontrolHUEAndSaturationColorName = @"controlHUEAndSaturationColor";

@interface TPLightbuldDimmerChannel ()

@property (readwrite) MTRDeviceController* chipController;
@property (nonatomic, copy, nullable) FlutterEventSink eventSink;

@end

@implementation TPLightbuldDimmerChannel {
    dispatch_queue_t deviceChannelQueue;
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPLightbuldDimmerChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPLightbuldDimmerChannel* instance = [[TPLightbuldDimmerChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* event = [FlutterEventChannel eventChannelWithName:TPLightbuldDimmerEventChannelDomain
                                                           binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (instancetype)init {
    if (self = [super init]) {
        _chipController = InitializeMTR();
        deviceChannelQueue = dispatch_queue_create("com.device.channel.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([methodTurnOnName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        result(@([self turnOnOff:deviceId andEndpoint:endpoint andOnOff:YES]));
    }
    else if ([methodTurnOffName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        result(@([self turnOnOff:deviceId andEndpoint:endpoint andOnOff:NO]));
    }
    else if ([methodSubscribeName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self subscribeWithDeviceId:deviceId]));
    }
    else if ([methodLevelControlName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* level = args[@"level"];
        NSNumber* endpoint = args[@"endpoint"];
        result(@([self controlLevelWithDeviceId:deviceId
                                    andEndpoint:endpoint
                                       andLevel:level]));
    }
    else if ([methodControlTemperatureColorName isEqual:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* temperature = args[@"temperatureColor"];
        NSNumber* endpoint = args[@"endpoint"];
        result(@([self controlTemperatureColorWithDeviceId:deviceId
                                               andEndpoint:endpoint
                                       andTemperatureColor:temperature]));
    }
    else if ([methodcontrolHUEAndSaturationColorName isEqual:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* hue = args[@"hue"];
        NSNumber* saturation = args[@"saturation"];
        NSNumber* endpoint = args[@"endpoint"];
        result(@([self controlHueAndSaturationColorWithDeviceId:deviceId
                                                    andEndpoint:endpoint
                                                         andHUE:hue
                                                  andSaturation:saturation]));
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)turnOnOff:(NSString*)deviceId andEndpoint:(NSNumber*)endpoint andOnOff:(BOOL)onOff {
    __weak typeof(self) weakSelf = self;
    if (MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable) = ^(NSNumber* _Nullable trueEndpoint) {
                typeof(self) strongSelf = weakSelf;
                if (!trueEndpoint) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [strongSelf sendControlErrorEventSink:deviceId andMessage:@"[DeviceControl] Status: Control failed"];
                    return;
                }
                
                
                MTRBaseClusterOnOff * onOffCluster = [[MTRBaseClusterOnOff alloc] initWithDevice:chipDevice
                                                                                        endpoint:trueEndpoint
                                                                                           queue:strongSelf->deviceChannelQueue];
                if (onOff) {
                    [onOffCluster onWithCompletion:^(NSError * error) {
                        if (error != NULL) {
                            [strongSelf sendControlErrorEventSink:deviceId andMessage:[error localizedDescription]];
                        }
                        else {
                            [strongSelf sendControlSuccessEventSink:deviceId andData:@(TRUE)];
                        }
                    }];
                }
                else {
                    [onOffCluster offWithCompletion:^(NSError * error) {
                        if (error != NULL) {
                            [strongSelf sendControlErrorEventSink:deviceId andMessage:[error localizedDescription]];
                        }
                        else {
                            [strongSelf sendControlSuccessEventSink:deviceId andData:@(TRUE)];
                        }
                    }];
                }
            };
            
            typeof(self) strongSelf = weakSelf;
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:endpoint
                                                  andClusterId:@(MTRClusterIDTypeOnOffID)
                                            andDeviceConnected:chipDevice
                                                      andQueue:strongSelf->deviceChannelQueue
                                                 andCompletion:verifyEndpointCompletion];
        } else {
            [self sendControlErrorEventSink:deviceId andMessage:@"Failed to establish a connection with the device"];
        }
    })) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)controlLevelWithDeviceId:(NSString*)deviceId andEndpoint:(NSNumber*)endpoint andLevel:(NSNumber*)level {
    __weak typeof(self) weakSelf = self;
    if (MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable) = ^(NSNumber* _Nullable trueEndpoint) {
                typeof(self) strongSelf = weakSelf;
                if (!trueEndpoint) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [strongSelf sendControlErrorEventSink:deviceId andMessage:@"[DeviceControl] Status: Control failed"];
                    return;
                }
                
                __auto_type * levelControl = [[MTRBaseClusterLevelControl alloc] initWithDevice:chipDevice
                                                                                       endpoint:trueEndpoint
                                                                                          queue:strongSelf->deviceChannelQueue];
                __auto_type *params = [[MTRLevelControlClusterMoveToLevelWithOnOffParams alloc] init];
                params.level = level;
                [levelControl moveToLevelWithOnOffWithParams:params completion:^(NSError * _Nullable error) {
                    if (error != NULL) {
                        [strongSelf sendControlErrorEventSink:deviceId andMessage:[error localizedDescription]];
                    }
                    else {
                        [strongSelf sendControlSuccessEventSink:deviceId andData:@(TRUE)];
                    }
                }];
            };
            
            typeof(self) strongSelf = weakSelf;
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:endpoint
                                                  andClusterId:@(MTRClusterIDTypeLevelControlID)
                                            andDeviceConnected:chipDevice
                                                      andQueue:strongSelf->deviceChannelQueue
                                                 andCompletion:verifyEndpointCompletion];
        } else {
            [self sendControlErrorEventSink:deviceId andMessage:@"Failed to establish a connection with the device"];
        }
    })) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)controlTemperatureColorWithDeviceId:(NSString*)deviceId andEndpoint:(NSNumber*)endpoint andTemperatureColor:(NSNumber*)temperature {
    __weak typeof(self) weakSelf = self;
    if (MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable) = ^(NSNumber* _Nullable trueEndpoint) {
                typeof(self) strongSelf = weakSelf;
                if (!trueEndpoint) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [strongSelf sendControlErrorEventSink:deviceId andMessage:@"[DeviceControl] Status: Control failed"];
                    return;
                }
                
                __auto_type* colorControl = [[MTRBaseClusterColorControl alloc] initWithDevice:chipDevice
                                                                                      endpoint:trueEndpoint
                                                                                         queue:strongSelf->deviceChannelQueue];
                __auto_type* params = [[MTRColorControlClusterMoveToColorTemperatureParams alloc] init];
                params.colorTemperature = temperature;
                [colorControl moveToColorTemperatureWithParams:params completion:^(NSError * _Nullable error) {
                    if (error != NULL) {
                        [strongSelf sendControlErrorEventSink:deviceId andMessage:[error localizedDescription]];
                    }
                    else {
                        [strongSelf sendControlSuccessEventSink:deviceId andData:@(TRUE)];
                    }
                }];
            };
            
            typeof(self) strongSelf = weakSelf;
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:endpoint
                                                  andClusterId:@(MTRClusterIDTypeColorControlID)
                                            andDeviceConnected:chipDevice
                                                      andQueue:strongSelf->deviceChannelQueue
                                                 andCompletion:verifyEndpointCompletion];
        } else {
            [self sendControlErrorEventSink:deviceId andMessage:@"Failed to establish a connection with the device"];
        }
    })) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)controlHueAndSaturationColorWithDeviceId:(NSString*)deviceId andEndpoint:(NSNumber*)endpoint andHUE:(NSNumber*)hue andSaturation:(NSNumber*)saturation {
    __weak typeof(self) weakSelf = self;
    if (MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable) = ^(NSNumber* _Nullable trueEndpoint) {
                typeof(self) strongSelf = weakSelf;
                if (!trueEndpoint) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [strongSelf sendControlErrorEventSink:deviceId andMessage:@"[DeviceControl] Status: Control failed"];
                    return;
                }
                
                __auto_type* colorControl = [[MTRBaseClusterColorControl alloc] initWithDevice:chipDevice
                                                                                      endpoint:trueEndpoint
                                                                                         queue:strongSelf->deviceChannelQueue];
                __auto_type* params = [[MTRColorControlClusterMoveToHueAndSaturationParams alloc] init];
                params.hue = hue;
                params.saturation = saturation;
                [colorControl moveToHueAndSaturationWithParams:params completion:^(NSError * _Nullable error) {
                    if (error != NULL) {
                        [strongSelf sendControlErrorEventSink:deviceId andMessage:[error localizedDescription]];
                    }
                    else {
                        [strongSelf sendControlSuccessEventSink:deviceId andData:@(TRUE)];
                    }
                }];
            };
            
            typeof(self) strongSelf = weakSelf;
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:endpoint
                                                  andClusterId:@(MTRClusterIDTypeColorControlID)
                                            andDeviceConnected:chipDevice
                                                      andQueue:strongSelf->deviceChannelQueue
                                                 andCompletion:verifyEndpointCompletion];
        } else {
            [self sendControlErrorEventSink:deviceId andMessage:@"Failed to establish a connection with the device"];
        }
    })) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)subscribeWithDeviceId:(NSString*)deviceId {
    __weak typeof(self) weakSelf = self;
    void (^attributeReportHandler)(NSArray * _Nullable) = ^(NSArray * _Nullable reports) {
        typeof(self) strongSelf = weakSelf;
        if (!reports)
            return;
        
        for (MTRAttributeReport * report in reports) {
            if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeOnOffID)] &&
                [report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterOnOffAttributeOnOffID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading on/off: %@", report.error);
                    [strongSelf sendReportErrorEventSink:deviceId andMessage:[report.error description]];
                } else {
                    [strongSelf sendReportEventSink:deviceId andData:@{@"isOn": (NSNumber *)report.value}];
                }
            }
            else if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeLevelControlID)] &&
                     [report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterLevelControlAttributeCurrentLevelID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading current level: %@", report.error);
                    [strongSelf sendReportErrorEventSink:deviceId andMessage:[report.error description]];
                } else {
                    [strongSelf sendReportEventSink:deviceId andData:@{@"level": (NSNumber *)report.value}];
                }
            }
            else if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeColorControlID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading color control: %@", report.error);
                    [strongSelf sendReportErrorEventSink:deviceId andMessage:[report.error description]];
                } else {
                    
                    if ([report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterColorControlAttributeColorTemperatureMiredsID)]) {
                        [strongSelf sendReportEventSink:deviceId andData:@{@"temperatureColor": (NSNumber *)report.value}];
                    }
                    else if ([report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterColorControlAttributeCurrentHueID)]) {
                        [strongSelf sendReportEventSink:deviceId andData:@{@"hue": (NSNumber *)report.value}];
                    }
                    else if ([report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterColorControlAttributeCurrentSaturationID)]) {
                        [strongSelf sendReportEventSink:deviceId andData:@{@"saturation": (NSNumber *)report.value}];
                    }
                }
            }
            else if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeOccupancySensingID)] &&
                     [report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterOccupancySensingAttributeOccupancyID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading current level: %@", report.error);
                    [strongSelf sendReportErrorEventSink:deviceId andMessage:[report.error description]];
                } else {
                    [strongSelf sendReportEventSink:deviceId andData:@{@"sensorDetected": (NSNumber *)report.value}];
                }
            }
        }
    };
    
    void (^errorHandler)(NSError *) = ^(NSError * error) {
        typeof(self) strongSelf = weakSelf;
        NSLog(@"Status: update reportAttributeMeasuredValue completed with error %@", [error description]);
        [strongSelf sendReportErrorEventSink:deviceId andMessage:[error description]];
    };
    
    void (^subscriptionEstablished)(void) = ^{};
    
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            // Use a wildcard subscription
            __auto_type * params = [[MTRSubscribeParams alloc] initWithMinInterval:@(5)
                                                                       maxInterval:@(60)];
            [chipDevice subscribeWithQueue:[TPDeviceChannelHelper eventQueue]
                                    params:params
                clusterStateCacheContainer:nil
                    attributeReportHandler:attributeReportHandler
                        eventReportHandler:nil
                              errorHandler:errorHandler
                   subscriptionEstablished:subscriptionEstablished
                   resubscriptionScheduled:nil];
        } else {
            NSLog(@"Status: Failed to establish a connection with the device");
        }
    });
    
    if (isConnected) {
        NSLog(@"Status: Waiting for connection with the device");
        return YES;
    } else {
        NSLog(@"Status: Failed to trigger the connection with the device");
        return NO;
    }
}

//MARK: - EventSink

- (void)sendControlErrorEventSink:(NSString*)deviceId andMessage:(NSString* _Nullable)message {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(@{ControlErrorKey: @{@"deviceId": deviceId, @"errorMessage": message}});
}

- (void)sendControlSuccessEventSink:(NSString*)deviceId andData:(id _Nullable)data {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(@{ControlSuccessKey: @{@"deviceId": deviceId, @"data": data}});
}

- (void)sendReportEventSink:(NSString*)deviceId andData:(id _Nullable)data {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(@{ReportEventKey: @{@"deviceId": deviceId, @"data": data}});
}

- (void)sendReportErrorEventSink:(NSString*)deviceId andMessage:(NSString* _Nullable)message {
    if (_eventSink == NULL) {
        return;
    }
    
    _eventSink(@{ReportErrorEventKey: @{@"deviceId": deviceId, @"errorMessage": message}});
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
