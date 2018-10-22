//
//  LMProfileCenterViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileCenterViewController.h"
#import "LMProfileCenterTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "LMSetPasswordViewController.h"
#import "LMCheckVerifyCodeViewController.h"

@interface LMProfileCenterViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth* qqAuth;

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* titleArray;
@property (nonatomic, assign) GenderType centerType;/**<性别*/
@property (nonatomic, copy) NSString* centerBirthday;/**<出生日期*/
@property (nonatomic, copy) NSString* centerLocalArea;/**<地区*/
@property (nonatomic, copy) UIImage* avatorImage;/**<头像Image*/
@property (nonatomic, copy) NSString* avatorUrlStr;/**<头像url*/
@property (nonatomic, copy) NSString* centerNick;/**<昵称*/
@property (nonatomic, copy) NSString* phoneNumber;/**<手机号*/
@property (nonatomic, assign) BOOL isBindWeChat;/**<是否已绑定微信*/
@property (nonatomic, assign) BOOL isBindQQ;/**<是否已绑定QQ*/
@property (nonatomic, assign) BOOL isSetPwd;/**<是否已设置密码*/
@property (nonatomic, copy) NSString* weChatNick;/**<微信昵称*/
@property (nonatomic, copy) NSString* qqNick;/**<qq昵称*/

@property (nonatomic, strong) UIView* bgView;

@property (nonatomic, strong) UIView* dateView;
@property (nonatomic, strong) UIDatePicker* datePicker;
@property (nonatomic, strong) UIView* placeView;
@property (nonatomic, strong) UIPickerView* placePicker;
@property (nonatomic, strong) NSMutableArray* provinceArray;
@property (nonatomic, strong) NSMutableDictionary* cityDic;
@property (nonatomic, strong) NSMutableArray* cityArray;


@end

@implementation LMProfileCenterViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人中心";
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMProfileCenterTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.titleArray = [NSMutableArray arrayWithObjects:@"头像", @"昵称", @"性别", @"出生日期", @"所在地区", @"修改密码", @"绑定微信", @"绑定QQ", @"绑定手机", nil];
    
    //
    [self initLoginedUserData];
    
    //微信 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatDidLogin:) name:weChatLoginNotifyName object:nil];
}

-(void)initLoginedUserData {
    self.loginedUser = [LMTool getLoginedRegUser];
    RegUser* regUser = self.loginedUser.user;
    NSString* genderStr = @"";
    GenderType type = regUser.gender;
    if (type == GenderTypeGenderMale) {
        genderStr = @"男";
    }else if (type == GenderTypeGenderFemale) {
        genderStr = @"女";
    }
    self.avatorUrlStr = regUser.icon;
    if (regUser.iconB != nil && regUser.iconB.length > 0) {
        self.avatorImage = [UIImage imageWithData:regUser.iconB];
    }
    self.phoneNumber = regUser.phoneNum;
    self.centerType = regUser.gender;
    self.centerBirthday = regUser.birthday;
    self.centerLocalArea = regUser.localArea;
    self.centerNick = regUser.phoneNum;
    if (regUser.nickname != nil && regUser.nickname.length > 0) {
        self.centerNick = regUser.nickname;
    }
    self.isSetPwd = NO;
    if (regUser.setpw == RegUserSetPwYes) {
        self.isSetPwd = YES;
    }
    self.isBindQQ = NO;
    if (regUser.qq != nil && regUser.qq.length > 0) {
        self.isBindQQ = YES;
        self.qqNick = regUser.qqNickname;
    }
    self.isBindWeChat = NO;
    if (regUser.wx != nil && regUser.wx.length > 0) {
        self.isBindWeChat = YES;
        self.weChatNick = regUser.wxNickname;
    }
    
    [self.tableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMProfileCenterTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMProfileCenterTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    cell.nameLab.text = [self.titleArray objectAtIndex:row];
    
    [cell setupShowContentImageView:NO];
    [cell setupShowContentLabel:YES];
    
    if (row == 0) {
        [cell setupShowContentImageView:YES];
        [cell setupShowContentLabel:NO];
        if (self.avatorImage != nil) {
            cell.contentIV.image = self.avatorImage;
        }else if (self.avatorUrlStr != nil && self.avatorUrlStr.length > 0) {
            [cell.contentIV sd_setImageWithURL:[NSURL URLWithString:self.avatorUrlStr] placeholderImage:[UIImage imageNamed:@"avator_LoginOut"]];
        }else {
            cell.contentIV.image = [UIImage imageNamed:@"avator_LoginOut"];
        }
    }else if (row == 1) {
        cell.contentLab.text = self.centerNick;
    }else if (row == 2) {
        NSString* genderStr = @"";
        if (self.centerType == GenderTypeGenderMale) {
            genderStr = @"男";
        }else if (self.centerType == GenderTypeGenderFemale) {
            genderStr = @"女";
        }else if (self.centerType == GenderTypeGenderOther) {
            genderStr = @"其它";
        }
        cell.contentLab.text = genderStr;
    }else if (row == 3) {
        if (self.centerBirthday != nil && self.centerBirthday.length > 0) {
            cell.contentLab.text = self.centerBirthday;
        }
    }else if (row == 4) {
        if (self.centerLocalArea != nil && self.centerLocalArea.length > 0) {
            cell.contentLab.text = self.centerLocalArea;
        }
    }else if (row == 5) {//修改密码
        [cell setupShowContentLabel:NO];
    }else if (row == 6) {//绑定微信
        NSString* str = @"未绑定";
        if (self.isBindWeChat) {
            str = @"已绑定";
            if (self.weChatNick != nil && self.weChatNick.length > 0) {
                str = self.weChatNick;
            }
        }
        cell.contentLab.text = str;
    }else if (row == 7) {//绑定QQ
        NSString* str = @"未绑定";
        if (self.isBindQQ) {
            str = @"已绑定";
            if (self.qqNick != nil && self.qqNick.length > 0) {
                str = self.qqNick;
            }
        }
        cell.contentLab.text = str;
    }else if (row == 8) {
        cell.contentLab.text = self.phoneNumber;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    if (row == 0) {
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"更改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* maleAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
            if (photoStatus == PHAuthorizationStatusDenied || photoStatus == PHAuthorizationStatusRestricted) {
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
    }else if (row == 1) {//昵称
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"请输入昵称" message:@"不超过12个字符" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction* sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *tf = [alertController.textFields objectAtIndex:0];
            NSString* tempNickStr = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (tempNickStr == nil || tempNickStr.length == 0) {
                return;
            }else if (tempNickStr.length > 12) {
                [self showMBProgressHUDWithText:@"昵称太长了"];
                return;
            }
            RegUserBuilder* regBuilder = [RegUser builder];
            [regBuilder setNickname:tempNickStr];
            //
            RegUser* tempUser = [self buildRegUserWithRegUserBuilder:regBuilder];
            [self updateUserInfoWithUser:tempUser];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (row == 2) {
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* maleAction = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.centerType == GenderTypeGenderMale) {
                return ;
            }
            self.centerType = GenderTypeGenderMale;
            
            RegUserBuilder* regBuilder = [RegUser builder];
            [regBuilder setGender:self.centerType];
            //
            RegUser* tempUser = [self buildRegUserWithRegUserBuilder:regBuilder];
            [self updateUserInfoWithUser:tempUser];
        }];
        UIAlertAction* femaleAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.centerType == GenderTypeGenderFemale) {
                return ;
            }
            self.centerType = GenderTypeGenderFemale;
            
            RegUserBuilder* regBuilder = [RegUser builder];
            [regBuilder setGender:self.centerType];
            //
            RegUser* tempUser = [self buildRegUserWithRegUserBuilder:regBuilder];
            [self updateUserInfoWithUser:tempUser];
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [controller addAction:maleAction];
        [controller addAction:femaleAction];
        [controller addAction:cancelAction];
        [self presentViewController:controller animated:YES completion:nil];
    }else if (row == 3) {
        [self showDateView];
    }else if (row == 4) {
        [self loadPlacePickerViewData];
    }else if (row == 5) {
        //进入设置密码界面，如果是第三方登录的，先必须绑定手机号
        if (self.phoneNumber != nil && self.phoneNumber.length > 0) {
            LMCheckVerifyCodeViewController* checkVC = [[LMCheckVerifyCodeViewController alloc]init];
            checkVC.type = SmsTypeSmsForgotpwd;
            [self.navigationController pushViewController:checkVC animated:YES];
        }else {
            LMCheckVerifyCodeViewController* checkVC = [[LMCheckVerifyCodeViewController alloc]init];
            checkVC.type = SmsTypeSmsBind;
            [self.navigationController pushViewController:checkVC animated:YES];
        }
    }else if (row == 6) {//绑定微信
        if (self.isBindWeChat) {
            [self showMBProgressHUDWithText:@"已经绑定过微信"];
            return;
        }
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            SendAuthReq* request = [[SendAuthReq alloc]init];
            request.state = weChatLoginState;
            request.scope = @"snsapi_userinfo";
            [WXApi sendReq:request];
        }else {
            [self showMBProgressHUDWithText:@"暂不能绑定"];
        }
    }else if (row == 7) {//绑定QQ
        if (self.isBindQQ) {
            [self showMBProgressHUDWithText:@"已经绑定过QQ"];
            return;
        }
        self.qqAuth = [[TencentOAuth alloc]initWithAppId:qqAppId andDelegate:self];
        NSArray* permissionArr = @[@"get_user_info", @"get_simple_userinfo"];
        [self.qqAuth authorize:permissionArr inSafari:NO];
    }else if (row == 8) {//绑定手机号
        if (self.phoneNumber != nil && self.phoneNumber.length > 0) {
            [self showMBProgressHUDWithText:@"已经绑定过手机号"];
            return;
        }
        __weak LMProfileCenterViewController* weakSelf = self;
        
        LMCheckVerifyCodeViewController* checkVC = [[LMCheckVerifyCodeViewController alloc]init];
        checkVC.type = SmsTypeSmsBind;
        checkVC.bindPhone = YES;
        checkVC.bindBlock = ^(NSString *bindPhoneStr) {
            if (bindPhoneStr != nil && bindPhoneStr.length > 0) {
                RegUserBuilder* regBuilder = [RegUser builder];
                [regBuilder setPhoneNum:bindPhoneStr];
                //
                RegUser* tempUser = [self buildRegUserWithRegUserBuilder:regBuilder];
                
                LoginedRegUserBuilder* builder = [LoginedRegUser builder];
                [builder setToken:weakSelf.loginedUser.token];
                [builder setUser:tempUser];
                LoginedRegUser* tempLogUser = [builder build];
                [LMTool saveLoginedRegUser:tempLogUser];
                
                [weakSelf showMBProgressHUDWithText:@"操作成功"];
                
                //刷新
                [weakSelf initLoginedUserData];
            }
        };
        [self.navigationController pushViewController:checkVC animated:YES];
    }
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
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
        } else {
            [self showMBProgressHUDWithText:@"打开出错了。。。"];
        }
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
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    LMProfileCenterTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.contentIV.image = image;
    
    NSData* imgData = UIImageJPEGRepresentation(image, 0.5);
    
    RegUserBuilder* regBuilder = [RegUser builder];
    [regBuilder setIconB:imgData];
    //
    RegUser* tempUser = [self buildRegUserWithRegUserBuilder:regBuilder];
    [self updateUserInfoWithUser:tempUser];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//
-(UIView *)bgView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, screenRect.size.height)];
        _bgView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_bgView];
        
        UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedBgView:)];
        [_bgView addGestureRecognizer:tapGR];
    }
    return _bgView;
}

//
-(void)tappedBgView:(UITapGestureRecognizer* )tapGR {
    [self hideDateView];
    [self hidePlacePickerView];
}

//选择日期
-(void)showDateView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.dateView) {
        self.dateView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250)];
        self.dateView.backgroundColor = [[UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1] colorWithAlphaComponent:1];
        [self.view insertSubview:self.dateView aboveSubview:self.bgView];
        
        UIButton* cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(clickedDateViewCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.dateView addSubview:cancelBtn];
        
        UIButton* sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.dateView.frame.size.width - 50, 0, 50, 30)];
        [sureBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(clickedDateViewSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.dateView addSubview:sureBtn];
        
        self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, cancelBtn.frame.size.height, self.dateView.frame.size.width, self.dateView.frame.size.height - cancelBtn.frame.size.height)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        [self.datePicker setLocale:[NSLocale currentLocale]];
        [self.datePicker setTimeZone:[NSTimeZone systemTimeZone]];
        [self.dateView addSubview:self.datePicker];
        
        NSDate* date = [NSDate date];
        if (self.loginedUser != nil) {
            RegUser* user = self.loginedUser.user;
            NSString* birthdayStr = user.birthday;
            if (birthdayStr != nil && ![birthdayStr isKindOfClass:[NSNull class]] && birthdayStr.length > 0) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd"];
                date = [dateFormatter dateFromString:birthdayStr];
            }
        }
        [self.datePicker setDate:date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate* minDate = [dateFormatter dateFromString:@"1900-01-01"];
        [self.datePicker setMinimumDate:minDate];
        
        NSDate* maxDate = [NSDate date];
        [self.datePicker setMaximumDate:maxDate];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        self.dateView.frame = CGRectMake(0, screenRect.size.height - 250, self.view.frame.size.width, 250);
    }];
}

//隐藏日期
-(void)hideDateView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, screenRect.size.height);
        self.dateView.frame = CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250);
    }];
}

//取消选择日期
-(void)clickedDateViewCancelButton:(UIButton* )sender {
    [self hideDateView];
}

//确定选择日期
-(void)clickedDateViewSureButton:(UIButton* )sender {
    NSDate *date = self.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* str = [dateFormatter stringFromDate:date];
    
    [self hideDateView];
    
    if ([str isEqualToString:self.centerBirthday]) {
        return;
    }
    
    self.centerBirthday = str;
    
    RegUserBuilder* regBuilder = [RegUser builder];
    [regBuilder setBirthday:str];
    //
    RegUser* tempUser = [self buildRegUserWithRegUserBuilder:regBuilder];
    [self updateUserInfoWithUser:tempUser];
}

//获取地区数据
-(void)loadPlacePickerViewData {
    if (self.provinceArray.count > 0) {
        [self showPlacePickerView];
        return;
    }
    
    [self showNetworkLoadingView];
    __weak LMProfileCenterViewController* weakSelf = self;
    
    ProvinceCityReqBuilder* builder = [ProvinceCityReq builder];
    ProvinceCityReq* req = [builder build];
    
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:15 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 15) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        ProvinceCityRes* res = [ProvinceCityRes parseFromData:apiRes.body];
                        NSArray* arr = res.provinces;
                        NSArray* arr2 = res.citys;
                        if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                            weakSelf.cityDic = [NSMutableDictionary dictionary];
                            for (NSInteger i = 0; i < arr.count; i ++) {
                                Province* provice = [arr objectAtIndex:i];
                                UInt32 proviceId = provice.id;
                                NSMutableArray* tempCityArr = [NSMutableArray array];
                                for (City* city in arr2) {
                                    if (proviceId == city.provinceId) {
                                        [tempCityArr addObject:city];
                                    }
                                }
                                if (tempCityArr.count > 0) {
                                    [weakSelf.cityDic setObject:tempCityArr forKey:[NSNumber numberWithUnsignedInt:proviceId]];
                                    if (i == 0) {
                                        weakSelf.cityArray = [tempCityArr mutableCopy];
                                    }
                                }
                            }
                            weakSelf.provinceArray = [NSMutableArray arrayWithArray:arr];
                        }
                        
                        [weakSelf showPlacePickerView];
                    }
                }
                
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            } @finally {
                
            }
        }
        
        [weakSelf hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

//选择地区
-(void)showPlacePickerView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.placeView) {
        self.placeView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250)];
        self.placeView.backgroundColor = [UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1];
        [self.view insertSubview:self.placeView aboveSubview:self.bgView];
        
        UIButton* cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(clickedPlacePickerViewCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.placeView addSubview:cancelBtn];
        
        UIButton* sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.placeView.frame.size.width - 50, 0, 50, 30)];
        [sureBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(clickedPlacePickerViewSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.placeView addSubview:sureBtn];
        
        self.placePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 220)];
        self.placePicker.dataSource = self;
        self.placePicker.delegate = self;
        [self.placeView addSubview:self.placePicker];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        self.placeView.frame = CGRectMake(0, screenRect.size.height - 250, self.view.frame.size.width, 250);
    }];
}

//隐藏 地区
-(void)hidePlacePickerView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, screenRect.size.height);
        self.placeView.frame = CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250);
    }];
}

//取消选择 地区
-(void)clickedPlacePickerViewCancelButton:(UIButton* )sender {
    [self hidePlacePickerView];
}

//选择 地区
-(void)clickedPlacePickerViewSureButton:(UIButton* )sender {
    NSInteger proviceInt = [self.placePicker selectedRowInComponent:0];
    NSInteger cityInt = [self.placePicker selectedRowInComponent:1];
    Province* province = [self.provinceArray objectAtIndex:proviceInt];
    City* city = [self.cityArray objectAtIndex:cityInt];
    
    NSString* str = [NSString stringWithFormat:@"%@-%@", province.name, city.name];
    
    [self hidePlacePickerView];
    
    if ([str isEqualToString:self.centerLocalArea]) {
        return;
    }
    self.centerLocalArea = str;
    
    RegUserBuilder* regBuilder = [RegUser builder];
    [regBuilder setLocalArea:str];
    //
    RegUser* tempUser = [self buildRegUserWithRegUserBuilder:regBuilder];
    [self updateUserInfoWithUser:tempUser];
}

#pragma mark -UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    }else if (component == 1) {
        return self.cityArray.count;
    }
    return 0;
}

#pragma mark -UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return @"省份";
    }else if (component == 1) {
        return @"城市";
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 30)];
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, vi.frame.size.height)];
    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentCenter;
    NSString* text = @"";
    if (component == 0) {
        Province* province = [self.provinceArray objectAtIndex:row];
        text = province.name;
    }else if (component == 1) {
        City* city = [self.cityArray objectAtIndex:row];
        text = city.name;
    }
    lab.text = text;
    [vi addSubview:lab];
    return vi;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        Province* provice = [self.provinceArray objectAtIndex:row];
        NSArray* arr = [self.cityDic objectForKey:[NSNumber numberWithUnsignedInt:provice.id]];
        if (arr.count > 0) {
            self.cityArray = [NSMutableArray arrayWithArray:arr];
            
            [self.placePicker reloadComponent:1];
        }
    }
}

//微信 登录成功
-(void)weChatDidLogin:(NSNotification* )notify {
    NSDictionary* dic = notify.userInfo;
    if (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
        
        [self showMBProgressHUDWithText:@"微信操作失败"];
        
        return;
    }
    NSString* codeStr = [dic objectForKey:weChatLoginKey];
    if (codeStr != nil && ![codeStr isKindOfClass:[NSNull class]] && codeStr.length > 0) {
        RegUserBuilder* userBuilder = [RegUser builder];
        [userBuilder setWx:@"1"];
        RegUser* regUser = [self buildRegUserWithRegUserBuilder:userBuilder];
        //
        [self bindWeChatOrQQWithUser:regUser tokenStr:codeStr isQQL:NO];
    }else {
        [self showMBProgressHUDWithText:@"微信操作失败"];
    }
}

#pragma mark -TencentSessionDelegate
-(void)tencentDidLogin {
    if (self.qqAuth.accessToken && [self.qqAuth.accessToken length] != 0) {
        RegUserBuilder* userBuilder = [RegUser builder];
        [userBuilder setQq:@"2"];
        RegUser* regUser = [self buildRegUserWithRegUserBuilder:userBuilder];
        //
        [self bindWeChatOrQQWithUser:regUser tokenStr:self.qqAuth.accessToken isQQL:YES];
        
    }else {
        [self showMBProgressHUDWithText:@"QQ操作失败"];
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled {
    [self showMBProgressHUDWithText:@"QQ操作失败"];
}

-(void)tencentDidNotNetWork {
    [self showMBProgressHUDWithText:@"QQ操作失败"];
}

-(void)getUserInfoResponse:(APIResponse *)response {
    
}


/** 绑定微信、qq
 *  @param user : user
 *  @param tokenStr 微信的code、qq的access_token
 */
-(void)bindWeChatOrQQWithUser:(RegUser* )user tokenStr:(NSString* )tokenStr isQQL:(BOOL )isQQ {
    [self showNetworkLoadingView];
    
    ThirdRegUserLoginReqBuilder* builder = [ThirdRegUserLoginReq builder];
    [builder setUser:user];
    [builder setCode:tokenStr];
    ThirdRegUserLoginReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMProfileCenterViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:34 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 34) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    ThirdRegUserLoginRes* res = [ThirdRegUserLoginRes parseFromData:apiRes.body];
                    LoginedRegUser* tempLogUser = res.loginedUser;
                    //保存登录用户信息
                    [LMTool saveLoginedRegUser:tempLogUser];
                    
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                    
                    if (isQQ) {
                        weakSelf.isBindQQ = YES;
                    }else {
                        weakSelf.isBindWeChat = YES;
                    }
                    //刷新
                    [weakSelf initLoginedUserData];
                    
                }else if (err == ErrCodeErrNotlogined) {//登录已过期
                    
                    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"操作已过期，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* sureAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [LMTool deleteLoginedRegUser];
                        
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        
                    }];
                    [controller addAction:sureAction];
                    [weakSelf presentViewController:controller animated:YES completion:nil];
                    
                }else if (err == ErrCodeErrQqexist) {
                    [weakSelf showMBProgressHUDWithText:@"该QQ号已经注册过"];
                }else if (err == ErrCodeErrWxexist) {
                    [weakSelf showMBProgressHUDWithText:@"该微信号已经注册过"];
                }else {//更改失败
                    [weakSelf showMBProgressHUDWithText:@"操作失败"];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        [weakSelf hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf hideNetworkLoadingView];
    }];
}

/** 通过RegUserBuilder组装RegUser
 *  @param userBuilder : userBuilder
 */
-(RegUser* )buildRegUserWithRegUserBuilder:(RegUserBuilder* )userBuilder {
    RegUser* regUser = self.loginedUser.user;
    
    if (![userBuilder hasUid]) {
        [userBuilder setUid:regUser.uid];
    }
    if (![userBuilder hasPhoneNum]) {
        [userBuilder setPhoneNum:regUser.phoneNum];
    }
    if (![userBuilder hasEmail]) {
        [userBuilder setEmail:regUser.email];
    }
    if (![userBuilder hasWx]) {
        [userBuilder setWx:regUser.wx];
    }
    if (![userBuilder hasGender]) {
        [userBuilder setGender:regUser.gender];
    }
    if (![userBuilder hasQq]) {
        [userBuilder setQq:regUser.qq];
    }
    if (![userBuilder hasBirthday]) {
        [userBuilder setBirthday:regUser.birthday];
    }
    if (![userBuilder hasNickname]) {
        [userBuilder setNickname:regUser.nickname];
    }
    if (![userBuilder hasLocalArea]) {
        [userBuilder setLocalArea:regUser.localArea];
    }
    if (![userBuilder hasRegisterTime]) {
        [userBuilder setRegisterTime:regUser.registerTime];
    }
    if (![userBuilder hasIcon]) {
        [userBuilder setIcon:regUser.icon];
    }
    if (![userBuilder hasSetpw]) {
        [userBuilder setSetpw:regUser.setpw];
    }
    if (![userBuilder hasIconB]) {
        [userBuilder setIconB:regUser.iconB];
    }
    if (![userBuilder hasWxNickname]) {
        [userBuilder setWxNickname:regUser.wxNickname];
    }
    if (![userBuilder hasQqNickname]) {
        [userBuilder setQqNickname:regUser.qqNickname];
    }
    
    RegUser* user = [userBuilder build];
    return user;
}

/** 更改用户信息
 *  @param user : user
 */
-(void)updateUserInfoWithUser:(RegUser* )user {
    [self showNetworkLoadingView];
    
    LoginedRegUserBuilder* builder = [LoginedRegUser builder];
    [builder setToken:self.loginedUser.token];
    [builder setUser:user];
    LoginedRegUser* tempLogUser = [builder build];
    
    __weak LMProfileCenterViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:20 regUser:tempLogUser ReqData:nil successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 20) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    //保存登录用户信息
                    [LMTool saveLoginedRegUser:tempLogUser];
                    
                    [weakSelf showMBProgressHUDWithText:@"更改成功"];
                    
                    //刷新
                    [weakSelf initLoginedUserData];
                    
                }else if (err == ErrCodeErrNotlogined) {//登录已过期
                    
                    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"操作已过期，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* sureAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [LMTool deleteLoginedRegUser];
                        
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                        
                    }];
                    [controller addAction:sureAction];
                    [weakSelf presentViewController:controller animated:YES completion:nil];
                    
                }else {//更改失败
                    [weakSelf showMBProgressHUDWithText:@"更改失败"];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        [weakSelf hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf hideNetworkLoadingView];
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:weChatLoginNotifyName object:nil];
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
