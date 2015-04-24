//
//  ContactFriendsViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-6-2.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "ContactFriendsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AddFriendsViewController.h"
#import "FriendVerifyViewController.h"


@interface ContactFriendsViewController ()<UITableViewDataSource,UITableViewDelegate,XMPPChatDelegate>
{
    NSMutableArray *_datas;
    UITableView *_tableView;
}
@end

@implementation ContactFriendsViewController

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
    [self ReadAllPeoples];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [XMPPServer sharedServer].chatDelegate = self;
    [self initDatas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews{
    [self initNavigationWithTitle:@"新的朋友" IsBack:YES ReturnType:1];
    [self addFriendsButton];
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

-(void)addFriendsButton{
    CGFloat w = 70;
    CGFloat h = 30;
    CGFloat x = self.header.frame.size.width-10-w;
    CGFloat y = (self.header.frame.size.height-h)/2;
    UIButton *addFriends = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    addFriends.backgroundColor = KClearColor;
//    addFriends.layer.backgroundColor = kButtonBackgroundColor.CGColor;
//    addFriends.layer.cornerRadius = 3;
//    addFriends.layer.borderColor = kButtonBackgroundColor.CGColor;
//    addFriends.layer.borderWidth = 0.5;
    [addFriends setTitle:@"添加朋友" forState:UIControlStateNormal];
    [addFriends setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
    [addFriends setTitleColor:UIColorWithHex(0xCCCCCC) forState:UIControlStateHighlighted];
    addFriends.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [addFriends addTarget:self action:@selector(pushToAddFriendsView) forControlEvents:UIControlEventTouchUpInside];
    [self.header addSubview:addFriends];
    addFriends = nil;
}


-(void)initDatas{
    NSArray *peoples = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"myJID='%@'",[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:@"time" sortType:NO];
    _datas = [NSMutableArray arrayWithArray:peoples];
    peoples = nil;
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

-(void)ReadAllPeoples
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        // 检查是否已经加载过
//        NSArray *peoples = [DataOperation select:@"EAddFriends" Where:nil orderBy:@"userName" sortType:YES];
//        if (peoples.count>0) {
//            
//            //return;
//        }
//        
//        peoples = nil;
        //取得本地通信录名柄
        ABAddressBookRef tmpAddressBook = nil;
        
        if ([[UIDevice currentDevice].systemVersion floatValue]>=6.0) {
            tmpAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
            dispatch_semaphore_t sema=dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
                dispatch_semaphore_signal(sema);
            });
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            sema = nil;
        }
        else
        {
            tmpAddressBook = ABAddressBookCreate();
        }
        //取得本地所有联系人记录
        if (tmpAddressBook==nil) {
            return ;
        };
        NSArray* tmpPeoples = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
        for(id tmpPerson in tmpPeoples)
        {
            //获取的联系人单一属性:First name
            NSString* tmpFirstName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
            //NSLog(@"First name:%@", tmpFirstName);
            //获取的联系人单一属性:Last name
            NSString* tmpLastName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
            //NSLog(@"Last name:%@", tmpLastName);
            //获取的联系人单一属性:Nickname
            NSString* tmpNickname = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonNicknameProperty);
            //NSLog(@"Nickname:%@", tmpNickname);
        
            NSString *userName;
            if (tmpLastName) {
                userName = tmpLastName;
            }
            if (tmpLastName && tmpFirstName) {
                userName = [userName stringByAppendingString:tmpFirstName];
            }else{
                userName = tmpFirstName;
            }
            if (userName.length<=0) {
                userName = tmpNickname;
            }
            tmpFirstName = nil;
            tmpLastName = nil;
            tmpNickname = nil;
            
            //获取的联系人单一属性:Generic phone number
            NSString *phones;
            ABMultiValueRef tmpPhones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
            for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
            {
                NSString* tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmpPhones, j);
                //NSLog(@"tmpPhoneIndex%d:%@", j, tmpPhoneIndex);
                if ([phones isEqualToString:@""]) {
                    phones = tmpPhoneIndex;
                }
                else{
                    phones = [[phones stringByAppendingString:@","] stringByAppendingString:tmpPhoneIndex];
                }
                tmpPhoneIndex = nil;
            }
            CFRelease(tmpPhones);
            
//            // 入库
//            NSArray *array = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"userName = '%@'",userName] orderBy:nil sortType:NO];
//            if (array.count<=0) {
//                if (userName.length>0) {
//                    [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
//                        EAddFriends *af = [NSEntityDescription insertNewObjectForEntityForName:@"EAddFriends" inManagedObjectContext:context];
//                        af.userName = userName;
//                        af.userPhones = phones;
//                        af.jid =
//                        af.isDelete = NO;
//                        af.myJID = [CommonOperation getMyJID];
//                        af.time = [CommonOperation getTimestamp];
//                        [DataOperation save];
//                        af = nil;
//                    }];
//                }
//            }
//            array = nil;
            
            phones = nil;
            userName = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initDatas];
        });
        
        //释放内存
        tmpPeoples = nil;
        CFRelease(tmpAddressBook);
    });
    
}

-(void)addFriendButtonAction:(UIButton*)button{
    int tag = button.tag;
    if (tag<_datas.count) {
        EAddFriends *mssage = [_datas objectAtIndex:tag];
        if (mssage.subscription) {
            XMPPJID *jid = [XMPPJID jidWithString:mssage.jid];
            
            if ([button.titleLabel.text isEqualToString:@"添加"]) {
                mssage.subscription = @"to";
                [[XMPPServer xmppRoster] addUser:jid withNickname:mssage.userName groups:[NSArray arrayWithObject:@"Friends"] subscribeToPresence:YES];
                [button setTitle:@"等待验证" forState:UIControlStateNormal];
            }else if([button.titleLabel.text isEqualToString:@"接受"]){
                //[[XMPPServer xmppRoster] addUser:jid withNickname:mssage.userName groups:[NSArray arrayWithObject:@"Friends"] subscribeToPresence:YES];
                [[XMPPServer xmppRoster]  acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
                [button setTitle:@"已添加" forState:UIControlStateNormal];
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
    return kCellHeight;
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
        CGRect frame = cell.bounds;
        frame.origin.y = kCellHeight;
        frame.size.height = 0.5;
        frame = cell.bounds;
        // imageview
        UIImage *face = [UIImage imageNamed:@"noface"];
        UIImageView *faceView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, face.size.width, face.size.height)];
        faceView.image = face;
        faceView.backgroundColor = KClearColor;
        [cell.contentView addSubview:faceView];
        // title
        CGFloat x = faceView.frame.size.width+faceView.frame.origin.x+10;
        CGFloat w = cell.frame.size.width - x;
        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(x, 5, w, 30)];
        t.backgroundColor = KClearColor;
        t.textColor = kFontColor;
        [cell.contentView addSubview:t];
        // description
        UILabel *d = [[UILabel alloc] initWithFrame:CGRectMake(x, 30, w, 30)];
        d.backgroundColor = KClearColor;
        d.textColor = UIColorWithHex(0x999999);
        d.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:d];
        // 添加否
        UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(_tableView.frame.size.width-60-10, 10, 60, 30)];
        [add setTitle:@"添加" forState:UIControlStateNormal];
        [add setTitleColor:UIColorWithHex(0x666666) forState:UIControlStateNormal];
        add.layer.cornerRadius = 3;
        add.layer.borderColor = UIColorWithHex(0xcccccc).CGColor;
        add.layer.borderWidth = 0.5;
        add.titleLabel.font = [UIFont systemFontOfSize:14];
        [add addTarget:self action:@selector(addFriendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:add];
        
        faceView = nil;
        face = nil;
        t = nil;
        d = nil;
        add = nil;
        
    }
    if (row<_datas.count) {
        EAddFriends *mssage = [_datas objectAtIndex:row];
        NSArray *views = [cell.contentView subviews];
        // face
        UIImageView *faceView = [views firstObject];
        // title
        UILabel *t = [views objectAtIndex:1];
        t.text = mssage.userName;
        [t sizeToFit];
        t = nil;
        // description
        UILabel *d = [views objectAtIndex:2];
        d.text = @"";
        if (mssage.type==0) {
            d.text = [NSString stringWithFormat:@"手机联系人：%@",mssage.userName];
        }else{
            d.text = @"请求添加为好友";
        }
        [d sizeToFit];
        d = nil;
        // add
        UIButton *add = [views lastObject];
        add.tag = row;
        // 判断是否已接受
        if ([mssage.subscription isEqualToString:@"both"]) {
            [add setTitle:@"已添加" forState:UIControlStateNormal];
            add.layer.borderWidth = 0;
        }else if ([mssage.subscription isEqualToString:@"to"]){
            [add setTitle:@"等待验证" forState:UIControlStateNormal];
            add.layer.borderWidth = 0;
        }else if ([mssage.subscription isEqualToString:@"from"]){
            [add setTitle:@"接受" forState:UIControlStateNormal];
            add.backgroundColor = kTinColor;
            add.layer.borderWidth = 0;
            [add setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
        }
        
        add = nil;
        mssage = nil;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
#pragma mark 设置删除按钮标题
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
#pragma mark 点击删除后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 从数据源中删除
    // 从列表中删除
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EAddFriends *mssage = [_datas objectAtIndex:indexPath.row];
        NSString *toUser = mssage.userName;
        if ([mssage.subscription isEqualToString:@"from"]) {
            // 拒绝添加为好友
            XMPPJID *jid = [XMPPJID jidWithUser:toUser domain:kHostName resource:kROSTER];
            [[XMPPServer xmppRoster]  rejectPresenceSubscriptionRequestFrom:jid];
        }
        mssage = nil;
        // 删除数据
        [DataOperation deleteWithManagedObject:[_datas objectAtIndex:indexPath.row]];
        [_datas removeObjectAtIndex:indexPath.row];
        // 删除单元格
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewAutomaticDimension];
    }
}


#pragma mark 消息代理
-(void)didReceiveMessage:(XMPPMessage *)xmppMessage WithXMPPStream:(XMPPStream *)xmppStream andEMessage:(EMessages *)em{}
@end
