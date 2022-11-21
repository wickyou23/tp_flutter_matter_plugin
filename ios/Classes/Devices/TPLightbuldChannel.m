//
//  TPLightbuldDevice.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 25/10/2022.
//

#import "TPLightbuldChannel.h"
#import <TPMatter/Matter.h>
#import "TPChannelConstant.h"
#import "DefaultsUtils.h"

NSString* const ControlErrorKey = @"ControlErrorKey";
NSString* const ControlSuccessKey = @"ControlSuccessKey";
NSString* const ReportEventKey = @"ReportEventKey";
NSString* const ReportErrorEventKey = @"ReportErrorEventKey";

@interface TPLightbuldChannel ()

@property (readwrite) MTRDeviceController* chipController;
@property (nonatomic, copy, nullable) FlutterEventSink eventSink;

@end

@implementation TPLightbuldChannel

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:TPLightbuldChannelDomain
                                     binaryMessenger:[registrar messenger]];
    TPLightbuldChannel* instance = [[TPLightbuldChannel alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* event = [FlutterEventChannel eventChannelWithName:TPLightbuldEventChannelDomain
                                                           binaryMessenger:[registrar messenger]];
    [event setStreamHandler:instance];
}

- (instancetype)init {
    if (self = [super init]) {
        _chipController = InitializeMTR();
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"turnON" isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self turnOn:deviceId]));
    }
    else if ([@"turnOFF" isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self turnOff:deviceId]));
    }
    else if ([@"subscribeWithDeviceId" isEqualToString:call.method]) {
        NSDictionary* args = (NSDictionary*)call.arguments;
        NSString* deviceId = args[@"deviceId"];
        result(@([self subscribeWithDeviceId:deviceId]));
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL)turnOn:(NSString*)deviceId {
    if (MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            MTRBaseClusterOnOff * onOff = [[MTRBaseClusterOnOff alloc] initWithDevice:chipDevice
                                                                             endpoint:@(1)
                                                                                queue:dispatch_get_main_queue()];
            [onOff onWithCompletion:^(NSError * error) {
                if (error != NULL) {
                    [self sendControlErrorEventSink:deviceId andMessage:[error localizedDescription]];
                }
                else {
                    [self sendControlSuccessEventSink:deviceId andData:@(TRUE)];
                }
            }];
        } else {
            [self sendControlErrorEventSink:deviceId andMessage:@"Failed to establish a connection with the device"];
        }
    })) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (BOOL)turnOff:(NSString*)deviceId {
    if (MTRGetConnectedDeviceWithID([deviceId toUInt64], ^(MTRBaseDevice * _Nullable chipDevice, NSError * _Nullable error) {
        if (chipDevice) {
            MTRBaseClusterOnOff * onOff = [[MTRBaseClusterOnOff alloc] initWithDevice:chipDevice
                                                                             endpoint:@(1)
                                                                                queue:dispatch_get_main_queue()];
            [onOff offWithCompletion:^(NSError * error) {
                if (error != NULL) {
                    [self sendControlErrorEventSink:deviceId andMessage:[error localizedDescription]];
                }
                else {
                    [self sendControlSuccessEventSink:deviceId andData:@(FALSE)];
                }
            }];
        } else {
            [self sendControlErrorEventSink:deviceId andMessage:@"Failed to establish a connection with the device"];
        }
    })) {
        return TRUE;
    } else {
        return FALSE;
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
                    NSLog(@"Error reading temperature: %@", report.error);
                    [strongSelf sendReportErrorEventSink:deviceId andMessage:[report.error description]];
                } else {
                    [strongSelf sendReportEventSink:deviceId andData:@{@"isOn": ((NSNumber *)report.value)}];
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
                                                                       maxInterval:@(10)];
            [chipDevice subscribeWithQueue:dispatch_get_main_queue()
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
        return TRUE;
    } else {
        NSLog(@"Status: Failed to trigger the connection with the device");
        return FALSE;
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
