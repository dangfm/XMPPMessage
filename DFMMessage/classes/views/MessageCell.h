//
//  MessageCell.h
//  DFMMessage
//
//  Created by dangfm on 14-5-6.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVAudioPlayer;
@class MessageFrame;

@interface MessageCell : UITableViewCell

@property (nonatomic, strong) MessageFrame *messageFrame;

@end