#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSObject+GetDeviceInfo.h"
#import "URLDefined.h"
#import "YSJNetworking.h"
#import "YSJNetworkingHeader.h"

FOUNDATION_EXPORT double YSJNetWorkingVersionNumber;
FOUNDATION_EXPORT const unsigned char YSJNetWorkingVersionString[];

