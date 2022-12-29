//
//  LYScannerView.m
//  Demo20210123OC
//
//  Created by liyz on 2022/12/28.
//

#import "LYScannerView.h"

#import "objc/runtime.h"
#import "LYQRCodeManager.h"

#define Scanner_Width 0.7*self.frame.size.width /** 扫描器宽度 */
#define Scanner_X (self.frame.size.width - Scanner_Width)/2 /** 扫描器初始x值 */
#define Scanner_Y (self.frame.size.height - Scanner_Width)/2 - 50   /** 扫描器初始y值 */

NSString *const LYScannerLineAnmationKey = @"ScannerLineAnmationKey"; /** 扫描线条动画Key值 */
CGFloat const LYScanner_BorderWidth = 1.0f;   /** 扫描器边框宽度 */
CGFloat const LYScanner_CornerWidth = 3.0f;   /** 扫描器棱角宽度 */
CGFloat const LYScanner_CornerLength = 20.0f; /** 扫描器棱角长度 */
CGFloat const LYScanner_LineHeight = 10.0f;   /** 扫描器线条高度 */

CGFloat const LYFlashlightBtn_Width = 20.0f;  /** 手电筒按钮宽度 */
CGFloat const LYFlashlightLab_Height = 15.0f; /** 手电筒提示文字高度 */
CGFloat const LYTipLab_Height = 50.0f;    /** 扫描器下方提示文字高度 */

static char FLASHLIGHT_ON;  /** 手电筒开关状态绑定标识符 */

@interface LYScannerView()

@property (nonatomic, strong) UIImageView *scannerLine; /** 扫描线条 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator; /** 加载指示器 */
@property (nonatomic, strong) UIButton *flashlightBtn;  /** 手电筒开关 */
@property (nonatomic, strong) UILabel *flashlightLab;   /** 手电筒提示文字 */
@property (nonatomic, strong) UILabel *tipLab;  /** 扫描器下方提示文字 */


@property (nonatomic, strong) LYQRCodeManager *manager;

@end

@implementation LYScannerView

- (instancetype)initWithFrame:(CGRect)frame config:(LYQRCodeManager *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        self.manager = manager;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.scannerLine];
    [self ly_addScannerLineAnimation];
    
    [self addSubview:self.tipLab];
    [self addSubview:self.flashlightBtn];
    [self addSubview:self.flashlightLab];
}

#pragma mark -- 手电筒点击事件
- (void)flashlightClicked:(UIButton *)button {
    button.selected = !button.selected;
    [self ly_setFlashlightOn:self.flashlightBtn.selected];
}

/** 添加扫描线条动画 */
- (void)ly_addScannerLineAnimation {
    
    // 若已添加动画，则先移除动画再添加
    [self.scannerLine.layer removeAllAnimations];
    
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    lineAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, Scanner_Width - LYScanner_LineHeight, 1)];
    lineAnimation.duration = 4;
    lineAnimation.repeatCount = HUGE;
    [self.scannerLine.layer addAnimation:lineAnimation forKey:LYScannerLineAnmationKey];
    // 重置动画运行速度为1.0
    self.scannerLine.layer.speed = 1.0;
}

/** 暂停扫描器动画 */
- (void)ly_pauseScannerLineAnimation {
    // 取出当前时间，转成动画暂停的时间
    CFTimeInterval pauseTime = [self.scannerLine.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
    self.scannerLine.layer.timeOffset = pauseTime;
    // 将动画的运行速度设置为0， 默认的运行速度是1.0
    self.scannerLine.layer.speed = 0;
}

/** 显示手电筒 */
- (void)ly_showFlashlightWithAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.6 animations:^{
            self.flashlightLab.alpha = 1.0;
            self.flashlightBtn.alpha = 1.0;
            self.tipLab.alpha = 0;
        } completion:^(BOOL finished) {
            self.flashlightBtn.enabled = YES;
        }];
    }else
    {
        self.flashlightLab.alpha = 1.0;
        self.flashlightBtn.alpha = 1.0;
        self.tipLab.alpha = 0;
        self.flashlightBtn.enabled = YES;
    }
}

/** 隐藏手电筒 */
- (void)ly_hideFlashlightWithAnimated:(BOOL)animated {
    self.flashlightBtn.enabled = NO;
    if (animated) {
        [UIView animateWithDuration:0.6 animations:^{
            self.flashlightLab.alpha = 0;
            self.flashlightBtn.alpha = 0;
            self.tipLab.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }else
    {
        self.tipLab.alpha = 1.0;
        self.flashlightLab.alpha = 0;
        self.flashlightBtn.alpha = 0;
    }
}

/** 添加指示器 */
- (void)ly_addActivityIndicator {
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:self.manager.indicatorViewStyle];
        self.activityIndicator.center = self.center;
        [self addSubview:self.activityIndicator];
    }
    [self.activityIndicator startAnimating];
}

/** 移除指示器 */
- (void)ly_removeActivityIndicator {
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

/** 设置手电筒开关 */
- (void)ly_setFlashlightOn:(BOOL)on {
    [LYQRCodeManager LY_FlashlightOn:on];
    self.flashlightLab.text = on ? @"轻触关闭":@"轻触照亮";
    self.flashlightBtn.selected = on;
    objc_setAssociatedObject(self, &FLASHLIGHT_ON, @(on), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/** 获取手电筒当前开关状态 */
- (BOOL)ly_flashlightOn {
    return [objc_getAssociatedObject(self, &FLASHLIGHT_ON) boolValue];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //** 控制是否全屏
    if (self.manager.isFullScreen) {
        return;
    }
    
    // 半透明区域
    [[UIColor colorWithWhite:0 alpha:0.7] setFill];
    UIRectFill(rect);
    
    // 透明区域
    CGRect scanner_rect = CGRectMake(Scanner_X, Scanner_Y, Scanner_Width, Scanner_Width);
    [[UIColor clearColor] setFill];
    UIRectFill(scanner_rect);
    
    // 边框
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(Scanner_X, Scanner_Y, Scanner_Width, Scanner_Width)];
    borderPath.lineCapStyle = kCGLineCapRound;
    borderPath.lineWidth = LYScanner_BorderWidth;
    [self.manager.scannerBorderColor set];
    [borderPath stroke];
    
    for (int index = 0; index < 4; ++index) {
        
        UIBezierPath *tempPath = [UIBezierPath bezierPath];
        tempPath.lineWidth = LYScanner_CornerWidth;
        [self.manager.scannerCornerColor set];
        
        switch (index) {
                // 左上角棱角
            case 0:
            {
                [tempPath moveToPoint:CGPointMake(Scanner_X + LYScanner_CornerLength, Scanner_Y)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X, Scanner_Y)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X, Scanner_Y + LYScanner_CornerLength)];
            }
                break;
                // 右上角
            case 1:
            {
                [tempPath moveToPoint:CGPointMake(Scanner_X + Scanner_Width - LYScanner_CornerLength, Scanner_Y)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width, Scanner_Y)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width, Scanner_Y + LYScanner_CornerLength)];
            }
                break;
                // 左下角
            case 2:
            {
                [tempPath moveToPoint:CGPointMake(Scanner_X, Scanner_Y + Scanner_Width - LYScanner_CornerLength)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X, Scanner_Y + Scanner_Width)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X + LYScanner_CornerLength, Scanner_Y + Scanner_Width)];
            }
                break;
                // 右下角
            case 3:
            {
                [tempPath moveToPoint:CGPointMake(Scanner_X + Scanner_Width - LYScanner_CornerLength, Scanner_Y + Scanner_Width)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width, Scanner_Y + Scanner_Width)];
                [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width, Scanner_Y + Scanner_Width - LYScanner_CornerLength)];
            }
                break;
            default:
                break;
        }
        [tempPath stroke];
    }
}

- (CGFloat)scanner_x {
    return Scanner_X;
}

- (CGFloat)scanner_y {
    return Scanner_Y;
}

- (CGFloat)scanner_width {
    return Scanner_Width;
}

/** 扫描线条 */
- (UIImageView *)scannerLine {
    if (!_scannerLine) {
        _scannerLine = [[UIImageView alloc]initWithFrame:CGRectMake(Scanner_X, Scanner_Y, Scanner_Width, LYScanner_LineHeight)];
        _scannerLine.image = [LYQRCodeManager getImg:@"ly_scannerAnimationLine_icon"];
    }
    return _scannerLine;
}

/** 扫描器下方提示文字 */
- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc]initWithFrame:CGRectMake(0, Scanner_Y + Scanner_Width, self.frame.size.width, 50)];
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.textColor = [UIColor lightGrayColor];
        _tipLab.text = @"将二维码/条码放入框内，即可自动扫描";
        
        _tipLab.font = [UIFont systemFontOfSize:12];
    }
    return _tipLab;
}

/** 手电筒开关 */
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        _flashlightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashlightBtn.frame = CGRectMake((self.frame.size.width - LYFlashlightBtn_Width)/2, Scanner_Y + Scanner_Width - 15 - LYFlashlightLab_Height - LYFlashlightBtn_Width, LYFlashlightBtn_Width, LYFlashlightBtn_Width);
        _flashlightBtn.enabled = NO;
        _flashlightBtn.alpha = 0;
        [_flashlightBtn addTarget:self action:@selector(flashlightClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_flashlightBtn setBackgroundImage:[LYQRCodeManager getImg:@"ly_flashlight_Off_icon"] forState:UIControlStateNormal];
        [_flashlightBtn setBackgroundImage:[LYQRCodeManager getImg:@"ly_flashlight_ON_icon"] forState:UIControlStateSelected];
    }
    return _flashlightBtn;
}

/** 手电筒提示文字 */
- (UILabel *)flashlightLab {
    if (!_flashlightLab) {
        _flashlightLab = [[UILabel alloc]initWithFrame:CGRectMake(Scanner_X, Scanner_Y + Scanner_Width - 10 - LYFlashlightLab_Height, Scanner_Width, LYFlashlightLab_Height)];
        _flashlightLab.font = [UIFont systemFontOfSize:12];
        _flashlightLab.textColor = [UIColor whiteColor];
        _flashlightLab.text = @"轻触照亮";
        _flashlightLab.alpha = 0;
        _flashlightLab.textAlignment = NSTextAlignmentCenter;
    }
    return _flashlightLab;
}
@end
