//
//  RegisterUserInfoViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-6-29.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "RegisterUserInfoViewController.h"
#import "AppDelegate.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "MaskView.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MyImagePickerViewController.h"
#import "QBImagePickerController.h"

@interface RegisterUserInfoViewController ()<XMPPChatDelegate,UIAlertViewDelegate,UITextFieldDelegate,VPImageCropperDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QBImagePickerControllerDelegate>{
    UITextField *_NickNameTextFiled;
    UIView *_registerView;
    UIImageView *_setFaceView;
    UIButton *_loginBt;
    EMe *_me;
}


@end

@implementation RegisterUserInfoViewController

-(void)viewDidLoad{
    // 视图初始化
    [self initParams];
    [self initViews];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [XMPPServer sharedServer].chatDelegate = self;
}

-(void)dealloc{
    _setFaceView = nil;
    _me = nil;
}



#pragma mark ------------------------------初始化视图
-(void)initParams{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 初始化
-(void)initViews{
    [self initNavigationWithTitle:@"填写昵称" IsBack:YES ReturnType:1];
    // self.view.backgroundColor = UIColorWithHex(0xFFFFFF);
    _registerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    CGFloat h = 50;
    CGFloat x = 15;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y+10;
    CGFloat w = self.view.frame.size.width-2*x;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewAction)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
    
    UIColor *borderColor = UIColorWithHex(0xDDDDDD);
    UIColor *bgColor = UIColorWithHex(0xFFFFFF);
    UIFont *font = [UIFont systemFontOfSize:16];
    
    // 请确认你的国家或地区并输入手机号
    UILabel *des = [[UILabel alloc] init];
    des.text = @"请设置头像、昵称，方便朋友认出你";
    des.textColor = UIColorWithHex(0x999999);
    des.font = font;
    [des sizeToFit];
    des.frame = CGRectMake((self.view.frame.size.width-des.frame.size.width)/2, y, des.frame.size.width, des.frame.size.height);
    y = des.frame.size.height + des.frame.origin.y+10;
    [_registerView addSubview:des];
    des = nil;
    int corner = 3;
    UIImage *face = [UIImage imageNamed:@"BigNoFace"];
    x = (self.view.frame.size.width-face.size.width)/2;
    
    _setFaceView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, face.size.width, face.size.height)];
    _setFaceView.image = face;
    _setFaceView.layer.cornerRadius = face.size.height/2;
    _setFaceView.layer.masksToBounds = YES;
    _setFaceView.layer.borderWidth = 3;
    _setFaceView.layer.borderColor = UIColorWithHex(0xFFFFFF).CGColor;
    _setFaceView.userInteractionEnabled = YES;
    [_registerView addSubview:_setFaceView];
    UITapGestureRecognizer *facetap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUploadFaceView)];
    [_setFaceView addGestureRecognizer:facetap];
    facetap = nil;

    h = 50;
    x = (self.view.frame.size.width-w)/2;
    y = _setFaceView.frame.size.height+_setFaceView.frame.origin.y+10;
    _NickNameTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    _NickNameTextFiled.placeholder = @"例如：咚咚";
    [_NickNameTextFiled addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _NickNameTextFiled.font = [UIFont boldSystemFontOfSize:16];
    _NickNameTextFiled.layer.borderColor = borderColor.CGColor;
    _NickNameTextFiled.layer.borderWidth = 0.5;
    _NickNameTextFiled.layer.cornerRadius = corner;
    _NickNameTextFiled.backgroundColor = bgColor;
    _NickNameTextFiled.layer.masksToBounds = YES;
    UILabel *leftTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, h)];
    leftTitle.text = @"昵称";
    leftTitle.font = [UIFont boldSystemFontOfSize:16];
    leftTitle.textAlignment = NSTextAlignmentCenter;
    leftTitle.textColor = UIColorWithHex(0x000000);
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftTitle.frame.size.width, leftTitle.frame.size.height)];
    [leftView addSubview:leftTitle];
    _NickNameTextFiled.leftView = leftView;
    leftTitle = nil;
    leftView = nil;
    _NickNameTextFiled.leftViewMode = UITextFieldViewModeAlways;
    [_registerView addSubview:_NickNameTextFiled];
    x = _NickNameTextFiled.frame.size.width + x + 10;
    w = w-70-10;
    
    
    // 登录按钮
    x = 15;
    w = self.view.frame.size.width-2*x;
    y = _NickNameTextFiled.frame.size.height + _NickNameTextFiled.frame.origin.y + 15;
    h = 50;
    _loginBt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [_loginBt setTitle:@"下一步" forState:UIControlStateNormal];
    [_loginBt setTitleColor:UIColorWithHex(0x90abbe) forState:UIControlStateNormal];
    [_loginBt setBackgroundImage:[CommonOperation imageWithColor:kNavigationLineColor andSize:_loginBt.frame.size] forState:UIControlStateHighlighted];
    _loginBt.layer.backgroundColor = kNavigationBackgroundColor.CGColor;
    _loginBt.layer.masksToBounds = YES;
    _loginBt.layer.cornerRadius = h/2;
    _loginBt.enabled = NO;
    [_loginBt addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_registerView addSubview:_loginBt];
    
    [self.view addSubview:_registerView];
    [self.view sendSubviewToBack:_registerView];
}


#pragma mark ------------------------------视图响应方法
-(void)clickSelectCountryCode{
    [self clickViewAction];
}

-(void)nextButtonAction{
    [self clickViewAction];
    if (_NickNameTextFiled.text.length>0) {
        // 保存用户昵称信息
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate free];
        [appDelegate initViews];
        appDelegate = nil;
    }];
}


-(void)clickViewAction{
    [self.view endEditing:YES];
}

#pragma mark 键盘通知
-(void)keyboardWillShow:(NSNotification*)notification{
    CGRect rt = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIButton *loginBt = [_registerView.subviews lastObject];
    CGFloat h = (self.view.frame.size.height-rt.size.height) - (loginBt.frame.origin.y+loginBt.frame.size.height);
    if (h<0) {
        CGRect frame = _registerView.frame;
        frame.origin = CGPointMake(frame.origin.x, h-20);
        [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _registerView.frame = frame;
        } completion:^(BOOL isFinish){}];
    }
    
}

-(void)keyboardWillHide:(NSNotification*)notification{
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        _registerView.frame = frame;
    } completion:^(BOOL isFinish){}];
}


#pragma mark 文本框输入事件
-(void)textFieldDidChange:(UITextField *)textField{
    if ([textField.text isEqualToString:@""]) {
        [_loginBt setTitleColor:UIColorWithHex(0x90abbe) forState:UIControlStateNormal];
        _loginBt.enabled = NO;
    }else{
        _loginBt.enabled = YES;
        [_loginBt setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
    }
}

#pragma mark ---------------选择并上传图片代码块-----------------
-(void)showUploadFaceView{
    
    MaskView *mask = [[MaskView alloc] initWithAlpha:0.5 Height:202];
    mask.sportView.backgroundColor = kBackgroundColor;
    CGFloat h = 44;
    CGFloat y = 202 - h - 10;
    CGFloat w = mask.sportView.frame.size.width - 20;
    CGFloat x = 10;
    // 取消按钮
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    bt.backgroundColor = KClearColor;
    [bt setTitle:@"取消" forState:UIControlStateNormal];
    [bt setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
    [bt setTitleColor:UIColorWithHex(0xCCCCCC) forState:UIControlStateHighlighted];
    bt.layer.cornerRadius = 5;
    bt.layer.backgroundColor = kNavigationBackgroundColor.CGColor;
    [bt addTarget:mask action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [mask.sportView addSubview:bt];
    bt = nil;
    //两个按钮
    NSArray *titles = @[@"拍照",@"从手机相册选择"];
    y = 20;
    
    for (int i=0; i<titles.count; i++) {
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        b.tag = i;
        [b setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [b setTitleColor:kFontColor forState:UIControlStateNormal];
        [b setTitleColor:kFontColor forState:UIControlStateHighlighted];
        [b setBackgroundImage:[CommonOperation imageWithColor:kCellBottomLineColor andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
        b.layer.masksToBounds = YES;
        b.layer.cornerRadius = 5;
        b.layer.backgroundColor = kButtonBackgroundColor.CGColor;
        b.layer.borderColor = kCellBottomLineColor.CGColor;
        b.layer.borderWidth = 0.5;
        [b addTarget:self action:@selector(clickUploadButtonWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [mask.sportView addSubview:b];
        b = nil;
        y += h + 10;
    }
    [mask show:nil];
    mask.hideFinishBlock = ^{
        
    };
    mask = nil;
    titles = nil;
}

#pragma mark 选择图片按钮
-(void)clickUploadButtonWithIndex:(UIButton *)sender{
    // 选择相册
    MaskView *mask = (MaskView*)[[sender superview] superview];
    if (sender.tag==1) {
        
        if (![QBImagePickerController isAccessible]) {
            NSLog(@"Error: Source is not accessible.");
        }else{
            
            mask.hideFinishBlock = ^{
                // 系统相册
                [self initUIImagePickerController];
                
            };
            [mask hide];
        }
    }
    // 选择相机
    if (sender.tag==0) {
        mask.hideFinishBlock = ^{
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        };
        [mask hide];
    }
}

#pragma mark 判断相机相册是否可用等
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark 初始化一个图片选择控制器
-(void)initUIImagePickerController{
    if ([self isPhotoLibraryAvailable]) {
        MyImagePickerViewController *controller = [[MyImagePickerViewController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
    }
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    // 拿到裁剪后的图片 editedImage;
    editedImage = [CommonOperation imageByScalingToMaxSize:editedImage];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        _setFaceView.image = editedImage;
        EMe *m = [XMPPHelper my];
        m.face = [UIImagePNGRepresentation(editedImage) base64EncodedString];
        [DataOperation save];
        m = nil;
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //[picker dismissViewControllerAnimated:YES completion:^() {
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // 相册拿到图片则调用裁剪控件
    VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    imgCropperVC.delegate = self;
    [picker pushViewController:imgCropperVC animated:YES];
    //}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
        
        
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}



#pragma mark 消息代理
-(void)xmppServerConnectState:(int)state WithXMPPStream:(XMPPStream *)xmppStream{
    // 注册成功
    if (state==8) {
        [[LoadingView instance] stop:@"验证成功" time:2];
        [[XMPPServer sharedServer] disconnect];
        
        [self dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate free];
            [appDelegate initViews];
            appDelegate = nil;
        }];
    }
    if (state==9) {
        [[LoadingView instance] stop:@"验证失败" time:0];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"验证失败" message:@"验证码错误，请重新输入" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}

@end
