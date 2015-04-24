//
//  SearchFriendsResultViewController.m
//  DFMMessage
//
//  Created by 21tech on 14-6-12.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "SearchFriendsResultViewController.h"
#import "AddFriendsViewController.h"
#import "FriendVerifyViewController.h"

@interface SearchFriendsResultViewController ()
<UITableViewDataSource,UITableViewDelegate,XMPPChatDelegate>
{
    NSMutableArray *_datas;
    UITableView *_tableView;
}

@end

@implementation SearchFriendsResultViewController

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
    //[DataOperation deleteTable:@"EAddFriends"];
    [self initViews];
    
}
-(void)viewWillAppear:(BOOL)animated{
    //[XMPPServer sharedServer].chatDelegate = self;
    [self initDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    _tableView = nil;
    _datas = nil;
}

-(id)initWithDatas:(NSMutableArray*)data{
    self = [super init];
    if (self) {
        _datas = data;
    }
    return self;
}

-(void)initViews{
    [self initNavigationWithTitle:@"搜索结果" IsBack:YES ReturnType:1];
    [self initTableView];
}

-(void)initTableView{
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-y;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x,y,w,h) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.separatorColor = UIColorWithHex(0xDDDDDD);
    //[_tableView setEditing:YES animated:YES];
    [self.view addSubview:_tableView];
}



-(void)initDatas{
    //NSArray *peoples = [DataOperation select:@"EAddFriends" Where:nil orderBy:@"time" sortType:NO];
    //_datas = [NSMutableArray arrayWithArray:peoples];
    //peoples = nil;
    if (_datas.count>0) {
        if (_tableView) {
            [_tableView reloadData];
        }
    }
}

#pragma mark 视图响应事件
-(void)pushToAddFriendsView{
    AddFriendsViewController *af = [[AddFriendsViewController alloc] init];
    [self.navigationController pushViewController:af animated:YES];
    af = nil;
}

-(void)addFriendButtonAction:(UIButton*)button{
    int tag = button.tag;
    if (tag<_datas.count) {
        UserModel *user = [_datas objectAtIndex:tag];
        NSString *toUser = user.nickName;
        if (user) {
            XMPPJID *jid = [XMPPJID jidWithString:user.jid];
            
            if ([button.titleLabel.text isEqualToString:@"添加"]) {
                NSArray *array = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jid.bare,[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
                if (array.count<=0) {
                    [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
                        EAddFriends *add = [NSEntityDescription insertNewObjectForEntityForName:@"EAddFriends" inManagedObjectContext:context];
                        add.userName = toUser;
                        add.time = [CommonOperation getTimestamp];
                        add.type = 1; // 非手机联系人
                        add.jid = jid.bare;
                        add.subscription = @"to";
                        add.isDelete = NO;
                        add.myJID = [CommonOperation getMyJID];
                        [DataOperation save];
                        add = nil;
                    }];
                }
                array = nil;
                
                
                [[XMPPServer xmppRoster] addUser:jid withNickname:user.nickName groups:[NSArray arrayWithObject:@"Friends"] subscribeToPresence:YES];
                [button setTitle:@"等待验证" forState:UIControlStateNormal];
            }else if([button.titleLabel.text isEqualToString:@"接受"]){
                [[XMPPServer xmppRoster]  acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
            }
            
            button.layer.borderWidth = 0;
            button.backgroundColor = KClearColor;
            [button setTitleColor:UIColorWithHex(0x666666) forState:UIControlStateNormal];
            [DataOperation save];
        }
        else{
            
            FriendVerifyViewController *friendVerify = [[FriendVerifyViewController alloc] init];
            UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:friendVerify];
            nc.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
            [self presentViewController:nc animated:YES completion:^{
                // 清空已读
            }];
        }
    }
    
    
}

#pragma mark 表格代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kImageCellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = indexPath.row;
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = kCellBackground;
        UIView *view = [[UIView alloc] initWithFrame:cell.contentView.frame];
        view.backgroundColor = kCellPressBackground;
        cell.selectedBackgroundView = view;
        view = nil;
        CGRect frame = cell.bounds;
        frame.origin.y = kCellHeight;
        frame.size.height = 0.5;
        frame = cell.bounds;
        // imageview
        UIImage *face = [UIImage imageNamed:@"noface"];
        UIImageView *faceView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kImageWidth, kImageHeight)];
        faceView.image = face;
        faceView.layer.cornerRadius = 3;
        faceView.layer.masksToBounds = YES;
        faceView.backgroundColor = KClearColor;
        [cell.contentView addSubview:faceView];
        // title
        CGFloat x = faceView.frame.size.width+faceView.frame.origin.x+10;
        CGFloat w = cell.frame.size.width - x -110;
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(x, 5, w, 30)];
        t.backgroundColor = KClearColor;
        [cell.contentView addSubview:t];
        // description
        UILabel *d = [[UILabel alloc] initWithFrame:CGRectMake(x, 28, w, 30)];
        d.backgroundColor = KClearColor;
        d.textColor = UIColorWithHex(0x999999);
        d.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:d];
        
        // 距离
        UILabel *distence = [[UILabel alloc] initWithFrame:CGRectMake(_tableView.frame.size.width-90-10, 5, 90, 30)];
        distence.backgroundColor = KClearColor;
        distence.textColor = UIColorWithHex(0xF08AB2);
        distence.font = [UIFont boldSystemFontOfSize:20];
        distence.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:distence];
        // [CommonOperation drawLineAtSuperView:distence andTopOrDown:1 andHeight:0.5 andColor:UIColorWithHex(0xCCCCCC)];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(_tableView.frame.size.width-90-10, 28, 90, 30)];
        time.backgroundColor = KClearColor;
        time.textColor = UIColorWithHex(0x666666);
        time.font = [UIFont systemFontOfSize:14];
        time.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:time];;
        
        distence = nil;
        time = nil;
        faceView = nil;
        face = nil;
        t = nil;
        d = nil;

    }
    if (row<_datas.count) {
        UserModel *mssage = (UserModel*)[_datas objectAtIndex:row];
        NSArray *views = [cell.contentView subviews];
        // face
        UIImageView *faceView = [views firstObject];
        faceView.image = [XMPPHelper xmppUserPhotoForJID:[XMPPJID jidWithString:mssage.jid]];
        // title
        UILabel *t = [views objectAtIndex:1];
        t.text = mssage.nickName;
  
        t = nil;
        // description
        UILabel *d = [views objectAtIndex:2];
        d.text = mssage.sign;

        d = nil;
        // 距离
        UILabel *distance = [views objectAtIndex:3];
        distance.text = [NSString stringWithFormat:@"%0.3f km",mssage.distance/1000];
        distance = nil;
        // 时间
        UILabel *time = [views objectAtIndex:4];
        time.text = [CommonOperation changeTimestampToCount:mssage.time];
        time = nil;
        mssage = nil;

        mssage = nil;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark 消息代理
-(void)didReceiveMessage:(XMPPMessage *)xmppMessage WithXMPPStream:(XMPPStream *)xmppStream andEMessage:(EMessages *)em{}
@end

