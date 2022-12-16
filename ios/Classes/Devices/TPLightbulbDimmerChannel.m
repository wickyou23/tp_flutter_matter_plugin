//
//  TPLightbuldDevice.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 25/10/2022.
//

#import "TPLightbulbDimmerChannel.h"
#import <TPMatter/Matter.h>
#import "TPChannelConstant.h"
#import "DefaultsUtils.h"
#import "ExtentionHelper.h"
#import "TPDeviceChannelHelper.h"
#import "TPMethodConstant.h"

@implementation TPLightbulbDimmerChannel {
    dispatch_queue_t deviceChannelQueue;
    dispatch_queue_t deviceEventQueue;
    MTRDeviceController* chipController;
    FlutterEventSink _Nullable eventSink;
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPLightbulbDimmerChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPLightbulbDimmerChannel* instance = [[TPLightbulbDimmerChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* event = [FlutterEventChannel eventChannelWithName:TPLightbulbDimmerEventChannelDomain
                                                           binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (instancetype)init {
    if (self = [super init]) {
        chipController = InitializeMTR();
        deviceChannelQueue = dispatch_queue_create("com.device.lightbulbdimmer.channel.queue", DISPATCH_QUEUE_CONCURRENT);
        deviceEventQueue = dispatch_queue_create("com.device.lightbulbdimmer.event.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([TPMethodTurnOnName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        [self turnOnOff:deviceId
            andEndpoint:endpoint
               andOnOff:YES
              andResult:result];
    }
    else if ([TPMethodTurnOffName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        [self turnOnOff:deviceId
            andEndpoint:endpoint
               andOnOff:NO
              andResult:result];
    }
    else if ([TPMethodSubscribeName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self subscribeWithDeviceId:deviceId]));
    }
    else if ([TPMethodLevelControlName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* level = args[@"level"];
        NSNumber* endpoint = args[@"endpoint"];
        [self controlLevelWithDeviceId:deviceId
                           andEndpoint:endpoint
                              andLevel:level
                             andResult: result];
    }
    else if ([TPMethodControlTemperatureColorName isEqual:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* temperature = args[@"temperatureColor"];
        NSNumber* endpoint = args[@"endpoint"];
        [self controlTemperatureColorWithDeviceId:deviceId
                                      andEndpoint:endpoint
                              andTemperatureColor:temperature
                                        andResult: result];
    }
    else if ([TPMethodcontrolHUEAndSaturationColorName isEqual:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* hue = args[@"hue"];
        NSNumber* saturation = args[@"saturation"];
        NSNumber* endpoint = args[@"endpoint"];
        [self controlHueAndSaturationColorWithDeviceId:deviceId
                                           andEndpoint:endpoint
                                                andHUE:hue
                                         andSaturation:saturation
                                             andResult:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)turnOnOff:(NSString*)deviceId
      andEndpoint:(NSNumber*)endpoint
         andOnOff:(BOOL)onOff
        andResult:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable, NSError* _Nullable) = ^(NSNumber* _Nullable trueEndpoint, NSError* _Nullable endpointError) {
                typeof(self) strongSelf = weakSelf;
                if (endpointError != NULL) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [TPDeviceChannelHelper sendControlErrorResult:result
                                                      andDeviceId:deviceId
                                                      andEndpoint:trueEndpoint
                                                         andError:endpointError
                                                       andMessage:@"[DeviceControl] Status: Control failed"];
                    
                    
                    return;
                }
                
                
                MTRBaseClusterOnOff * onOffCluster = [[MTRBaseClusterOnOff alloc] initWithDevice:chipDevice
                                                                                        endpoint:trueEndpoint
                                                                                           queue:strongSelf->deviceChannelQueue];
                if (onOff) {
                    [onOffCluster onWithCompletion:^(NSError * error) {
                        if (error != NULL) {
                            [TPDeviceChannelHelper sendControlErrorResult:result
                                                              andDeviceId:deviceId
                                                              andEndpoint:trueEndpoint
                                                                 andError:error
                                                               andMessage:[error localizedDescription]];
                        }
                        else {
                            [TPDeviceChannelHelper sendControlSuccessResult:result
                                                                andDeviceId:deviceId
                                                                andEndpoint:trueEndpoint
                                                                    andData:@(TRUE)];
                        }
                    }];
                }
                else {
                    [onOffCluster offWithCompletion:^(NSError * error) {
                        if (error != NULL) {
                            [TPDeviceChannelHelper sendControlErrorResult:result
                                                              andDeviceId:deviceId
                                                              andEndpoint:trueEndpoint
                                                                 andError:error
                                                               andMessage:[error localizedDescription]];
                        }
                        else {
                            [TPDeviceChannelHelper sendControlSuccessResult:result
                                                                andDeviceId:deviceId
                                                                andEndpoint:trueEndpoint
                                                                    andData:@(TRUE)];
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
            [TPDeviceChannelHelper sendControlErrorResult:result
                                              andDeviceId:deviceId
                                              andEndpoint:endpoint
                                                 andError:error
                                               andMessage:@"Failed to establish a connection with the device"];
        }
    });
    
    if (!isConnected) {
        [TPDeviceChannelHelper sendControlErrorResult:result
                                          andDeviceId:deviceId
                                          andEndpoint:endpoint
                                             andError:NULL
                                           andMessage:@"Failed to establish a connection with the device"];
    }
}

- (void)controlLevelWithDeviceId:(NSString*)deviceId
                     andEndpoint:(NSNumber*)endpoint
                        andLevel:(NSNumber*)level
                       andResult:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable, NSError* _Nullable) = ^(NSNumber* _Nullable trueEndpoint, NSError* _Nullable endpointError) {
                typeof(self) strongSelf = weakSelf;
                if (endpointError != NULL) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [TPDeviceChannelHelper sendControlErrorResult:result
                                                      andDeviceId:deviceId
                                                      andEndpoint:trueEndpoint
                                                         andError:endpointError
                                                       andMessage:@"[DeviceControl] Status: Control failed"];
                    return;
                }
                
                __auto_type * levelControl = [[MTRBaseClusterLevelControl alloc] initWithDevice:chipDevice
                                                                                       endpoint:trueEndpoint
                                                                                          queue:strongSelf->deviceChannelQueue];
                __auto_type *params = [[MTRLevelControlClusterMoveToLevelWithOnOffParams alloc] init];
                params.level = level;
                [levelControl moveToLevelWithOnOffWithParams:params completion:^(NSError * _Nullable error) {
                    if (error != NULL) {
                        [TPDeviceChannelHelper sendControlErrorResult:result
                                                          andDeviceId:deviceId
                                                          andEndpoint:trueEndpoint
                                                             andError:error
                                                           andMessage:[error localizedDescription]];
                    }
                    else {
                        [TPDeviceChannelHelper sendControlSuccessResult:result
                                                            andDeviceId:deviceId
                                                            andEndpoint:trueEndpoint
                                                                andData:@(TRUE)];
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
            [TPDeviceChannelHelper sendControlErrorResult:result
                                              andDeviceId:deviceId
                                              andEndpoint:endpoint
                                                 andError:error
                                               andMessage:@"Failed to establish a connection with the device"];
        }
    });
    
    if (!isConnected) {
        [TPDeviceChannelHelper sendControlErrorResult:result
                                          andDeviceId:deviceId
                                          andEndpoint:endpoint
                                             andError:NULL
                                           andMessage:@"Device is not connected"];
    }
}

- (void)controlTemperatureColorWithDeviceId:(NSString*)deviceId
                                andEndpoint:(NSNumber*)endpoint
                        andTemperatureColor:(NSNumber*)temperature
                                  andResult:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable, NSError* _Nullable) = ^(NSNumber* _Nullable trueEndpoint, NSError* _Nullable endpointError) {
                typeof(self) strongSelf = weakSelf;
                if (endpointError != NULL) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [TPDeviceChannelHelper sendControlErrorResult:result
                                                      andDeviceId:deviceId
                                                      andEndpoint:trueEndpoint
                                                         andError:endpointError
                                                       andMessage:@"[DeviceControl] Status: Control failed"];
                    return;
                }
                
                __auto_type* colorControl = [[MTRBaseClusterColorControl alloc] initWithDevice:chipDevice
                                                                                      endpoint:trueEndpoint
                                                                                         queue:strongSelf->deviceChannelQueue];
                __auto_type* params = [[MTRColorControlClusterMoveToColorTemperatureParams alloc] init];
                params.colorTemperature = temperature;
                [colorControl moveToColorTemperatureWithParams:params completion:^(NSError * _Nullable error) {
                    if (error != NULL) {
                        [TPDeviceChannelHelper sendControlErrorResult:result
                                                          andDeviceId:deviceId
                                                          andEndpoint:trueEndpoint
                                                             andError:error
                                                           andMessage:[error localizedDescription]];
                    }
                    else {
                        [TPDeviceChannelHelper sendControlSuccessResult:result
                                                            andDeviceId:deviceId
                                                            andEndpoint:trueEndpoint
                                                                andData:@(TRUE)];
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
            [TPDeviceChannelHelper sendControlErrorResult:result
                                              andDeviceId:deviceId
                                              andEndpoint:endpoint
                                                 andError:error
                                               andMessage:@"Failed to establish a connection with the device"];
        }
    });
    
    if (!isConnected) {
        [TPDeviceChannelHelper sendControlErrorResult:result
                                          andDeviceId:deviceId
                                          andEndpoint:endpoint
                                             andError:NULL
                                           andMessage:@"Device is not connected"];
    }
}

- (void)controlHueAndSaturationColorWithDeviceId:(NSString*)deviceId
                                     andEndpoint:(NSNumber*)endpoint
                                          andHUE:(NSNumber*)hue
                                   andSaturation:(NSNumber*)saturation
                                       andResult:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            void (^verifyEndpointCompletion)(NSNumber* _Nullable, NSError* _Nullable) = ^(NSNumber* _Nullable trueEndpoint, NSError* _Nullable endpointError) {
                typeof(self) strongSelf = weakSelf;
                if (endpointError != NULL) {
                    NSLog(@"[DeviceControl] Status: Control failed");
                    [TPDeviceChannelHelper sendControlErrorResult:result
                                                      andDeviceId:deviceId
                                                      andEndpoint:trueEndpoint
                                                         andError:endpointError
                                                       andMessage:@"[DeviceControl] Status: Control failed"];
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
                        [TPDeviceChannelHelper sendControlErrorResult:result
                                                          andDeviceId:deviceId
                                                          andEndpoint:trueEndpoint
                                                             andError:error
                                                           andMessage:[error localizedDescription]];
                    }
                    else {
                        [TPDeviceChannelHelper sendControlSuccessResult:result
                                                            andDeviceId:deviceId
                                                            andEndpoint:trueEndpoint
                                                                andData:@(TRUE)];
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
            [TPDeviceChannelHelper sendControlErrorResult:result
                                              andDeviceId:deviceId
                                              andEndpoint:endpoint
                                                 andError:error
                                               andMessage:@"Failed to establish a connection with the device"];
        }
    });
    
    if (!isConnected) {
        [TPDeviceChannelHelper sendControlErrorResult:result
                                          andDeviceId:deviceId
                                          andEndpoint:endpoint
                                             andError:NULL
                                           andMessage:@"Device is not connected"];
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
                    [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                                        andDeviceId:deviceId
                                                        andEndpoint:report.path.endpoint
                                                           andError:report.error
                                                         andMessage:[report.error description]];
                } else {
                    [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                   andDeviceId:deviceId
                                                   andEndpoint:report.path.endpoint
                                                       andData:@{@"isOn": (NSNumber *)report.value}];
                }
            }
            else if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeLevelControlID)] &&
                     [report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterLevelControlAttributeCurrentLevelID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading current level: %@", report.error);
                    [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                                        andDeviceId:deviceId
                                                        andEndpoint:report.path.endpoint
                                                           andError:report.error
                                                         andMessage:[report.error description]];
                } else {
                    [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                   andDeviceId:deviceId
                                                   andEndpoint:report.path.endpoint
                                                       andData:@{@"level": (NSNumber *)report.value}];
                }
            }
            else if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeColorControlID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading color control: %@", report.error);
                    [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                                        andDeviceId:deviceId
                                                        andEndpoint:report.path.endpoint
                                                           andError:report.error
                                                         andMessage:[report.error description]];
                } else {
                    
                    if ([report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterColorControlAttributeColorTemperatureMiredsID)]) {
                        [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                       andDeviceId:deviceId
                                                       andEndpoint:report.path.endpoint
                                                           andData:@{@"temperatureColor": (NSNumber *)report.value}];
                    }
                    else if ([report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterColorControlAttributeCurrentHueID)]) {
                        [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                       andDeviceId:deviceId
                                                       andEndpoint:report.path.endpoint
                                                           andData:@{@"hue": (NSNumber *)report.value}];
                    }
                    else if ([report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterColorControlAttributeCurrentSaturationID)]) {
                        [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                       andDeviceId:deviceId
                                                       andEndpoint:report.path.endpoint
                                                           andData:@{@"saturation": (NSNumber *)report.value}];
                    }
                }
            }
            else if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeOccupancySensingID)] &&
                     [report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterOccupancySensingAttributeOccupancyID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading current level: %@", report.error);
                    [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                                        andDeviceId:deviceId
                                                        andEndpoint:report.path.endpoint
                                                           andError:report.error
                                                         andMessage:[report.error description]];
                } else {
                    [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                   andDeviceId:deviceId
                                                   andEndpoint:report.path.endpoint
                                                       andData:@{@"sensorDetected":(NSNumber *)report.value}];
                }
            }
        }
    };
    
    void (^errorHandler)(NSError *) = ^(NSError * error) {
        typeof(self) strongSelf = weakSelf;
        NSLog(@"[subscribeWithQueue] Status: Failed with error %@", [error localizedDescription]);
        [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                            andDeviceId:deviceId
                                            andEndpoint:NULL
                                               andError:error
                                             andMessage:[error localizedDescription]];
    };
    
    void (^subscriptionEstablished)(void) = ^{};
    
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            // Use a wildcard subscription
            __auto_type * params = [[MTRSubscribeParams alloc] initWithMinInterval:@(0)
                                                                       maxInterval:@(10)];
            [chipDevice subscribeWithQueue:self->deviceEventQueue
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

//MARK: - FlutterStreamHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    eventSink = NULL;
    return NULL;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    eventSink = events;
    return NULL;
}

@end
