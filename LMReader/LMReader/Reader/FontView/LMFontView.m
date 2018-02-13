//
//  LMFontView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFontView.h"

@interface LMFontView ()

@property (nonatomic, strong) UILabel* smallLab;
@property (nonatomic, strong) UILabel* bigLab;
@property (nonatomic, strong) UISlider* slider;

@end

@implementation LMFontView

CGFloat miniFont = 15;
CGFloat maxFont = 25;

-(instancetype)initWithFrame:(CGRect)frame currentFontSize:(CGFloat)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        self.smallLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, frame.size.height)];
        self.smallLab.font = [UIFont systemFontOfSize:miniFont];
        self.smallLab.text = @"A";
        self.smallLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.smallLab];
        
        self.bigLab = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, 0, 40, frame.size.height)];
        self.bigLab.font = [UIFont systemFontOfSize:maxFont];
        self.bigLab.text = @"A";
        self.bigLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.bigLab];
        
        self.slider = [[UISlider alloc]initWithFrame:CGRectMake(self.smallLab.frame.origin.x + self.smallLab.frame.size.width + 10, frame.size.height/2 - 5, frame.size.width - self.smallLab.frame.size.width - self.bigLab.frame.size.width - 10 * 4, 10)];
        self.slider.minimumValue = 0;
        self.slider.maximumValue = 1;
        self.slider.value = (fontSize - miniFont)/(maxFont - miniFont);
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
        
        self.isShow = NO;
    }
    return self;
}

-(void)sliderValueChanged:(UISlider* )slider {
    float fontFloat = self.slider.value * (maxFont - miniFont) + miniFont;
    int result = (int)roundf(fontFloat);
    NSLog(@"fontFloat = %f, fontSize = %d", fontFloat, result);
    [self.slider setValue:(result - miniFont)/(maxFont - miniFont) animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(fontViewCurrentValue:)]) {
        [self.delegate fontViewCurrentValue:result];
    }
}

-(void)showFontViewWithFinalFrame:(CGRect )finalFrame {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = finalFrame;
    } completion:^(BOOL finished) {
        self.isShow = YES;
    }];
}

-(void)hideFontViewWithFinalFrame:(CGRect )finalFrame {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = finalFrame;
    } completion:^(BOOL finished) {
        self.isShow = NO;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
