//
//  TPDevice.h
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 18/10/2022.
//

#import <Foundation/Foundation.h>
#import <TPMatter/Matter.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint16_t, TPDeviceType) {
    kLightbulb = 0x0100,
    kLightbulbDimmer = 0x0101,
    kSwitch = 0x0103,
    kContactSensor = 0x0015,
    kDoorLock = 0x000A,
    kLightSensor = 0x0106,
    kOccupancySensor = 0x0107,
    kOutlet = 0x010A,
    kColorBulb = 0x010C,
    kWindowCovering = 0x0202,
    kThermostat = 0x0301,
    kTemperatureSensor = 0x0302,
    kFlowSensor = 0x0306
};

@interface TPDevice : NSObject

@property (nonatomic, strong) NSString* deviceId;
@property (nonatomic, assign) TPDeviceType deviceType;
@property (nonatomic, strong) NSArray* subDevices;
@property (nonatomic, strong) NSNumber* endpoint;

//@property (nonatomic, strong) NSMutableArray* subDeviceTypes;
//@property (nonatomic, strong) NSArray<NSNumber*>* endpoints;

- (instancetype)initWithDeviceId:(NSString*)deviceId andEndpoint:(NSNumber*)endpoint andDeviceType:(uint16_t)deviceType;
- (NSDictionary*)convertToDict;
- (void)addSubDevices:(NSArray*)subDevices;

//- (instancetype)initWithDeviceId:(NSString*)deviceId andDeviceType:(uint16_t)deviceType;
//- (void)addSubDeviceType:(TPDeviceType)deviceType;
//- (void)addEndpoints:(NSArray<NSNumber*>*)endpoins;

@end

NS_ASSUME_NONNULL_END
