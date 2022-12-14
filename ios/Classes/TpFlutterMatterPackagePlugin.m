#import "TpFlutterMatterPackagePlugin.h"
#import <TPMatter/Matter.h>
#import "DefaultsUtils.h"
#import "TPChannelConstant.h"
#import "TPDeviceChannel.h"
#import "TPCommissionChannel.h"
#import "TPLightbulbDimmerChannel.h"
#import "TPLightbulbChannel.h"
#import "TPLightSwitchChannel.h"

//MARK: - TpFlutterMatterPackagePlugin

@interface TpFlutterMatterPackagePlugin ()

@property (readwrite) MTRDeviceController* chipController;

@end

@implementation TpFlutterMatterPackagePlugin

- (instancetype)init {
    if (self = [super init]) {
        self.chipController = InitializeMTR();
    }
    
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [TPDeviceChannel registerWithRegistrar:registrar];
    [TPCommissionChannel registerWithRegistrar:registrar];
    [TPLightbulbDimmerChannel registerWithRegistrar:registrar];
    [TPLightbulbChannel registerWithRegistrar:registrar];
    [TPLightSwitchChannel registerWithRegistrar:registrar];
}

@end
