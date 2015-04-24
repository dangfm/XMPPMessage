//
//  MaskView.h
//  21cbh_iphone
//
//  Created by 21tech on 14-6-13.
//  Copyright (c) 2014年 ZX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^hiddenFinishedRunBlock)(void);

@interface MaskView : UIView{
    CGFloat _alpha;
    CGFloat _h;
}
@property (nonatomic,retain) UIView *mainBody;
@property (nonatomic,retain) UIView *sportView;
@property (nonatomic,copy) hiddenFinishedRunBlock hideFinishBlock;
- (id)initWithAlpha:(CGFloat)alpha Height:(int)height;
- (void)show:(void (^)(void))animations;
- (void)hide;

@end
