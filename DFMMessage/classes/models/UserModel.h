//
//  UserModel.h
//  DFMMessage
//
//  Created by 21tech on 14-6-12.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * face;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * area;
@property (nonatomic, retain) NSString * sign;
@property (nonatomic, retain) NSString * allInfo;
@property (nonatomic, assign) double longitude;     // 精度
@property (nonatomic, assign) double latitude;      // 纬度
@property (nonatomic, retain) NSString * geoHash;   // GEOHASH算法编码
@property (nonatomic, assign) double distance;      // 距离
@property (nonatomic, assign) double time;          // 最后登录时间

@end
