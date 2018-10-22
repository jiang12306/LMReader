//
//  LMBaiduSplashAdView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/16.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaiduSplashAdView.h"
#import "LMNetworkTool.h"
#import "LMTool.h"
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>

@interface LMBaiduSplashAdView () <BaiduMobAdSplashDelegate>

@property (nonatomic, strong) BaiduMobAdSplash* splash;
@property (nonatomic, strong) UIView* baiduContainer;

@end

@implementation LMBaiduSplashAdView

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenRect];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        
        BaiduMobAdSplash *splash = [[BaiduMobAdSplash alloc] init];
        splash.delegate = self;
        splash.AdUnitTag = @"5919589";
        splash.canSplashClick = YES;
        self.splash = splash;
        
        CGFloat bottomViewHeight = [[UIScreen mainScreen] bounds].size.height / 6;
        if (bottomViewHeight < 110) {
            bottomViewHeight = 110;
        }
        CGFloat slogonLabHeight = 30;
        
        UIImageView *logoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
        logoIV.frame = CGRectMake(0, 0, 60, 60);
        logoIV.center = CGPointMake(screenRect.size.width /  2, (screenRect.size.height - slogonLabHeight) / 2);
        [self addSubview:logoIV];
        UILabel* slogonLab = [[UILabel alloc] initWithFrame:CGRectMake(0, logoIV.frame.origin.y + logoIV.frame.size.height, [UIScreen mainScreen].bounds.size.width, 30)];
        slogonLab.font = [UIFont boldSystemFontOfSize:18];
        slogonLab.textAlignment = NSTextAlignmentCenter;
        slogonLab.text = @"海量小说  尽情阅读";
        [self addSubview:slogonLab];
        
        self.baiduContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - bottomViewHeight)];
        self.baiduContainer.backgroundColor = [UIColor redColor];
        [self.splash loadAndDisplayUsingContainerView:self.baiduContainer];
    }
    return self;
}

-(void)removeSplash {
    if (self.splash) {
        self.splash.delegate = nil;
        self.splash = nil;
        [self.baiduContainer removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (NSString *)publisherId {
    return baiduAdPublisherId;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
