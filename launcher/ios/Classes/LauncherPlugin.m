#import "LauncherPlugin.h"
#if __has_include(<launcher/launcher-Swift.h>)
#import <launcher/launcher-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "launcher-Swift.h"
#endif

@implementation LauncherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLauncherPlugin registerWithRegistrar:registrar];
}
@end
