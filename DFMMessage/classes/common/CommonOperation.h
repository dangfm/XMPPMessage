//
//  CommonOperation.h
//  dapai
//
//  Created by dangfm on 14-4-8.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonOperation : NSObject

/**
 获取当前时间戳 毫秒级
 */
+(double)getTimestamp;

/**
 把时间戳转换为文字描述的时间表示
 */
+(NSString*)toDescriptionStringWithTimestamp:(double)timestamp;

/**
 比较两个时间相差的秒数
 @param timeOne 一般为当前时间，或者比较大的时间
 @param timeTow 为比较的时间
 @return 返回两个时间相差的秒数，正负值
 */
+(NSTimeInterval)compareWithTime:(NSDate*)timeOne TimeTow:(NSDate*)timeTow;

/**
 把时间转换为数值对象
 */
+(NSDateComponents*)getDateComponents:(NSDate*)date;

// 换算时间
+(NSString*)changeTimestampToCount:(double)time;



/**
 画一根线在视图上
 @superView 
 @type
 @height
 @color
 */
+(void)drawLineAtSuperView:(UIView*)superView andTopOrDown:(int)type andHeight:(CGFloat)height andColor:(UIColor*)color;

/**
 图片前景色变换
 @param tintColor 需要变换的颜色
 @param blenMode 填充模式
 @param image 被填充的图片
 @return UIImage 填充后的图片
 */
+(UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode WithImageObject:(UIImage*)image;

/**
 获取字符串字符个数，支持中英文计算
 */
+ (int)stringLength:(NSString*)strtemp;

/**
 画纯色图片，指定颜色生成图片
 @param color 图片颜色
 @param size 图片大小
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

/**
 根据JID得到用户昵称
 */
+(NSString*)getUserNickNameWithJID:(NSString*)jid;

/**
 获取当前登录用户JID字符串
 */
+(NSString*)getMyJID;

/**
 汉子转拼音
 */
+(NSString*)getPinyin:(NSString*)str;

/**
 红色圆点提示
 @num 提示的数目，最大99+
 @superView 提示所在父级视图
 */
+(void)circleTipWithNumber:(int)num SuperView:(UIView*)superView WithPoint:(CGPoint)point;

/**
 有多少个添加好友请求
 @return 好友请求个数
 */
+(int)numberWithAddFriendRequest;

/**
 有多少条未读消息
 @jid 与用户绑定则返回某用户的未读消息数
 */
+(int)numberWithNewMessageWithJId:(NSString*)jid;

/**
 状态指示类型  
 @type 状态类型 -1=连接失败 0=未连接 1=正在连接 2=已连接 3=断开连接 4=连接超时 5=验证错误 6=接收中
 */
+(NSString*)stateWithType:(NSInteger)type;

/**
 GEOHash编码转换
 @latitude  纬度
 @longitude 经度
 @precision 精度
 @return 返回编码后字符串
 */
+(NSString*)geoHash_EnCode:(double)latitude Longitude:(double) longitude Precision:(int)precision;

/**
 计算两个经纬度的距离
 */
+(double)GetLocationDist:(double)lon1 other_Lat:(double)lat1;

/**
 裁剪图片
 默认大小640像素
 */
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;

/**
 按指定大小裁剪图片
 */
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

// 随机生成GUID
+(NSString*)guid;

// 保存用户进分组
+(void)saveFriendIntoGroupWithJid:(NSString*)jid andNickName:(NSString*)nickName;
// 保存用户添加好友请求
+(void)saveAddFriendWithJid:(NSString*)jid andNickName:(NSString*)nickName;
+(void)deleteFriendWithJid:(NSString*)jid;

@end
