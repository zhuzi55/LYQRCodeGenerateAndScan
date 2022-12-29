//
//  LYViewController.m
//  LYQRCodeScan
//
//  Created by zhuzi55 on 12/23/2022.
//  Copyright (c) 2022 zhuzi55. All rights reserved.
//

#import "LYViewController.h"

#import "LYQRCodeGenerateManager.h"
#import "LYQRCodeManager.h"

@interface LYViewController ()<LYQRCodeManagerDelegate>

@property (nonatomic, strong) UIButton *qrCodeGenerateBtn;
@property (nonatomic, strong) UIButton *qrCodeScanBtn;
@property (nonatomic, strong) UIButton *qrCodeAlumScanBtn;

@property (nonatomic, strong) UIImageView *resultImgView;

@end

@implementation LYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor yellowColor];
    
    [self creatUI];
    
}

-(void)creatUI{
    
    // 二维码生成
    [self.view addSubview:self.qrCodeGenerateBtn];
    
    // 二维码扫描+条形码扫描
    [self.view addSubview:self.qrCodeScanBtn];
    
    // 二维码扫描+条形码相册识别
    [self.view addSubview:self.qrCodeAlumScanBtn];
    
    // 二维码生成图片预览
    [self.view addSubview:self.resultImgView];
    
}

#pragma mark - 二维码生成事件
-(void)qrCodeGenerateBtnAction{
    
    UIImage *resultImg = [LYQRCodeGenerateManager generateNormalQRCodeWithDataString:@"测试" ImageWidth:200];
    self.resultImgView.image = resultImg;
    
}
#pragma mark - 二维码扫描事件
-(void)qrCodeScanBtnAction{
    
    [[LYQRCodeManager sharedManager] startScanWithController:self Delegate:self];
    
}
#pragma mark - 相册扫描事件
-(void)qrCodeAlumScanBtnAction{
    
    [[LYQRCodeManager sharedManager] startAlumScanWithController:self Delegate:self];
    
}
/// 扫码识别结果
-(void)ly_QRCodeScanResultText:(NSString *)resultText{
    NSLog(@"识别结果 == %@", resultText);
    [[[UIAlertView alloc] initWithTitle:@"识别结果" message:resultText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}
-(void)ly_QRCodeScanResultFail{
    NSLog(@"识别失败");
    [[[UIAlertView alloc] initWithTitle:@"识别结果" message:@"失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}



#pragma mark - 懒加载
-(UIButton *)qrCodeGenerateBtn{
    if (!_qrCodeGenerateBtn) {
        _qrCodeGenerateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _qrCodeGenerateBtn.frame = CGRectMake(50, 100, self.view.frame.size.width-100, 50);
        _qrCodeGenerateBtn.backgroundColor = [UIColor whiteColor];
        [_qrCodeGenerateBtn setTitle:@"二维码生成" forState:UIControlStateNormal];
        [_qrCodeGenerateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_qrCodeGenerateBtn addTarget:self action:@selector(qrCodeGenerateBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrCodeGenerateBtn;
}
-(UIButton *)qrCodeScanBtn{
    if (!_qrCodeScanBtn) {
        _qrCodeScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _qrCodeScanBtn.frame = CGRectMake(50, CGRectGetMaxY(_qrCodeGenerateBtn.frame)+50, self.view.frame.size.width-100, 50);
        _qrCodeScanBtn.backgroundColor = [UIColor whiteColor];
        [_qrCodeScanBtn setTitle:@"二维码扫描" forState:UIControlStateNormal];
        [_qrCodeScanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_qrCodeScanBtn addTarget:self action:@selector(qrCodeScanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrCodeScanBtn;
}
-(UIButton *)qrCodeAlumScanBtn{
    if (!_qrCodeAlumScanBtn) {
        _qrCodeAlumScanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _qrCodeAlumScanBtn.frame = CGRectMake(50, CGRectGetMaxY(_qrCodeScanBtn.frame)+50, self.view.frame.size.width-100, 50);
        _qrCodeAlumScanBtn.backgroundColor = [UIColor whiteColor];
        [_qrCodeAlumScanBtn setTitle:@"相册识别" forState:UIControlStateNormal];
        [_qrCodeAlumScanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_qrCodeAlumScanBtn addTarget:self action:@selector(qrCodeAlumScanBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrCodeAlumScanBtn;
}
-(UIImageView *)resultImgView{
    if (!_resultImgView) {
        _resultImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4, CGRectGetMaxY(_qrCodeAlumScanBtn.frame)+50, self.view.frame.size.width/2, self.view.frame.size.width/2)];
    }
    return _resultImgView;
}

@end
