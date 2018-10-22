//
//  LMReaderSettingView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderSettingView.h"

@interface LMReaderSettingView ()

@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) NSInteger bgInteger;
@property (nonatomic, assign) NSInteger lineSpaceIndex;

@property (nonnull, strong) UILabel* brightLab;
@property (nonnull, strong) UIImageView* brightSmallIV;
@property (nonatomic, strong) UISlider* brightSlider;
@property (nonnull, strong) UIImageView* brightBigIV;
@property (nonnull, strong) UILabel* fontLab;
@property (nonnull, strong) UIImageView* fontSmallIV;
@property (nonatomic, strong) UISlider* fontSlider;
@property (nonnull, strong) UIImageView* fontBigIV;
@property (nonnull, strong) UILabel* bgLab;
@property (nonnull, strong) UIButton* bgBtn1;
@property (nonnull, strong) UIButton* bgBtn2;
@property (nonnull, strong) UIButton* bgBtn3;
@property (nonnull, strong) UIButton* bgBtn4;
@property (nonnull, strong) UILabel* lineSpaceLab;
@property (nonnull, strong) UIButton* lineSpaceBtn1;
@property (nonnull, strong) UIButton* lineSpaceBtn2;
@property (nonnull, strong) UIButton* lineSpaceBtn3;

@end

@implementation LMReaderSettingView

CGFloat miniFont = 15;
CGFloat maxFont = 25;
CGFloat labWidth = 40;
CGFloat labHeight = 60;
CGFloat ivSmallWidth = 20;
CGFloat ivBigWidth = 30;
CGFloat settingBtnWidth = 40;
CGFloat settingBtnHeight = 30;

-(instancetype)initWithFrame:(CGRect )frame bringht:(CGFloat )bright fontSize:(CGFloat )fontSize bgInteger:(NSInteger )bgInteger lineSpaceIndex:(NSInteger )lineSpaceIndex {
    self = [super initWithFrame:frame];
    if (self) {
        self.brightness = bright;
        self.fontSize = fontSize;
        self.bgInteger = bgInteger;
        self.lineSpaceIndex = lineSpaceIndex;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:1];
        //亮度
        self.brightLab = [self createLabelWithFrame:CGRectMake(10, 0, labWidth, labHeight) title:@"亮度"];
        [self addSubview:self.brightLab];
        self.brightSmallIV = [self createImageViewWithFrame:CGRectMake(labWidth + 10, 20, ivSmallWidth, ivSmallWidth) img:[UIImage imageNamed:@"readerSetting_Light_Low"]];
        [self addSubview:self.brightSmallIV];
        self.brightBigIV = [self createImageViewWithFrame:CGRectMake(screenWidth - ivBigWidth - 10, 15, ivBigWidth, ivBigWidth) img:[UIImage imageNamed:@"readerSetting_Light_High"]];
        [self addSubview:self.brightBigIV];
        self.brightSlider = [self createSliderWithFrame:CGRectMake(self.brightSmallIV.frame.origin.x + self.brightSmallIV.frame.size.width + 10, 20, self.brightBigIV.frame.origin.x - self.brightSmallIV.frame.origin.x - self.brightSmallIV.frame.size.width - 20, 20) minValue:0 maxValue:1 valueFloat:bright selector:@selector(didSlideBrightSlider:)];
        [self addSubview:self.brightSlider];
        
        //字号
        self.fontLab = [self createLabelWithFrame:CGRectMake(10, self.brightLab.frame.origin.y + self.brightLab.frame.size.height, labWidth, labHeight) title:@"字号"];
        [self addSubview:self.fontLab];
        self.fontSmallIV = [self createImageViewWithFrame:CGRectMake(labWidth + 10, self.fontLab.frame.origin.y + 20, ivSmallWidth, ivSmallWidth) img:[UIImage imageNamed:@"readerSetting_Font1"]];
        [self addSubview:self.fontSmallIV];
        self.fontBigIV = [self createImageViewWithFrame:CGRectMake(screenWidth - ivBigWidth - 10, self.fontLab.frame.origin.y + 15, ivBigWidth, ivBigWidth) img:[UIImage imageNamed:@"readerSetting_Font2"]];
        [self addSubview:self.fontBigIV];
        self.fontSlider = [self createSliderWithFrame:CGRectMake(self.brightSmallIV.frame.origin.x + self.brightSmallIV.frame.size.width + 10, self.fontLab.frame.origin.y + 20, self.brightSlider.frame.size.width, 20) minValue:miniFont maxValue:maxFont valueFloat:fontSize selector:@selector(didSlideFontSlider:)];
        [self addSubview:self.fontSlider];
        
        //背景
        self.bgLab = [self createLabelWithFrame:CGRectMake(10, self.fontLab.frame.origin.y + self.brightLab.frame.size.height, labWidth, labHeight) title:@"背景"];
        [self addSubview:self.bgLab];
        BOOL bgState1 = NO;
        BOOL bgState2 = NO;
        BOOL bgState3 = NO;
        BOOL bgState4 = NO;
        if (bgInteger == 1) {
            bgState1 = YES;
        }else if (bgInteger == 2) {
            bgState2 = YES;
        }else if (bgInteger == 3) {
            bgState3 = YES;
        }else if (bgInteger == 4) {
            bgState4 = YES;
        }
        self.bgBtn1 = [self createButtonWithFrame:CGRectMake(labWidth + 10, self.bgLab.frame.origin.y + 15, settingBtnWidth, settingBtnHeight) bgColor:nil normalImg:[UIImage imageNamed:@"readerSetting_BgColor1"] selectedImg:nil isSelected:bgState1 selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn1];
        self.bgBtn2 = [self createButtonWithFrame:CGRectMake(self.bgBtn1.frame.origin.x + self.bgBtn1.frame.size.width + 10, self.bgBtn1.frame.origin.y, settingBtnWidth, settingBtnHeight) bgColor:nil normalImg:[UIImage imageNamed:@"readerSetting_BgColor2"] selectedImg:nil isSelected:bgState2 selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn2];
        self.bgBtn3 = [self createButtonWithFrame:CGRectMake(self.bgBtn2.frame.origin.x + self.bgBtn2.frame.size.width + 10, self.bgBtn1.frame.origin.y, settingBtnWidth, settingBtnHeight) bgColor:nil normalImg:[UIImage imageNamed:@"readerSetting_BgColor3"] selectedImg:nil isSelected:bgState3 selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn3];
        self.bgBtn4 = [self createButtonWithFrame:CGRectMake(self.bgBtn3.frame.origin.x + self.bgBtn3.frame.size.width + 10, self.bgBtn1.frame.origin.y, settingBtnWidth, settingBtnHeight) bgColor:nil normalImg:[UIImage imageNamed:@"readerSetting_BgColor4"] selectedImg:nil isSelected:bgState4 selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn4];
        
        //行间距
        self.lineSpaceLab = [self createLabelWithFrame:CGRectMake(10, self.bgLab.frame.origin.y + self.bgLab.frame.size.height, labWidth, labHeight) title:@"行距"];
        [self addSubview:self.lineSpaceLab];
        BOOL lineSpaceState1 = NO;
        BOOL lineSpaceState2 = NO;
        BOOL lineSpaceState3 = NO;
        if (lineSpaceIndex == 1) {
            lineSpaceState1 = YES;
        }else if (lineSpaceIndex == 2) {
            lineSpaceState2 = YES;
        }else if (lineSpaceIndex == 3) {
            lineSpaceState3 = YES;
        }else {
            lineSpaceState1 = YES;
        }
        self.lineSpaceBtn1 = [self createButtonWithFrame:CGRectMake(labWidth + 10, self.lineSpaceLab.frame.origin.y + 15, settingBtnWidth, settingBtnHeight) bgColor:[UIColor clearColor] normalImg:[UIImage imageNamed:@"readerSetting_LineSpace1"] selectedImg:nil isSelected:lineSpaceState1 selector:@selector(didClickLineSpaceButton:)];
        [self addSubview:self.lineSpaceBtn1];
        self.lineSpaceBtn2 = [self createButtonWithFrame:CGRectMake(self.lineSpaceBtn1.frame.origin.x + self.lineSpaceBtn1.frame.size.width + 10, self.lineSpaceBtn1.frame.origin.y, settingBtnWidth, settingBtnHeight) bgColor:[UIColor clearColor] normalImg:[UIImage imageNamed:@"readerSetting_LineSpace2"] selectedImg:nil isSelected:lineSpaceState2 selector:@selector(didClickLineSpaceButton:)];
        [self addSubview:self.lineSpaceBtn2];
        self.lineSpaceBtn3 = [self createButtonWithFrame:CGRectMake(self.lineSpaceBtn2.frame.origin.x + self.lineSpaceBtn2.frame.size.width + 10, self.lineSpaceBtn1.frame.origin.y, settingBtnWidth, settingBtnHeight) bgColor:[UIColor clearColor] normalImg:[UIImage imageNamed:@"readerSetting_LineSpace3"] selectedImg:nil isSelected:lineSpaceState3 selector:@selector(didClickLineSpaceButton:)];
        [self addSubview:self.lineSpaceBtn3];
        
        self.isShow = NO;
    }
    return self;
}

//UISlider
-(UISlider* )createSliderWithFrame:(CGRect )frame minValue:(CGFloat )minValue maxValue:(CGFloat )maxValue valueFloat:(CGFloat )valueFloat selector:(SEL )selector {
    UISlider* slider = [[UISlider alloc]initWithFrame:frame];
    slider.minimumValue = minValue;
    slider.maximumValue = maxValue;
    [slider addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
    slider.value = valueFloat;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedSlider:)];
    [slider addGestureRecognizer:tap];
    
    return slider;
}

-(void)tappedSlider:(UITapGestureRecognizer* )tapGR {
    UIView* tapVi = tapGR.view;
    CGPoint touchPoint = [tapGR locationInView:tapVi];
    if (tapVi == self.brightSlider) {
        CGFloat value = (self.brightSlider.maximumValue - self.brightSlider.minimumValue) * (touchPoint.x / self.brightSlider.frame.size.width );
        [self.brightSlider setValue:value animated:YES];
        
        //
        [self didSlideBrightSlider:self.brightSlider];
    }else if (tapVi == self.fontSlider) {
        CGFloat value = (self.fontSlider.maximumValue - self.fontSlider.minimumValue) * (touchPoint.x / self.fontSlider.frame.size.width) + self.fontSlider.minimumValue;
        [self.fontSlider setValue:value animated:YES];
        
        //
        [self didSlideFontSlider:self.fontSlider];
    }
}

//UILabel
-(UILabel* )createLabelWithFrame:(CGRect )frame title:(NSString* )title {
    UILabel* lab = [[UILabel alloc]initWithFrame:frame];
    lab.font = [UIFont systemFontOfSize:16];
    lab.textColor = [UIColor whiteColor];
    lab.text = title;
    return lab;
}

//UIImageView
-(UIImageView* )createImageViewWithFrame:(CGRect )frame img:(UIImage* )img {
    UIImageView* iv = [[UIImageView alloc]initWithFrame:frame];
    iv.image = img;
    return iv;
}

//UIButton
-(UIButton* )createButtonWithFrame:(CGRect )frame bgColor:(UIColor* )bgColor normalImg:(UIImage* )normalImg selectedImg:(UIImage* )selectedImg isSelected:(BOOL )isSelected selector:(SEL )selector {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    btn.layer.cornerRadius = 2;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 2;
    if (bgColor) {
        btn.backgroundColor = bgColor;
    }
    if (normalImg) {
        [btn setImage:normalImg forState:UIControlStateNormal];
    }
    if (selectedImg) {
        [btn setImage:selectedImg forState:UIControlStateSelected];
    }
    if (isSelected) {
        btn.selected = YES;
        btn.layer.borderColor = [UIColor redColor].CGColor;
    }else {
        btn.selected = NO;
        btn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    if (selector) {
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
}

//字体改变
-(void)didSlideFontSlider:(UISlider* )slider {
    if (slider == self.fontSlider) {
        float fontFloat = self.fontSlider.value;
        int result = (int)roundf(fontFloat);
        [self.fontSlider setValue:result animated:YES];
        if (result != self.fontSize) {
            self.fontSize = result;
            if (self.fontBlock) {
                UIFont* currentFont = [UIFont systemFontOfSize:self.fontSize];
                CGFloat lineHeight = currentFont.lineHeight;
                CGFloat lpValue = lineHeight / 2;
                if (self.lineSpaceIndex == 2) {
                    lpValue = lineHeight * 2 / 3;
                }else if (self.lineSpaceIndex == 3) {
                    lpValue = lineHeight * 6 / 7;
                }
                
                self.fontBlock(result, lpValue);
            }
        }
    }
}

//亮度改变
-(void)didSlideBrightSlider:(UISlider* )slider {
    if (slider == self.brightSlider) {
        float brightFloat = self.brightSlider.value;
        if (brightFloat != self.brightness) {
            self.brightness = brightFloat;
            if (self.brightBlock) {
                self.brightBlock(brightFloat);
            }
        }
    }
}

//切换背景
-(void)didClickBackgroundButton:(UIButton* )sender {
    self.bgBtn1.layer.borderColor = [UIColor clearColor].CGColor;
    self.bgBtn2.layer.borderColor = [UIColor clearColor].CGColor;
    self.bgBtn3.layer.borderColor = [UIColor clearColor].CGColor;
    self.bgBtn4.layer.borderColor = [UIColor clearColor].CGColor;
    self.bgBtn1.selected = NO;
    self.bgBtn2.selected = NO;
    self.bgBtn3.selected = NO;
    self.bgBtn1.selected = NO;
    
    sender.layer.borderColor = [UIColor redColor].CGColor;
    sender.selected = YES;
    
    NSInteger bgValue = 1;
    if (sender == self.bgBtn2) {
        bgValue = 2;
    }else if (sender == self.bgBtn3) {
        bgValue = 3;
    }else if (sender == self.bgBtn4) {
        bgValue = 4;
    }
    if (bgValue != self.bgInteger) {
        self.bgInteger = bgValue;
        if (self.bgBlock) {
            self.bgBlock(bgValue);
        }
    }
}

//切换行间距
-(void)didClickLineSpaceButton:(UIButton* )sender {
    self.lineSpaceBtn1.layer.borderColor = [UIColor clearColor].CGColor;
    self.lineSpaceBtn2.layer.borderColor = [UIColor clearColor].CGColor;
    self.lineSpaceBtn3.layer.borderColor = [UIColor clearColor].CGColor;
    self.lineSpaceBtn1.selected = NO;
    self.lineSpaceBtn2.selected = NO;
    self.lineSpaceBtn3.selected = NO;
    
    sender.layer.borderColor = [UIColor redColor].CGColor;
    sender.selected = YES;
    
    UIFont* currentFont = [UIFont systemFontOfSize:self.fontSize];
    CGFloat lineHeight = currentFont.lineHeight;
    CGFloat lpValue = lineHeight / 2;
    NSInteger lpInt = 1;
    if (sender == self.lineSpaceBtn2) {
        lpValue = lineHeight * 2 / 3;
        lpInt = 2;
    }else if (sender == self.lineSpaceBtn3) {
        lpValue = lineHeight * 6 / 7;
        lpInt = 3;
    }
    if (lpInt != self.lineSpaceIndex) {
        self.lineSpaceIndex = lpInt;
        if (self.lpBlock) {
            self.lpBlock(lpValue, lpInt);
        }
    }
}

-(void)showSettingViewWithFinalFrame:(CGRect )finalFrame {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = finalFrame;
    } completion:^(BOOL finished) {
        self.isShow = YES;
    }];
}

-(void)hideSettingViewWithFinalFrame:(CGRect )finalFrame {
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
