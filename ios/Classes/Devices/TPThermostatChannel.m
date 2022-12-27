//
//  TPThermostatChannel.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 20/12/2022.
//

#import "TPThermostatChannel.h"
#import <TPMatter/Matter.h>
#import "TPChannelConstant.h"
#import "DefaultsUtils.h"
#import "TPDeviceChannelHelper.h"
#import "TPMethodConstant.h"

@implementation TPThermostatChannel {
    dispatch_queue_t deviceChannelQueue;
    dispatch_queue_t deviceEventQueue;
    MTRDeviceController* chipController;
    FlutterEventSink _Nullable eventSink;
}


+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPThermostatChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPThermostatChannel* instance = [[TPThermostatChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* event = [FlutterEventChannel eventChannelWithName:TPThermostatEventChannelDomain
                                                           binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (instancetype)init {
    if (self = [super init]) {
        chipController = InitializeMTR();
        deviceChannelQueue = dispatch_queue_create("com.device.thermostat.channel.queue", DISPATCH_QUEUE_CONCURRENT);
        deviceEventQueue = dispatch_queue_create("com.device.thermostat.event.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([TPMethodSubscribeName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self subscribeWithDeviceId:deviceId]));
    }
    else if ([TPMethodControlSystemModeName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        NSNumber* systemMode = args[@"systemMode"];
        [self controlAttributeValuesWithDeviceId:deviceId
                                     andEndpoint:endpoint
                                  andAttributeID:MTRAttributeIDTypeClusterThermostatAttributeSystemModeID
                                        andValue:systemMode
                                       andResult:result];
    }
    else if ([TPMethodControlMinCoolName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        NSNumber* min = args[@"min"];
        [self controlAttributeValuesWithDeviceId:deviceId
                                     andEndpoint:endpoint
                                  andAttributeID:MTRAttributeIDTypeClusterThermostatAttributeMinCoolSetpointLimitID
                                        andValue:min
                                       andResult:result];
    }
    else if ([TPMethodControlMaxCoolName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        NSNumber* max = args[@"max"];
        [self controlAttributeValuesWithDeviceId:deviceId
                                     andEndpoint:endpoint
                                  andAttributeID:MTRAttributeIDTypeClusterThermostatAttributeMaxCoolSetpointLimitID
                                        andValue:max
                                       andResult:result];
    }
    else if ([TPMethodControlMinHeatName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        NSNumber* max = args[@"min"];
        [self controlAttributeValuesWithDeviceId:deviceId
                                     andEndpoint:endpoint
                                  andAttributeID:MTRAttributeIDTypeClusterThermostatAttributeMinHeatSetpointLimitID
                                        andValue:max
                                       andResult:result];
    }
    else if ([TPMethodControlMaxHeatName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        NSNumber* max = args[@"max"];
        [self controlAttributeValuesWithDeviceId:deviceId
                                     andEndpoint:endpoint
                                  andAttributeID:MTRAttributeIDTypeClusterThermostatAttributeMaxHeatSetpointLimitID
                                        andValue:max
                                       andResult:result];
    }
    else if ([TPMethodControlOccupiedCoolingName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        NSNumber* occupiedCooling = args[@"occupiedCooling"];
        [self controlAttributeValuesWithDeviceId:deviceId
                                     andEndpoint:endpoint
                                  andAttributeID:MTRAttributeIDTypeClusterThermostatAttributeOccupiedCoolingSetpointID
                                        andValue:occupiedCooling
                                       andResult:result];
    }
    else if ([TPMethodControlOccupiedHeatingName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        NSNumber* endpoint = args[@"endpoint"];
        NSNumber* occupiedHeating = args[@"occupiedHeating"];
        [self controlAttributeValuesWithDeviceId:deviceId
                                     andEndpoint:endpoint
                                  andAttributeID:MTRAttributeIDTypeClusterThermostatAttributeOccupiedHeatingSetpointID
                                        andValue:occupiedHeating
                                       andResult:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)controlAttributeValuesWithDeviceId:(NSString*)deviceId
                               andEndpoint:(NSNumber*)endpoint
                            andAttributeID:(MTRAttributeIDType)attributeId
                                  andValue:(NSNumber*)value
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
                
                void (^handleWriteResponse)(NSError * _Nullable) = ^(NSError * _Nullable error) {
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
                };
                
                __auto_type* thermostatControl = [[MTRBaseClusterThermostat alloc] initWithDevice:chipDevice
                                                                                         endpoint:trueEndpoint
                                                                                            queue:strongSelf->deviceChannelQueue];
                switch (attributeId) {
                    case MTRAttributeIDTypeClusterThermostatAttributeMinCoolSetpointLimitID:
                        [thermostatControl writeAttributeMinCoolSetpointLimitWithValue:value completion:handleWriteResponse];
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeMaxCoolSetpointLimitID:
                        [thermostatControl writeAttributeMaxCoolSetpointLimitWithValue:value completion:handleWriteResponse];
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeMinHeatSetpointLimitID:
                        [thermostatControl writeAttributeMinHeatSetpointLimitWithValue:value completion:handleWriteResponse];
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeMaxHeatSetpointLimitID:
                        [thermostatControl writeAttributeMaxHeatSetpointLimitWithValue:value completion:handleWriteResponse];
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeSystemModeID:
                        [thermostatControl writeAttributeSystemModeWithValue:value completion:handleWriteResponse];
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeOccupiedCoolingSetpointID:
                        [thermostatControl writeAttributeOccupiedCoolingSetpointWithValue:value completion:handleWriteResponse];
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeOccupiedHeatingSetpointID:
                        [thermostatControl writeAttributeOccupiedHeatingSetpointWithValue:value completion:handleWriteResponse];
                        break;
                    default:
                        break;
                }
            };
            
            typeof(self) strongSelf = weakSelf;
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:endpoint
                                                  andClusterId:@(MTRClusterIDTypeThermostatID)
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
        if (!strongSelf) {
            return;
        }
        
        if (!reports) {
            return;
        }
        
        void (^handleSendEvent)(NSString*, MTRAttributeReport*) = ^(NSString* key, MTRAttributeReport* report) {
            typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            [TPDeviceChannelHelper sendReportEventSink:strongSelf->eventSink
                                           andDeviceId:deviceId
                                           andEndpoint:report.path.endpoint
                                               andData:@{key: (NSNumber *)report.value}];
        };
        
        for (MTRAttributeReport* report in reports) {
            if (report.error != nil) {
                NSLog(@"Error reading on/off: %@", report.error);
                [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                                    andDeviceId:deviceId
                                                    andEndpoint:report.path.endpoint
                                                       andError:report.error
                                                     andMessage:[report.error description]];
                continue;
            }
            
            if ([report.path.cluster isEqualToNumber:@(MTRClusterIDTypeThermostatID)]) {
                switch ([report.path.attribute intValue]) {
                    case MTRAttributeIDTypeClusterThermostatAttributeLocalTemperatureID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeLocalTemperatureID: %@", report.value);
                        handleSendEvent(@"localTemperature", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeSystemModeID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeSystemModeID: %@", report.value);
                        handleSendEvent(@"systemMode", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeAbsMaxCoolSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeAbsMaxCoolSetpointLimitID: %@", report.value);
                        handleSendEvent(@"absMaxCool", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeAbsMaxHeatSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeAbsMaxHeatSetpointLimitID: %@", report.value);
                        handleSendEvent(@"absMaxHeat", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeAbsMinHeatSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeAbsMinHeatSetpointLimitID: %@", report.value);
                        handleSendEvent(@"absMinHeat", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeAbsMinCoolSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeAbsMinCoolSetpointLimitID: %@", report.value);
                        handleSendEvent(@"absMinCool", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeMaxCoolSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeMaxCoolSetpointLimitID: %@", report.value);
                        handleSendEvent(@"maxCool", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeMinCoolSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeMinCoolSetpointLimitID: %@", report.value);
                        handleSendEvent(@"minCool", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeMaxHeatSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeMaxHeatSetpointLimitID: %@", report.value);
                        handleSendEvent(@"maxHeat", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeMinHeatSetpointLimitID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeMinHeatSetpointLimitID: %@", report.value);
                        handleSendEvent(@"minHeat", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeOccupiedCoolingSetpointID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeOccupiedCoolingSetpointID: %@", report.value);
                        handleSendEvent(@"occupiedCooling", report);
                        break;
                    case MTRAttributeIDTypeClusterThermostatAttributeOccupiedHeatingSetpointID:
                        NSLog(@"MTRAttributeIDTypeClusterThermostatAttributeOccupiedHeatingSetpointID: %@", report.value);
                        handleSendEvent(@"occupiedHeating", report);
                        break;
                    default:
                        break;
                }
            }
        }
    };
    
    void (^errorHandler)(NSError *) = ^(NSError * error) {
        typeof(self) strongSelf = weakSelf;
        NSLog(@"Status: update reportAttribute completed with error %@", [error description]);
        [TPDeviceChannelHelper sendReportErrorEventSink:strongSelf->eventSink
                                            andDeviceId:deviceId
                                            andEndpoint:NULL
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
                clusterStateCacheContainer:NULL
                    attributeReportHandler:attributeReportHandler
                        eventReportHandler:NULL
                              errorHandler:errorHandler
                   subscriptionEstablished:subscriptionEstablished
                   resubscriptionScheduled:NULL];
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
