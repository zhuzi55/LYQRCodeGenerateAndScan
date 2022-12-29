//
//  LYQRCodeGenerateManager.h
//  LYQRCodeScan_Example
//
//  Created by liyz on 2022/12/23.
//  Copyright © 2022 zhuzi55. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYQRCodeGenerateManager : NSObject

/// 生成一张普通的二维码
+ (UIImage *)generateNormalQRCodeWithDataString:(NSString *)dataStr ImageWidth:(CGFloat)imageWidth;

/// 生成一张带有logo的二维码
/// logoScaleToSuperView 相对于父视图的缩放比取值范围0-1, 0-不显示，1-代表与父视图大小相同,一般取0.3
+ (UIImage *)generateLogoQRCodeWithDataString:(NSString *)dataStr LogoImage:(UIImage *)logoImage LogoScaleToSuperView:(CGFloat)logoScaleToSuperView;

/// 生成一张彩色的二维码
+ (UIImage *)generateWithColorQRCodeData:(NSString *)data BackgroundColor:(CIColor *)backgroundColor MainColor:(CIColor *)mainColor;


@end

NS_ASSUME_NONNULL_END
