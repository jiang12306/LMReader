//
//  LMSplashAdView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/9.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSplashAdView.h"
#import "LMNetworkTool.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMSplashAdView ()

@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) NSInteger timeCount;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIButton* overBtn;
@property (nonatomic, strong) UILabel* infoLab;

@property (nonatomic, strong) TopicAd* topAd;

@end

@implementation LMSplashAdView

NSTimeInterval splashAdViewRequestLimitTime = 5;
NSTimeInterval splashAdViewImageLimitTime = 5;

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenRect];
    if (self) {
        UIImage* launchImage = [UIImage imageNamed:@"defaultFirstLaunch"];
        
        self.imageView = [[UIImageView alloc]initWithFrame:screenRect];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.image = launchImage;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        
        //获取开屏广告
        FtAdReqBuilder* builder = [FtAdReq builder];
        [builder setAdlId:1];
        FtAdReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:41 ReqData:reqData limitTime:splashAdViewRequestLimitTime successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 41) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        FtAdRes* res = [FtAdRes parseFromData:apiRes.body];
                        NSArray* arr = res.ftAd;
                        if (arr.count > 0) {
                            FtAd* subAd = [arr firstObject];
                            NSArray* adArr = subAd.topicAd;
                            if (adArr.count > 0) {
                                self.topAd = [adArr objectAtIndex:0];
                                Ad* detailAd = self.topAd.ad;
                                if ([self.topAd hasBook]) {//书籍类型广告
                                    detailAd = self.topAd.book;
                                }
                                NSString* encodeImgStr = [detailAd.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                                if (encodeImgStr != nil && encodeImgStr.length > 0) {
                                    NSURL *nsurl = [NSURL URLWithString:encodeImgStr];
                                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
                                    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                    config.timeoutIntervalForRequest = splashAdViewImageLimitTime;
                                    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
                                    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                        if (error == nil && data != nil && ![data isKindOfClass:[NSNull class]] && data.length > 0) {
                                            UIImage* img = [UIImage imageWithData:data];
                                            if (img != nil) {
                                                
                                                self.imageView.image = img;
                                                
                                                [self uploadAdShowLog];
                                                
                                                UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedImageView:)];
                                                [self.imageView addGestureRecognizer:tap];
                                                
                                                //
                                                [self createOverButtonWithPosition:detailAd.pos];
                                                if (![self.topAd hasBook]) {
                                                    [self createInfoLabelWithPosition:detailAd.pos];
                                                }
                                                
                                                [self startTimerWithTimeCount:detailAd.lT];
                                            }else {
                                                [self clickedStepOverButton:nil];
                                            }
                                        }else {
                                            [self clickedStepOverButton:nil];
                                        }
                                    }];
                                    [dataTask resume];
                                }else {
                                    [self clickedStepOverButton:nil];
                                }
                            }else {
                                [self clickedStepOverButton:nil];
                            }
                        }else {
                            [self clickedStepOverButton:nil];
                        }
                    }else {
                        [self clickedStepOverButton:nil];
                    }
                }else {
                    [self clickedStepOverButton:nil];
                }
            } @catch (NSException *exception) {
                
                [self clickedStepOverButton:nil];
                
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {
            
            [self clickedStepOverButton:nil];
            
        }];
    }
    return self;
}

//
-(void)uploadAdShowLog {
    if (self.topAd == nil) {
        return;
    }
    Ad* detailAd = self.topAd.ad;
    if ([self.topAd hasBook]) {//书籍类型广告
        detailAd = self.topAd.book;
    }
    
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    [builder setAdlId:1];
    [builder setAdPt:1];
    [builder setAdId:detailAd.id];
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

-(void)tappedImageView:(UITapGestureRecognizer* )tapGR {
    BOOL isBookType = NO;
    Ad* detailAd = self.topAd.ad;
    NSString* idStr = @"";
    if ([self.topAd hasBook]) {
        isBookType = YES;
        detailAd = self.topAd.book;
        idStr = [NSString stringWithFormat:@"%u", (unsigned int)detailAd.book.bookId];
    }
    NSString* resultUrlStr = detailAd.to;
    if (self.clickBlock) {
        self.clickBlock(isBookType, idStr, resultUrlStr);
    }
    
    [self clickedStepOverButton:nil];
}

-(void)createInfoLabelWithPosition:(NSInteger )position {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat headerHeight = 20;
    CGFloat infoHeight = 15;
    CGFloat infoWidth = 30;
    if ([LMTool isBangsScreen]) {
        headerHeight = 44 + 10;
    }
    CGRect infoRect = CGRectMake(10, screenRect.size.height - headerHeight - infoHeight, infoWidth, infoHeight);
    if (position == 1) {//右上角
        infoRect.origin.x = screenRect.size.width - 10 - infoWidth;
        infoRect.origin.y = headerHeight;
    }else if (position == 2) {//右下角
        infoRect.origin.x = screenRect.size.width - 10 - infoWidth;
        infoRect.origin.y = screenRect.size.height - headerHeight;
    }else if (position == 3) {//左上角
        infoRect.origin.x = 10;
        infoRect.origin.y = headerHeight;
    }else if (position == 4) {//左下角
        infoRect.origin.x = 10;
        infoRect.origin.y = screenRect.size.height - headerHeight;
    }
    
    self.infoLab = [[UILabel alloc]init];
    self.infoLab.layer.cornerRadius = 2;
    self.infoLab.layer.masksToBounds = YES;
    self.infoLab.backgroundColor = [UIColor colorWithRed:192.f/255 green:192.f/255 blue:192.f/255 alpha:1];
    self.infoLab.textColor = [UIColor whiteColor];
    self.infoLab.textAlignment = NSTextAlignmentCenter;
    self.infoLab.font = [UIFont systemFontOfSize:13];
    self.infoLab.text = @"广告";
    self.infoLab.frame = infoRect;
    [self addSubview:self.infoLab];
}

-(void)createOverButtonWithPosition:(NSInteger )position {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat headerHeight = 20;
    CGFloat overHeight = 30;
    CGFloat overWidth = 75;
    if ([LMTool isBangsScreen]) {
        headerHeight = 44 + 10;
    }
    CGRect overRect = CGRectMake(screenRect.size.width - 10 - overWidth, headerHeight, overWidth, overHeight);
    if (position == 1) {//infoLab右上角
        overRect.origin.y = screenRect.size.height - headerHeight;
    }else if (position == 2) {//右下角
        
    }else if (position == 3) {//左上角
        
    }else if (position == 4) {//左下角
        
    }
    
    self.overBtn = [[UIButton alloc]initWithFrame:overRect];
    self.overBtn.backgroundColor = [UIColor grayColor];
    self.overBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.overBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.overBtn setTitle:@"跳过" forState:UIControlStateNormal];
    self.overBtn.layer.cornerRadius = 5;
    self.overBtn.layer.masksToBounds = YES;
    [self.overBtn addTarget:self action:@selector(clickedStepOverButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.overBtn];
}

-(void)startTimerWithTimeCount:(NSInteger )count {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCount) userInfo:nil repeats:YES];
    }
    [self.timer setFireDate:[NSDate distantPast]];
    self.timeCount = count;
}

-(void)startCount {
    if (self.timeCount <= 0) {
        [self clickedStepOverButton:self.overBtn];
    }else {
        self.timeCount --;
        
        NSString* str = [NSString stringWithFormat:@"跳过(%lds)", self.timeCount];
        [self.overBtn setTitle:str forState:UIControlStateNormal];
    }
}

-(void)clickedStepOverButton:(UIButton* )sender {
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.imageView = nil;
    
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
