//
//  LMBookShelfAdView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfAdView.h"
#import "LMNetworkTool.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMBookShelfAdView ()

@property (nonatomic, assign) CGRect imageFrame;

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* detailLab;

@property (nonatomic, strong) UILabel* infoLab;
@property (nonatomic, strong) UIButton* closeBtn;

@property (nonatomic, strong) TopicAd* topAd;

@end

@implementation LMBookShelfAdView

NSTimeInterval bookShelfAdViewRequestLimitTime = 5;
NSTimeInterval bookShelfAdViewImageLimitTime = 5;

-(instancetype)initWithFrame:(CGRect)frame imgFrame:(CGRect )imgFrame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageFrame = imgFrame;
        
        //获取书架页广告
        FtAdReqBuilder* builder = [FtAdReq builder];
        [builder setAdlId:2];
        FtAdReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:41 ReqData:reqData limitTime:bookShelfAdViewRequestLimitTime successBlock:^(NSData *successData) {
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
                                config.timeoutIntervalForRequest = bookShelfAdViewImageLimitTime;
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
                                
                                /*
                                self.imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
                                [self.imageView sd_setImageWithURL:[NSURL URLWithString:encodeImgStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                    if (image != nil && error == nil) {
                                        self.image = image;
                                        [self callSuccessLoad];
                                    }else {
                                        [self callFailureLoad];
                                    }
                                }];
                                 */
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
    self.imageView = [[UIImageView alloc]initWithFrame:self.imageFrame];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.image = self.image;
    [self addSubview:self.imageView];
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + 10, self.imageView.frame.origin.y, self.frame.size.width - self.imageView.frame.origin.x - self.imageView.frame.size.width - 10 * 2, 0)];
    self.titleLab.font = [UIFont systemFontOfSize:13];
    self.titleLab.numberOfLines = 0;
    self.titleLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.titleLab.text = detailAd.zTitle;
    [self addSubview:self.titleLab];
    CGRect titleRect = self.titleLab.frame;
    CGSize titleSize = [self.titleLab sizeThatFits:CGSizeMake(titleRect.size.width, 9999)];
    titleRect.size.height = titleSize.height;
    self.titleLab.frame = titleRect;
    
    CGFloat infoY = self.imageView.frame.origin.y + self.imageView.frame.size.height - 15;
    if (infoY < self.titleLab.frame.origin.y + self.titleLab.frame.size.height) {
        infoY = self.titleLab.frame.origin.y + self.titleLab.frame.size.height;
    }
    
    if (isAd) {//是广告
        self.infoLab = [[UILabel alloc]init];
        self.infoLab.layer.cornerRadius = 2;
        self.infoLab.layer.masksToBounds = YES;
        self.infoLab.backgroundColor = [UIColor colorWithRed:192.f/255 green:192.f/255 blue:192.f/255 alpha:1];
        self.infoLab.textColor = [UIColor whiteColor];
        self.infoLab.textAlignment = NSTextAlignmentCenter;
        self.infoLab.font = [UIFont systemFontOfSize:13];
        self.infoLab.text = @"广告";
        self.infoLab.frame = CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + 10, infoY, 30, 15);
        [self addSubview:self.infoLab];
    }else {
        self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + 10, infoY, 0, 0)];
        [self addSubview:self.infoLab];
    }
    
    CGFloat closeBtnWidth = 15;
    
    self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(self.infoLab.frame.origin.x + self.infoLab.frame.size.width + 10, self.infoLab.frame.origin.y, self.frame.size.width - self.infoLab.frame.origin.x - self.infoLab.frame.size.width - closeBtnWidth - 10 * 3, 0)];
    self.detailLab.font = [UIFont systemFontOfSize:11];
    self.detailLab.textColor = [UIColor grayColor];
    self.detailLab.numberOfLines = 0;
    self.detailLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.detailLab.text = detailAd.fTitle;
    [self addSubview:self.detailLab];
    CGRect detailRect = self.detailLab.frame;
    CGSize detailSize = [self.detailLab sizeThatFits:CGSizeMake(detailRect.size.width, 9999)];
    detailRect.size.height = detailSize.height;
    if (detailRect.origin.y + detailRect.size.height > self.frame.size.height) {
        detailRect.size.height = self.frame.size.height - detailRect.origin.y;
    }
    self.detailLab.frame = detailRect;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAdView:)];
    [self addGestureRecognizer:tap];
    
    self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 10 - closeBtnWidth, self.frame.size.height - 10 - closeBtnWidth, closeBtnWidth, closeBtnWidth)];
    [self.closeBtn setImage:[UIImage imageNamed:@"ad_Close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
    
    //
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    [builder setAdlId:2];
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
