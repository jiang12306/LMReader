//
//  LMWindowLoadingView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMWindowLoadingView.h"

@interface LMWindowLoadingView ()

@property (nonatomic, strong) UIView* loadingView;
@property (nonatomic, strong) UIImageView* loadingIV;
@property (nonatomic, strong) UILabel* loadingLab;
@property (nonatomic, strong) UIButton* closeBtn;

@end

@implementation LMWindowLoadingView

static LMWindowLoadingView *_sharedNetworkTool;
static dispatch_once_t onceToken;

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        if (_sharedNetworkTool == nil) {
            _sharedNetworkTool = [super allocWithZone:zone];
            
            
        }
    });
    return _sharedNetworkTool;
}

-(id)copyWithZone:(NSZone *)zone {
    return _sharedNetworkTool;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedNetworkTool;
}

+(instancetype)sharedWindowLoadingView {
    return [[self alloc]init];
}

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        UIColor* blackColor = [UIColor blackColor];
        self.backgroundColor = [blackColor colorWithAlphaComponent:0.5];
        self.center = CGPointMake(screenRect.size.width/2, screenRect.size.height/2);
        self.alpha = 0;
        
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
        self.loadingView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.loadingView.backgroundColor = [UIColor colorWithRed:40.f/255 green:40.f/255 blue:40.f/255 alpha:0.6];
        self.loadingView.layer.cornerRadius = 5;
        self.loadingView.layer.masksToBounds = YES;
        [self addSubview:self.loadingView];
        
        self.loadingIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 30)];
        NSMutableArray* imgArr = [NSMutableArray array];
        for (NSInteger i = 0; i < 7; i ++) {
            NSString* imgStr = [NSString stringWithFormat:@"loading%ld", (long)i];
            UIImage* img = [UIImage imageNamed:imgStr];
            [imgArr addObject:img];
        }
        self.loadingIV.animationImages = imgArr;
        self.loadingIV.animationDuration = 1;
        [self.loadingView addSubview:self.loadingIV];
        
        self.loadingLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.loadingView.frame.size.height - 25, self.loadingView.frame.size.height, 20)];
        self.loadingLab.textColor = [UIColor whiteColor];
        self.loadingLab.textAlignment = NSTextAlignmentCenter;
        self.loadingLab.font = [UIFont systemFontOfSize:14];
        self.loadingLab.text = @"加载中···";
        [self.loadingView addSubview:self.loadingLab];
        
        self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.closeBtn.center = CGPointMake(self.loadingView.frame.origin.x + self.loadingView.frame.size.width, self.loadingView.frame.origin.y);
        self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:25];
        [self.closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
    }
    return self;
}

-(void)clickedCloseButton:(UIButton* )sender {
    [self hideWithAnimated:YES];
}

-(void)showWithAnimated:(BOOL)animated {
    NSTimeInterval time = 0;
    if (animated) {
        time = 0.2;
    }
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [self.loadingIV startAnimating];
    [keyWindow addSubview:self];
    self.alpha = 1;
    
//    [UIView animateWithDuration:time animations:^{
//
//    } completion:^(BOOL finished) {
//
//    }];
}

-(void)hideWithAnimated:(BOOL)animated {
    NSTimeInterval time = 0;
    if (animated) {
        time = 0.2;
    }
    [self.loadingIV stopAnimating];
    [self removeFromSuperview];
    
//    [UIView animateWithDuration:time animations:^{
//
//    } completion:^(BOOL finished) {
//
//    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
