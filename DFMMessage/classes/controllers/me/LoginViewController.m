//
//  LoginViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-5-13.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"

@interface LoginViewController()<XMPPChatDelegate>{
    UITextField *_userName;
    UITextField *_userPass;
    UIImageView *_userFace;
    UIButton *_loginBt;
    UIView *_loginView;
}

@end

@implementation LoginViewController

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
    _userName = nil;
    _userPass = nil;
    _userFace = nil;
    _loginView = nil;
}
#pragma mark ------------------------------初始化视图
-(void)initParams{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 初始化
-(void)initViews{
    //[self initNavigationWithTitle:@"登录" IsBack:NO ReturnType:2];
    self.view.backgroundColor = kBackgroundColor;
    _loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGFloat w = self.view.frame.size.width;
    CGFloat h = 50;
    CGFloat x = (self.view.frame.size.width-w)/2;
    CGFloat y = 150;
    UIImage *faceImg = [CommonOperation imageWithColor:kNavigationLineColor andSize:CGSizeMake(w, y)];
    faceImg = [UIImage imageNamed:@"loginTopBg"];
    _userFace = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, faceImg.size.width, faceImg.size.height)];
    _userFace.image = faceImg;
    
    y = _userFace.frame.size.height+_userFace.frame.origin.y;
    _userName = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h+5)];
    _userName.placeholder = @"附近号/手机号登录";
    _userName.font = [UIFont boldSystemFontOfSize:16];
    _userName.textColor = UIColorWithHex(0x666666);
    _userName.backgroundColor = UIColorWithHex(0xFFFFFF);
    UIImage *leftBg = [UIImage imageNamed:@"Login_Person"];
    UIImageView *_leftico = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, leftBg.size.width, leftBg.size.height)];
    _leftico.image = [CommonOperation imageWithTintColor:UIColorWithHex(0xCCCCCC) blendMode:kCGBlendModeDestinationIn WithImageObject:leftBg];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftBg.size.width+20, leftBg.size.height)];
    [leftView addSubview:_leftico];
    _userName.leftView = leftView;
    _leftico = nil;
    leftView = nil;
    _userName.leftViewMode = UITextFieldViewModeAlways;
    
    _userName.keyboardType = UIKeyboardTypeNumberPad;
    _userName.rightViewMode = UITextFieldViewModeUnlessEditing;
    _userName.clearsOnBeginEditing = NO;
    _userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    [CommonOperation drawLineAtSuperView:_userName andTopOrDown:1 andHeight:0.5 andColor:UIColorWithHex(0xDDDDDD)];
    
    y = _userName.frame.size.height+_userName.frame.origin.y;
    _userPass = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h+5)];
    _userPass.placeholder = @"请输入密码";
    _userPass.font = [UIFont boldSystemFontOfSize:16];
    _userPass.textColor = UIColorWithHex(0x666666);
    _userPass.backgroundColor = UIColorWithHex(0xFFFFFF);
    [_userPass addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    UIImage *leftBg2 = [UIImage imageNamed:@"Login_Pass"];
    UIImageView *_leftico2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, leftBg2.size.width, leftBg2.size.height)];
    _leftico2.image = [CommonOperation imageWithTintColor:UIColorWithHex(0xCCCCCC) blendMode:kCGBlendModeDestinationIn WithImageObject:leftBg2];
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, leftBg2.size.width+20, leftBg2.size.height)];
    [leftView2 addSubview:_leftico2];
    _userPass.leftView = leftView2;
    _leftico2 = nil;
    leftView2 = nil;
    _userPass.secureTextEntry = YES;
    _userPass.leftViewMode = UITextFieldViewModeAlways;
    _userPass.rightViewMode = UITextFieldViewModeUnlessEditing;
    _userPass.clearsOnBeginEditing = NO;
    _userPass.clearButtonMode = UITextFieldViewModeWhileEditing;
    [CommonOperation drawLineAtSuperView:_userPass andTopOrDown:1 andHeight:0.5 andColor:UIColorWithHex(0xDDDDDD)];
    
    [_loginView addSubview:_userFace];
    [_loginView addSubview:_userName];
    [_loginView addSubview:_userPass];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewAction)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
    
    // 登录按钮
    y = _userPass.frame.size.height + _userPass.frame.origin.y + 20;
    _loginBt = [[UIButton alloc] initWithFrame:CGRectMake(10, y, w-20, h)];
    [_loginBt setTitle:@"直接登录" forState:UIControlStateNormal];
    [_loginBt setTitleColor:UIColorWithHex(0x90abbe) forState:UIControlStateNormal];
    [_loginBt setBackgroundImage:[CommonOperation imageWithColor:kNavigationLineColor andSize:_loginBt.frame.size] forState:UIControlStateHighlighted];
    _loginBt.layer.backgroundColor = kNavigationBackgroundColor.CGColor;
    _loginBt.layer.masksToBounds = YES;
    _loginBt.layer.cornerRadius = h/2;
    _loginBt.enabled = NO;
    [_loginBt addTarget:self action:@selector(LoginButton) forControlEvents:UIControlEventTouchUpInside];
    [_loginView addSubview:_loginBt];
    
    w = 110;
    h = 40;
    y = _loginView.frame.size.height - 20 - h;
    x = _loginView.frame.size.width - w;
    UIImage *registerIco = [UIImage imageNamed:@"Login_Register"];
    UIButton *registBt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [registBt setTitle:@"账号注册" forState:UIControlStateNormal];
    registBt.titleLabel.font = [UIFont systemFontOfSize:14];
    [registBt setImage:[CommonOperation imageWithTintColor:UIColorWithHex(0x666666) blendMode:kCGBlendModeDestinationIn WithImageObject:registerIco] forState:UIControlStateNormal];
    registBt.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [registBt setTitleColor:UIColorWithHex(0x666666) forState:UIControlStateNormal];
    registBt.backgroundColor = KClearColor;
    [registBt addTarget:self action:@selector(registButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginView addSubview:registBt];
    registBt = nil;
    
    
    [self.view addSubview:_loginView];
    [self.view sendSubviewToBack:_loginView];
}


#pragma mark ------------------------------视图响应方法
- (void)LoginButton{
    [self clickViewAction];
    if (_userName.text.length<=1 || _userPass.text.length<=0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"填写错误" message:@"用户名或密码为空，请重新输入" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
        return;
    }
    [[LoadingView instance] start:@"正在登录..."];
    // 保存用户信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_userName.text forKey:USERID];
    [defaults setObject:_userPass.text forKey:PASS];

    //保存
    [defaults synchronize];
    [[XMPPServer sharedServer] disconnect];
    // 连接服务器
    [[XMPPServer sharedServer] connect];
    
}

-(void)registButtonAction{
    RegisterViewController *regist = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:regist animated:YES];
    regist = nil;
}

-(void)clickViewAction{
    [self.view endEditing:YES];
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


-(void)keyboardWillShow:(NSNotification*)notification{
    CGRect rt = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat h = (self.view.frame.size.height-rt.size.height) - (_loginBt.frame.origin.y+_loginBt.frame.size.height);
    if (h<0) {
        CGRect frame = _loginView.frame;
        frame.origin = CGPointMake(frame.origin.x, h-20);
        [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            _loginView.frame = frame;
        } completion:^(BOOL isFinish){}];
    }
    
}

-(void)keyboardWillHide:(NSNotification*)notification{
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        _loginView.frame = frame;
    } completion:^(BOOL isFinish){}];
}
#pragma mark 消息代理
-(void)xmppServerConnectState:(int)state WithXMPPStream:(XMPPStream *)xmppStream{
    
    // 登录验证通过
    if (state==7 || 1==1) {
        [XMPPServer sharedServer].chatDelegate = nil;
        [[LoadingView instance] stop:@"登录成功" time:2];
        [self dismissViewControllerAnimated:YES completion:^{
            [[XMPPServer sharedServer] disconnect];
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate free];
            [appDelegate initViews];
            appDelegate = nil;
        }];
        return;
    }else{
        
        if (state==5) {
            // 清空
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"" forKey:USERID];
            [defaults setObject:@"" forKey:PASS];
            [defaults synchronize];
            [[LoadingView instance] stop:@"验证错误" time:0];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"验证错误" message:@"用户名或密码错误，请重新输入" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
            return;
        }
}
    
}

@end
