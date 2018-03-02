//
//  LMProfileViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileViewController.h"
#import "LMProfileTableViewCell.h"
#import "LMBookStoreViewController.h"
#import "LMSearchViewController.h"
#import "LMSearchBarView.h"
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

@interface LMProfileViewController () <UITableViewDelegate, UITableViewDataSource, LMSearchBarViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
    
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 25)];
    UILabel* leftItemLab = [[UILabel alloc]initWithFrame:leftView.frame];
    leftItemLab.font = [UIFont systemFontOfSize:20];
    leftItemLab.textColor = [UIColor whiteColor];
    leftItemLab.textAlignment = NSTextAlignmentCenter;
    leftItemLab.text = APPNAME;
    [leftView addSubview:leftItemLab];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    UIButton* rightItemBtn = [[UIButton alloc]initWithFrame:rightView.frame];
    rightItemBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    rightItemBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [rightItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightItemBtn setTitle:@"书城" forState:UIControlStateNormal];
    [rightItemBtn addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightItemBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    LMSearchBarView* titleView = [[LMSearchBarView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - leftView.frame.size.width - rightView.frame.size.width - 60, 25)];
    titleView.delegate = self;
    self.navigationItem.titleView = titleView;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
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
    [headerView addSubview:self.avatorIV];
    self.avatorIV.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedAvatorIV:)];
    [self.avatorIV addGestureRecognizer:tap];
    
    self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.avatorIV.frame.origin.x + self.avatorIV.frame.size.width + spaceX, self.avatorIV.frame.origin.y, self.view.frame.size.width - self.avatorIV.frame.size.width - spaceX*4 - 20, 30)];
    self.nameLab.font = [UIFont systemFontOfSize:18];
    self.nameLab.text = @"昵称";
    [headerView addSubview:self.nameLab];
    self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, self.nameLab.frame.size.width, self.nameLab.frame.size.height)];
    self.timeLab.font = [UIFont systemFontOfSize:16];
    self.timeLab.text = @"相伴200天";
    [headerView addSubview:self.timeLab];
    UIImageView* arrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 10.5, 30, 10.5, 20)];
    arrowIV.image = [UIImage imageNamed:@"cell_Arrow"];
    [headerView addSubview:arrowIV];
    self.tableView.tableHeaderView = headerView;
    
    self.dataArray = [NSMutableArray arrayWithObjects:@[@"阅读记录", @"阅读偏好", @"系统设置"], @[@"意见反馈", @"关于我们", @"版权声明"], nil];
    [self.tableView reloadData];
}

//书城
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    LMBookStoreViewController* storeVC = [[LMBookStoreViewController alloc]init];
    [self.navigationController pushViewController:storeVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //更新头像、昵称信息
    self.loginedRegUser = [LMTool getLoginedRegUser];
    NSString* nickStr = @"未登录";
    NSString* timeStr = @"";
    NSString* imageStr = @"avator_LoginOut";
    if (self.loginedRegUser != nil) {
        RegUser* user = self.loginedRegUser.user;
        NSString* phoneNumStr = user.phoneNum;
        if (phoneNumStr.length > 0) {
            nickStr = phoneNumStr;
        }else {
            NSString* uidStr = user.uid;
            if (uidStr.length > 0) {
                nickStr = uidStr;
            }
        }
        NSString* birthdayStr = user.birthday;
        if (birthdayStr.length > 0) {
            timeStr = birthdayStr;
        }
        imageStr = @"avator_Login";
    }
    self.nameLab.text = nickStr;
    self.timeLab.text = timeStr;
    self.avatorIV.image = [UIImage imageNamed:imageStr];
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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
    
    NSArray* arr = [self.dataArray objectAtIndex:indexPath.section];
    cell.nameLab.text = [arr objectAtIndex:indexPath.row];
    
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

#pragma mark -LMSearchBarViewDelegate
-(void)searchBarViewDidStartSearch:(NSString *)inputText {
    if (inputText.length > 0) {
        LMSearchViewController* searchVC = [[LMSearchViewController alloc]init];
        searchVC.searchStr = inputText;
        [self.navigationController pushViewController:searchVC animated:YES];
    }
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
