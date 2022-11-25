//
//  TPDeviceChannelHelper.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 23/11/2022.
//

#import "TPDeviceChannelHelper.h"
#import "DefaultsUtils.h"
#import "ExtentionHelper.h"

@implementation TPDeviceChannelHelper

static dispatch_queue_t eventQueue;

+ (dispatch_queue_t)eventQueue {
    if (eventQueue == NULL) {
        eventQueue = dispatch_queue_create("com.device.event", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return eventQueue;
}

+ (void)verifyClusterIdWithEndpoint:(NSNumber*)endpoint
                       andClusterId:(NSNumber*)clusterId
                 andDeviceConnected:(MTRBaseDevice*)device
                           andQueue:(dispatch_queue_t)queue
                      andCompletion:(void(^)(NSNumber* _Nullable))completion {
    [device readAttributePathWithEndpointID:endpoint
                                  clusterID:clusterId
                                attributeID:NULL
                                     params:NULL
                                      queue:queue
                                 completion:^(NSArray<NSDictionary<NSString *,id> *> * _Nullable values, NSError * _Nullable error) {
        if (error == NULL) {
            completion(endpoint);
        }
        else {
            if ([endpoint intValue] == 0) {
                completion(NULL);
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

@end
