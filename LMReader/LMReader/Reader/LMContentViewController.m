//
//  LMContentViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/31.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMContentViewController.h"
#import "LMTool.h"
#import "GDTNativeExpressAd.h"

@interface LMContentViewController () <GDTNativeExpressAdDelegete, BaiduMobAdInterstitialDelegate, BaiduMobAdViewDelegate>

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;//

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel* titleLab;//章节名label
@property (nonatomic, strong) UILabel* pageCountLab;//页数label
@property (nonatomic, strong) UILabel* chapterCountLab;//进度label
@property (nonatomic, strong) UILabel* timeLab;//时间label
@property (nonatomic, strong) UIImageView* battaryIV;//电池imageView
@property (nonatomic, strong) UILabel* battaryLab;//电量label

@end

@implementation LMContentViewController

-(instancetype)initWithReadModel:(LMReadModel)readModel fontSize:(CGFloat)fontSize content:(NSString *)content {
    self = [super init];
    if (self) {
        self.readModel = readModel;
        self.fontSize = fontSize;
        self.content = content;
    }
    return self;
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.sharedAdView) {
        [self.sharedAdView removeFromSuperview];
        self.sharedAdView.delegate = nil;
        self.sharedAdView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 9.0, *)) {
        
    }else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    self.contentLabel = [[UILabel alloc]initWithFrame:contentLabRect];
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.contentLabel.numberOfLines = 0;
    UIColor* textColor = [UIColor blackColor];
    if (self.readModel == LMReaderBackgroundType1) {
        self.view.backgroundColor = [UIColor colorWithRed:226/255.f green:210/255.f blue:178/255.f alpha:1];
        textColor = [UIColor colorWithRed:35.f/255 green:35.f/255 blue:35.f/255 alpha:1];
    }else if (self.readModel == LMReaderBackgroundType2) {
        self.view.backgroundColor = [UIColor colorWithRed:177/255.f green:198/255.f blue:200/255.f alpha:1];
        textColor = [UIColor colorWithRed:12/255.f green:30/255.f blue:12/255.f alpha:1];
    }else if (self.readModel == LMReaderBackgroundType3) {
        self.view.backgroundColor = [UIColor colorWithRed:199/255.f green:167/255.f blue:166/255.f alpha:1];
        textColor = [UIColor colorWithRed:47/255.f green:26/255.f blue:19/255.f alpha:1];
    }else if (self.readModel == LMReaderBackgroundType4) {
        self.view.backgroundColor = [UIColor colorWithRed:24/255.f green:24/255.f blue:24/255.f alpha:1];
        textColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:1];
    }
    [self.view addSubview:self.contentLabel];
    
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc]init];
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.lineSpacing = self.lineSpace;
    if (self.content != nil && ![self.content isKindOfClass:[NSNull class]] && self.content.length > 0) {
        self.content = [self.content stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];//去掉尾部换行
        NSAttributedString* attributeStr = [[NSAttributedString alloc]initWithString:self.content attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.fontSize], NSParagraphStyleAttributeName : paraStyle, NSForegroundColorAttributeName : textColor, NSKernAttributeName:@(1)}];
        
        self.contentLabel.attributedText = attributeStr;
        
        [self.contentLabel sizeToFit];
    }
    
    if (self.titleStr != nil) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, contentNaviHeight - 44, contentScreenWidth - 10 * 2, 44)];
        self.titleLab.font = [UIFont systemFontOfSize:14];
        self.titleLab.text = self.titleStr;
        self.titleLab.textColor = textColor;
        [self.view addSubview:self.titleLab];
    }
    
    //如果文本内容覆盖进度文字，将进度文字下移
    CGFloat countStartX = 10;
    CGFloat countStartY = contentScreenHeight - 30;
    CGFloat adWidth = contentScreenWidth - 20;//广告图片宽度
    CGFloat adHeight = adWidth * contentTencentInnerAdScale;//广告图片+文字总高度
    if (self.adFromWhich == 1) {//自家内嵌广告高度
        adHeight = adWidth * contentSelfInnerAdScale;
    }else if (self.adFromWhich == 2) {//百度内嵌广告高度
        adHeight = adWidth * contentBaiduInnerAdScale;
    }
    if ([LMTool isBangsScreen]) {
        countStartX = 44;
        countStartY = contentScreenHeight - 44;
    }
    CGFloat textLabHeight = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height;
    if (textLabHeight > countStartY) {//如果内容高度超过预定，显示页数label对应下移
        countStartY = textLabHeight;
    }
    
    if (self.shouldShowAd) {
        CGRect tempAdRect = CGRectMake(10, textLabHeight + 10, contentScreenWidth - 20, adHeight);
        NSString* tencentAdPlaceId = tencentGDTNativeExpressPlacementID;
        if (self.adType == 2) {
            adHeight = adWidth * contentTencentInsertAdScale;
            if (self.adFromWhich == 1) {//自家插屏广告高度
                adHeight = adWidth * contentSelfInsertAdScale;
            }else if (self.adFromWhich == 2) {//百度插屏广告高度
                adHeight = adWidth * contentBaiduInsertAdScale;
            }
            tempAdRect.origin.y = (contentScreenHeight - adHeight) / 2;
            tempAdRect.size.height = adHeight;
            tencentAdPlaceId = tencentGDTNativeExpressSplashPlacementID;
        }
        if (self.adFromWhich == 1) {//自家广告
            LMReaderContentAdView* adView = [[LMReaderContentAdView alloc]initWithFrame:tempAdRect adType:self.adType];
            __weak LMReaderContentAdView* weakAdView = adView;
            __weak LMContentViewController* weakSelf = self;
            adView.loadBlock = ^(BOOL loadSucceed) {
                if (loadSucceed) {
                    [weakAdView startShow];
                    
                    [weakSelf.view addSubview:weakAdView];
                    weakSelf.ownerAdView = weakAdView;
                }
            };
            adView.closeBlock = ^(BOOL didClose) {
                if (didClose) {
                    weakSelf.ownerAdView = nil;
                }
            };
            adView.clickBlock = ^(BOOL isBook, NSString * _Nonnull bookIdStr, NSString * _Nonnull urlStr) {
                if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(didClickedAdViewIsBook:bookIdStr:urlStr:)]) {
                    [weakSelf.delegate didClickedAdViewIsBook:isBook bookIdStr:bookIdStr urlStr:urlStr];
                }
            };
        }else if (self.adFromWhich == 2) {//百度广告
            if (self.adType == 1) {
                if (self.sharedAdView) {
                    [self.sharedAdView removeFromSuperview];
                    self.sharedAdView.delegate = nil;
                    self.sharedAdView = nil;
                }
                //使用嵌入广告的方法实例。
                self.sharedAdView = [[BaiduMobAdView alloc] init];
                self.sharedAdView.AdUnitTag = @"5925318";
                self.sharedAdView.AdType = BaiduMobAdViewTypeBanner;
                self.sharedAdView.frame = tempAdRect;
                [self.view addSubview:self.sharedAdView];
                
                self.sharedAdView.delegate = self;
                [self.sharedAdView start];
            }else if (self.adType == 2) {
                self.initerstitialAdContainer = [[UIView alloc]initWithFrame:tempAdRect];
                self.initerstitialAdContainer.backgroundColor = [UIColor clearColor];
                [self.view addSubview:self.initerstitialAdContainer];
                
                self.interstitialAdView = [[BaiduMobAdInterstitial alloc]init];
                self.interstitialAdView.AdUnitTag = @"5919987";
                self.interstitialAdView.delegate = self;
                self.interstitialAdView.interstitialType = BaiduMobAdViewTypeInterstitialPauseVideo;
                [self.interstitialAdView loadUsingSize:tempAdRect];
            }
        }else {//腾讯广告  默认
            self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:tencentGDTAPPID placementId:tencentAdPlaceId adSize:tempAdRect.size];
            self.nativeExpressAd.delegate = self;
            [self.nativeExpressAd loadAd:1];
        }
    }
    
    if (self.pageProgress != nil) {
        self.pageCountLab = [[UILabel alloc]initWithFrame:CGRectMake(countStartX, countStartY, 100, 20)];
        self.pageCountLab.font = [UIFont systemFontOfSize:14];
        self.pageCountLab.numberOfLines = 0;
        self.pageCountLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.pageCountLab.text = self.pageProgress;
        self.pageCountLab.textAlignment = NSTextAlignmentLeft;
        self.pageCountLab.textColor = textColor;
        CGSize countSize = [self.pageCountLab sizeThatFits:CGSizeMake(9999, 20)];
        if (countSize.width > contentScreenWidth / 2) {
            countSize.width = contentScreenWidth / 2;
        }
        self.pageCountLab.frame = CGRectMake(countStartX, countStartY, countSize.width, 20);
        [self.view addSubview:self.pageCountLab];
    }
    if (self.chapterProgress != nil) {
        self.chapterCountLab = [[UILabel alloc]initWithFrame:CGRectMake(self.pageCountLab.frame.origin.x + self.pageCountLab.frame.size.width + 10, self.pageCountLab.frame.origin.y, 80, 20)];//+20 往下移20，否则底部间距太大
        self.chapterCountLab.font = [UIFont systemFontOfSize:14];
        self.chapterCountLab.text = self.chapterProgress;
        self.chapterCountLab.textColor = textColor;
        CGSize countSize = [self.chapterCountLab sizeThatFits:CGSizeMake(9999, 20)];
        if (countSize.width > contentScreenWidth / 2) {
            countSize.width = contentScreenWidth / 2;
        }
        self.chapterCountLab.frame = CGRectMake(self.pageCountLab.frame.origin.x + self.pageCountLab.frame.size.width + 10, self.pageCountLab.frame.origin.y, countSize.width, 20);
        [self.view addSubview:self.chapterCountLab];
    }
    
    CGFloat battaryWidth = 20;
    CGFloat battaryHeight = 10;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(batteryLevelChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(batteryStateChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    UIDevice* device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    //电量
    CGFloat battaryLevel = device.batteryLevel;
    self.battaryLab = [[UILabel alloc]initWithFrame:CGRectMake(contentScreenWidth - 20 - countStartX, self.pageCountLab.frame.origin.y + 6.5, (battaryWidth - 5) * battaryLevel, 7)];
    UIColor* battaryColor = [UIColor colorWithRed:40 / 255.f green:200 / 255.f blue:60 / 255.f alpha:1];
    if (battaryLevel >= 0 && battaryLevel <= 0.2) {
        battaryColor = [UIColor redColor];
    }else if (battaryLevel > 0.2 && battaryLevel <= 0.3) {
        battaryColor = [UIColor colorWithRed:1 green:190 / 255.f blue:10 / 255.f alpha:1];
    }
    self.battaryLab.backgroundColor = battaryColor;
    [self.view addSubview:self.battaryLab];
    //电池
    self.battaryIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.battaryLab.frame.origin.x - 1.5, self.pageCountLab.frame.origin.y + 5, battaryWidth, battaryHeight)];
    NSString* battaryImageStr = @"battary_Normal";
    if (device.batteryState == UIDeviceBatteryStateCharging) {
        battaryImageStr = @"battary_Charge";
    }
    self.battaryIV.tintColor = textColor;
    self.battaryIV.image = [[UIImage imageNamed:battaryImageStr] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.view addSubview:self.battaryIV];
    
    
    //时间
    NSDate* nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString* nowDateStr = [dateFormatter stringFromDate:nowDate];
    self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.battaryIV.frame.origin.x - 60 - 5, self.pageCountLab.frame.origin.y, 60, 20)];
    self.timeLab.font = [UIFont systemFontOfSize:14];
    self.timeLab.textAlignment = NSTextAlignmentRight;
    self.timeLab.textColor = textColor;
    self.timeLab.text = nowDateStr;
    [self.view addSubview:self.timeLab];
}

//更新时间
-(void)resetupTime {
    NSDate* nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString* nowDateStr = [dateFormatter stringFromDate:nowDate];
    self.timeLab.text = nowDateStr;
}

//电池容量
-(void)batteryLevelChanged:(NSNotification* )notify {
    UIDevice* device = [UIDevice currentDevice];
    CGFloat battaryLevel = device.batteryLevel;
    CGRect battaryRect = self.battaryLab.frame;
    self.battaryLab = [[UILabel alloc]initWithFrame:CGRectMake(battaryRect.origin.x, battaryRect.origin.y, (self.battaryIV.frame.size.width - 5) * battaryLevel, battaryRect.size.height)];
    self.battaryIV.layer.borderColor = [UIColor clearColor].CGColor;
    UIColor* battaryColor = [UIColor colorWithRed:40 / 255.f green:200 / 255.f blue:60 / 255.f alpha:1];
    if (battaryLevel >= 0 && battaryLevel <= 0.2) {
        battaryColor = [UIColor redColor];
    }else if (battaryLevel > 0.2 && battaryLevel <= 0.3) {
        battaryColor = [UIColor colorWithRed:1 green:190 / 255.f blue:10 / 255.f alpha:1];
    }
    self.battaryLab.backgroundColor = battaryColor;
    
    [self resetupTime];
}

//电池状态
-(void)batteryStateChanged:(NSNotification* )notify {
    UIDevice* device = [UIDevice currentDevice];
    NSString* battaryImageStr = @"battary_Normal";
    if (device.batteryState == UIDeviceBatteryStateCharging) {
        battaryImageStr = @"battary_Charge";
    }
    self.battaryIV.image = [[UIImage imageNamed:battaryImageStr] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self resetupTime];
}

//点击“关闭”腾讯插屏广告
-(void)clickedCloseButton:(UIButton* )sender {
    [sender removeFromSuperview];
    [self.adView removeFromSuperview];
    self.adView.controller = nil;
    self.adView = nil;
}

#pragma mark - GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (views != nil && views.count > 0) {
        self.adView = [views firstObject];
        self.adView.controller = self;
        [self.adView render];
        
        CGFloat adHeight = (contentScreenWidth - 20) * contentTencentInsertAdScale;
        CGFloat adOriginY = (contentScreenHeight - adHeight) / 2;
        if (adOriginY < contentLabRect.origin.y) {
            adOriginY = contentLabRect.origin.y;
        }
        if (self.adType == 1) {
            adOriginY = self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + 10;
            adHeight = (contentScreenWidth - 20) * contentTencentInnerAdScale;
        }
        self.adView.frame = CGRectMake(10, adOriginY, contentScreenWidth - 20, adHeight);
        [self.view addSubview:self.adView];
        
        if (self.adType == 2) {//手动添加“关闭”按钮
            CGFloat closeBtnWidth = 40;
            CGRect closeRect = CGRectMake(self.adView.frame.origin.x + self.adView.frame.size.width - closeBtnWidth, self.adView.frame.origin.y, closeBtnWidth, closeBtnWidth);
            UIButton* closeBtn = [[UIButton alloc]initWithFrame:closeRect];
            [closeBtn setImage:[UIImage imageNamed:@"ad_Close_Background"] forState:UIControlStateNormal];
            [closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:closeBtn];
        }
        
        AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
        if (self.adType == 2) {
            [builder setAdlId:4];
        }else {
            [builder setAdlId:3];
        }
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
}

- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    NSLog(@"Express Ad Load Fail : %@",error);
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
    [self.adView removeFromSuperview];
    self.adView = nil;
}


#pragma mark -BaiduMobAdInterstitialDelegate
- (NSString *)publisherId {
    return baiduAdPublisherId;
}

- (BOOL) enableLocation {
    return NO;
}

- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"baiduAd:%s", __FUNCTION__);
    
    
    [self.interstitialAdView presentFromView:self.initerstitialAdContainer];
}

- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"baiduAd:%s", __FUNCTION__);
}

- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"baiduAd:%s", __FUNCTION__);
}

- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"baiduAd:%s", __FUNCTION__);
    
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    [builder setAdlId:4];
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

- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason {
    NSLog(@"baiduAd:%s", __FUNCTION__);
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"baiduAd:%s", __FUNCTION__);
    
}

- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"baiduAd:%s", __FUNCTION__);
    
    if (self.interstitialAdView) {
        [self.initerstitialAdContainer removeFromSuperview];
        self.initerstitialAdContainer = nil;
        self.interstitialAdView.delegate = nil;
        self.interstitialAdView = nil;
    }
}

- (void)interstitialDidDismissLandingPage:(BaiduMobAdInterstitial *)interstitial {
    NSLog(@"baiduAd:%s", __FUNCTION__);
}



#pragma mark -BaiduMobAdViewDelegate
-(void) willDisplayAd:(BaiduMobAdView*) adview {
    NSLog(@"delegate: will display ad");
    
    //上报百度广告显示
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    [builder setAdlId:3];
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

-(void) failedDisplayAd:(BaiduMobFailReason) reason {
    NSLog(@"delegate: failedDisplayAd %d", reason);
}

- (void)didAdImpressed {
    NSLog(@"delegate: didAdImpressed");
}

- (void)didAdClicked {
    NSLog(@"delegate: didAdClicked");
}

- (void)didAdClose {
    NSLog(@"delegate: didAdClose");
    
    [self.sharedAdView removeFromSuperview];
    self.sharedAdView.delegate = nil;
    self.sharedAdView = nil;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
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
