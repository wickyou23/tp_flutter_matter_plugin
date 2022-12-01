//
//  TPDeviceErrorConstant.h
//  tp_flutter_matter_package
//
//  Created by Thang Phung on 29/11/2022.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t, TPDeviceErrorType) {
    TPSubscribeTimeoutError = 0x00000001,
    TPReportEventError = 0x00000002,
    
    TPControlTimeoutError = 0x00000003,
    TPControlUnknowError = 0x00000004,
    
    TPDeviceDisconnectedError = 0x00000005,
    TPDeviceUnknowError = 0xffffffff,
};
