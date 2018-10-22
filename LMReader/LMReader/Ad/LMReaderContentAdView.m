//
//  LMReaderContentAdView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderContentAdView.h"
#import "LMNetworkTool.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMReaderContentAdView ()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* detailLab;

@property (nonatomic, strong) UILabel* infoLab;
@property (nonatomic, strong) UIButton* closeBtn;

@property (nonatomic, strong) TopicAd* topAd;

@property (nonatomic, assign) NSInteger adType;

@end

@implementation LMReaderContentAdView

NSTimeInterval contentAdViewRequestLimitTime = 3;
NSTimeInterval contentAdViewImageLimitTime = 3;

-(instancetype)initWithFrame:(CGRect)frame adType:(NSInteger)adType {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.adType = adType;
        //获取章节末尾内嵌广告
        FtAdReqBuilder* builder = [FtAdReq builder];
        if (adType == 2) {
            [builder setAdlId:4];
        }else {
            [builder setAdlId:3];
        }
        FtAdReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:41 ReqData:reqData limitTime:contentAdViewRequestLimitTime successBlock:^(NSData *successData) {
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
                                self.topAd = [adArr firstObject];
                                Ad* detailAd = self.topAd.ad;
                                if ([self.topAd hasBook]) {//书籍类型广告
                                    detailAd = self.topAd.book;
                                }
                                NSString* encodeImgStr = [detailAd.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                                NSURL *nsurl = [NSURL URLWithString:encodeImgStr];
                                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
                                NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                                config.timeoutIntervalForRequest = contentAdViewImageLimitTime;
                                NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
                                NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                    if (error == nil && data != nil && ![data isKindOfClass:[NSNull class]] && data.length > 0) {
                                        UIImage* img = [UIImage imageWithData:data];
                                        if (img != nil) {
                                            self.image = img;
                                            [self callSuccessLoad];
                                        }else {
                                            [self callFailureLoad];
                                        }
                                    }else {
                                        [self callFailureLoad];
                                    }
                                }];
                                [dataTask resume];
                            }else {
                                [self callFailureLoad];
                            }
                        }else {
                            [self callFailureLoad];
                        }
                    }else {
                        [self callFailureLoad];
                    }
                }else {
                    [self callFailureLoad];
                }
            } @catch (NSException *exception) {
                [self callFailureLoad];
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {
            [self callFailureLoad];
        }];
    }
    return self;
}

-(void)callFailureLoad {
    if (self.loadBlock) {
        self.loadBlock(NO);
    }
}

-(void)callSuccessLoad {
    if (self.loadBlock) {
        self.loadBlock(YES);
    }
}

-(void)didTapAdView:(UITapGestureRecognizer* )tapGR {
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
}

-(void)startShow {
    if (self.topAd == nil || self.image == nil) {
        return;
    }
    
    Ad* detailAd = self.topAd.ad;
    BOOL isAd = YES;
    if ([self.topAd hasBook]) {//书籍类型广告
        detailAd = self.topAd.book;
        isAd = NO;
    }
    
    //优先显示文字，图片高度根据文字高度和总高度来调整
    if (self.adType == 2) {//章节末插页，纯图
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.image = self.image;
        [self addSubview:self.imageView];
        
        CGFloat closeBtnWidth = 40;
        UIEdgeInsets imgInsets = UIEdgeInsetsMake(closeBtnWidth + 5, 15, 15, closeBtnWidth + 5);
        UInt32 position = detailAd.pos;
        CGFloat headerHeight = 10;
        CGFloat infoHeight = 15;
        CGFloat infoWidth = 30;
        CGRect infoRect = CGRectMake(10, self.frame.size.height - headerHeight - infoHeight, infoWidth, infoHeight);
        CGRect closeRect = CGRectMake(self.frame.size.width - closeBtnWidth, 0 - closeBtnWidth, closeBtnWidth * 2, closeBtnWidth * 2);
        if (position == 1) {//右上角
            infoRect.origin.x = self.frame.size.width - 10 - infoWidth;
            infoRect.origin.y = headerHeight;
            closeRect.origin.y = self.frame.size.height - closeBtnWidth;
            imgInsets = UIEdgeInsetsMake(15, 15, closeBtnWidth + 5, closeBtnWidth + 5);
        }else if (position == 2) {//右下角
            infoRect.origin.x = self.frame.size.width - 10 - infoWidth;
            infoRect.origin.y = self.frame.size.height - headerHeight - infoHeight;
        }else if (position == 3) {//左上角
            infoRect.origin.x = 10;
            infoRect.origin.y = headerHeight;
        }else if (position == 4) {//左下角
            infoRect.origin.x = 10;
            infoRect.origin.y = self.frame.size.height - headerHeight - infoHeight;
        }
        if (isAd) {//是广告
            self.infoLab = [[UILabel alloc]initWithFrame:infoRect];
            self.infoLab.layer.cornerRadius = 2;
            self.infoLab.layer.masksToBounds = YES;
            self.infoLab.backgroundColor = [UIColor colorWithRed:192.f/255 green:192.f/255 blue:192.f/255 alpha:1];
            self.infoLab.textColor = [UIColor whiteColor];
            self.infoLab.textAlignment = NSTextAlignmentCenter;
            self.infoLab.font = [UIFont systemFontOfSize:13];
            self.infoLab.text = @"广告";
            [self addSubview:self.infoLab];
        }
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAdView:)];
        [self addGestureRecognizer:tap];
        
        self.closeBtn = [[UIButton alloc]initWithFrame:closeRect];
        self.closeBtn.layer.cornerRadius = closeBtnWidth;
        self.closeBtn.layer.masksToBounds = YES;
        self.closeBtn.backgroundColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:0.5];
        [self.closeBtn setImage:[UIImage imageNamed:@"ad_Close_White"] forState:UIControlStateNormal];
        [self.closeBtn setImageEdgeInsets:imgInsets];
        [self.closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
        
        self.clipsToBounds = YES;
    }else {
        if (isAd) {//是广告
            self.infoLab = [[UILabel alloc]init];
            self.infoLab.layer.cornerRadius = 2;
            self.infoLab.layer.masksToBounds = YES;
            self.infoLab.backgroundColor = [UIColor colorWithRed:192.f/255 green:192.f/255 blue:192.f/255 alpha:1];
            self.infoLab.textColor = [UIColor whiteColor];
            self.infoLab.textAlignment = NSTextAlignmentCenter;
            self.infoLab.font = [UIFont systemFontOfSize:13];
            self.infoLab.text = @"广告";
            self.infoLab.frame = CGRectMake(10, self.frame.size.height - 10 - 15, 30, 15);
            [self addSubview:self.infoLab];
        }else {
            self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.frame.size.height - 10 - 15, 0, 0)];
            [self addSubview:self.infoLab];
        }
        
        CGFloat closeBtnWidth = 15;//20;
        
        self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(self.infoLab.frame.origin.x + self.infoLab.frame.size.width + 10, self.infoLab.frame.origin.y, self.frame.size.width - self.infoLab.frame.origin.x - self.infoLab.frame.size.width - closeBtnWidth - 10 * 3, 0)];
        self.detailLab.font = [UIFont systemFontOfSize:11];
        self.detailLab.textColor = [UIColor grayColor];
        self.detailLab.numberOfLines = 0;
        self.detailLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.detailLab.text = detailAd.fTitle;
        [self addSubview:self.detailLab];
        CGRect detailRect = self.detailLab.frame;
        CGSize detailSize = [self.detailLab sizeThatFits:CGSizeMake(detailRect.size.width, 9999)];
        detailRect.origin.y = self.frame.size.height - 10 - detailSize.height;
        detailRect.size.height = detailSize.height;
        self.detailLab.frame = detailRect;
        
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.detailLab.frame.origin.y - 10, self.frame.size.width - 10 * 2, 0)];
        self.titleLab.font = [UIFont systemFontOfSize:13];
        self.titleLab.numberOfLines = 0;
        self.titleLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.titleLab.text = detailAd.zTitle;
        [self addSubview:self.titleLab];
        CGRect titleRect = self.titleLab.frame;
        CGSize titleSize = [self.titleLab sizeThatFits:CGSizeMake(titleRect.size.width, 9999)];
        titleRect.origin.y = self.detailLab.frame.origin.y - titleSize.height - 10;
        titleRect.size.height = titleSize.height;
        self.titleLab.frame = titleRect;
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.frame.size.width - 10 * 2, self.titleLab.frame.origin.y - 10 * 2)];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.image = self.image;
        [self addSubview:self.imageView];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAdView:)];
        [self addGestureRecognizer:tap];
        
        self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 10 - closeBtnWidth, self.frame.size.height - 10 - closeBtnWidth, closeBtnWidth, closeBtnWidth)];
        [self.closeBtn setImage:[UIImage imageNamed:@"ad_Close"] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
    }
    //
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    if (self.adType == 2) {
        [builder setAdlId:4];
    }else {
        [builder setAdlId:3];
    }
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

-(void)clickedCloseButton:(UIButton* )sender {
    if (self.closeBlock) {
        self.closeBlock(YES);
    }
    
    [self startHide];
}

-(void)startHide {
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
