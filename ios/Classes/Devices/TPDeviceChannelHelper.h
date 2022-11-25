//
//  TPDeviceChannelHelper.h
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 23/11/2022.
//

#import <Foundation/Foundation.h>
#import <TPMatter/Matter.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPDeviceChannelHelper : NSObject

+ (dispatch_queue_t)eventQueue;
+ (void)verifyClusterIdWithEndpoint:(NSNumber*)endpoint
                       andClusterId:(NSNumber*)clusterId
                 andDeviceConnected:(MTRBaseDevice*)device
                           andQueue:(dispatch_queue_t)queue
                      andCompletion:(void(^)(NSNumber* _Nullable))completion;
@end

NS_ASSUME_NONNULL_END
