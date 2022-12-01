//
//  TPLightbulbChannel.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 28/11/2022.
//

#import "TPLightbulbChannel.h"
#import <TPMatter/Matter.h>
#import "TPChannelConstant.h"
#import "DefaultsUtils.h"
#import "TPDeviceChannelHelper.h"
#import "TPMethodConstant.h"
#import "TPDeviceErrorConstant.h"

@implementation TPLightbulbChannel {
    dispatch_queue_t deviceChannelQueue;
    dispatch_queue_t deviceEventQueue;
    MTRDeviceController* chipController;
    FlutterEventSink _Nullable eventSink;
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPLightbulbChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPLightbulbChannel* instance = [[TPLightbulbChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* event = [FlutterEventChannel eventChannelWithName:TPLightbulbEventChannelDomain
                                                           binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (instancetype)init {
    if (self = [super init]) {
        chipController = InitializeMTR();
        deviceChannelQueue = dispatch_queue_create("com.device.lightbulb.channel.queue", DISPATCH_QUEUE_SERIAL);
        deviceEventQueue = dispatch_queue_create("com.device.lightbulb.event.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([methodTurnOnName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        [self turnOnOff:deviceId andEndpoint:endpoint andOnOff:YES andResult:result];
    }
    else if ([methodTurnOffName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        [self turnOnOff:deviceId andEndpoint:endpoint andOnOff:NO andResult:result];
    }
    else if ([methodSubscribeName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self subscribeWithDeviceId:deviceId]));
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
                                                                 andError:error
                                                               andMessage:[error localizedDescription]];
                        }
                        else {
                            [TPDeviceChannelHelper sendControlSuccessResult:result
                                                                andDeviceId:deviceId
                                                                    andData:@(TRUE)];
                        }
                    }];
                }
                else {
                    [onOffCluster offWithCompletion:^(NSError * error) {
                        if (error != NULL) {
                            [TPDeviceChannelHelper sendControlErrorResult:result
                                                              andDeviceId:deviceId
                                                                 andError:error
                                                               andMessage:[error localizedDescription]];
                        }
                        else {
                            [TPDeviceChannelHelper sendControlSuccessResult:result
                                                                andDeviceId:deviceId
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
                                                 andError:error
                                               andMessage:@"Failed to establish a connection with the device"];
        }
    });
    
    if (!isConnected) {
        [TPDeviceChannelHelper sendControlErrorResult:result
                                          andDeviceId:deviceId
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
                                                           andError:report.error
                                                         andMessage:[report.error description]];
                } else {
                    [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                   andDeviceId:deviceId
                                                       andData:@{@"isOn": (NSNumber *)report.value}];
                }
            }
            else if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeOccupancySensingID)] &&
                     [report.path.attribute isEqualToNumber:@(MTRAttributeIDTypeClusterOccupancySensingAttributeOccupancyID)]) {
                if (report.error != nil) {
                    NSLog(@"Error reading current level: %@", report.error);
                    [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                                        andDeviceId:deviceId
                                                           andError:report.error
                                                         andMessage:[report.error description]];
                } else {
                    [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                                   andDeviceId:deviceId
                                                       andData:@{@"sensorDetected": (NSNumber *)report.value}];
                }
            }
        }
    };
    
    void (^errorHandler)(NSError *) = ^(NSError * error) {
        typeof(self) strongSelf = weakSelf;
        NSLog(@"Status: update reportAttributeMeasuredValue completed with error %@", [error description]);
        [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                            andDeviceId:deviceId
                                               andError:error
                                             andMessage:[error description]];
    };
    
    void (^subscriptionEstablished)(void) = ^{};
    
    BOOL isConnected = MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            // Use a wildcard subscription
            __auto_type * params = [[MTRSubscribeParams alloc] initWithMinInterval:@(5)
                                                                       maxInterval:@(60)];
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