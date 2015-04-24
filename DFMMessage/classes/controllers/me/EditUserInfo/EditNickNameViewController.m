//
//  EditNickNameViewController.m
//  DFMMessage
//
//  Created by 21tech on 14-7-2.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "EditNickNameViewController.h"

@interface EditNickNameViewController ()
{
    UITextField *_nickNameField;
}
@end

@implementation EditNickNameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initParams];
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{

}

-(void)dealloc{
   
}

-(void)initParams{
   
    
}
-(void)initViews{
    [self initNavigationWithTitle:@"名字" IsBack:YES ReturnType:1];
    [self addEditFiled];
    [self addSaveButton];
}

-(void)addEditFiled{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewAction)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y+15;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = 50;
    UITextField *nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    nickNameField.text = [XMPPHelper my].nickName;
    nickNameField.font = [UIFont boldSystemFontOfSize:16];
    nickNameField.layer.borderColor = kCellBottomLineColor.CGColor;
    nickNameField.layer.borderWidth = 0.5;
    nickNameField.layer.masksToBounds = YES;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    nickNameField.leftView = leftView;
    leftView = nil;
    nickNameField.leftViewMode = UITextFieldViewModeAlways;
    nickNameField.rightViewMode = UITextFieldViewModeUnlessEditing;
    nickNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nickNameField.backgroundColor = UIColorWithHex(0xFFFFFF);
    [self.view addSubview:nickNameField];
    _nickNameField = nickNameField;
    nickNameField = nil;
    [_nickNameField becomeFirstResponder];
    
    
}

-(void)addSaveButton{
    CGFloat w = 50;
    CGFloat h = 30;
    CGFloat x = self.header.frame.size.width-10-w;
    CGFloat y = (self.header.frame.size.height-h)/2;
    UIButton *addsave = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    addsave.backgroundColor = KClearColor;
    //addFriends.layer.backgroundColor = KClearColor.CGColor;
    //addFriends.layer.cornerRadius = 3;
    //addFriends.layer.borderColor = KClearColor.CGColor;
    //addFriends.layer.borderWidth = 0.5;
    [addsave setTitle:@"保存" forState:UIControlStateNormal];
    [addsave setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
    [addsave setTitleColor:UIColorWithHex(0xCCCCCC) forState:UIControlStateHighlighted];
    addsave.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [addsave addTarget:self action:@selector(clickSaveButton) forControlEvents:UIControlEventTouchUpInside];
    [self.header addSubview:addsave];
    addsave = nil;
}

#pragma mark 保存
-(void)clickSaveButton{
    if (_nickNameField.text.length>0) {
        [XMPPHelper my].nickName = _nickNameField.text;
        [DataOperation save];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请设置昵称" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}

-(void)clickViewAction{
    [self.view endEditing:YES];
}
@end
