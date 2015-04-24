//
//  SmallCircleViewController.m
//  DFMMessage
//
//  Created by 21tech on 14-6-25.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "SmallCircleViewController.h"
#import "SmallCircleTableViewCell.h"
#import "SmallCircleCellFrame.h"

@interface SmallCircleViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *_datas;
    UIImageView *_topView;
}

@end

@implementation SmallCircleViewController

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
    [self initWithDatas];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)dealloc{
    _tableView = nil;
    _datas = nil;

}

-(void)initParams{
    
}
-(void)initViews{
    [self initNavigationWithTitle:@"大广播" IsBack:YES ReturnType:1];
    self.view.backgroundColor = KClearColor;
    self.view.userInteractionEnabled = YES;
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-y;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x,y,w,h) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.separatorColor = kCellBottomLineColor;
    [self.view addSubview:_tableView];
    UIImage *image = [UIImage imageNamed:@"smallCircleTopImage"];
    _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, 250)];
    _topView.image = image;
    image = nil;
    _tableView.tableHeaderView = _topView;
    
}
-(void)initWithDatas{
   
}



#pragma mark 表格代理实现

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SmallCircleCellFrame *frame = [_datas objectAtIndex:indexPath.row];
    if (frame) {
        return frame.cellHeight;
    }
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _datas.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    SmallCircleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SmallCircleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.userPages = [_datas objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}
@end
