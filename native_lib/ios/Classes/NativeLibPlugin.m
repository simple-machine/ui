#import "NativeLibPlugin.h"
#if __has_include(<native_lib/native_lib-Swift.h>)
#import <native_lib/native_lib-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_lib-Swift.h"
#endif

@implementation NativeLibPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeLibPlugin registerWithRegistrar:registrar];
}
@end
