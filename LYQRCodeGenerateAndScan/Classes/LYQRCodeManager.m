//
//  LYQRCodeManager.m
//  Demo20210123OC
//
//  Created by liyz on 2022/12/28.
//

#import "LYQRCodeManager.h"

#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "LYQRCodeViewController.h"
#import "ZXingObjC.h"

@interface LYQRCodeManager()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation LYQRCodeManager

+ (instancetype)sharedManager{
    static LYQRCodeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LYQRCodeManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scannerCornerColor = [UIColor colorWithRed:63/255.0 green:187/255.0 blue:54/255.0 alpha:1.0];
        self.scannerBorderColor = [UIColor whiteColor];
        self.indicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return self;
}

/** 校验是否有相机权限 */
+ (void)LY_checkCameraAuthorizationStatu:(UIViewController*)controller SMYithGrand:(void(^)(BOOL granted))permissionGranted
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该设备不支持拍照" preferredStyle:UIAlertControllerStyleAlert];
               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
               [alertController addAction:cancelAction];
            [controller presentViewController:alertController animated:YES completion:nil];
            return;
    }
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (videoAuthStatus) {
        // 已授权
        case AVAuthorizationStatusAuthorized:
        {
            permissionGranted(YES);
        }
            break;
        // 未询问用户是否授权
        case AVAuthorizationStatusNotDetermined:
        {
            // 提示用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                permissionGranted(granted);
            }];
        }
            break;
        // 用户拒绝授权或权限受限
        case AVAuthorizationStatusRestricted:
            
        case AVAuthorizationStatusDenied:
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在”设置-隐私-相机”选项中，允许访问你的相机" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIApplication *app = [UIApplication sharedApplication];
                NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([app canOpenURL:settingURL]) {
                        [app openURL:settingURL];
                    }

            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [controller presentViewController:alertController animated:YES completion:nil];
            permissionGranted(NO);
        }
            break;
        default:
            break;
    }
}

/** 校验是否有相册权限 */
+ (void)LY_checkAlbumAuthorizationStatu:(UIViewController*)controller SMYithGrand:(void(^)(BOOL granted))permissionGranted {
    
    PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthStatus) {
        // 已授权
        case PHAuthorizationStatusAuthorized:
        {
            permissionGranted(YES);
        }
            break;
        // 未询问用户是否授权
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                permissionGranted(status == PHAuthorizationStatusAuthorized);
            }];
        }
            break;
        // 用户拒绝授权或权限受限
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在”设置-隐私-相片”选项中，允许访问你的相册" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIApplication *app = [UIApplication sharedApplication];
                NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([app canOpenURL:settingURL]) {
                        [app openURL:settingURL];
                    }

            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [controller presentViewController:alertController animated:YES completion:nil];
            permissionGranted(NO);
        }
            break;
        default:
            break;
    }
    
}

/** 手电筒开关 */
+ (void)LY_FlashlightOn:(BOOL)on {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch] && [captureDevice hasFlash]) {
        [captureDevice lockForConfiguration:nil];
        if (on) {
            [captureDevice setTorchMode:AVCaptureTorchModeOn];
            [captureDevice setFlashMode:AVCaptureFlashModeOn];
        }else
        {
            [captureDevice setTorchMode:AVCaptureTorchModeOff];
            [captureDevice setFlashMode:AVCaptureFlashModeOff];
        }
        [captureDevice unlockForConfiguration];
    }
}

+ (UIImage *)getImg:(NSString *)imgName {

    // 获取当前的bundle,self只是在当前pod库中的一个类，也可以随意写一个其他的类
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    // 获取屏幕pt和px之间的比例
    NSInteger scale = [UIScreen mainScreen].scale;
    NSString *imagefailName = [NSString stringWithFormat:@"%@@%zdx.png",imgName,scale];
    // 获取图片的路径,其中SMYQRCode是组件名
    NSString *imagePath = [currentBundle pathForResource:imagefailName ofType:nil inDirectory:[NSString stringWithFormat:@"%@.bundle",@"LYQRCodeGenerateAndScan"]];
    
    UIImage *imageName = [UIImage imageNamed:imgName];
    if (imageName) {
        return imageName;
    }else if(imagePath){
        return [UIImage imageWithContentsOfFile:imagePath];
    }else{
        return nil;
    }
}


-(void)startScanWithController:(UIViewController *)vc Delegate:(nonnull id)delegate{
    
    LYQRCodeViewController *qrVC = [[LYQRCodeViewController alloc] init];
    qrVC.manager = self;
    self.scanDelegate = delegate;
    if (vc.navigationController) {
        [vc.navigationController pushViewController:qrVC animated:YES];
    }else{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:qrVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc presentViewController:nav animated:YES completion:nil];
    }
    
}

#pragma mark -- 跳转相册
-(void)startAlumScanWithController:(UIViewController *)vc Delegate:(nonnull id)delegate{
    
    self.scanDelegate = delegate;
    
    // 校验相册权限
    [LYQRCodeManager LY_checkAlbumAuthorizationStatu:vc SMYithGrand:^(BOOL granted) {
        if (granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 支持条形码识别
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
                [vc presentViewController:imagePicker animated:YES completion:nil];
            });

        }
    }];
        
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
            if (self.scanDelegate) {
                [self.scanDelegate ly_QRCodeScanResultText:stringValue];
            }

        } else {
//            NSLog(@"识别失败 == %@", error);
            if (self.scanDelegate) {
                [self.scanDelegate ly_QRCodeScanResultFail];
            }
        }

    }];

}


@end
