//
//  SetViewController.m
//  DFMMessage
//
//  Created by 21tech on 14-6-26.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "SetViewController.h"
#import "EGOImageView.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "MaskView.h"
#import "TalkViewController.h"
#import "AppDelegate.h"

@interface SetViewController ()
<UITableViewDataSource,UITableViewDelegate,XMPPChatDelegate>{
    UITableView *_tableView;
    NSMutableArray *_groupNames;
    NSMutableDictionary *_groupDatas;
    NSMutableDictionary *_groupImages;
    EGOImageView *_imageView;
    int _row;
}
@end

@implementation SetViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initParams];
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [XMPPServer sharedServer].chatDelegate = self;
    [self initDatas];
}

-(void)dealloc{
    _tableView = nil;
    _groupDatas = nil;
    _groupNames = nil;
    _groupImages = nil;
    _imageView = nil;
}


-(void)initParams{
    [self initDatas];
    
}
-(void)initViews{
    [self initNavigationWithTitle:@"设置" IsBack:YES ReturnType:1];
    [self addTables];
}

-(void)addTables{
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-y;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x,y,w,h) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.separatorColor = kCellBottomLineColor;
    _tableView.sectionIndexColor = UIColorWithHex(0x333333);
    if (kSystemVersion>=7) {
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionIndexBackgroundColor = KClearColor;
    }
    [self.view addSubview:_tableView];
}


-(void)initDatas{
    
    _groupNames = [[NSMutableArray alloc] initWithObjects:@"0",@"1",@"2",@"3", nil];
    _groupDatas = [[NSMutableDictionary alloc] init];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"账号与安全", nil] forKey:@"0"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"新消息通知",@"隐私",@"通用", nil] forKey:@"1"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"关于附近", nil] forKey:@"2"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"退出登录",nil] forKey:@"3"];

    if (_tableView) {
        [_tableView reloadData];
    }
}

-(void)showLoginoutView{
    
    MaskView *mask = [[MaskView alloc] initWithAlpha:0.5 Height:148];
    mask.sportView.backgroundColor = kBackgroundColor;
    CGFloat h = 44;
    CGFloat y = 148 - h - 10;
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
    NSArray *titles = @[@"退出登录"];
    y = 20;
    
    for (int i=0; i<titles.count; i++) {
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        b.tag = i;
        [b setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [b setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
        [b setTitleColor:UIColorWithHex(0xCCCCCC) forState:UIControlStateHighlighted];
        [b setBackgroundImage:[CommonOperation imageWithColor:UIColorWithHex(0xF60000) andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
        b.layer.masksToBounds = YES;
        b.layer.cornerRadius = 5;
        b.layer.backgroundColor = UIColorWithHex(0xFF0000).CGColor;
        b.layer.borderColor = UIColorWithHex(0xF60000).CGColor;
        b.layer.borderWidth = 0.5;
        [b addTarget:self action:@selector(clickLoginoutButtonWithIndex:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark 确认退出登录
-(void)clickLoginoutButtonWithIndex:(UIButton *)sender{
    // 确定退出
    MaskView *mask = (MaskView*)[[sender superview] superview];
    if (sender.tag==0) {
        mask.hideFinishBlock = ^{
            // 清空用户信息
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"" forKey:USERID];
            [defaults setObject:@"" forKey:PASS];
            //保存
            [defaults synchronize];
            // 断开连接
            [[XMPPServer sharedServer] disconnect];
            
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate free];
            [appDelegate initViews];
            appDelegate = nil;
        };
        [mask hide];
    }

}


#pragma mark 表格代理实现
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *data = [_groupDatas objectForKey:[NSString stringWithFormat:@"%d",section]];
    NSInteger count = data.count;
    data = nil;
    return count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _groupNames.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 20;
    }
    return 0.0001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_%d_%d",indexPath.section,indexPath.row];
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = kCellBackground;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = kFontColor;
        cell.tag = _row;
        _row ++;
    }
    
    int row = indexPath.section;
    if (row<_groupNames.count) {
        NSArray *data = [_groupDatas objectForKey:[NSString stringWithFormat:@"%d",row]];
        if (data.count>0) {
            cell.textLabel.text = [data objectAtIndex:indexPath.row];
        }
        data = nil;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 3:{
            if (indexPath.row==0) {
                // 退出登录 弹出确认退出登录界面
                [self showLoginoutView];
            }
        }
            break;
            
        default:
            break;
    }
}




#pragma mark - 代理方法

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}


@end
