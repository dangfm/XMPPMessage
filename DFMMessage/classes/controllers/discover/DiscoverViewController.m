//
//  DiscoverViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-5-17.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "DiscoverViewController.h"
#import "AppDelegate.h"
#import "EGOImageView.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "SmallCircleViewController.h"

@interface DiscoverViewController ()<UITableViewDataSource,UITableViewDelegate,XMPPChatDelegate>{
    UITableView *_tableView;
    NSMutableArray *_groupNames;
    NSMutableDictionary *_groupDatas;
    NSMutableDictionary *_groupImages;
    EGOImageView *_imageView;
    int _row;
}
@end

@implementation DiscoverViewController

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
    [self initNavigationWithTitle:@"发现附近" IsBack:NO ReturnType:1];
    [self addTables];
}

-(void)addTables{
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-y-self.header.frame.size.height;
    
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
    [_groupDatas setObject:[NSArray arrayWithObjects:@"大广播",@"朋友圈", nil] forKey:@"0"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"附近商圈",@"扫一扫",@"摇一摇", nil] forKey:@"1"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"附近新闻", nil] forKey:@"2"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"附近有奖",@"附近钱包", nil] forKey:@"3"];
    // 图标
    _groupImages = [[NSMutableDictionary alloc] init];
    [_groupImages setObject:[NSArray arrayWithObjects:@"daguangbo",@"myFriendLive", nil] forKey:@"0"];
    [_groupImages setObject:[NSArray arrayWithObjects:@"myHome",@"myFav",@"myTowCode", nil] forKey:@"1"];
    [_groupImages setObject:[NSArray arrayWithObjects:@"myFace", nil] forKey:@"2"];
    [_groupImages setObject:[NSArray arrayWithObjects:@"mySet",@"myFace", nil] forKey:@"3"];
    if (_tableView) {
        [_tableView reloadData];
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
        NSArray *imgData = [_groupImages objectForKey:[NSString stringWithFormat:@"%d",row]];
        if (imgData.count>0) {
            cell.imageView.image = [UIImage imageNamed:[imgData objectAtIndex:indexPath.row]];
        }
        imgData = nil;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row==0) {
                SmallCircleViewController *small = [[SmallCircleViewController alloc] init];
                [self.navigationController pushViewController:small animated:YES];
                small = nil;
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

#pragma mark 消息代理
-(void)didReceiveMessage:(XMPPMessage *)xmppMessage WithXMPPStream:(XMPPStream *)xmppStream andEMessage:(EMessages *)em{
    [CommonOperation circleTipWithNumber:[CommonOperation numberWithNewMessageWithJId:nil] SuperView:[[self.footer subviews]firstObject] WithPoint:CGPointMake(40, 0)];
    [self initDatas];
}

-(void)friendWhenSendAddAction:(XMPPJID *)friendJID Subscription:(NSString *)subscription{
    [CommonOperation circleTipWithNumber:[CommonOperation numberWithAddFriendRequest] SuperView:[[self.footer subviews] objectAtIndex:1] WithPoint:CGPointMake(35, 0)];
    [_tableView reloadData];
}
@end
