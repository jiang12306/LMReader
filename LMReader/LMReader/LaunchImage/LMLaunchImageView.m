//
//  LMLaunchImageView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/4/4.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMLaunchImageView.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"
#import "LMNetworkTool.h"

@interface LMLaunchImageView ()

@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) NSInteger timeCount;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIButton* overBtn;
@property (nonatomic, strong) UILabel* infoLab;
@property (nonatomic, strong) Conver* currentCover;

@end

@implementation LMLaunchImageView

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    self = [super initWithFrame:screenRect];
    if (self) {
        UIImage* launchImage = [UIImage imageNamed:@"defaultFirstLaunch"];
        
        self.imageView = [[UIImageView alloc]initWithFrame:screenRect];
        self.imageView.image = launchImage;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedImageView:)];
        [self.imageView addGestureRecognizer:tap];
        
        BOOL shouldLoadData = YES;
        
        @try {
            NSData* data = [LMTool queryLaunchImageData];
            if (data != nil && ![data isKindOfClass:[NSNull class]] && data.length > 0) {
                ConverRes* res = [ConverRes parseFromData:data];
                NSArray* arr = res.conver;
                if (arr != nil && arr.count > 0) {
                    
                    NSInteger index = [LMTool queryLastLaunchImageIndex];
                    index ++;
                    
                    if (index <= arr.count - 1) {
                        shouldLoadData = NO;
                        [LMTool saveLastLaunchImageIndex:index];
                    }else {
                        [LMTool deleteLaunchImageData];
                        [LMTool deleteLastLaunchImageIndex];
                    }
                    if (shouldLoadData) {
                        [self loadLaunchImageData];
                    }else {
                        self.currentCover = [arr objectAtIndex:index];
                        UInt32 position = self.currentCover.pos;
                        if (position == 1) {//右上角
                            
                        }else if (position == 2) {//底部居中
                            self.overBtn.center = CGPointMake(screenRect.size.width/2, screenRect.size.height - 30);
                        }else if (position == 3) {//右下角
                            self.overBtn.frame = CGRectMake(screenRect.size.width - 10 - 75, screenRect.size.height - 44, 75, 30);
                        }
                        
                        NSString* picStr = [self.currentCover.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        [self.imageView sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:launchImage options:SDWebImageHighPriority];
                        
                        [self startTimerWithTimeCount:self.currentCover.showTime];
                        
                        self.infoLab.hidden = NO;
                    }
                }else {
                    [self loadLaunchImageData];
                    
                    [self startTimerWithTimeCount:3];
                }
            }else {
                [self loadLaunchImageData];
            }
            
            self.overBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width - 10 - 75, 44, 75, 30)];
            self.overBtn.backgroundColor = [UIColor grayColor];
            self.overBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [self.overBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.overBtn setTitle:@"跳过" forState:UIControlStateNormal];
            self.overBtn.layer.cornerRadius = 5;
            self.overBtn.layer.masksToBounds = YES;
            [self.overBtn addTarget:self action:@selector(clickedStepOverButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.overBtn];
            
        } @catch (NSException *exception) {
            [LMTool deleteLaunchImageData];
            [LMTool deleteLastLaunchImageIndex];
            
            [self clickedStepOverButton:self.overBtn];
        } @finally {
            
        }
    }
    return self;
}

-(UILabel *)infoLab {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!_infoLab) {
        _infoLab = [[UILabel alloc]init];
        _infoLab.backgroundColor = [UIColor grayColor];
        _infoLab.alpha = 0.8f;
        _infoLab.textColor = [UIColor whiteColor];
        _infoLab.textAlignment = NSTextAlignmentCenter;
        _infoLab.font = [UIFont systemFontOfSize:13];
        _infoLab.text = @"广告";
        _infoLab.frame = CGRectMake(10, screenRect.size.height - 44, 30, 15);
        [self addSubview:_infoLab];
        _infoLab.hidden = YES;
    }
    return _infoLab;
}

-(void)loadLaunchImageData {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    __weak LMLaunchImageView* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:23 ReqData:nil successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 23) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    //保存
                    [LMTool saveLaunchImageData:apiRes.body];
                    
                    ConverRes* res = [ConverRes parseFromData:apiRes.body];
                    NSArray* arr = res.conver;
                    if (arr != nil && arr.count > 0) {
                        
                        weakSelf.currentCover = [arr objectAtIndex:0];
                        UInt32 position = weakSelf.currentCover.pos;
                        if (position == 1) {//右上角
                            
                        }else if (position == 2) {//底部居中
                            weakSelf.overBtn.center = CGPointMake(screenRect.size.width/2, screenRect.size.height - 44);
                        }else if (position == 3) {//右下角
                            weakSelf.overBtn.frame = CGRectMake(screenRect.size.width - 10 - 75, screenRect.size.height - 44, 75, 30);
                        }
                        
                        NSString* picStr = [weakSelf.currentCover.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        [weakSelf.imageView sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"defaultFirstLaunch"] options:SDWebImageHighPriority];
                        
                        [weakSelf startTimerWithTimeCount:weakSelf.currentCover.showTime];
                        
                        weakSelf.infoLab.hidden = NO;
                    }else {
                        [weakSelf clickedStepOverButton:weakSelf.overBtn];
                    }
                    
                }else {
                    [weakSelf clickedStepOverButton:weakSelf.overBtn];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf clickedStepOverButton:weakSelf.overBtn];
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf clickedStepOverButton:weakSelf.overBtn];
    }];
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
    
    //回调
    if (self.callBlock) {
        self.callBlock(YES, nil);
    }
    
    [self removeFromSuperview];
}

-(void)tappedImageView:(UITapGestureRecognizer* )tapGR {
    NSString* urlStr = self.currentCover.url;
    if (urlStr != nil && ![urlStr isKindOfClass:[NSNull class]] && urlStr.length > 0) {
        self.callBlock(YES, urlStr);
    }
    
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
