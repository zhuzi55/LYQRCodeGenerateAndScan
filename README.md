
## 效果图
![效果图](assets/%E6%95%88%E6%9E%9C%E5%9B%BE.gif)

## 功能介绍
1. 一行代码生成二维码
2. 一行代码进行二维码或条形码扫描
3. 一行代码进行相册图片识别二维码或条形码


## 使用方式

可以通过pod导入，也可以下载demo后把LYQRCodeGenerateAndScan文件夹导入。

```
pod 'LYQRCodeGenerateAndScan', '~> 0.0.3'
```

```
// 二维码生成事件
UIImage *resultImg = [LYQRCodeGenerateManager generateNormalQRCodeWithDataString:@"测试" ImageWidth:200];

// 二维码扫描+条形码扫描
[[LYQRCodeManager sharedManager] startScanWithController:self Delegate:self];

// 二维码扫描+条形码相册识别
[[LYQRCodeManager sharedManager] startAlumScanWithController:self Delegate:self];

// 回调代理
-(void)ly_QRCodeScanResultText:(NSString *)resultText{
    NSLog(@"识别结果 == %@", resultText);
}
-(void)ly_QRCodeScanResultFail{
    NSLog(@"识别失败");
}
```

##注意
```
如果pod repo update后还pod search不到，可以运行如下命令清下缓存后应该就可以了。
rm ~/Library/Caches/CocoaPods/search_index.json
```

##具体demo代码
```
在使用的控制器中，
    
遵守代理<LYQRCodeManagerDelegate>

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


```

<hr>

##### 如对您有帮助，还请star一下。



