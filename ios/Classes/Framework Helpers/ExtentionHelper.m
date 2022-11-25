//
//  ExtentionHelper.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 26/10/2022.
//

#import "ExtentionHelper.h"
#import <TPMatter/Matter.h>

//MARK: - MTRDiscoverDevice+Ext

@implementation MTRDiscoverDevice(Ext)

- (NSDictionary*)convertToDict {
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    NSPredicate* ipv4Predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    
    return @{
        @"deviceName": self.deviceName,
        @"ipAddressList": [self.ipAddressList filteredArrayUsingPredicate:ipv4Predicate],
        @"discriminator": self.discriminator
    };
}

@end

//MARK: - MTRBaseDevice+Ext

@implementation MTRBaseDevice(Ext)

- (void)getEndpointByClusterId:(NSNumber*)clusterId
         andAvailableEndpoints:(NSMutableArray*)endpoints
                      andQueue:(dispatch_queue_t)queue
                 andCompletion:(void(^)(NSNumber* _Nullable))completion {
    if (endpoints.count == 0) {
        completion(NULL);
        return;
    }
    
    NSNumber* endpoint = [endpoints firstObject];
    [endpoints removeObjectAtIndex:0];
    
    __weak typeof(self) weakSelf = self;
    [self readAttributePathWithEndpointID:endpoint
                                clusterID:clusterId
                              attributeID:NULL
                                   params:NULL
                                    queue:queue
                               completion:^(NSArray<NSDictionary<NSString *,id> *> * _Nullable values, NSError * _Nullable error) {
        if (error == NULL) {
            completion(endpoint);
        }
        else {
            typeof(self) strongSelf = weakSelf;
            [strongSelf getEndpointByClusterId:clusterId
                         andAvailableEndpoints:endpoints
                                      andQueue:queue
                                 andCompletion:completion];
        }
    }];
}

@end

//MARK: - MTRPayload+Ext

@implementation MTRSetupPayload(Ext)

- (NSDictionary*)convertToDict {
    return @{
        @"version": self.version,
        @"vendorId": self.vendorID,
        @"productID": [self.productID stringValue],
        @"discriminator": self.discriminator,
        @"hasShortDiscriminator": @(self.hasShortDiscriminator),
        @"setupPasscode": [self.setupPasscode stringValue],
        @"commissioningFlow": @(self.commissioningFlow),
        @"discoveryCapabilities": @(self.discoveryCapabilities),
    };
}

@end


@implementation NSString (Extension)

- (NSData *)dataFromHexString {
    const char *chars = [self UTF8String];
    NSInteger i = 0;
    NSInteger len = [self length];
    
    NSMutableData* data = [NSMutableData dataWithCapacity:len/2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

@end

@implementation NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
