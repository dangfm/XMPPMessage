//
//  RegisterViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-5-13.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "RegisterVerifyCodeViewController.h"

@interface RegisterViewController()<XMPPChatDelegate,UIAlertViewDelegate,UITextFieldDelegate>{
    UIButton *_countryCode;
    UITextField *_phoneCode;
    UITextField *_phoneNumber;
    UIView *_registerView;
    NSString *_oldValue;
    UIButton *_loginBt;
}

@end

@implementation RegisterViewController

-(void)viewDidLoad{
    // 视图初始化
    [self initParams];
    [self initViews];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [XMPPServer sharedServer].chatDelegate = self;
}

#pragma mark ------------------------------初始化视图
-(void)initParams{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 初始化
-(void)initViews{
    [self initNavigationWithTitle:@"注册" IsBack:YES ReturnType:1];
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
    des.text = @"请确认你的国家或地区并输入手机号";
    des.textColor = UIColorWithHex(0x999999);
    des.font = font;
    [des sizeToFit];
    des.frame = CGRectMake((self.view.frame.size.width-des.frame.size.width)/2, y, des.frame.size.width, des.frame.size.height);
    y = des.frame.size.height + des.frame.origin.y+10;
    [_registerView addSubview:des];
    des = nil;
    
    int corner = 3;
    // 国家区号
    _countryCode = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    _countryCode.backgroundColor = bgColor;
    _countryCode.layer.masksToBounds = YES;
    _countryCode.layer.cornerRadius = corner;
    _countryCode.layer.borderColor = borderColor.CGColor;
    _countryCode.layer.borderWidth = 0.5;
    [_countryCode setBackgroundImage:[CommonOperation imageWithColor:UIColorWithHex(0xEEEEEE) andSize:_countryCode.frame.size] forState:UIControlStateHighlighted];
    [_countryCode addTarget:self action:@selector(clickSelectCountryCode) forControlEvents:UIControlEventTouchUpInside];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, w, h)];
    l.text = @"国家和地区";
    l.font = font;
    [_countryCode addSubview:l];
    l = nil;
    UILabel *z = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w-20, h)];
    z.text = @"中国";
    z.textAlignment = NSTextAlignmentRight;
    z.font = [UIFont boldSystemFontOfSize:16];
    [_countryCode addSubview:z];
    z = nil;
    [_registerView addSubview:_countryCode];
    // +86
    y = _countryCode.frame.size.height + _countryCode.frame.origin.y +10;
    _phoneCode = [[UITextField alloc] initWithFrame:CGRectMake(x, y, 70, h)];
    _phoneCode.text = @"+86";
    [_phoneCode setEnabled:NO];
    _phoneCode.font = [UIFont boldSystemFontOfSize:18];
    _phoneCode.layer.borderColor = borderColor.CGColor;
    _phoneCode.layer.borderWidth = 0.5;
    _phoneCode.layer.cornerRadius = corner;
    _phoneCode.backgroundColor = bgColor;
    _phoneCode.layer.masksToBounds = YES;
    _phoneCode.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _phoneCode.leftViewMode = UITextFieldViewModeAlways;
    [_registerView addSubview:_phoneCode];
    x = _phoneCode.frame.size.width + x + 10;
    w = w-70-10;
    _phoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    _phoneNumber.delegate = self;
    _phoneNumber.placeholder = @"请填写手机号码";
    _phoneNumber.font = [UIFont boldSystemFontOfSize:18];
    [_phoneNumber addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _phoneNumber.layer.borderColor = borderColor.CGColor;
    _phoneNumber.layer.borderWidth = 0.5;
    _phoneNumber.layer.cornerRadius = corner;
    _phoneNumber.backgroundColor = bgColor;
    _phoneNumber.layer.masksToBounds = YES;
    _phoneNumber.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    _phoneNumber.leftViewMode = UITextFieldViewModeAlways;
    _phoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    _phoneNumber.rightViewMode = UITextFieldViewModeUnlessEditing;
    _phoneNumber.clearsOnBeginEditing = NO;
    _phoneNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_registerView addSubview:_phoneNumber];
    
    // 登录按钮
    x = 15;
    w = self.view.frame.size.width-2*x;
    y = _phoneNumber.frame.size.height + _phoneNumber.frame.origin.y + 20;
    UIButton *loginBt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [loginBt setTitle:@"注册" forState:UIControlStateNormal];
    [loginBt setTitleColor:UIColorWithHex(0x90abbe) forState:UIControlStateNormal];
    [loginBt setBackgroundImage:[CommonOperation imageWithColor:kNavigationLineColor andSize:loginBt.frame.size] forState:UIControlStateHighlighted];
    loginBt.layer.backgroundColor = kNavigationBackgroundColor.CGColor;
    loginBt.layer.masksToBounds = YES;
    loginBt.layer.cornerRadius = h/2;
    [loginBt addTarget:self action:@selector(registButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_registerView addSubview:loginBt];
    loginBt.enabled = NO;
    _loginBt = loginBt;
    loginBt = nil;
    
    
    [self.view addSubview:_registerView];
    [self.view sendSubviewToBack:_registerView];
}


#pragma mark ------------------------------视图响应方法
-(void)clickSelectCountryCode{
    [self clickViewAction];
}

-(void)registButtonAction{
    [self clickViewAction];
    if (_phoneNumber.text.length>0) {
        NSString *message = [NSString stringWithFormat:@"我们将发送验证码短信到这个号码: %@ %@",_phoneCode.text,_phoneNumber.text];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认手机号码" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
        [alert show];
        alert = nil;
    }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"填写错误" message:@"请填写手机号码" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
            return;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        // 调用接口发送验证码
        RegisterVerifyCodeViewController *VerifyCode = [[RegisterVerifyCodeViewController alloc] init];
        VerifyCode.phone = [NSString stringWithFormat:@"%@",_phoneNumber.text];
        [self.navigationController pushViewController:VerifyCode animated:YES];
        VerifyCode = nil;
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
    int length = value.length;
    int kong = [value componentsSeparatedByString:@" "].count;
    kong --;
    length -= kong;
    int newLength = kong * 4 + 3;
    NSLog(@"%d==%d",length,newLength);
    if (length==newLength && ![_oldValue isEqualToString:[value stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
        value = [value stringByAppendingString:@" "];
    }
    textField.text = value;
    _oldValue = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([textField.text isEqualToString:@""]) {
        [_loginBt setTitleColor:UIColorWithHex(0x90abbe) forState:UIControlStateNormal];
        _loginBt.enabled = NO;
    }else{
        _loginBt.enabled = YES;
        [_loginBt setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"%@",string);
    return YES;
}

#pragma mark 消息代理
-(void)xmppServerConnectState:(int)state WithXMPPStream:(XMPPStream *)xmppStream{
    // 注册成功
    if (state==8) {
        [[LoadingView instance] stop:@"注册成功" time:2];
        [[XMPPServer sharedServer] disconnect];
        // 保存用户信息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_phoneNumber.text forKey:USERID];
        [defaults setObject:@"0" forKey:PASS];
        //保存
        [defaults synchronize];
        [self dismissViewControllerAnimated:YES completion:^{
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate free];
            [appDelegate initViews];
            appDelegate = nil;
        }];
    }
    if (state==9) {
        [[LoadingView instance] stop:@"注册失败" time:0];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"注册失败" message:@"手机号冲突,请更换手机号或者用此手机号登录" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}


@end
