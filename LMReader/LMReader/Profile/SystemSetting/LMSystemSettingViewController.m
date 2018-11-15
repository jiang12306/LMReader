//
//  LMSystemSettingViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSystemSettingViewController.h"
#import "LMSystemSettingTableViewCell.h"
#import "LMTool.h"
#import "SDWebImageManager.h"
#import "LMDatabaseTool.h"
#import <UserNotifications/UserNotifications.h>
#import "JPUSHService.h"
#import "AppDelegate.h"

@interface LMSystemSettingViewController () <UITableViewDelegate, UITableViewDataSource, LMSystemSettingTableViewCellDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* titleArray;
@property (nonatomic, assign) NSUInteger memoryInt;
@property (nonatomic, assign) BOOL isAlert;
@property (nonatomic, assign) CGFloat isFont;
@property (nonatomic, assign) BOOL isDownload;
@property (nonatomic, assign) BOOL isLoadNext;

@property (nonatomic, assign) BOOL isNightShift;//夜间模式

@property (nonatomic, assign) BOOL allowedNotify;//系统级 用户是否禁止通知
@property (nonatomic, assign) BOOL isNotify;//app里 用户是否关闭通知

@end

@implementation LMSystemSettingViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"系统设置";
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMSystemSettingTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 65)];
        UIButton* loginOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, 15, footerView.frame.size.width - 60 * 2, 50)];
        loginOutBtn.backgroundColor = THEMEORANGECOLOR;
        loginOutBtn.layer.cornerRadius = 25;
        loginOutBtn.layer.masksToBounds = YES;
        [loginOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [loginOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginOutBtn addTarget:self action:@selector(clickedLoginOutButton:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:loginOutBtn];
        
        self.tableView.tableFooterView = footerView;
    }
    
    self.memoryInt = 0;
    
    [LMTool getSystemSettingConfig:^(BOOL alert, BOOL download, BOOL loadNext) {
        self.isAlert = alert;
        self.isDownload = download;
        self.isLoadNext = loadNext;
    }];
    
    self.isNightShift = [LMTool getSystemNightShift];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        SDImageCache* imageCache = manager.imageCache;
        self.memoryInt += [imageCache getSize];
        self.memoryInt += [imageCache getDiskCount];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* recordPath = [LMTool getBookRecordPath];
        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
        NSArray* recordArr = [tool queryBookReadRecordOver30Days];
        for (NSDictionary* dic in recordArr) {//删除保存的图书
            NSNumber* bookIdNum = [dic objectForKey:@"bookId"];
            if (bookIdNum != nil && ![bookIdNum isKindOfClass:[NSNull class]]) {
                UInt32 bookId = bookIdNum.intValue;
                NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
                NSString* bookPath = [recordPath stringByAppendingPathComponent:bookIdStr];
                BOOL isDir;
                if ([fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {//书本
                    NSDictionary* attributes = [fileManager attributesOfItemAtPath:bookPath error:nil];
                    NSNumber *sizeNumber = attributes[@"NSFileSize"];
                    self.memoryInt += sizeNumber.integerValue;
                }
                //图书目录
                NSData* catalogData = [LMTool unArchiveBookCatalogListWithBookId:bookId];
                if (catalogData != nil && ![catalogData isKindOfClass:[NSNull class]]) {
                    self.memoryInt += catalogData.length;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* indexpath = [NSIndexPath indexPathForRow:1 inSection:0];
            NSArray* arr = @[indexpath];
            [self.tableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
        });
    });
    
    self.titleArray = [NSMutableArray arrayWithObjects:@"夜间模式", @"清理缓存", @"预加载下一章节", @"推送设置", nil];
    [self.tableView reloadData];
    
    //
    [self getUserNotificationSetting];
    
    //
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appDidBecomeActive:(NSNotification* )notify {
    [self getUserNotificationSetting];
}

-(void)getUserNotificationSetting {
    [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        
        self.allowedNotify = YES;
        self.isNotify = [LMTool getUserNotificatioinState];
        
        UNAuthorizationStatus notifyState = settings.authorizationStatus;
        if (notifyState == UNAuthorizationStatusDenied) {
            self.allowedNotify = NO;
            self.isNotify = NO;
        }else if (notifyState == UNAuthorizationStatusAuthorized) {
            
        }else {
            if (@available(iOS 12.0, *)) {
                if (notifyState == UNAuthorizationStatusProvisional) {
                    
                }
            }
        }
        
        [self.tableView reloadData];
        
        //
        [LMTool setupUserNotificatioinState:self.isNotify];
        
        if (self.isNotify) {
            [JPUSHService setAlias:[[LMTool uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                
            } seq:0];
        }else {
            [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                
            } seq:0];
        }
    }];
}

//退出登录
-(void)clickedLoginOutButton:(UIButton* )sender {
    if ([LMTool deleteLoginedRegUser]) {
        [self showMBProgressHUDWithText:@"退出成功"];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//前往系统设置
-(void)clickedJumpToSystemSettingButton:(UIButton* )sender {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else {
        [self showMBProgressHUDWithText:@"打开出错了。。。"];
    }
}

#pragma mark -UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.allowedNotify == NO) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(vi.frame.size.width - 90 - 10, 0, 90, vi.frame.size.height)];
        NSMutableAttributedString* attributedStr = [[NSMutableAttributedString alloc]initWithString:@"前往“设置”" attributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont systemFontOfSize:16]}];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(3, 2)];
        [btn setAttributedTitle:attributedStr forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickedJumpToSystemSettingButton:) forControlEvents:UIControlEventTouchUpInside];
        [vi addSubview:btn];
        return vi;
    }
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
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
    return 25;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMSystemSettingTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMSystemSettingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showLineView:NO];
    
    NSInteger row = indexPath.row;
    cell.nameLab.text = [self.titleArray objectAtIndex:row];
    
    cell.contentSwitch.hidden = YES;
    cell.contentLab.hidden = YES;
    cell.delegate = self;
    
    if (row == 0) {
        cell.contentSwitch.hidden = NO;
        cell.contentLab.hidden = YES;
        
        cell.contentSwitch.on = self.isNightShift;
    }else if (row == 1) {
        cell.contentSwitch.hidden = YES;
        cell.contentLab.hidden = NO;
        
        cell.contentLab.text = [NSString stringWithFormat:@"%.2fMB", ((float)self.memoryInt)/1024/1024];
    }else if (row == 2) {
        cell.contentSwitch.hidden = NO;
        cell.contentLab.hidden = YES;
        
        cell.contentSwitch.on = self.isLoadNext;
    }else if (row == 3) {
        cell.contentSwitch.hidden = NO;
        cell.contentLab.hidden = YES;
        
        BOOL shouldOn = NO;
        if (self.allowedNotify) {
            if (self.isNotify) {
                shouldOn = YES;
            }
        }
        cell.contentSwitch.on = shouldOn;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        
    }else if (row == 1) {
        [self showNetworkLoadingView];
        
        SDWebImageManager* manager = [SDWebImageManager sharedManager];
        SDImageCache* imageCache = manager.imageCache;
        [imageCache clearMemory];
        [imageCache clearDiskOnCompletion:^{
            
        }];
        
        self.memoryInt = 0;
        LMSystemSettingTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.contentLab.text = [NSString stringWithFormat:@"%.2fMB", ((float)self.memoryInt)/1024/1024];
        
        
        //添加子线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray* allBookPathArr = [LMTool queryAllBookDirectory];//所有图书目录
            NSArray* bookShelfArr = [[LMDatabaseTool sharedDatabaseTool] queryAllUserBooks];
            for (NSString* subBookPath in allBookPathArr) {
                NSString* bookNameStr = [[subBookPath componentsSeparatedByString:@"/"] lastObject];
                @try {
                    int subBookId = bookNameStr.intValue;
                    BOOL hasCollect = NO;
                    for (UserBook* userBook in bookShelfArr) {
                        UInt32 shelfBookId = userBook.book.bookId;
                        if (subBookId == shelfBookId) {
                            hasCollect = YES;
                            break;
                        }
                    }
                    if (!hasCollect) {//删除未加入书架、但是已经缓存的图书
                        [LMTool deleteBookWithBookId:subBookId];
                    }
                } @catch (NSException *exception) {
                    continue;
                } @finally {
                    
                }
            }
            
            //清理30天以上阅读记录
            LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
            NSArray* recordArr = [tool queryBookReadRecordOver30Days];
            for (NSDictionary* dic in recordArr) {//删除保存的图书
                NSNumber* bookIdNum = [dic objectForKey:@"bookId"];
                if (bookIdNum != nil && ![bookIdNum isKindOfClass:[NSNull class]]) {
                    UInt32 bookId = bookIdNum.intValue;
                    [LMTool deleteBookWithBookId:bookId];//删除章节内容
                    
                    //删除章节目录
                    [LMTool deleteArchiveBookCatalogListWithBookId:bookId];
                    [LMTool deleteArchiveBookNewParseCatalogListWithBookId:bookId];
                }
            }
            //阅读记录
            [tool deleteBookReadRecordOver30Days];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideNetworkLoadingView];
                [self showMBProgressHUDWithText:@"清理完成"];
            });
        });
    }else if (row == 2) {
        
    }else if (row == 3) {
        
    }
}

#pragma mark -LMSystemSettingTableViewCellDelegate
-(void)didClickSwitch:(BOOL)isOn systemSettingCell:(LMSystemSettingTableViewCell *)cell {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    if (row == 0) {//夜间模式
        self.isNightShift = isOn;
        cell.contentSwitch.on = self.isNightShift;
        
        [LMTool changeSystemNightShift:self.isNightShift];
        
        AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
        [appDelegate updateSystemNightShift];
    }else if (row == 1) {//清理缓存
        
    }else if (row == 2) {//预加载下一章节
        self.isLoadNext = isOn;
        cell.contentSwitch.on = self.isLoadNext;
        
        [LMTool changeSystemSettingWithAlert:self.isAlert download:self.isDownload loadNext:self.isLoadNext];
    }else if (row == 3) {//推送
        if (self.isNotify == YES) {
            self.isNotify = NO;
            [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                
            } seq:0];
        }else {
            self.isNotify = YES;
            [JPUSHService setAlias:[[LMTool uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                
            } seq:0];
        }
        [LMTool setupUserNotificatioinState:self.isNotify];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
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
