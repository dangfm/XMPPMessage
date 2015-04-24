//
//  FriendVerifyViewController.m
//  DFMMessage
//
//  Created by 21tech on 14-6-4.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "FriendVerifyViewController.h"
#define kCellHeight 44
@interface FriendVerifyViewController ()
<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITableView *_tableView;
    UITextField *_textField;
}

@end

@implementation FriendVerifyViewController

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
    [self initParams];
    [self initViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initParams{
    
}

-(void)initViews{
    [self initNavigationWithTitle:@"添加朋友" IsBack:YES ReturnType:2];
    [self addSearchTextFiled];
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-y;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x,y,w,h) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackgroundColor;
    if (kSystemVersion>=7) {
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_textField action:@selector(resignFirstResponder)];
    [_tableView addGestureRecognizer:tap];
    tap = nil;
    [self.view addSubview:_tableView];
}

-(void)addSearchTextFiled{
    UITextField *searchText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kCellHeight)];
    searchText.backgroundColor = UIColorWithHex(0xFFFFFF);
    searchText.placeholder = @"";
    XMPPvCardTempModule *vCard = [XMPPServer sharedServer].xmppvCardTempModule;
    searchText.text = vCard.myvCardTemp.nickname;
    vCard = nil;
    searchText.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    searchText.leftViewMode = UITextFieldViewModeAlways;
    searchText.rightViewMode = UITextFieldViewModeUnlessEditing;
//    UIImage *simg = [UIImage imageNamed:@"search"];
//    simg = [CommonOperation imageWithTintColor:UIColorWithHex(0xCCCCCC) blendMode:kCGBlendModeDestinationIn WithImageObject:simg];
//    UIImageView *rightView = [[UIImageView alloc] initWithImage:simg];
//    searchText.rightView = rightView;
//    rightView = nil;
//    simg = nil;
    searchText.clearsOnBeginEditing = NO;
    searchText.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchText.returnKeyType = UIReturnKeySearch;
    searchText.delegate = self;
    _textField = searchText;
    searchText = nil;
}

#pragma mark 文本框代理
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"搜索");
    [self addButty];
    return YES;
}

#pragma mark - private
-(void)addButty{
    XMPPJID *jid = [XMPPJID jidWithString:[CommonOperation getMyJID]];
    //添加好友
    [[XMPPServer sharedServer].xmppRoster addUser:jid withNickname:nil];
    [self.view endEditing:YES];
}

#pragma mark 表格代理实现
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 44)];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _tableView.frame.size.width, 44)];
    l.textColor = UIColorWithHex(0x999999);
    l.font = [UIFont systemFontOfSize:16];
    if (section==0) {
        l.text = @"你需要发送验证申请，等对方通过";
    }
    if (section==1) {
        l.text = @"权限";
    }
    [view addSubview:l];
    l = nil;
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = UIColorWithHex(0xFFFFFF);
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        if (indexPath.section==0) {
            [cell.contentView addSubview:_textField];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
    if (indexPath.section==1) {
        cell.textLabel.text = @"我是";
    }
    if (indexPath.section==2) {
        
    }
  
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - 代理方法

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

@end
