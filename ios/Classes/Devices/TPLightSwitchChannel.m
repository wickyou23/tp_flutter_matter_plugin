//
//  TPLightSwitchChannel.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 01/12/2022.
//

#import "TPLightSwitchChannel.h"
#import <TPMatter/Matter.h>
#import "TPChannelConstant.h"
#import "DefaultsUtils.h"
#import "TPDeviceChannelHelper.h"
#import "TPMethodConstant.h"
#import "TPDeviceErrorConstant.h"

@implementation TPLightSwitchChannel {
    dispatch_queue_t deviceChannelQueue;
    dispatch_queue_t deviceEventQueue;
    MTRDeviceController* chipController;
    FlutterEventSink _Nullable eventSink;
}

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPLightSwitchChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPLightSwitchChannel* instance = [[TPLightSwitchChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* event = [FlutterEventChannel eventChannelWithName:TPLightSwitchEventChannelDomain
                                                           binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (instancetype)init {
    if (self = [super init]) {
        chipController = InitializeMTR();
        deviceChannelQueue = dispatch_queue_create("com.device.lightswitch.channel.queue", DISPATCH_QUEUE_CONCURRENT);
        deviceEventQueue = dispatch_queue_create("com.device.lightswitch.event.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([TPMethodSubscribeName isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self subscribeWithDeviceId:deviceId]));
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)subscribeWithDeviceId:(NSString*)deviceId {
    __weak typeof(self) weakSelf = self;
    void (^attributeReportHandler)(NSArray * _Nullable) = ^(NSArray * _Nullable reports) {
        typeof(self) strongSelf = weakSelf;
        if (!reports)
            return;
        
        for (MTRAttributeReport* report in reports) {
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
