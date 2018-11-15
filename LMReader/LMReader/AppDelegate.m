//
//  AppDelegate.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "AppDelegate.h"
#import "LMRootViewController.h"
#import "LMSplashAdView.h"
#import "LMTool.h"
#import <Bugly/Bugly.h>
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <ShareSDK/ShareSDK.h>
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/TencentOAuth.h>//qq
#import <TencentOpenAPI/QQApiInterface.h>
#import "LMBookDetailViewController.h"
#import "WXApi.h"//微信
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "LMShareMessage.h"
#import "GDTSplashAd.h"
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>

@interface AppDelegate () <JPUSHRegisterDelegate, WXApiDelegate, GDTSplashAdDelegate, BaiduMobAdSplashDelegate>

@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) BaiduMobAdSplash* splash;
@property (nonatomic, strong) UIView* customSplashView;


@end

@implementation AppDelegate

//用户id，全局唯一标识，切换登录账号时跟着变
-(NSString *)userId {
    NSString* uuidStr = [LMTool getAppUserId];
    return uuidStr;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //JPush
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:@"b76ea27093341076921e0ed8" channel:@"App Store" apsForProduction:NO advertisingIdentifier:advertisingId];
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (resCode == 0) {
            NSLog(@"registrationID获取成功：%@",registrationID);
        }else {
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    //WeChat
    [WXApi registerApp:weChatAppId];
    
    //UMeng
    [UMConfigure setEncryptEnabled:YES];
    [MobClick setScenarioType:E_UM_NORMAL];
    [MobClick setCrashReportEnabled:YES];
    [UMConfigure initWithAppkey:@"5ac32cdef29d980653000140" channel:@"App Store"];
    
    
    
    //bugly集成
    [Bugly startWithAppId:@"be3c044061"];
    
    //清理启动次数
//    [LMTool clearLaunchCount];
    
    //初始化用户数据
    [LMTool initFirstLaunchData];
    
    
    UIWindow* window = [[UIWindow alloc]init];
    window.frame = [UIScreen mainScreen].bounds;
    window.backgroundColor = [UIColor whiteColor];
    self.window = window;
    
    LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
    
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    if ([LMTool isFirstLaunch]) {
        
    }else {
        if (@available(iOS 9.0, *)) {
            UIApplicationShortcutItem *shoreItem1 = [[UIApplicationShortcutItem alloc] initWithType:@"com.tkmob.LMReader.Search" localizedTitle:@"搜索" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
            
            UIApplicationShortcutItem *shoreItem2 = [[UIApplicationShortcutItem alloc] initWithType:@"com.tkmob.LMReader.Choice" localizedTitle:@"精选" localizedSubtitle:@"" icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"shortcutItem_Choice"] userInfo:nil];
            [UIApplication sharedApplication].shortcutItems = @[shoreItem1, shoreItem2];
        }
        
        //解压广告开关
        NSData* adData = [LMTool unArchiveAdvertisementSwitchData];
        if (adData != nil && ![adData isKindOfClass:[NSNull class]] && adData.length > 0) {
            InitSwitchRes* res = [InitSwitchRes parseFromData:adData];
            BOOL showSplashAd = NO;
            NSInteger adType = 0;
            for (AdControl* subControl in res.adControl) {
                if (subControl.adlId == 1 && subControl.state == 1) {//显示开屏
                    showSplashAd = YES;
                    
                    adType = subControl.adPt;
                    break;
                }
            }
            if (showSplashAd) {
                if (adType == 1) {//自家开屏广告
                    LMSplashAdView* splashView = [[LMSplashAdView alloc]init];
                    splashView.clickBlock = ^(BOOL isBook, NSString* bookIdStr, NSString * _Nonnull urlStr) {
                        if (isBook) {
                            LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
                            [rootVC openViewControllerCalss:@"LMBookDetailViewController" paramString:bookIdStr];
                        }else {
                            if ([urlStr rangeOfString:@"itunes.apple.com"].location != NSNotFound) {
                                NSString* encodeStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                                NSURL* encodeUrl = [NSURL URLWithString:encodeStr];
                                if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                                    [[UIApplication sharedApplication] openURL:encodeUrl options:@{} completionHandler:^(BOOL success) {
                                        
                                    }];
                                }
                            }else {
                                //打开广告页详情
                                [rootVC openViewControllerCalss:@"LMLaunchDetailViewController" paramString:urlStr];
                            }
                        }
                    };
                    [self.window addSubview:splashView];
                }else if (adType == 2) {//百度广告
                    self.splash = [[BaiduMobAdSplash alloc] init];
                    self.splash.delegate = self;
                    self.splash.AdUnitTag = @"5919589";
                    self.splash.canSplashClick = YES;
                    //可以在customSplashView上显示包含icon的自定义开屏
                    self.customSplashView = [[UIView alloc]initWithFrame:self.window.frame];
                    self.customSplashView.backgroundColor = [UIColor whiteColor];
                    [self.window addSubview:self.customSplashView];
                    
                    CGFloat slogonViewHeight = [[UIScreen mainScreen] bounds].size.height / 6;
                    if (slogonViewHeight < 110) {
                        slogonViewHeight = 110;
                    }
                    CGFloat slogonLabHeight = 30;
                    UIImageView *logoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
                    logoIV.frame = CGRectMake(0, 0, 60, 60);
                    logoIV.center = CGPointMake(self.customSplashView.frame.size.width /  2, self.customSplashView.frame.size.height - slogonViewHeight + (slogonViewHeight - slogonLabHeight) / 2);
                    [self.customSplashView addSubview:logoIV];
                    UILabel* slogonLab = [[UILabel alloc] initWithFrame:CGRectMake(0, logoIV.frame.origin.y + logoIV.frame.size.height, [UIScreen mainScreen].bounds.size.width, 30)];
                    slogonLab.font = [UIFont boldSystemFontOfSize:18];
                    slogonLab.textAlignment = NSTextAlignmentCenter;
                    slogonLab.text = @"海量小说  尽情阅读";
                    [self.customSplashView addSubview:slogonLab];
                    
                    UIView * baiduSplashContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.customSplashView.frame.size.width, self.customSplashView.frame.size.height - slogonViewHeight)];
                    [self.customSplashView addSubview:baiduSplashContainer];
                    //在的baiduSplashContainer里展现百度广告
                    [self.splash loadAndDisplayUsingContainerView:baiduSplashContainer];
                }else {//广点通 开屏广告 if (adType == 0)
                    CGFloat bottomViewHeight = [[UIScreen mainScreen] bounds].size.height / 6;
                    if (bottomViewHeight < 110) {
                        bottomViewHeight = 110;
                    }
                    CGFloat slogonLabHeight = 30;
                    self.splashAd = [[GDTSplashAd alloc] initWithAppId:tencentGDTAPPID placementId:tencentGDTSplashPlacementID];
                    self.splashAd.delegate = self;
                    self.splashAd.fetchDelay = 3;
                    self.splashAd.backgroundImage = [UIImage imageNamed:@"defaultFirstLaunch"];
                    
                    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - bottomViewHeight, [[UIScreen mainScreen] bounds].size.width, bottomViewHeight)];
                    self.bottomView.backgroundColor = [UIColor whiteColor];
                    UIImageView *logoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
                    logoIV.frame = CGRectMake(0, 0, 60, 60);
                    logoIV.center = CGPointMake(self.bottomView.frame.size.width /  2, (self.bottomView.frame.size.height - slogonLabHeight) / 2);
                    [self.bottomView addSubview:logoIV];
                    UILabel* slogonLab = [[UILabel alloc] initWithFrame:CGRectMake(0, logoIV.frame.origin.y + logoIV.frame.size.height, [UIScreen mainScreen].bounds.size.width, 30)];
                    slogonLab.font = [UIFont boldSystemFontOfSize:18];
                    slogonLab.textAlignment = NSTextAlignmentCenter;
                    slogonLab.text = @"海量小说  尽情阅读";
                    [self.bottomView addSubview:slogonLab];
                    
                    [self.splashAd loadAdAndShowInWindow:self.window withBottomView:self.bottomView skipView:nil];
                }
            }
        }
        
        //获取广告开关
        LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
        [networkTool postWithCmd:40 ReqData:nil successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 40) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        [LMTool archiveAdvertisementSwitchData:apiRes.body];
                    }
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {
            
        }];
    }
    
    
    //增加统计次数
    [LMTool incrementLaunchCount];
    
    
    return YES;
}

//更新 夜间、日间模式
-(void)updateSystemNightShift {
    BOOL isNight = [LMTool getSystemNightShift];
    if (isNight) {
        BOOL didContain = NO;
        for (CALayer* subLayer in self.window.layer.sublayers) {
            NSString* layerName = subLayer.name;
            if (layerName != nil && [layerName isKindOfClass:[NSString class]] && [layerName isEqualToString:AppSystemNightShift]) {
                didContain = YES;
                break;
            }
        }
        if (!didContain) {
            CGRect screenRect = [UIScreen mainScreen].bounds;
            CALayer* brightnessLayer = [CALayer layer];
            brightnessLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            brightnessLayer.name = AppSystemNightShift;
            brightnessLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
            brightnessLayer.zPosition = 0;
            [self.window.layer addSublayer:brightnessLayer];
        }
    }else {
        for (CALayer* subLayer in self.window.layer.sublayers) {
            NSString* layerName = subLayer.name;
            if (layerName != nil && [layerName isKindOfClass:[NSString class]] && [layerName isEqualToString:AppSystemNightShift]) {
                [subLayer removeFromSuperlayer];
            }
        }
    }
}

//夜间模式时，将layer置顶
-(void)bringSystemNightShiftToFront {
    BOOL isNight = [LMTool getSystemNightShift];
    if (isNight) {
        BOOL didContain = NO;
        CALayer* nightLayer = nil;
        for (CALayer* subLayer in self.window.layer.sublayers) {
            NSString* layerName = subLayer.name;
            if (layerName != nil && [layerName isKindOfClass:[NSString class]] && [layerName isEqualToString:AppSystemNightShift]) {
                didContain = YES;
                nightLayer = subLayer;
                break;
            }
        }
        if (didContain && nightLayer != nil) {
            nightLayer.zPosition = 1;
        }
    }
}

//夜间模式时，将layer放底下 否则会覆盖广告
-(void)sendSystemNightShiftToback {
    BOOL isNight = [LMTool getSystemNightShift];
    if (isNight) {
        BOOL didContain = NO;
        CALayer* nightLayer = nil;
        for (CALayer* subLayer in self.window.layer.sublayers) {
            NSString* layerName = subLayer.name;
            if (layerName != nil && [layerName isKindOfClass:[NSString class]] && [layerName isEqualToString:AppSystemNightShift]) {
                didContain = YES;
                nightLayer = subLayer;
                break;
            }
        }
        if (didContain && nightLayer != nil) {
            nightLayer.zPosition = 0;
        }
    }
}

-(void)removeSplash {
    if (self.splash) {
        self.splash.delegate = nil;
        self.splash = nil;
        [self.customSplashView removeFromSuperview];
    }
}

- (NSString *)publisherId {
    return @"ae019302";
}

-(BOOL)enableLocation {
    return NO;
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidClicked");
    
    [self removeSplash];
}

- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidDismissLp");
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidDismissScreen");
    
    [self removeSplash];
}

- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"splashSuccessPresentScreen");
    
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    [builder setAdlId:1];
    [builder setAdPt:2];
    AdShowedLogReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:42 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 42) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                [LMTool archiveAdvertisementSwitchData:apiRes.body];
            }
        }
    } failureBlock:^(NSError *failureError) {
        
    }];
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    NSLog(@"splashlFailPresentScreen withError %d", reason);
    
    [self removeSplash];
}




-(UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

//3D Touch
-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler NS_AVAILABLE_IOS(9_0) {
    @ try {
        if ([LMTool isFirstLaunch]) {
            return;
        }
        NSString* typeStr = shortcutItem.type;
        LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
        if ([typeStr isEqualToString:@"com.tkmob.LMReader.Search"]) {
            [rootVC openViewControllerCalss:@"LMSearchViewController" paramString:nil];
        }else if ([typeStr isEqualToString:@"com.tkmob.LMReader.Choice"]) {
            [rootVC openViewControllerCalss:@"LMChoiceViewController" paramString:nil];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark -WXApiDelegate
-(void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {//登录
        SendAuthResp* authResp = (SendAuthResp* )resp;
        if ([authResp.state isEqualToString:weChatLoginState] && authResp.errCode == 0) {
            NSString* codeStr = authResp.code;
            //发通知
            NSDictionary* infoDic = @{weChatLoginKey: codeStr};
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatLoginNotifyName object:nil userInfo:infoDic];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatLoginNotifyName object:nil userInfo:nil];
        }
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {//分享
        SendMessageToWXResp* wxResp = (SendMessageToWXResp* )resp;
        if (wxResp.errCode == 0) {
            NSDictionary* infoDic = @{weChatShareKey : [NSNumber numberWithBool:YES]};
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatShareNotifyName object:nil userInfo:infoDic];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatShareNotifyName object:nil userInfo:nil];
        }
    }
}

//iOS  9.0 before
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"11111111111url : %@",url);
    
    //WeChat
    [WXApi handleOpenURL:url delegate:self];
    
    //QQ
    [TencentOAuth HandleOpenURL:url];
    //QQZone
    //    [QQApiInterface handleOpenURL:url delegate:self];
    LMShareMessage* shareMsg = [[LMShareMessage alloc]init];
    [shareMsg qqHandleOpenURL:url delegate:shareMsg];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    //WeChat
    [WXApi handleOpenURL:url delegate:self];
    
    //QQ
    [TencentOAuth HandleOpenURL:url];
    //QQZone
    //    [QQApiInterface handleOpenURL:url delegate:self];
    LMShareMessage* shareMsg = [[LMShareMessage alloc]init];
    [shareMsg qqHandleOpenURL:url delegate:shareMsg];
    
    return YES;
}

//iOS 9.0 later
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if (@available(iOS 9.0, *)) {
        NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
        NSLog(@"sourceApplication : %@",sourceApplication);
    }
    
    //WeChat
    [WXApi handleOpenURL:url delegate:self];
    
    //QQ
    [TencentOAuth HandleOpenURL:url];
    //QQZone
    LMShareMessage* shareMsg = [[LMShareMessage alloc]init];
    [shareMsg qqHandleOpenURL:url delegate:shareMsg];
    
    //打开指定书籍
    NSString* paramsStr = [url query];
    if (paramsStr != nil && ![paramsStr isKindOfClass:[NSNull class]] && paramsStr.length > 0) {
        if ([paramsStr rangeOfString:@"bookId"].location != NSNotFound) {
            NSString* bookIdStr = nil;
            NSArray* paramsArr = [paramsStr componentsSeparatedByString:@"&"];
            for (NSString* subStr in paramsArr) {
                NSRange equalRange = [subStr rangeOfString:@"="];
                if (equalRange.location != NSNotFound && (equalRange.location + equalRange.length < subStr.length)) {
                    bookIdStr = [subStr substringFromIndex:(equalRange.location + equalRange.length)];
                    break;
                }
            }
            if (bookIdStr != nil && ![bookIdStr isKindOfClass:[NSNull class]] && bookIdStr.length > 0) {
                LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
                [rootVC openViewControllerCalss:@"LMBookDetailViewController" paramString:bookIdStr];
            }
        }
    }
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //
    [LMTool setupUserNotificatioinState:YES];
    
    [JPUSHService registerDeviceToken:deviceToken];
    
    //设置alias
    [JPUSHService setAlias:[[LMTool uuid] stringByReplacingOccurrencesOfString:@"-" withString:@""] completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:0];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //
    [LMTool setupUserNotificatioinState:NO];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^) (UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request;
    // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    @try {
        NSDictionary* userInfoDic = content.userInfo;
        if (userInfoDic != nil && ![userInfoDic isKindOfClass:[NSNull class]] && userInfoDic.count > 0) {
            NSNumber* num = [userInfoDic objectForKey:@"bookId"];
            NSString* bookIdStr = [NSString stringWithFormat:@"%@", num];
            
            if (bookIdStr != nil && ![bookIdStr isKindOfClass:[NSNull class]] && bookIdStr.length > 0) {
                
                LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
                [rootVC openViewControllerCalss:@"LMBookDetailViewController" paramString:bookIdStr];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif


- (void)applicationWillResignActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




#pragma mark GDTSplashAdDelegate
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
    
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    [builder setAdlId:1];
    [builder setAdPt:0];
    AdShowedLogReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:42 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 42) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                [LMTool archiveAdvertisementSwitchData:apiRes.body];
            }
        }
    } failureBlock:^(NSError *failureError) {
        
    }];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    
    //更新 夜间、日间模式
    [self updateSystemNightShift];
    
    NSLog(@"%s%@",__FUNCTION__,error);
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdWillClosed:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    
    //更新 夜间、日间模式
    [self updateSystemNightShift];
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}

- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd {
    NSLog(@"%s",__FUNCTION__);
}


@end
