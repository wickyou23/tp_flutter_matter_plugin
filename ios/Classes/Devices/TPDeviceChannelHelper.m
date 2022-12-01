//
//  TPDeviceChannelHelper.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 23/11/2022.
//

#import "TPDeviceChannelHelper.h"
#import "DefaultsUtils.h"
#import "ExtentionHelper.h"

NSString* const ControlErrorKey = @"ControlErrorKey";
NSString* const ControlSuccessKey = @"ControlSuccessKey";
NSString* const ReportEventKey = @"ReportEventKey";
NSString* const ReportErrorEventKey = @"ReportErrorEventKey";

@implementation TPDeviceChannelHelper

+ (void)verifyClusterIdWithEndpoint:(NSNumber*)endpoint
                       andClusterId:(NSNumber*)clusterId
                 andDeviceConnected:(MTRBaseDevice*)device
                           andQueue:(dispatch_queue_t)queue
                      andCompletion:(void(^)(NSNumber* _Nullable, NSError* _Nullable))completion {
    [device readAttributePathWithEndpointID:endpoint
                                  clusterID:clusterId
                                attributeID:NULL
                                     params:NULL
                                      queue:queue
                                 completion:^(NSArray<NSDictionary<NSString *,id> *> * _Nullable values, NSError * _Nullable error) {
        if (error == NULL) {
            completion(endpoint, NULL);
        }
        else {
            if (error.code == MTRErrorCodeTimeout) {
                completion(NULL, error);
                return;
            }
            
            if ([endpoint intValue] == 0) {
                completion(NULL, error);
                return;
            }
            
            [TPDeviceChannelHelper verifyClusterIdWithEndpoint:@(0)
                                                  andClusterId:clusterId
                                            andDeviceConnected:device
                                                      andQueue:queue
                                                 andCompletion:completion];
        }
    }];
}


//MARK: - EventSink

+ (void)sendControlErrorResult:(FlutterResult)result
                   andDeviceId:(NSString*)deviceId
                      andError:(NSError* _Nullable)error
                    andMessage:(NSString* _Nullable)message {
    if (result == NULL) {
        return;
    }
    
    TPDeviceErrorType errorType;
    if (error.code == MTRErrorCodeTimeout) {
        errorType = TPControlTimeoutError;
    }
    else {
        errorType = TPControlUnknowError;
    }
    
    result(@{ControlErrorKey: @{@"deviceId": deviceId, @"errorType": @(errorType), @"errorMessage": message}});
}

+ (void)sendControlSuccessResult:(FlutterResult)result
                     andDeviceId:(NSString*)deviceId
                         andData:(id _Nullable)data {
    if (result == NULL) {
        return;
    }
    
    result(@{ControlSuccessKey: @{@"deviceId": deviceId, @"data": data}});
}

+ (void)sendReportEventSink:(FlutterEventSink)eventSink
                andDeviceId:(NSString*)deviceId
                    andData:(id _Nullable)data {
    if (eventSink == NULL) {
        return;
    }
    
    eventSink(@{ReportEventKey: @{@"deviceId": deviceId, @"data": data}});
}

+ (void)sendReportErrorEventSink:(FlutterEventSink)eventSink
                     andDeviceId:(NSString*)deviceId
                        andError:(NSError*)error
                      andMessage:(NSString* _Nullable)message {
    if (eventSink == NULL) {
        return;
    }
    
    TPDeviceErrorType errorType;
    if (error.code == MTRErrorCodeTimeout) {
        errorType = TPSubscribeTimeoutError;
    }
    else {
        errorType = TPReportEventError;
    }
    
    eventSink(@{ReportErrorEventKey: @{@"deviceId": deviceId, @"errorType": @(errorType), @"errorMessage": message}});
}

@end
