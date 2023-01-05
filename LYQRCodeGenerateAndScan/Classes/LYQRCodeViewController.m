//
//  LYQRCodeViewController.m
//  Demo20210123OC
//
//  Created by liyz on 2022/12/28.
//

#import "LYQRCodeViewController.h"

#import "LYScannerView.h"
#import "LYQRCodeManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ZXingObjC.h"


@interface LYQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** 扫描器 */
@property (nonatomic, strong) LYScannerView *scannerView;
@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation LYQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [self setupUI];


}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = NO;
    [self resumeScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = YES;
    [self.scannerView ly_setFlashlightOn:NO];
    [self.scannerView ly_hideFlashlightWithAnimated:YES];
}

-(void)popBack{
    
//    if (self.navigationController) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}

#pragma mark - 创建视图
- (void)setupUI {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 40, 40)]; // 8 15
    [backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 10);
    [backButton setImage:[LYQRCodeManager getImg:@"ly_scannerNavBack_icon"] forState:UIControlStateNormal];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem=backBarButton;
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *albumItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(showAlbum)];
    [albumItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = albumItem;
    
    //** 修改导航栏颜色白
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont systemFontOfSize:16];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = @"扫一扫";
    [titleLable sizeToFit];
    self.navigationItem.titleView = titleLable;
    
    
    [self.view addSubview:self.scannerView];
    
    // 校验相机权限
    [LYQRCodeManager LY_checkCameraAuthorizationStatu:self SMYithGrand:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _setupScanner];
            });
        }
    }];
}

#pragma mark - 创建扫描器
- (void)_setupScanner {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //** 控制是否全屏
    if (self.manager.isFullScreen) {
        metadataOutput.rectOfInterest = CGRectMake([self.scannerView scanner_y]/self.view.frame.size.height, [self.scannerView scanner_x]/self.view.frame.size.width, [self.scannerView scanner_width]/self.view.frame.size.height, [self.scannerView scanner_width]/self.view.frame.size.width);
    }
    
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    if ([self.session canAddOutput:metadataOutput]) {
        [self.session addOutput:metadataOutput];
    }
    if ([self.session canAddOutput:videoDataOutput]) {
        [self.session addOutput:videoDataOutput];
    }
    
    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                           AVMetadataObjectTypeEAN13Code,
                                           AVMetadataObjectTypeEAN8Code,
                                           AVMetadataObjectTypeUPCECode,
                                           AVMetadataObjectTypeCode39Code,
                                           AVMetadataObjectTypeCode39Mod43Code,
                                           AVMetadataObjectTypeCode93Code,
                                           AVMetadataObjectTypeCode128Code,
                                           AVMetadataObjectTypePDF417Code];
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreviewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:videoPreviewLayer atIndex:0];
    
    [self.session startRunning];
}

#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate
/** 此方法会实时监听亮度值 */
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    
    // 亮度值
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    if (![self.scannerView ly_flashlightOn]) {
        if (brightnessValue < 1.0) {
            [self.scannerView ly_showFlashlightWithAnimated:YES];
        }else
        {
            [self.scannerView ly_hideFlashlightWithAnimated:YES];
        }
    }
}

#pragma mark -- 扫一扫识别结果处理
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    // 获取扫一扫结果
    if (metadataObjects && metadataObjects.count > 0) {
        
        [self pauseScanning];
    
        //处理扫描结果
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *stringValue = metadataObject.stringValue;
        
        if (self.manager.scanDelegate) {
            [self.manager.scanDelegate ly_QRCodeScanResultText:stringValue];
        }
        
        [self popBack];
    }
}




#pragma mark -- 跳转相册
- (void)showAlbum {
    // 校验相册权限
    [LYQRCodeManager LY_checkAlbumAuthorizationStatu:self SMYithGrand:^(BOOL granted) {
        if (granted) {
            [self imagePicker];
        }
    }];
}
- (void)imagePicker {
    dispatch_async(dispatch_get_main_queue(), ^{

        // 支持条形码识别
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:imagePicker animated:YES completion:nil];
    });

}

#pragma mark -- 相册图片处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
//    NSLog(@"图片信息 == %@", info);
//    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    UIImage *pickImage = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        CGImageRef imageToDecode = pickImage.CGImage;
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];

        NSError *error = nil;
        ZXDecodeHints *hints = [ZXDecodeHints hints];
        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
                                    error:&error];
        if (result) {
            NSString *stringValue = result.text;
//          ZXBarcodeFormat format = result.barcodeFormat;
//          NSLog(@"识别结果 == %@ \n 码类型== %d", contents, format);
            if (self.manager.scanDelegate) {
                [self.manager.scanDelegate ly_QRCodeScanResultText:stringValue];
            }

        } else {
//            NSLog(@"识别失败 == %@", error);
            if (self.manager.scanDelegate) {
                [self.manager.scanDelegate ly_QRCodeScanResultFail];
            }
        }

    }];

}

#pragma mark -- App 从后台进入前台
- (void)appDidBecomeActive:(NSNotification *)notify {
    [self resumeScanning];
}

#pragma mark -- App 从前台进入后台
- (void)appWillResignActive:(NSNotification *)notify {
    [self pauseScanning];
}

/** 恢复扫一扫功能 */
- (void)resumeScanning {
    if (self.session) {
        [self.session startRunning];
        [self.scannerView ly_addScannerLineAnimation];
    }
}

/** 暂停扫一扫功能 */
- (void)pauseScanning {
    if (self.session) {
        [self.session stopRunning];
        [self.scannerView ly_pauseScannerLineAnimation];
    }
}

#pragma mark - 懒加载
- (LYScannerView *)scannerView{
    if (!_scannerView) {
        _scannerView = [[LYScannerView alloc]initWithFrame:self.view.bounds config:self.manager];;
    }
    return _scannerView;
}


@end
