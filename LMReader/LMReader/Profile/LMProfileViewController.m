//
//  LMProfileViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileViewController.h"
#import "LMProfileTableViewCell.h"
#import "LMSearchViewController.h"
#import "LMReadRecordViewController.h"
#import "LMReadPreferencesViewController.h"
#import "LMSystemSettingViewController.h"
#import "LMFeedBackViewController.h"
#import "LMAboutUsViewController.h"
#import "LMCopyrightViewController.h"
#import "LMProfileCenterViewController.h"
#import "LMLoginViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LMTool.h"
#import "LMLeftItemView.h"
#import "LMRightItemView.h"
#import "UIImageView+WebCache.h"
#import "LMProfileBookCommentViewController.h"

@interface LMProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIImageView* avatorIV;
@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) LoginedRegUser* loginedRegUser;

@end

@implementation LMProfileViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LMLeftItemView* leftView = [[LMLeftItemView alloc]initWithFrame:CGRectMake(0, 0, 80, 25)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    __weak LMProfileViewController* weakSelf = self;
    
    LMRightItemView* rightView = [[LMRightItemView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    rightView.callBlock = ^(BOOL clicked) {
        if (clicked) {
            LMSearchViewController* searchVC = [[LMSearchViewController alloc]init];
            [weakSelf.navigationController pushViewController:searchVC animated:YES];
        }
    };
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMProfileTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    CGFloat spaceX = 10;
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIButton* profileCenterBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    profileCenterBtn.backgroundColor = [UIColor clearColor];
    [profileCenterBtn addTarget:self action:@selector(clickedProfileCenterButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:profileCenterBtn];
    
    self.avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceX, spaceX, 60, 60)];
    self.avatorIV.image = [UIImage imageNamed:@"avator_LoginOut"];
    self.avatorIV.contentMode = UIViewContentModeScaleAspectFill;
    self.avatorIV.clipsToBounds = YES;
    [headerView addSubview:self.avatorIV];
    self.avatorIV.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedAvatorIV:)];
    [self.avatorIV addGestureRecognizer:tap];
    
    self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.avatorIV.frame.origin.x + self.avatorIV.frame.size.width + spaceX, self.avatorIV.frame.origin.y, self.view.frame.size.width - self.avatorIV.frame.size.width - spaceX*4 - 20, 30)];
    self.nameLab.font = [UIFont systemFontOfSize:18];
    self.nameLab.text = @"昵称";
    self.nameLab.textColor = THEMEORANGECOLOR;
    [headerView addSubview:self.nameLab];
    
    self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, self.nameLab.frame.size.width, self.nameLab.frame.size.height)];
    self.timeLab.font = [UIFont systemFontOfSize:15];
    self.timeLab.textColor = [UIColor grayColor];
    self.timeLab.lineBreakMode = NSLineBreakByTruncatingTail;
    [headerView addSubview:self.timeLab];
    
    UIImageView* arrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 10.5, 30, 10.5, 20)];
    UIImage* image = [UIImage imageNamed:@"cell_Arrow"];
    UIImage* tintImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [arrowIV setTintColor:[UIColor grayColor]];
    arrowIV.image = tintImage;
    [headerView addSubview:arrowIV];
    self.tableView.tableHeaderView = headerView;
    
    self.dataArray = [NSMutableArray arrayWithObjects:@[@{@"name" : @"阅读记录", @"cover" : @"profile_ReadRecord"}, @{@"name" : @"阅读偏好", @"cover" : @"profile_ReadPreferences"}, @{@"name" : @"我的评论", @"cover" : @"profile_MyComment"}, @{@"name" : @"系统设置", @"cover" : @"profile_SystemSetting"}], @[@{@"name" : @"意见反馈", @"cover" : @"profile_FeedBack"}, @{@"name" : @"关于我们", @"cover" : @"profile_AboutUs"}, @{@"name" : @"版权声明", @"cover" : @"profile_Copyright"}], nil];
    [self.tableView reloadData];
    
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToViewController:) name:@"jumpToViewController" object:nil];
}

//登录状态过期时，接收通知并重新跳转至登录界面
-(void)jumpToViewController:(NSNotification* )notify {
    LMLoginViewController* loginVC = [[LMLoginViewController alloc]init];
    loginVC.userBlock = ^(LoginedRegUser *loginUser) {
        NSString* tokenStr = loginUser.token;
        if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
            
        }
    };
    [self.navigationController pushViewController:loginVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //防止iOS11 刘海屏tabBar下移34
    UITabBarController* tabBarController = self.tabBarController;
    if (tabBarController) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat tabBarHeight = 49;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
        }
        tabBarController.tabBar.frame = CGRectMake(0, screenRect.size.height - tabBarHeight, screenRect.size.width, tabBarHeight);
    }
    
    //更新头像、昵称信息
    self.loginedRegUser = [LMTool getLoginedRegUser];
    NSString* nickStr = @"未登录";
    NSString* timeStr = @"请先登录，让您享受更好服务";
    if (self.loginedRegUser != nil) {
        timeStr = @"相伴0天";
        RegUser* user = self.loginedRegUser.user;
        NSString* userNickStr = user.nickname;
        if (userNickStr.length > 0) {
            nickStr = userNickStr;
        }else {
            NSString* phoneNumStr = user.phoneNum;
            if (phoneNumStr.length > 0) {
                nickStr = phoneNumStr;
            }else {
                NSString* uidStr = user.uid;
                if (uidStr.length > 0) {
                    nickStr = uidStr;
                }
            }
        }
        UInt32 timeInt = user.registerTime;
        NSInteger day = [LMTool convertTimeStampToDayTime:timeInt];
        if (timeInt > 0 && day >= 0) {
            timeStr = [NSString stringWithFormat:@"相伴%ld天", day];
        }
        
        NSData* imgData = user.iconB;
        if (imgData != nil && imgData.length > 0) {
            self.avatorIV.image = [UIImage imageWithData:imgData];
        }else {
            NSString* avator = user.icon;
            if (avator != nil && avator.length > 0) {
                [self.avatorIV sd_setImageWithURL:[NSURL URLWithString:avator] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
            }else {
                self.avatorIV.image = [UIImage imageNamed:@"avator_LoginOut"];
            }
        }
    }else {
        self.avatorIV.image = [UIImage imageNamed:@"avator_LoginOut"];
    }
    self.nameLab.text = nickStr;
    self.timeLab.text = timeStr;
}

//个人中心
-(void)clickedProfileCenterButton:(UIButton* )sender {
    if (self.loginedRegUser) {
        LMProfileCenterViewController* centerVC = [[LMProfileCenterViewController alloc]init];
        centerVC.loginedUser = self.loginedRegUser;
        [self.navigationController pushViewController:centerVC animated:YES];
        return;
    }
    
    LMLoginViewController* loginVC = [[LMLoginViewController alloc]init];
    loginVC.userBlock = ^(LoginedRegUser *loginUser) {
        NSString* tokenStr = loginUser.token;
        if (tokenStr != nil && ![tokenStr isKindOfClass:[NSNull class]] && tokenStr.length > 0) {
            
        }
    };
    [self.navigationController pushViewController:loginVC animated:YES];
}

//切换头像
-(void)tappedAvatorIV:(UITapGestureRecognizer* )tapGR {
    return;
    /*
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"更改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* maleAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ALAuthorizationStatus photoStatus = [ALAssetsLibrary authorizationStatus];
        if (photoStatus == ALAuthorizationStatusDenied || photoStatus == ALAuthorizationStatusRestricted) {
            [self openSystemSettingWithCamera:NO];
            return;
        }
        
        UIImagePickerController* pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.allowsEditing = YES;
        pickerController.editing = YES;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
    UIAlertAction* femaleAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        if (!cameraAvailable) {
            [self showMBProgressHUDWithText:@"相机不可用"];
            return;
        }
        AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (cameraStatus == AVAuthorizationStatusDenied || cameraStatus == AVAuthorizationStatusRestricted) {
            [self openSystemSettingWithCamera:YES];
            return;
        }
        
        UIImagePickerController* pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.allowsEditing = YES;
        pickerController.editing = YES;
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        pickerController.mediaTypes = @[(NSString* )kUTTypeImage];
        pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:maleAction];
    [controller addAction:femaleAction];
    [controller addAction:cancelAction];
    [self presentViewController:controller animated:YES completion:nil];
     */
}

//前往系统设置打开权限
-(void)openSystemSettingWithCamera:(BOOL )isCamera {
    NSString* messageStr = @"前往系统设置-隐私-照片，允许访问您的照片";
    if (isCamera) {
        messageStr = @"前往系统设置-隐私-相机，允许访问您的相机";
    }
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"提示" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction* sureAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    //获取到的图片
    UIImage * image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    self.avatorIV.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    vi.backgroundColor = [UIColor colorWithRed:233.f/255 green:233.f/255 blue:233.f/255 alpha:1];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    vi.backgroundColor = [UIColor colorWithRed:233.f/255 green:233.f/255 blue:233.f/255 alpha:1];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* arr = [self.dataArray objectAtIndex:section];
    return arr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMProfileTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMProfileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSArray* subArr = [self.dataArray objectAtIndex:section];
    NSDictionary* detailDic = [subArr objectAtIndex:row];
    NSString* nameStr = [detailDic objectForKey:@"name"];
    NSString* imgStr = [detailDic objectForKey:@"cover"];
    
    cell.nameLab.text = nameStr;
    cell.coverIV.image = [UIImage imageNamed:imgStr];
    
    if (row == subArr.count - 1 && section != self.dataArray.count - 1) {
        [cell showLineView:NO];
    }else {
        [cell showLineView:YES];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        switch (row) {
            case 0:
            {
                LMReadRecordViewController* recordVC = [[LMReadRecordViewController alloc]init];
                [self.navigationController pushViewController:recordVC animated:YES];
            }
                break;
            case 1:
            {
                LMReadPreferencesViewController* preferencesVC = [[LMReadPreferencesViewController alloc]init];
                [self.navigationController pushViewController:preferencesVC animated:YES];
            }
                break;
            case 2:
            {
                LMProfileBookCommentViewController* bookCommentVC = [[LMProfileBookCommentViewController alloc]init];
                [self.navigationController pushViewController:bookCommentVC animated:YES];
            }
                break;
            case 3:
            {
                LMSystemSettingViewController* settingVC = [[LMSystemSettingViewController alloc]init];
                [self.navigationController pushViewController:settingVC animated:YES];
            }
                break;
            default:
                break;
        }
    }else if (section == 1) {
        switch (row) {
            case 0:
            {
                LMFeedBackViewController* feedBackVC = [[LMFeedBackViewController alloc]init];
                [self.navigationController pushViewController:feedBackVC animated:YES];
            }
                break;
            case 1:
            {
                LMAboutUsViewController* aboutUsVC = [[LMAboutUsViewController alloc]init];
                [self.navigationController pushViewController:aboutUsVC animated:YES];
            }
                break;
            case 2:
            {
                LMCopyrightViewController* copyrightVC = [[LMCopyrightViewController alloc]init];
                [self.navigationController pushViewController:copyrightVC animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"jumpToViewController" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
