#import <substrate.h>
#import <os/log.h>
#import <mach-o/dyld.h>

#import "pac_helpers.h"

NSString *safe_getExecutablePath()
{
	char executablePathC[PATH_MAX];
	uint32_t executablePathCSize = sizeof(executablePathC);
	_NSGetExecutablePath(&executablePathC[0], &executablePathCSize);
	return [NSString stringWithUTF8String:executablePathC];
}

extern "C" {
    size_t (*UIApplicationInitialize)(void) = NULL;
    void *(*fakeCTFontSetAltTextStyleSpec)(void) = NULL;
    void *CTFontSetAltTextStyleSpec(void) __attribute__((weak_import));
}

MSHook(size_t, UIApplicationInitialize) {
        size_t orig = _UIApplicationInitialize();
        CTFontSetAltTextStyleSpec();
        return orig;
}

%ctor {
    NSString *executablePath = safe_getExecutablePath();
    BOOL isApplication = [executablePath.stringByDeletingLastPathComponent.pathExtension isEqualToString:@"app"];

    if (isApplication) {
        MSImageRef image = MSGetImageByName("/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore");
        if (!image) {
            NSLog(@"[compactor] no UIKit");
            return;
        }

        UIApplicationInitialize = (size_t (*)(void))MSFindSymbol(image, "_UIApplicationInitialize");
        if (!UIApplicationInitialize) {
            NSLog(@"[compactor] no _UIApplicationInitialize wtf???");
            return;
        }

        MSHookFunction(UIApplicationInitialize, MSHake(UIApplicationInitialize));
    }
}