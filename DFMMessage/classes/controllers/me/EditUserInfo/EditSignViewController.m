//
//  EditSignViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-7-2.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "EditSignViewController.h"

#define kTextMaxLength 30

@interface EditSignViewController ()<UITextViewDelegate>
{
    UITextView *_signView;
    UILabel *_textLength;
}
@end

@implementation EditSignViewController

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
    [self initNavigationWithTitle:@"个性签名" IsBack:YES ReturnType:1];
    [self addEditFiled];
    [self addSaveButton];
}

-(void)addEditFiled{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickViewAction)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
    CGFloat x = 10;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y+15;
    CGFloat w = self.view.frame.size.width-20;
    CGFloat h = 120;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    textView.contentInset = UIEdgeInsetsMake(0, 10, 5, 10);
    textView.text = [XMPPHelper my].sign;
    textView.font = [UIFont boldSystemFontOfSize:16];
    textView.layer.borderColor = kCellBottomLineColor.CGColor;
    textView.layer.borderWidth = 0.5;
    textView.layer.masksToBounds = YES;
    textView.backgroundColor = UIColorWithHex(0xFFFFFF);
    textView.delegate = self;
    [self.view addSubview:textView];
    _signView = textView;
    textView = nil;
    [_signView becomeFirstResponder];
    // 长度
    _textLength = [[UILabel alloc] init];
    _textLength.text = [NSString stringWithFormat:@"%d",kTextMaxLength-_signView.text.length];
    _textLength.backgroundColor = KClearColor;
    _textLength.textColor = UIColorWithHex(0xCCCCCC);
    _textLength.font = [UIFont boldSystemFontOfSize:16];
    [_textLength sizeToFit];
    _textLength.frame = CGRectMake(_signView.frame.size.width-_textLength.frame.size.width-10, _signView.frame.size.height-_textLength.frame.size.height-10, _textLength.frame.size.width, _textLength.frame.size.height);
    [_signView addSubview:_textLength];
    
    
}

-(void)addSaveButton{
    CGFloat w = 50;
    CGFloat h = 30;
    CGFloat x = self.header.frame.size.width-10-w;
    CGFloat y = (self.header.frame.size.height-h)/2;
    UIButton *addsave = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    addsave.backgroundColor = KClearColor;
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
    if (_signView.text.length>0) {
        if (_signView.text.length>kTextMaxLength) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"签名字符数量过大，请控制在%d个字符以内",kTextMaxLength] delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
            return;
        }else{
            [XMPPHelper my].sign = _signView.text;
            [DataOperation save];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickViewAction{
    [self.view endEditing:YES];
}

#pragma mark textView Delegate
-(void)textViewDidChange:(UITextView *)textView{
    int length = textView.text.length;
    length = kTextMaxLength - length;
    _textLength.text = [NSString stringWithFormat:@"%d",length];
    [_textLength sizeToFit];
    _textLength.frame = CGRectMake(_signView.frame.size.width-_textLength.frame.size.width-10, _signView.frame.size.height-_textLength.frame.size.height-10, _textLength.frame.size.width, _textLength.frame.size.height);
}
@end
