//
//  CommonOperation.m
//  dapai
//
//  Created by dangfm on 14-4-8.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "CommonOperation.h"
#define BASE32 @"0,1,2,3,4,5,6,7,8,9,b,c,d,e,f,g,h,j,k,m,n,p,q,r,s,t,u,v,w,x,y,z"
#define PI 3.1415926
#define ORIGINAL_MAX_WIDTH 160.0f

@implementation CommonOperation


+(double)getTimestamp{
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    double timestamp = time;
    return timestamp;
}
+(NSString*)toDescriptionStringWithTimestamp:(double)timestamp{
    NSString * des;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:MM:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    if (!date) {
        return 0;
    }
    
    // 比较
    NSDate *nowDate = [NSDate date];
    // 比较结果 发布时间与当前时间相差的秒数
    NSTimeInterval result = [self compareWithTime:nowDate TimeTow:date];
    //result = abs(result);
    // 凌晨到现在的秒数
    [formatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *today00Date = [formatter dateFromString:[formatter stringFromDate:nowDate]];
    NSTimeInterval today00toNowSenconds = [self compareWithTime:nowDate TimeTow:today00Date];;
    NSDateComponents *comps = [self getDateComponents:date];
    
    //今天
    NSInteger hour = comps.hour;
    NSString *j = @"上午";
    if (hour>12) {
        j = @"下午";
        hour -= 12;
    }
    if (result<=today00toNowSenconds) {
        
        NSString *m = [NSString stringWithFormat:@"%ld",(long)comps.minute];
        if (comps.minute<10) {
            m = [NSString stringWithFormat:@"0%ld",(long)comps.minute];
        }
        des = [NSString stringWithFormat:@"%@ %ld:%@",j,(long)hour,m];
    }
    else{
        des = [NSString stringWithFormat:@"%ld月%ld日 %@ %ld:%ld",(long)comps.month,(long)comps.day,j,(long)hour,(long)comps.minute];
    }
    formatter = nil;
    j = nil;
    return des;
}

+(NSString*)changeTimestampToCount:(double)time{
    int newInt = 0;
    NSString *danwei = @"";
    int result = [[NSDate date] timeIntervalSince1970]-time; // 相差多少秒
    
    if (result<60) {
        return @"刚刚";
    }
    if (result>60) {
        newInt = result/60;
        danwei = @"分钟";
    }
    if (result>60*60) {
        newInt = result/60/60;
        danwei = @"小时";
    }
    if (result>24*60*60) {
        newInt = result/24/60/60;
        danwei = @"天";
    }
    if (time<=0) {
        return @"很久以前";
    }

    return [NSString stringWithFormat:@"%d%@前",newInt,danwei];
}

+(NSTimeInterval)compareWithTime:(NSDate*)timeOne TimeTow:(NSDate*)timeTow{
    NSTimeInterval time = [timeOne timeIntervalSince1970];
    double timestamp = time;
    
    NSTimeInterval time2 = [timeTow timeIntervalSince1970];
    double timestampTow = time2;
    
    double timeInterVal = timestamp - timestampTow;
    return timeInterVal;
}

+(NSDateComponents*)getDateComponents:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    // 年月日获得
    comps =[calendar components:(NSYearCalendarUnit |
                                 NSMonthCalendarUnit |
                                 NSDayCalendarUnit |
                                 NSHourCalendarUnit |
                                 NSMinuteCalendarUnit |
                                 NSSecondCalendarUnit)
                       fromDate:date];
    return comps;
}

#pragma mark 画一根线在视图上
+(void)drawLineAtSuperView:(UIView*)superView andTopOrDown:(int)type andHeight:(CGFloat)height andColor:(UIColor*)color{
    CGRect frame = CGRectMake(0, 0, superView.frame.size.width, height);
    if (type==1) {
        frame = CGRectMake(0, superView.frame.size.height-height, superView.frame.size.width, height);
    }
    UIView *line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = color;
    [superView addSubview:line];
    line = nil;
}

+ (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode WithImageObject:(UIImage*)image
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (int)stringLength:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(NSString*)getUserNickNameWithJID:(NSString*)jid{
    NSString *userName;
    NSArray *friend = [DataOperation select:@"EFriends" Where:[NSString stringWithFormat:@"jid='%@'",jid] orderBy:nil sortType:YES];
    ;
    if (friend.count>0) {
        EFriends *e = [friend firstObject];
        userName = e.nickName;
        e = nil;
    }
    friend = nil;
    return userName;
}

+(NSString*)getMyJID{
    NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:USERID];
    NSString *domain = [[NSUserDefaults standardUserDefaults] stringForKey:SERVER];
    if (user.length>0) {
        return [NSString stringWithFormat:@"%@@%@",user,domain];
    }
    return nil;
}

+(NSString*)getPinyin:(NSString*)str{
    if (str) {
        CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (CFStringRef)str);
        CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
        return (__bridge NSString*)string;
    }
    return nil;
}


+(void)circleTipWithNumber:(int)num SuperView:(UIView*)superView WithPoint:(CGPoint)point{
    
    int tag = 10010;
    UILabel *cricle;
    UILabel *l = (UILabel*)[superView viewWithTag:tag];
    if (l==nil) {
        cricle = [[UILabel alloc] init];
        [superView addSubview:cricle];
    }else{
        cricle = l;
    }
    CGFloat w = 18;
    CGFloat x = superView.frame.size.width - w;
    CGFloat y = 2;
    CGFloat h = 18;
    
    cricle.layer.cornerRadius = 9;
    cricle.layer.backgroundColor = UIColorWithHex(0xFF0000).CGColor;
//    cricle.layer.shadowRadius = 1.0;
//    cricle.layer.shadowColor = UIColorWithHex(0xFFFFFF).CGColor;
//    cricle.layer.shadowOffset = CGSizeMake(1, 1);
//    cricle.layer.shadowOpacity = 1.0;
    cricle.font = [UIFont boldSystemFontOfSize:12];
    cricle.textAlignment = NSTextAlignmentCenter;
    cricle.textColor = UIColorWithHex(0xFFFFFF);
    cricle.tag = tag;
    cricle.text = [NSString stringWithFormat:@"%d",num];
    [cricle sizeToFit];
    x = point.x;
    y = point.y;
    if (num>=10) {
        w = 22;
    }
    cricle.frame = CGRectMake(x, y, w, h);
    if (num==0) {
        cricle.hidden = YES;
    }
    else{
        cricle.hidden = NO;
    }
    cricle = nil;
}

+(int)numberWithAddFriendRequest{
    int number = 0;
    // 查询有多少个添加好友请求
    NSArray *array = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"myJID='%@' and (isDelete=0 or isDelete=null) and subscription='from' ",[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
    number = (int)array.count;
    array = nil;
    return number;
}

+(int)numberWithNewMessageWithJId:(NSString*)jid{
    int number = 0;
    // 查询有多少条未读新消息
    if (jid) {
        NSArray *array = [DataOperation select:@"EMessages" Where:[NSString stringWithFormat:@"myJID='%@' and (isRead=0 or isRead=null) and send_jid='%@' and receive_jid=myJID",[XMPPServer sharedServer].xmppStream.myJID.bare,jid] orderBy:nil sortType:NO];
        number = (int)array.count;
        array = nil;
    }
    else{
        NSArray *array = [DataOperation select:@"EMessages" Where:[NSString stringWithFormat:@"myJID='%@' and (isRead=0 or isRead=null) and receive_jid=myJID",[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
        number = (int)array.count;
        array = nil;
    }
    return number;
}

/**
 状态指示类型  -1=连接失败 0=未连接 1=正在连接 2=已连接 3=断开连接 4=连接超时 5=验证错误 6=接收中
 */
+(NSString*)stateWithType:(NSInteger)type{
    switch (type) {
        case -1:
            return @"未连接";
            break;
        case 0:
            return @"未连接";
            break;
        case 1:
            return @"连接中";
            break;
        case 2:
            return @"已连接";
            break;
        case 3:
            return @"断开连接";
            break;
        case 4:
            return @"连接超时";
            break;
        case 5:
            return @"验证错误";
            break;
        case 6:
            return @"接收中";
            break;
        case 7:
            return @"验证成功";
            break;
        case 8:
            return @"注册成功";
            break;
        case 9:
            return @"注册失败";
            break;
        case 10:
            return @"验证中";
            break;
        default:
            break;
    }
    return @"未连接";
}

// 如果geohash的位数是6位数的时候，大概为附近1千米
+(NSString*)geoHash_EnCode:(double)latitude Longitude:(double) longitude Precision:(int)precision {
    
    NSString *geohash = @"";
    int is_even=1, i=0;
    double lat[2], lon[2], mid;
    char bits[] = {16,8,4,2,1};
    int bit=0, ch=0;
    lat[0] = -90.0; lat[1] = 90.0;
    lon[0] = -180.0; lon[1] = 180.0;
    
    while (i < precision) {
        if (is_even) {
            mid = (lon[0] + lon[1]) / 2;
            if (longitude > mid) {
                ch |= bits[bit];
                lon[0] = mid;
            } else
                lon[1] = mid;
        } else {
            mid = (lat[0] + lat[1]) / 2;
            if (latitude > mid) {
                ch |= bits[bit];
                lat[0] = mid;
            } else  
                lat[1] = mid;  
        }  
        is_even = !is_even;  
        if (bit < 4)  
            bit++;  
        else {
            i++;
            geohash = [geohash stringByAppendingString:[[BASE32 componentsSeparatedByString:@","] objectAtIndex:ch]];
            bit = 0;  
            ch = 0;  
        }
    }
    
    geohash = [geohash stringByAppendingString:@"0"];
    return geohash;
}



+(double)GetLocationDist:(double)lon1 other_Lat:(double)lat1{
    EMe *me = [XMPPHelper my];
    double lon2 = me.longitude;
    double lat2 = me.latitude;
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    me = nil;
    return dist;
}

#pragma mark 图片裁剪
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSString*)guid{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

+(void)saveFriendIntoGroupWithJid:(NSString*)jid andNickName:(NSString*)nickName{
    // 保存用户进分组
    NSArray *array = [DataOperation select:@"EFriends" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jid,[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
    if (array.count<=0) {
        // 添加进朋友列表
        [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
            EFriends *friends = [NSEntityDescription insertNewObjectForEntityForName:@"EFriends" inManagedObjectContext:context];
            friends.userName = nickName;
            friends.jid = jid;
            friends.nickName = nickName;
            friends.note = nickName;
            friends.myJID = [XMPPServer sharedServer].xmppStream.myJID.bare;
            friends.isDelete = NO;
            friends.firstChar = [[[CommonOperation getPinyin:nickName] substringToIndex:1] uppercaseString];
            [DataOperation save];
            friends = nil;
        }];
    }else{
        EFriends *friends = [array firstObject];
        friends.userName = nickName;
        friends.jid = jid;
        friends.nickName = nickName;
        friends.note = nickName;
        friends.myJID = [XMPPServer sharedServer].xmppStream.myJID.bare;
        friends.isDelete = NO;
        friends.firstChar = [[[CommonOperation getPinyin:nickName] substringToIndex:1] uppercaseString];
        [DataOperation save];
        friends = nil;
    }
    // 用户请求好友信息至为both
    NSArray *addfriends = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jid,[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
    if (addfriends.count>0) {
        EAddFriends *add = [addfriends firstObject];
        add.subscription = @"both";
        [DataOperation save];
        add = nil;
    }
    addfriends = nil;
}

+(void)saveAddFriendWithJid:(NSString*)jid andNickName:(NSString*)nickName{
    NSArray *array = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jid,[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
    if (array.count>0) {
        EAddFriends *add = [array firstObject];
        if (add.subscription.length<=0) {
            add.subscription = @"from";
        }
        add.myJID = [XMPPServer sharedServer].xmppStream.myJID.bare;
        add.isDelete = NO;
        [DataOperation save];
        add = nil;
    }else{
        [DataOperation addUsingBlock:^(NSManagedObjectContext *context){
            EAddFriends *add = [NSEntityDescription insertNewObjectForEntityForName:@"EAddFriends" inManagedObjectContext:context];
            add.userName = nickName;
            add.time = [CommonOperation getTimestamp];
            add.type = 1; // 非手机联系人
            add.jid = jid;
            add.subscription = @"from";
            add.isDelete = NO;
            add.myJID = [XMPPServer sharedServer].xmppStream.myJID.bare;
            [DataOperation save];
            add = nil;
        }];
    }
    array = nil;

}

+(void)deleteFriendWithJid:(NSString*)jid{
    NSArray *friends = [DataOperation select:@"EFriends" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jid,[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
    if (friends.count>0) {
        EFriends *friend = [friends firstObject];
        // 删除数据
        [DataOperation deleteWithManagedObject:friend];
    }
    friends = nil;
    
    NSArray *array = [DataOperation select:@"EAddFriends" Where:[NSString stringWithFormat:@"jid='%@' and myJID='%@'",jid,[XMPPServer sharedServer].xmppStream.myJID.bare] orderBy:nil sortType:NO];
    if (array.count>0) {
        EAddFriends *add = [array firstObject];
        // 删除数据
        [DataOperation deleteWithManagedObject:add];
        add = nil;
    }
    array = nil;
}
@end
