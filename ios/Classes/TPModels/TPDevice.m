//
//  TPDevice.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 18/10/2022.
//

#import "TPDevice.h"

@implementation TPDevice

- (instancetype)initWithDeviceId:(NSString*)deviceId andDeviceType:(uint16_t)deviceType {
    if (self = [super init]) {
        _deviceId = deviceId;
        _deviceType = deviceType;
    }
    
    return self;
}

- (NSDictionary*)convertToDict {
    return @{
        @"deviceId": _deviceId,
        @"deviceType": @(_deviceType)
    };
}

@end
