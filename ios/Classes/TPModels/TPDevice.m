//
//  TPDevice.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 18/10/2022.
//

#import "TPDevice.h"

@implementation TPDevice

- (instancetype)initWithDeviceId:(NSString*)deviceId
                   andDeviceType:(uint16_t)deviceType
                     andEndpoint:(NSNumber*)endpoint
                     andMetadata:(NSDictionary*)metadata {
    if (self = [super init]) {
        _deviceId = deviceId;
        _deviceType = deviceType;
        _subDevices = [NSArray array];
        _endpoint = endpoint;
        _metadata = metadata;
    }
    
    return self;
}

- (NSDictionary*)convertToDict {
    NSMutableArray* subDevicesDict = [NSMutableArray array];
    for (TPDevice *subDevice in _subDevices) {
        [subDevicesDict addObject: [subDevice convertToDict]];
    }
    
    return @{
        @"deviceId": _deviceId,
        @"deviceType": @(_deviceType),
        @"subDevices": subDevicesDict,
        @"endpoint": _endpoint,
        @"metadata": _metadata
    };
}

- (void)addSubDevices:(NSArray*)subDevices {
    _subDevices = subDevices;
}

@end
