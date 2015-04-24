//
//  UserInfoViewController.m
//  DFMMessage
//
//  Created by dangfm on 14-6-18.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "UserInfoViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "MessageViewController.h"
#import "AddFriendsViewController.h"
#import "ContactFriendsViewController.h"
#import "EGOImageView.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "MaskView.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MyImagePickerViewController.h"
#import "EditNickNameViewController.h"
#import "EditSignViewController.h"

@interface UserInfoViewController ()<UITableViewDataSource,UITableViewDelegate,XMPPChatDelegate,VPImageCropperDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>{
    UITableView *_tableView;
    NSMutableArray *_datas;
    NSMutableArray *_groupNames;
    NSMutableDictionary *_groupDatas;
    EGOImageView *_imageView;
    EMe *_me;
    int _row;
}


@end

@implementation UserInfoViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initParams];
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [XMPPServer sharedServer].chatDelegate = self;
    [self initDatas];
}

-(void)dealloc{
    _tableView = nil;
    _datas = nil;
    _me = nil;
}


-(void)initParams{
    
    [self initDatas];
    
}
-(void)initViews{
    [self initNavigationWithTitle:@"个人信息" IsBack:YES ReturnType:1];
    [self addTables];
}

-(void)addTables{
    CGFloat x = 0;
    CGFloat y = self.header.frame.size.height+self.header.frame.origin.y;
    CGFloat w = self.view.frame.size.width;
    CGFloat h = self.view.frame.size.height-y;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(x,y,w,h) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.separatorColor = kCellBottomLineColor;
    _tableView.sectionIndexColor = UIColorWithHex(0x333333);
    if (kSystemVersion>=7) {
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.sectionIndexBackgroundColor = KClearColor;
    }
    [self.view addSubview:_tableView];
}


-(void)initDatas{
    _me = [XMPPHelper my];
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
    }else{
        [_datas removeAllObjects];
    }
    [_datas addObject:_me.face==nil?@"":_me.face];
    [_datas addObject:_me.nickName==nil?@"":_me.nickName];
    [_datas addObject:[XMPPServer sharedServer].xmppStream.myJID.user];
    [_datas addObject:_me.sex==nil?@"":_me.sex];
    [_datas addObject:_me.sign==nil?@"":_me.sign];

    
    _groupNames = [[NSMutableArray alloc] initWithObjects:@"0",@"1",@"2", nil];
    _groupDatas = [[NSMutableDictionary alloc] init];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"头像", nil] forKey:@"0"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"名字",@"账号", nil] forKey:@"1"];
    [_groupDatas setObject:[NSArray arrayWithObjects:@"性别",@"个性签名", nil] forKey:@"2"];
    if (_tableView) {
        [_tableView reloadData];
    }
}

-(void)returnBack{
    [XMPPHelper updateVCardWithEMe:[XMPPHelper my]];
    [XMPPHelper updateUserInfo:[XMPPHelper my]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 表格代理实现
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 70;
    }
    return kCellHeight;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *data = [_groupDatas objectForKey:[NSString stringWithFormat:@"%d",section]];
    NSInteger count = data.count;
    data = nil;
    return count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _groupNames.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 20;
    }
    return 0.0001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell_%d_%d",indexPath.section,indexPath.row];
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = kCellBackground;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = kFontColor;
        
        if (indexPath.section==0) {
            NSString *imgstring = [_datas firstObject];
            _imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"noface"]];
            if (imgstring.length>0) {
                _imageView.image = [UIImage imageWithData:[imgstring base64DecodedData]];
            }
            imgstring = nil;
            _imageView.frame = CGRectMake(cell.frame.size.width-60-30, 5, 60, 60);
            _imageView.layer.cornerRadius = 5;
            _imageView.layer.masksToBounds = YES;
            [cell.contentView addSubview:_imageView];
        }else{
            //[_imageView removeFromSuperview];
        }
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, cell.frame.size.width-130, kCellHeight)];
        info.textColor = UIColorWithHex(0x999999);
        info.font = [UIFont systemFontOfSize:14];
        info.textAlignment = NSTextAlignmentRight;
        info.backgroundColor = KClearColor;
        [cell.contentView addSubview:info];
        info = nil;
        cell.tag = _row;
        _row ++;
    }
    
    int row = indexPath.section;
    if (row<_groupNames.count) {
        NSArray *data = [_groupDatas objectForKey:[NSString stringWithFormat:@"%d",row]];
        if (data.count>0) {
            cell.textLabel.text = [data objectAtIndex:indexPath.row];
            int index = cell.tag;
            if (index<_datas.count) {
                if (row==0) {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSString *imgstring = [_datas firstObject];
                        if (imgstring.length>0) {
                            UIImage *img = [UIImage imageWithData:[imgstring base64DecodedData]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _imageView.image = img;
                            });
                            img = nil;
                        }
                        imgstring = nil;
                    });
                }else{
                    NSArray *views = [cell.contentView subviews];
                    UILabel *info = [views lastObject];
                    info.text = [_datas objectAtIndex:index];
                    info = nil;
                }
            }
            
            
        }
        data = nil;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            //[self performSelector:@selector(showUploadFaceView) withObject:nil afterDelay:0.3];
            [self showUploadFaceView];
            break;
        case 1:
            if (indexPath.row==0) {
                EditNickNameViewController *editNickName = [[EditNickNameViewController alloc] init];
                [self.navigationController pushViewController:editNickName animated:YES];
                editNickName = nil;
            }
            break;
        case 2:
            if (indexPath.row==0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择性别" message:@"" delegate:self cancelButtonTitle:@"女" otherButtonTitles:@"男", nil];
                alert.tag = 1001;
                [alert show];
                alert = nil;
            }
            if (indexPath.row==1) {
                EditSignViewController *editSign = [[EditSignViewController alloc] init];
                [self.navigationController pushViewController:editSign animated:YES];
                editSign = nil;
            }
            break;
        default:
            break;
    }
}

#pragma mark - scrollview代理方法
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark 提示框代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1001) {
        EMe *me = [XMPPHelper my];
        if (buttonIndex==0) {
            // 选择女
            me.sex = @"女";
        }
        if (buttonIndex==1) {
            me.sex = @"男";
        }
        [DataOperation save];
        
        [self initDatas];
    }
}

#pragma mark ---------------选择并上传图片代码块-----------------
-(void)showUploadFaceView{
    
    MaskView *mask = [[MaskView alloc] initWithAlpha:0.5 Height:202];
    mask.sportView.backgroundColor = kBackgroundColor;
    CGFloat h = 44;
    CGFloat y = 202 - h - 10;
    CGFloat w = mask.sportView.frame.size.width - 20;
    CGFloat x = 10;
    // 取消按钮
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    bt.backgroundColor = KClearColor;
    [bt setTitle:@"取消" forState:UIControlStateNormal];
    [bt setTitleColor:UIColorWithHex(0xFFFFFF) forState:UIControlStateNormal];
    [bt setTitleColor:UIColorWithHex(0xCCCCCC) forState:UIControlStateHighlighted];
    bt.layer.cornerRadius = 5;
    bt.layer.backgroundColor = kNavigationBackgroundColor.CGColor;
    [bt addTarget:mask action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [mask.sportView addSubview:bt];
    bt = nil;
    //两个按钮
    NSArray *titles = @[@"拍照",@"从手机相册选择"];
    y = 20;
    
    for (int i=0; i<titles.count; i++) {
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        b.tag = i;
        [b setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [b setTitleColor:kFontColor forState:UIControlStateNormal];
        [b setTitleColor:kFontColor forState:UIControlStateHighlighted];
        [b setBackgroundImage:[CommonOperation imageWithColor:kCellBottomLineColor andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
        b.layer.masksToBounds = YES;
        b.layer.cornerRadius = 5;
        b.layer.backgroundColor = kButtonBackgroundColor.CGColor;
        b.layer.borderColor = kCellBottomLineColor.CGColor;
        b.layer.borderWidth = 0.5;
        [b addTarget:self action:@selector(clickUploadButtonWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [mask.sportView addSubview:b];
        b = nil;
        y += h + 10;
    }
    [mask show:nil];
    mask.hideFinishBlock = ^{
        
    };
    mask = nil;
    titles = nil;
}

#pragma mark 选择图片按钮
-(void)clickUploadButtonWithIndex:(UIButton *)sender{
    // 选择相册
    MaskView *mask = (MaskView*)[[sender superview] superview];
    if (sender.tag==1) {
        
        if (![QBImagePickerController isAccessible]) {
            NSLog(@"Error: Source is not accessible.");
        }else{
            
            mask.hideFinishBlock = ^{
                // 多选插件
//                QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//                imagePickerController.delegate = self;
//                imagePickerController.groupTypes = @[
//                                                     @(ALAssetsGroupSavedPhotos),
//                                                     @(ALAssetsGroupPhotoStream),
//                                                     @(ALAssetsGroupAlbum)
//                                                     ];
//                imagePickerController.allowsMultipleSelection = YES;
//                imagePickerController.minimumNumberOfSelection = 1;
//                imagePickerController.maximumNumberOfSelection = 1;
//                
//                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
//                [self presentViewController:navigationController animated:YES completion:NULL];
//                imagePickerController = nil;
                
                // 系统相册
                [self initUIImagePickerController];
                
            };
            [mask hide];
        }
    }
    // 选择相机
    if (sender.tag==0) {
        mask.hideFinishBlock = ^{
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        };
        [mask hide];
    }
}

#pragma mark 判断相机相册是否可用等
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark 初始化一个图片选择控制器
-(void)initUIImagePickerController{
    if ([self isPhotoLibraryAvailable]) {
        MyImagePickerViewController *controller = [[MyImagePickerViewController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
    }
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    // 拿到裁剪后的图片 editedImage;
    [[LoadingView instance] start:@"正在处理图片..."];
    editedImage = [CommonOperation imageByScalingToMaxSize:editedImage];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        // TO DO
        _imageView.image = editedImage;
        EMe *m = [XMPPHelper my];
        m.face = [UIImagePNGRepresentation(editedImage) base64EncodedString];
        [DataOperation save];
        [XMPPHelper updateVCardWithEMe:m];
        [XMPPHelper updateUserInfo:[XMPPHelper my]];
        m = nil;
        [[LoadingView instance] stop:nil time:0];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //[picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        // 相册拿到图片则调用裁剪控件
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [picker pushViewController:imgCropperVC animated:YES];
    //}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
        
        
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}


#pragma mark - QBImagePickerControllerDelegate

//- (void)dismissImagePickerController
//{
//    if (self.presentedViewController) {
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    } else {
//        [self.navigationController popToViewController:self animated:YES];
//    }
//}
//
//- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
//{
//    NSLog(@"*** imagePickerController:didSelectAsset:");
//    NSLog(@"%@", asset);
//    
//    [self dismissImagePickerController];
//}
//
//- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
//{
//    NSLog(@"*** imagePickerController:didSelectAssets:");
//    NSLog(@"%@", assets);
//    
//    [self dismissImagePickerController];
//}
//
//- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
//{
//    NSLog(@"*** imagePickerControllerDidCancel:");
//    
//    [self dismissImagePickerController];
//}



#pragma mark 消息代理
-(void)didReceiveMessage:(XMPPMessage *)xmppMessage WithXMPPStream:(XMPPStream *)xmppStream andEMessage:(EMessages *)em{
    [CommonOperation circleTipWithNumber:[CommonOperation numberWithNewMessageWithJId:nil] SuperView:[[self.footer subviews]firstObject] WithPoint:CGPointMake(40, 0)];
    [self initDatas];
}

-(void)friendWhenSendAddAction:(XMPPJID *)friendJID Subscription:(NSString *)subscription{
    [CommonOperation circleTipWithNumber:[CommonOperation numberWithAddFriendRequest] SuperView:[[self.footer subviews] objectAtIndex:1] WithPoint:CGPointMake(35, 0)];
    [_tableView reloadData];
}

@end
