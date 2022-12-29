//
//  LYQRCodeManager.h
//  Demo20210123OC
//
//  Created by liyz on 2022/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LYQRCodeManagerDelegate <NSObject>

- (void)ly_QRCodeScanResultText:(NSString *)resultText;
-(void)ly_QRCodeScanResultFail;

@end


@interface LYQRCodeManager : NSObject

/// 是否全屏扫描 默认是NO
@property (nonatomic, assign) BOOL isFullScreen;
/** 棱角颜色 */
@property (nonatomic, strong) UIColor *scannerCornerColor;
/** 边框颜色 */
@property (nonatomic, strong) UIColor *scannerBorderColor;
/** 指示器风格 */
@property (nonatomic, assign) UIActivityIndicatorViewStyle indicatorViewStyle;

@property (nonatomic, weak) id<LYQRCodeManagerDelegate> scanDelegate;

+ (instancetype)sharedManager;

/**
 校验是否有相机权限
 
 @param permissionGranted 获取相机权限回调
 */
+ (void)LY_checkCameraAuthorizationStatu:(UIViewController*)controller SMYithGrand:(void(^)(BOOL granted))permissionGranted;

/**
 校验是否有相册权限

 @param permissionGranted 获取相机权限回调
 */
+ (void)LY_checkAlbumAuthorizationStatu:(UIViewController*)controller SMYithGrand:(void(^)(BOOL granted))permissionGranted;

+ (UIImage *)getImg:(NSString *)imgName;

/**
 手电筒开关
 @param on YES:打开 NO:关闭
 */
+ (void)LY_FlashlightOn:(BOOL)on;

/// 开始扫一扫
-(void)startScanWithController:(UIViewController *)vc Delegate:(id<LYQRCodeManagerDelegate>)delegate;

/// 开始相册识别
-(void)startAlumScanWithController:(UIViewController *)vc Delegate:(id<LYQRCodeManagerDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
