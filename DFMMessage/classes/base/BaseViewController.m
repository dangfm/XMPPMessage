//
//  BaseViewController.m
//  dapai
//
//  Created by dangfm on 14-4-6.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "BaseViewController.h"
#import "CommonOperation.h"
#import "AppDelegate.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (kSystemVersion<7) {
        CGRect frame = [UIScreen mainScreen].bounds;
        frame.origin.y-=20;
        self.view.frame=frame;
        NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
}

#pragma mark 初始化导航
-(void)initNavigationWithTitle:(NSString*)title IsBack:(BOOL)back ReturnType:(int)returnType{
    self.view.backgroundColor = kBackgroundColor;
    self.returnType = returnType;
    // 初始化导航视图
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = kScreenBounds.size.width;
    CGFloat h = kNavigationHeight;
    UIView *nav = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    nav.backgroundColor = kNavigationBackgroundColor;
    // 画根线
    [CommonOperation drawLineAtSuperView:nav andTopOrDown:1 andHeight:0.5 andColor:kNavigationLineColor];
    self.header = nav;
    [self.view addSubview:self.header];
    nav = nil;
    
    // 状态栏
    if (kSystemVersion>=7) {
        UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 20)];
        [self.view addSubview:stateView];
        stateView.backgroundColor = kNavigationBackgroundColor;
        // 适配7.0
        self.header.frame = CGRectMake(self.header.frame.origin.x, stateView.frame.size.height, self.header.frame.size.width, self.header.frame.size.height);
        stateView = nil;
    }else{
        
    }
    if (back) {
        //标题栏的返回键
        UIImage *back_imge=[UIImage imageNamed:@"return"];
        UIImage *back_imge_touchdown=[UIImage imageNamed:@"return_touchdown"];
        back_imge = [CommonOperation imageWithTintColor:UIColorWithHex(0xFFFFFF) blendMode:kCGBlendModeDestinationIn WithImageObject:back_imge];
        UIButton *returnBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, back_imge.size.width, back_imge.size.height)];
        returnBtn.backgroundColor=[UIColor clearColor];
        [returnBtn setBackgroundImage:back_imge forState:UIControlStateNormal];
        [returnBtn setBackgroundImage:back_imge_touchdown forState:UIControlStateHighlighted];
        [returnBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
        [self.header addSubview:returnBtn];
        [returnBtn setTag:100];
        back_imge = nil;
    }
    
    
    // 标题
    UILabel *t = [[UILabel alloc] init];
    t.text = title;
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textColor = kButtonColor;
    t.backgroundColor = KClearColor;
    [t sizeToFit];
    t.frame = CGRectMake((w-t.frame.size.width)/2, (h-t.frame.size.height)/2, t.frame.size.width, t.frame.size.height);
    [self.header addSubview:t];
    self.titler = t;
    t = nil;
}

-(void)titleWithName:(NSString*)name{
    _titler.text = name;
    [_titler sizeToFit];
    _titler.frame = CGRectMake((self.view.frame.size.width-_titler.frame.size.width)/2, (self.header.frame.size.height-_titler.frame.size.height)/2, _titler.frame.size.width, _titler.frame.size.height);
}

#pragma mark 返回主界面
-(void)returnBack{
    switch (self.returnType) {
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 2:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
    
}
@end
