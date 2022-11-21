#import "TpFlutterMatterPackagePlugin.h"
#import <TPMatter/Matter.h>
#import "DefaultsUtils.h"
#import "TPChannelConstant.h"
#import "TPDeviceChannel.h"
#import "TPCommissionChannel.h"
#import "TPLightbuldChannel.h"

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
    [TPLightbuldChannel registerWithRegistrar:registrar];
}

@end
