//
//  TPMethodConstant.m
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 28/11/2022.
//

#import "TPMethodConstant.h"

//Device
NSString* const TPMethodGetPlatformVersion = @"getPlatformVersion";
NSString* const TPMethodGetDiscoverDevice = @"getDiscoverDevice";
NSString* const TPMethodGetDeviceList = @"getDeviceList";
NSString* const TPMethodUnpairDeviceById = @"unpairDeviceById";
NSString* const TPMethodGetSetupPayloadFromQRCodeString = @"getSetupPayloadFromQRCodeString";
NSString* const TPMethodSaveBindingWithDeviceId = @"saveBindingWithDeviceId";
NSString* const TPMethodReadBindingDatasWithDeviceId = @"readBindingDatasWithDeviceId";

//Basic
NSString* const TPMethodTurnOnName = @"turnON";
NSString* const TPMethodTurnOffName = @"turnOFF";
NSString* const TPMethodSubscribeName = @"subscribeWithDeviceId";

//Dimmer
NSString* const TPMethodLevelControlName = @"controlLevel";
NSString* const TPMethodControlTemperatureColorName = @"controlTemperatureColor";
NSString* const TPMethodcontrolHUEAndSaturationColorName = @"controlHUEAndSaturationColor";

//Thermostat controlMinMaxForCoolMode
NSString* const TPMethodControlSystemModeName = @"controlSystemMode";
NSString* const TPMethodControlMinCoolName = @"controlMinCool";
NSString* const TPMethodControlMaxCoolName = @"controlMaxCool";
NSString* const TPMethodControlMinHeatName = @"controlMinHeat";
NSString* const TPMethodControlMaxHeatName = @"controlMaxHeat";
NSString* const TPMethodControlOccupiedCoolingName = @"controlOccupiedCooling";
NSString* const TPMethodControlOccupiedHeatingName = @"controlOccupiedHeating";
