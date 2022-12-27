//
//  TPMethodConstant.h
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 28/11/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: - Device
extern NSString* const TPMethodGetPlatformVersion;
extern NSString* const TPMethodGetDiscoverDevice;
extern NSString* const TPMethodGetDeviceList;
extern NSString* const TPMethodUnpairDeviceById;
extern NSString* const TPMethodGetSetupPayloadFromQRCodeString;
extern NSString* const TPMethodSaveBindingWithDeviceId;
extern NSString* const TPMethodReadBindingDatasWithDeviceId;

//Basic
extern NSString* const TPMethodTurnOnName;
extern NSString* const TPMethodTurnOffName;

//Dimmer
extern NSString* const TPMethodLevelControlName;
extern NSString* const TPMethodSubscribeName;
extern NSString* const TPMethodControlTemperatureColorName;
extern NSString* const TPMethodcontrolHUEAndSaturationColorName;

//Thermostat
extern NSString* const TPMethodControlSystemModeName;
extern NSString* const TPMethodControlMinCoolName;
extern NSString* const TPMethodControlMaxCoolName;
extern NSString* const TPMethodControlMinHeatName;
extern NSString* const TPMethodControlMaxHeatName;
extern NSString* const TPMethodControlOccupiedCoolingName;
extern NSString* const TPMethodControlOccupiedHeatingName;

NS_ASSUME_NONNULL_END
