//
//  LYScannerView.h
//  Demo20210123OC
//
//  Created by liyz on 2022/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LYQRCodeManager;
@interface LYScannerView : UIView

- (instancetype)initWithFrame:(CGRect)frame config:(LYQRCodeManager *)manager;

/** 添加扫描线条动画 */
- (void)ly_addScannerLineAnimation;

/** 暂停扫描线条动画 */
- (void)ly_pauseScannerLineAnimation;

/** 添加指示器 */
- (void)ly_addActivityIndicator;

/** 移除指示器 */
- (void)ly_removeActivityIndicator;

- (CGFloat)scanner_x;
- (CGFloat)scanner_y;
- (CGFloat)scanner_width;

/**
 显示手电筒
 @param animated 是否附带动画
 */
- (void)ly_showFlashlightWithAnimated:(BOOL)animated;

/**
 隐藏手电筒
 @param animated 是否附带动画
 */
- (void)ly_hideFlashlightWithAnimated:(BOOL)animated;

/**
 设置手电筒开关
 @param on YES:开  NO:关
 */
- (void)ly_setFlashlightOn:(BOOL)on;

/**
 获取手电筒当前开关状态
 @return YES:开  NO:关
 */
- (BOOL)ly_flashlightOn;

@end

NS_ASSUME_NONNULL_END
