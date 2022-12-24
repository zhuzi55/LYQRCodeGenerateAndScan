//
//  LYViewController.m
//  LYQRCodeScan
//
//  Created by zhuzi55 on 12/23/2022.
//  Copyright (c) 2022 zhuzi55. All rights reserved.
//

#import "LYViewController.h"

@interface LYViewController ()

@end

@implementation LYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor yellowColor];
    [self creatUI];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"== touchesBegan");
}

-(void)creatUI{
    
    // 二维码生成
    
    // 二维码+条形码扫描 - 包含从相册识别二维码+条形码
    
    
}

@end
