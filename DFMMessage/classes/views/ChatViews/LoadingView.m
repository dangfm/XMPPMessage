//
//  LoadingView.m
//  DFMMessage
//
//  Created by dangfm on 14-6-28.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "LoadingView.h"

static UIView *mainView;
static LoadingView *_instance;
@interface LoadingView(){
    NSString *_title;   // 标题
    CGFloat _width;
    CGFloat _height;
    UIActivityIndicatorView *_load;
    UILabel *_loadLb;
    UIView *_loadingView;
    UIFont *_font;
    NSTimer *_timer;
}

@end

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(LoadingView*)instance{
    
    if (!_instance) {
        _instance = [[LoadingView alloc] init];
    }
    return _instance;
}

-(void)start:(NSString*)title{
        //初始化
        _title = title;
        _width = 100;
        _height = 100;
        [self initViews];
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timeOutAction:) userInfo:nil repeats:NO];
    }

}

-(void)stop:(NSString*)title time:(CGFloat)time{
    if (time<=0) {
        [self free];
    }
    _title = title;
    [self viewsWithTitle];
    if (_loadLb) {
         _loadLb.text = title;
        _loadLb = nil;
        [UIView animateWithDuration:time animations:^{
            _loadingView.alpha = 0.8;
        } completion:^(BOOL finish){
            [self free];
        }];
    }
    
}

-(void)free{
    [_load stopAnimating];
    [mainView removeFromSuperview];
    _loadLb = nil;
    _load = nil;
    _loadingView = nil;
    mainView = nil;
    [_timer setFireDate:[NSDate distantFuture]];
    _timer = nil;
}

-(void)timeOutAction:(id)sender{
    [self stop:@"网络超时，请重试" time:2];
}

-(void)initViews{
    if (!mainView) {
        
        mainView = [[UIView alloc] initWithFrame:kScreenBounds];
        [[UIApplication sharedApplication].keyWindow addSubview:mainView];
        CGFloat w = _width;
        CGFloat h = _height;
        // 加载图标
        _load = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _load.frame = CGRectMake(10, (h-_load.frame.size.height)/2, _load.frame.size.width, _load.frame.size.height);
        // 计算标题的长度
        _font = [UIFont systemFontOfSize:18];
        CGSize titleSize = [_title sizeWithFont:_font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
        w = titleSize.width + 30 + _load.frame.size.width;
        CGFloat x = (kScreenBounds.size.width-w)/2;
        CGFloat y = (kScreenBounds.size.height-h)/2;
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _loadingView.backgroundColor = [UIColor blackColor];
        _loadingView.layer.cornerRadius = 5;
        _loadingView.layer.masksToBounds = YES;
        _loadingView.alpha = 1;
        
        [_loadingView addSubview:_load];
        [_load startAnimating];
        _loadLb = [[UILabel alloc] init];
        _loadLb.backgroundColor = KClearColor;
        _loadLb.text = _title;
        _loadLb.font = _font;
        _loadLb.textColor = [UIColor whiteColor];
        [_loadLb sizeToFit];
        _loadLb.frame = CGRectMake(_load.frame.size.width+20, (h-_loadLb.frame.size.height)/2, _loadLb.frame.size.width, _loadLb.frame.size.height);
        [_loadingView addSubview:_loadLb];
        [mainView addSubview:_loadingView];
        //mainView.alpha = 0;
    }
    
    [self viewsWithTitle];
}

-(void)viewsWithTitle{
    _loadLb.text = _title;
    [_loadLb sizeToFit];
    
    CGFloat w = _width;
    CGFloat h = _height;
    // 加载图标
    _load = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // 计算标题的长度
    _font = [UIFont systemFontOfSize:18];
    CGSize titleSize = [_title sizeWithFont:_font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    w = titleSize.width + 30 + _load.frame.size.width;
    if (_title.length<=0) {
        w = 20 + _load.frame.size.width;
    }
    CGFloat x = (kScreenBounds.size.width-w)/2;
    CGFloat y = (kScreenBounds.size.height-h)/2;
    
    [UIView animateWithDuration:0.3 animations:^{
        _load.frame = CGRectMake(10, (h-_load.frame.size.height)/2, _load.frame.size.width, _load.frame.size.height);
        _loadingView.frame = CGRectMake(x, y, w, h);
        _loadLb.frame = CGRectMake(_load.frame.size.width+20, (h-_loadLb.frame.size.height)/2, _loadLb.frame.size.width, _loadLb.frame.size.height);
    }];
    
}


@end
