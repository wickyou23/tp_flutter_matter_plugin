//
//  TPDeviceChannelHelper.h
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 23/11/2022.
//

#import <Foundation/Foundation.h>
#import <TPMatter/Matter.h>
#import <Flutter/Flutter.h>
#import "TPDeviceErrorConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TPDeviceChannelHelper : NSObject

+ (void)verifyClusterIdWithEndpoint:(NSNumber*)endpoint
                       andClusterId:(NSNumber*)clusterId
                 andDeviceConnected:(MTRBaseDevice*)device
                           andQueue:(dispatch_queue_t)queue
                      andCompletion:(void(^)(NSNumber* _Nullable, NSError* _Nullable))completion;

//MARK: - EventSink
+ (void)sendControlErrorResult:(FlutterResult)result
                   andDeviceId:(NSString*)deviceId
                   andEndpoint:(NSNumber*)endpoint
                      andError:(NSError* _Nullable)error
                    andMessage:(NSString* _Nullable)message;
+ (void)sendControlSuccessResult:(FlutterResult)result
                     andDeviceId:(NSString*)deviceId
                     andEndpoint:(NSNumber*)endpoint
                         andData:(id _Nullable)data;
+ (void)sendReportEventSink:(FlutterEventSink)eventSink
                andDeviceId:(NSString*)deviceId
                andEndpoint:(NSNumber*)endpoint
                    andData:(id _Nullable)data;
+ (void)sendReportErrorEventSink:(FlutterEventSink)eventSink
                     andDeviceId:(NSString*)deviceId
                     andEndpoint:(NSNumber* _Nullable)endpoint
                        andError:(NSError*)error
                      andMessage:(NSString* _Nullable)message;

//MARK: - Evensink Common
+ (void)sendErrorResult:(FlutterResult)result
            andDeviceId:(NSString*)deviceId
               andError:(NSError* _Nullable)error
             andMessage:(NSString* _Nullable)message;
+ (void)sendSuccessResult:(FlutterResult)result
              andDeviceId:(NSString*)deviceId
                  andData:(id _Nullable)data;
@end

NS_ASSUME_NONNULL_END
