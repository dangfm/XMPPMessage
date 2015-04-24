//
//  AddFriendsViewController.m
//  DFMMessage
//
//  Created by 21tech on 14-5-28.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "XMPPFramework.h"
#import "AppDelegate.h"
#import "SearchFriendsResultViewController.h"

@interface AddFriendsViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,XMPPChatDelegate>
{
    UITableView *_tableView;
    UITextField *_textField;
}

@end

@implementation AddFriendsViewController

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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [XMPPServer sharedServer].chatDelegate = self;
}


-(void)initParams{
    //[XMPPHelper checkSearchUser];
}

-(void)initViews{
    [self initNavigationWithTitle:@"添加朋友" IsBack:YES ReturnType:1];
    [self addSearchTextFiled];
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-y;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x,y,w,h) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackgroundColor;
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, w, 24)];
    t.backgroundColor = KClearColor;
    t.text = @"搜索号码添加朋友";
    t.textColor = kFontColor;
    t.font = [UIFont systemFontOfSize:16];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 34)];
    [headerView addSubview:t];
    t = nil;
    _tableView.tableHeaderView = headerView;
    _tableView.separatorColor = kCellBottomLineColor;
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
    searchText.placeholder = @"附近号/手机号";
    searchText.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    searchText.leftViewMode = UITextFieldViewModeAlways;
    searchText.rightViewMode = UITextFieldViewModeUnlessEditing;
    UIImage *simg = [UIImage imageNamed:@"search"];
    simg = [CommonOperation imageWithTintColor:UIColorWithHex(0xCCCCCC) blendMode:kCGBlendModeDestinationIn WithImageObject:simg];
    UIImageView *rightView = [[UIImageView alloc] initWithImage:simg];
    searchText.rightView = rightView;
    rightView = nil;
    simg = nil;
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
    [self.view endEditing:YES];
    [[LoadingView instance] start:@"正在查询..."];
    [XMPPHelper searchServerUsersWithKeyword:textField.text];
    return YES;
}

#pragma mark - private
-(void)addButty{
    
    XMPPJID *jid = [XMPPJID jidWithUser:_textField.text domain:kHostName resource:kROSTER];
    //添加好友
    [[XMPPServer sharedServer].xmppRoster addUser:jid withNickname:@"test11" groups:[NSArray arrayWithObject:@"Friends"]];
    [self.view endEditing:YES];
}

#pragma mark 表格代理实现
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = kCellBackground;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = kFontColor;
        if (indexPath.section==0) {
            [cell.contentView addSubview:_textField];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
    if (indexPath.section==1) {
        cell.textLabel.text = @"添加手机联系人";
    }
    if (indexPath.section==2) {
        cell.textLabel.text = @"查找门派";
    }
    if (indexPath.section==3) {
        cell.textLabel.text = @"移魂大法";
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

#pragma mark 消息代理
-(void)searchFriendsResult:(NSMutableArray *)data{
    
    if (data.count>0) {
        [[LoadingView instance] stop:[NSString stringWithFormat:@"找到%d个结果",data.count] time:1];
        SearchFriendsResultViewController *search = [[SearchFriendsResultViewController alloc] initWithDatas:data];
        [self.navigationController pushViewController:search animated:YES];
        search = nil;
        
    }else{
        NSLog(@"未找到查询结果");
        [[LoadingView instance] stop:nil time:0];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该用户不存在" message:@"无法找到该用户，请检查你填写的账号是否正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}
@end
