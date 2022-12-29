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

#import "LYQRCodeGenerateManager.h"
#import "LYQRCodeManager.h"
#import "LYQRCodeViewController.h"
#import "LYScannerView.h"

FOUNDATION_EXPORT double LYQRCodeGenerateAndScanVersionNumber;
FOUNDATION_EXPORT const unsigned char LYQRCodeGenerateAndScanVersionString[];

