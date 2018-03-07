//
//  ViewController.m
//  IOSNativeModule
//
//  Created by Maybe_文仔 on 2018/3/7.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "ViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>

@interface ViewController ()<RCTBridgeModule,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, strong) RCTPromiseResolveBlock resolve;
@end

const ViewController * selfDelegate;

@implementation ViewController

//这里的模块名“DataModule”是需要在react native中用到的，可自己定义。
RCT_EXPORT_MODULE(DataModule);

//桥接到Javascript的方法返回值类型必须是void。React Native的桥接操作是异步的，所以要返回结果给Javascript，必须通过回调或者触发事件来进行
RCT_EXPORT_METHOD(openImagePickerWithResolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter)
{
  NSLog(@"********openImagePicker********");
  dispatch_async(dispatch_get_main_queue(), ^{
    selfDelegate.resolve = resolver;
    [selfDelegate showPhotoChooseSheetWithTitle:@"" message:@"选择头像"];
  });
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
  NSURL *jsCodeLocation;
  
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"IOSNativeModule"
                                               initialProperties:nil
                                                   launchOptions:nil];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  
  self.view = rootView;
  
  selfDelegate = self;
}

- (void)showPhotoChooseSheetWithTitle:( NSString *)title message:( NSString *)message {
  
  //打开拍照
  void(^cameraBlock)() = ^(){
    UIImagePickerController *upc = [[UIImagePickerController alloc] init];
    upc.videoQuality = UIImagePickerControllerQualityTypeMedium;
    upc.delegate = self;
    upc.allowsEditing = NO;
    
    //拍照
    upc.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:upc animated:YES completion:nil];
  };
  //系统相册
  void(^photoBlock)() = ^(){
    UIImagePickerController *upc = [[UIImagePickerController alloc] init];
    upc.videoQuality = UIImagePickerControllerQualityTypeMedium;
    upc.delegate = self;
    upc.allowsEditing = NO;
    
    //系统相册
    upc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self  presentViewController:upc animated:YES completion:nil];
  };
  
  NSArray *array = @[
                     @{@"拍摄":cameraBlock},
                     @{@"系统相册":photoBlock}
                     ];
  
  [self showAlertWithTitle:title message:message array:array cancleBlock:nil];
}
-(void)showAlertWithTitle:( NSString *)title message:( NSString *)message array:(NSArray <NSDictionary *>*)array cancleBlock:(void(^)())cancleBlock {
  
  UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  
  for (NSDictionary *dict in array) {
    NSString *actionTitle = [[dict allKeys] lastObject];
    void(^sureBlock)() = [[[dict allValues] lastObject] isKindOfClass:[NSNumber class]] ? nil:[[dict allValues] lastObject];
    [alertVC addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      if (sureBlock) {
        sureBlock();
      }
    }]];
  }
  [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    if (cancleBlock) {
      cancleBlock();
    }
  }]];
  
  [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
  CGSize size = {100, 100};
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  [[UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, size} cornerRadius:0] addClip];
  [image drawInRect:(CGRect){CGPointZero, size}];
  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  NSData *data = UIImageJPEGRepresentation(result, 1.0f);
  [data writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/header.png"] atomically:YES];
  [picker dismissViewControllerAnimated:NO completion:^{
    // 传给JS
    self.resolve([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/header.png"]);
  }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
