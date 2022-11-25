//
//  ExtentionHelper.h
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 26/10/2022.
//

#import <Foundation/Foundation.h>
#import <TPMatter/Matter.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: - MTRDiscoverDevice+Ext

@interface MTRDiscoverDevice(Ext)

- (NSDictionary*)convertToDict;

@end

//MARK: - MTRBaseDevice+Ext

@interface MTRBaseDevice(Ext)

- (void)getEndpointByClusterId:(NSNumber*)clusterId
         andAvailableEndpoints:(NSMutableArray*)endpoints
                      andQueue:(dispatch_queue_t)queue
                 andCompletion:(void(^)(NSNumber* _Nullable))completion;

@end

//MARK: - MTRPayload+Ext

@interface MTRSetupPayload(Ext)

- (NSDictionary*)convertToDict;

@end


@interface NSString (Extension)

- (NSData *)dataFromHexString;

@end

@interface NSData (NSData_Conversion)

- (NSString *)hexadecimalString;

@end

NS_ASSUME_NONNULL_END
