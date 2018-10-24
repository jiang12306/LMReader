//
//  LMContentViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/31.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"
#import "GDTNativeExpressAdView.h"
#import "LMReaderContentAdView.h"
#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>
#import <BaiduMobAdSDK/BaiduMobAdView.h>

typedef NS_ENUM(NSInteger, LMReadModel) {
    LMReaderBackgroundType1 = 1,
    LMReaderBackgroundType2 = 2,
    LMReaderBackgroundType3 = 3,
    LMReaderBackgroundType4 = 4
};

#define contentBottomLabelHeight ([LMTool isBangsScreen]?(44):(20 + 10))
#define contentNaviHeight ([LMTool isBangsScreen]?88:64)
#define contentBottomHeight ([LMTool isBangsScreen]?83:49)
#define contentScreenWidth [UIScreen mainScreen].bounds.size.width
#define contentScreenHeight [UIScreen mainScreen].bounds.size.height
//计算label文本用
#define contentRect CGRectMake(10, contentNaviHeight, contentScreenWidth - 10*2, contentScreenHeight - contentNaviHeight - contentBottomHeight)
//label尺寸
#define contentLabRect CGRectMake(10, contentNaviHeight, contentScreenWidth - 10*2, contentScreenHeight - contentNaviHeight - contentBottomLabelHeight)


static CGFloat contentTencentInnerAdScale = 0.74;//720.f / 1280;//上图下文，腾讯内嵌广告高、宽比
static CGFloat contentTencentInsertAdScale = 1200.f / 800;//纯图，腾讯插屏广告高、宽比
static CGFloat contentBaiduInnerAdScale = 2.f / 3;//横幅，百度内嵌广告高、宽比
static CGFloat contentBaiduInsertAdScale = 5.f / 6;//插屏，百度插屏广告高、宽比
static CGFloat contentSelfInnerAdScale = 0.74;//720.f / 1280;//横幅，自家内嵌广告高、宽比
static CGFloat contentSelfInsertAdScale = 1200.f / 800;//插屏，自家插屏广告高、宽比


@protocol LMContentViewControllerDelegate <NSObject>

@optional
-(void)didClickedAdViewIsBook:(BOOL )isBook bookIdStr:(NSString* )bookIdStr urlStr:(NSString* )urlStr;

@end

@interface LMContentViewController : LMBaseViewController

-(instancetype )initWithReadModel:(LMReadModel )readModel fontSize:(CGFloat )fontSize content:(NSString* )content;

@property (nonatomic, weak) id <LMContentViewControllerDelegate> delegate;

@property (nonatomic, strong) GDTNativeExpressAdView* adView;//腾讯广告
@property (nonatomic, strong) LMReaderContentAdView* ownerAdView;//自家内嵌广告
@property (nonatomic, strong) UIView* initerstitialAdContainer;/**<百度插页广告 容器*/
@property (nonatomic, strong) BaiduMobAdInterstitial* interstitialAdView;/**<插页  百度插页广告*/
@property (nonatomic, strong) BaiduMobAdView* sharedAdView;/**<内嵌  百度横幅广告*/


@property (nonatomic, assign) BOOL shouldShowAd;//是否显示广告
@property (nonatomic, assign) NSInteger adType;//广告类型：1.内嵌；2.插屏
@property (nonatomic, assign) NSInteger adFromWhich;//广告来源：0.腾讯；1.自家；2.百度

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString* pageProgress;
@property (nonatomic, copy) NSString *chapterProgress;

@property (nonatomic, assign) LMReadModel readModel;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;

@end
