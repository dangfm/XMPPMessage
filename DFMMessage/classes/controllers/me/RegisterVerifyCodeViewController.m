//
//  RegisterVerifyCodeViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-6-28.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "RegisterVerifyCodeViewController.h"
#import "AppDelegate.h"
#import "RegisterUserInfoViewController.h"

@interface RegisterVerifyCodeViewController ()<XMPPChatDelegate,UIAlertViewDelegate,UITextFieldDelegate>{
    UITextField *_phoneCode;
    UITextField *_phoneNumber;
    UIView *_registerView;
    UIButton *_loginBt;
}


@end

@implementation RegisterVerifyCodeViewController

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

}



#pragma mark ------------------------------初始化视图
-(void)initParams{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 初始化
-(void)initViews{
    [self initNavigationWithTitle:@"填写验证码" IsBack:YES ReturnType:1];
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
    des.text = @"我们已发送验证码短信到这个号码";
    des.textColor = UIColorWithHex(0x999999);
    des.font = font;
    [des sizeToFit];
    des.frame = CGRectMake((self.view.frame.size.width-des.frame.size.width)/2, y, des.frame.size.width, des.frame.size.height);
    y = des.frame.size.height + des.frame.origin.y+10;
    [_registerView addSubview:des];
    des = nil;
    
    int corner = 3;
    _phoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, 25)];
    _phoneNumber.text = self.phone;
    [_phoneNumber setEnabled:NO];
    _phoneNumber.font = [UIFont boldSystemFontOfSize:18];
    _phoneNumber.backgroundColor = KClearColor;
    _phoneNumber.textAlignment = NSTextAlignmentCenter;

    [_registerView addSubview:_phoneNumber];
    // +86
    y = _phoneNumber.frame.size.height + _phoneNumber.frame.origin.y +10;
    w = 140;
    h = 50;
    x = (self.view.frame.size.width-w)/2;
    _phoneCode = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    _phoneCode.placeholder = @"请输入验证码";
    [_phoneCode addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _phoneCode.textAlignment = NSTextAlignmentCenter;
    _phoneCode.font = [UIFont boldSystemFontOfSize:35];
    _phoneCode.layer.borderColor = borderColor.CGColor;
    _phoneCode.layer.borderWidth = 0.5;
    _phoneCode.layer.cornerRadius = corner;
    _phoneCode.backgroundColor = bgColor;
    _phoneCode.layer.masksToBounds = YES;
    _phoneCode.adjustsFontSizeToFitWidth = YES;
    _phoneCode.minimumFontSize = 23;
    _phoneCode.keyboardType = UIKeyboardTypeNumberPad;
    [_registerView addSubview:_phoneCode];
    x = _phoneCode.frame.size.width + x + 10;
    w = w-70-10;
    
    
    // 登录按钮
    x = 15;
    w = self.view.frame.size.width-2*x;
    y = _phoneCode.frame.size.height + _phoneCode.frame.origin.y + 15;
    h = 50;
    _loginBt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [_loginBt setTitle:@"下一步" forState:UIControlStateNormal];
    [_loginBt setTitleColor:UIColorWithHex(0x90abbe) forState:UIControlStateNormal];
    [_loginBt setBackgroundImage:[CommonOperation imageWithColor:kNavigationLineColor andSize:_loginBt.frame.size] forState:UIControlStateHighlighted];
    _loginBt.layer.backgroundColor = kNavigationBackgroundColor.CGColor;
    _loginBt.layer.masksToBounds = YES;
    _loginBt.layer.cornerRadius = h/2;
    _loginBt.enabled = NO;
    [_loginBt addTarget:self action:@selector(registButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_registerView addSubview:_loginBt];

    [self.view addSubview:_registerView];
    [self.view sendSubviewToBack:_registerView];
}


#pragma mark ------------------------------视图响应方法
-(void)clickSelectCountryCode{
    [self clickViewAction];
}

-(void)registButtonAction{
    [self clickViewAction];
    if (_phoneCode.text.length>0) {
        
        // 验证并提交注册
        [[LoadingView instance] start:@"正在验证..."];
        
        [XMPPHelper registerWithUserName:_phoneNumber.text Pass:@"000000"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"填写错误" message:@"请填写验证码" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
        return;
    }
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
    NSString *value = textField.text;
    if (value.length>6) {
        value = [value substringToIndex:6];
    }
    textField.text = value;
    if ([textField.text isEqualToString:@""]) {
        [_loginBt setTitleColor:UIColorWithHex(0x90abbe) forState:UIControlStateNormal];
        _loginBt.enabled = NO;
    }else{
        _loginBt.enabled = YES;
        [_loginBt setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
    }
}

#pragma mark 消息代理
-(void)xmppServerConnectState:(int)state WithXMPPStream:(XMPPStream *)xmppStream{
    // 注册成功
    if (state==8) {
        [[LoadingView instance] stop:@"验证成功" time:2];
        [[XMPPServer sharedServer] disconnect];
        [XMPPHelper setUserDefaultWithUserName:_phoneNumber.text Pass:@"000000"];
        // 进入设置昵称界面
        RegisterUserInfoViewController *userinfo = [[RegisterUserInfoViewController alloc] init];
        [self.navigationController pushViewController:userinfo animated:YES];
        userinfo = nil;
        
    }
    if (state==9) {
        [[LoadingView instance] stop:@"验证失败" time:0];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"验证失败" message:@"验证码错误，请重新输入" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
        // 进入设置昵称界面
        RegisterUserInfoViewController *userinfo = [[RegisterUserInfoViewController alloc] init];
        [self.navigationController pushViewController:userinfo animated:YES];
        userinfo = nil;
    }
}

@end
