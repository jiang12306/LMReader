//
//  LMReaderSettingView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderSettingView.h"

@implementation LMReaderSettingView

-(instancetype)initWithFrame:(CGRect )frame fontSize:(CGFloat )fontSize bgInteger:(NSInteger )bgInteger lineSpaceIndex:(NSInteger )lineSpaceIndex {
    self = [super initWithFrame:frame];
    if (self) {
        self.fontSize = fontSize;
        self.bgInteger = bgInteger;
        self.lineSpaceIndex = lineSpaceIndex;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.backgroundColor = [UIColor whiteColor];
        
        //字号
        self.fontLab = [self createLabelWithFrame:CGRectMake(20, 20, 40, 30) title:@"字号"];
        [self addSubview:self.fontLab];
        
        CGFloat fontBtnWidth = (screenWidth - 20 * 3 - self.fontLab.frame.size.width - 40) / 2;
        self.fontSmallBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.fontLab.frame.origin.x + self.fontLab.frame.size.width + 20, self.fontLab.frame.origin.y, fontBtnWidth, 30)];
        self.fontSmallBtn.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        self.fontSmallBtn.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.fontSmallBtn.layer.borderWidth = 1.f;
        [self.fontSmallBtn setImage:[[UIImage imageNamed:@"settingView_Font_Small"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.fontSmallBtn setImageEdgeInsets:UIEdgeInsetsMake(2.5, (fontBtnWidth - 25) / 2, 2.5, (fontBtnWidth - 25) / 2)];
        self.fontSmallBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        [self.fontSmallBtn addTarget:self action:@selector(clickedFontChangeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.fontSmallBtn];
        
        self.currentFontLab = [self createLabelWithFrame:CGRectMake(self.fontSmallBtn.frame.origin.x + self.fontSmallBtn.frame.size.width, self.fontSmallBtn.frame.origin.y, 40, 30) title:[NSString stringWithFormat:@"%d", (int )fontSize]];
        [self addSubview:self.currentFontLab];
        
        self.fontBigBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.currentFontLab.frame.origin.x + self.currentFontLab.frame.size.width, self.fontLab.frame.origin.y, fontBtnWidth, 30)];
        self.fontBigBtn.backgroundColor = [UIColor whiteColor];
        self.fontBigBtn.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.fontBigBtn.layer.borderWidth = 1.f;
        [self.fontBigBtn setImage:[[UIImage imageNamed:@"settingView_Font_Big"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.fontBigBtn setImageEdgeInsets:UIEdgeInsetsMake(2.5, (fontBtnWidth - 25) / 2, 2.5, (fontBtnWidth - 25) / 2)];
        self.fontBigBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        [self.fontBigBtn addTarget:self action:@selector(clickedFontChangeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.fontBigBtn];
        
        //背景
        self.bgLab = [self createLabelWithFrame:CGRectMake(self.fontLab.frame.origin.x, self.fontLab.frame.origin.y + self.fontLab.frame.size.height + 20, self.fontLab.frame.size.width, self.fontLab.frame.size.height) title:@"背景"];
        [self addSubview:self.bgLab];
        
        CGFloat bgBtnWidth = (screenWidth - self.bgLab.frame.origin.x - self.bgLab.frame.size.width - 20 * 2 - 10 * 3) / 4;
        self.bgBtn1 = [self createButtonWithFrame:CGRectMake(self.bgLab.frame.origin.x + self.bgLab.frame.size.width + 20, self.bgLab.frame.origin.y, bgBtnWidth, 30) bgColor:[UIColor colorWithRed:245.f/255 green:245.f/255 blue:245.f/255 alpha:1] selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn1];
        self.bgBtn2 = [self createButtonWithFrame:CGRectMake(self.bgBtn1.frame.origin.x + self.bgBtn1.frame.size.width + 10, self.bgBtn1.frame.origin.y, self.bgBtn1.frame.size.width, self.bgBtn1.frame.size.height) bgColor:[UIColor colorWithRed:240.f/255 green:240.f/255 blue:230.f/255 alpha:1] selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn2];
        self.bgBtn3 = [self createButtonWithFrame:CGRectMake(self.bgBtn2.frame.origin.x + self.bgBtn2.frame.size.width + 10, self.bgBtn1.frame.origin.y, self.bgBtn1.frame.size.width, self.bgBtn1.frame.size.height) bgColor:[UIColor colorWithRed:183.f/255 green:230.f/255 blue:192.f/255 alpha:1] selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn3];
        self.bgBtn4 = [self createButtonWithFrame:CGRectMake(self.bgBtn3.frame.origin.x + self.bgBtn3.frame.size.width + 10, self.bgBtn1.frame.origin.y, self.bgBtn1.frame.size.width, self.bgBtn1.frame.size.height) bgColor:[UIColor colorWithRed:15.f/255 green:15.f/255 blue:15.f/255 alpha:1] selector:@selector(didClickBackgroundButton:)];
        [self addSubview:self.bgBtn4];
        
        if (bgInteger == 1) {
            self.bgBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (bgInteger == 2) {
            self.bgBtn2.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (bgInteger == 3) {
            self.bgBtn3.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (bgInteger == 4) {
            self.bgBtn4.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else {
            self.bgBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }
        
        //行间距
        self.lineSpaceLab = [self createLabelWithFrame:CGRectMake(self.bgLab.frame.origin.x, self.bgLab.frame.origin.y + self.bgLab.frame.size.height + 20, self.bgLab.frame.size.width, self.bgLab.frame.size.height) title:@"行距"];
        [self addSubview:self.lineSpaceLab];
        
        CGFloat lpBtnWidth = (screenWidth - self.lineSpaceLab.frame.origin.x - self.lineSpaceLab.frame.size.width - 20 * 2) / 3;
        self.lineSpaceBtn1 = [self createButtonWithFrame:CGRectMake(self.lineSpaceLab.frame.origin.x + self.lineSpaceLab.frame.size.width + 20, self.lineSpaceLab.frame.origin.y, lpBtnWidth, 30) bgColor:[UIColor whiteColor] selector:@selector(didClickLineSpaceButton:)];
        [self.lineSpaceBtn1 setImage:[[UIImage imageNamed:@"readerSetting_LineSpace1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.lineSpaceBtn1 setImageEdgeInsets:UIEdgeInsetsMake(2.5, (lpBtnWidth - 25) / 2, 2.5, (lpBtnWidth - 25) / 2)];
        self.lineSpaceBtn1.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.lineSpaceBtn1.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        [self addSubview:self.lineSpaceBtn1];
        
        self.lineSpaceBtn2 = [self createButtonWithFrame:CGRectMake(self.lineSpaceBtn1.frame.origin.x + self.lineSpaceBtn1.frame.size.width, self.lineSpaceBtn1.frame.origin.y, self.lineSpaceBtn1.frame.size.width, self.lineSpaceBtn1.frame.size.height) bgColor:[UIColor whiteColor] selector:@selector(didClickLineSpaceButton:)];
        [self.lineSpaceBtn2 setImage:[[UIImage imageNamed:@"readerSetting_LineSpace2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.lineSpaceBtn2 setImageEdgeInsets:UIEdgeInsetsMake(2.5, (lpBtnWidth - 25) / 2, 2.5, (lpBtnWidth - 25) / 2)];
        self.lineSpaceBtn2.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.lineSpaceBtn2.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        [self addSubview:self.lineSpaceBtn2];
        
        self.lineSpaceBtn3 = [self createButtonWithFrame:CGRectMake(self.lineSpaceBtn2.frame.origin.x + self.lineSpaceBtn2.frame.size.width, self.lineSpaceBtn1.frame.origin.y, self.lineSpaceBtn2.frame.size.width, self.lineSpaceBtn2.frame.size.height) bgColor:[UIColor whiteColor] selector:@selector(didClickLineSpaceButton:)];
        [self.lineSpaceBtn3 setImage:[[UIImage imageNamed:@"readerSetting_LineSpace3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.lineSpaceBtn3 setImageEdgeInsets:UIEdgeInsetsMake(2.5, (lpBtnWidth - 25) / 2, 2.5, (lpBtnWidth - 25) / 2)];
        self.lineSpaceBtn3.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.lineSpaceBtn3.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        [self addSubview:self.lineSpaceBtn3];
        
        if (lineSpaceIndex == 1) {
            self.lineSpaceBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn1.tintColor = THEMEORANGECOLOR;
        }else if (lineSpaceIndex == 2) {
            self.lineSpaceBtn2.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn2.tintColor = THEMEORANGECOLOR;
        }else if (lineSpaceIndex == 3) {
            self.lineSpaceBtn3.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn3.tintColor = THEMEORANGECOLOR;
        }else {
            self.lineSpaceBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn1.tintColor = THEMEORANGECOLOR;
        }
        
        LMReadModel tempModel = LMReaderBackgroundType1;
        if (self.bgInteger == 1) {
            tempModel = LMReaderBackgroundType1;
        }else if (self.bgInteger == 2) {
            tempModel = LMReaderBackgroundType2;
        }else if (self.bgInteger == 3) {
            tempModel = LMReaderBackgroundType3;
        }else if (self.bgInteger == 4) {
            tempModel = LMReaderBackgroundType4;
        }
        [self reloadReaderSettingViewWithModel:tempModel];
        
        self.isShow = NO;
    }
    return self;
}

//字体改变
-(void)clickedFontChangeButton:(UIButton* )sender {
    CGFloat value = self.fontSize;
    if (sender == self.fontSmallBtn) {
        value = self.fontSize - 1;
        if (value < ReaderMinFontSize) {
            value = ReaderMinFontSize;
            return;
        }
    }else if (sender == self.fontBigBtn) {
        value = self.fontSize + 1;
        if (value > ReaderMaxFontSize) {
            value = ReaderMaxFontSize;
            return;
        }
    }
    
    self.fontSize = value;
    self.currentFontLab.text = [NSString stringWithFormat:@"%d", (int )value];
    if (self.fontBlock) {
        UIFont* currentFont = [UIFont systemFontOfSize:self.fontSize];
        CGFloat lineHeight = currentFont.lineHeight;
        CGFloat lpValue = lineHeight / 2;
        if (self.lineSpaceIndex == 2) {
            lpValue = lineHeight * 2 / 3;
        }else if (self.lineSpaceIndex == 3) {
            lpValue = lineHeight * 6 / 7;
        }
        self.fontBlock(value, lpValue);
    }
}

//UILabel
-(UILabel* )createLabelWithFrame:(CGRect )frame title:(NSString* )title {
    UILabel* lab = [[UILabel alloc]initWithFrame:frame];
    lab.font = [UIFont systemFontOfSize:15];
    lab.textColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = title;
    return lab;
}

//UIButton
-(UIButton* )createButtonWithFrame:(CGRect )frame bgColor:(UIColor* )bgColor selector:(SEL )selector {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    btn.layer.cornerRadius = 0;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 1.f;
    if (bgColor) {
        btn.backgroundColor = bgColor;
    }
    if (selector) {
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
}

//切换背景
-(void)didClickBackgroundButton:(UIButton* )sender {
    LMReadModel tempModel = LMReaderBackgroundType1;
    if (sender == self.bgBtn1) {
        if (self.bgInteger == 1) {
            return;
        }
        self.bgInteger = 1;
        tempModel = LMReaderBackgroundType1;
    }else if (sender == self.bgBtn2) {
        if (self.bgInteger == 2) {
            return;
        }
        self.bgInteger = 2;
        tempModel = LMReaderBackgroundType2;
    }else if (sender == self.bgBtn3) {
        if (self.bgInteger == 3) {
            return;
        }
        self.bgInteger = 3;
        tempModel = LMReaderBackgroundType3;
    }else if (sender == self.bgBtn4) {
        if (self.bgInteger == 4) {
            return;
        }
        self.bgInteger = 4;
        tempModel = LMReaderBackgroundType4;
    }else {
        self.bgInteger = 1;
    }
    
    [self reloadReaderSettingViewWithModel:tempModel];
    
    //
    if (self.bgBlock) {
        self.bgBlock(self.bgInteger);
    }
}

//切换行间距
-(void)didClickLineSpaceButton:(UIButton* )sender {
    if (sender == self.lineSpaceBtn1) {
        if (self.lineSpaceIndex == 1) {
            return;
        }
        self.lineSpaceIndex = 1;
    }else if (sender == self.lineSpaceBtn2) {
        if (self.lineSpaceIndex == 2) {
            return;
        }
        self.lineSpaceIndex = 2;
    }else if (sender == self.lineSpaceBtn3) {
        if (self.lineSpaceIndex == 3) {
            return;
        }
        self.lineSpaceIndex = 3;
    }else {
        self.lineSpaceIndex = 1;
    }
    
    LMReadModel tempModel = LMReaderBackgroundType1;
    if (self.bgInteger == 1) {
        tempModel = LMReaderBackgroundType1;
    }else if (self.bgInteger == 2) {
        tempModel = LMReaderBackgroundType2;
    }else if (self.bgInteger == 3) {
        tempModel = LMReaderBackgroundType3;
    }else if (self.bgInteger == 4) {
        tempModel = LMReaderBackgroundType4;
    }
    [self reloadReaderSettingViewWithModel:tempModel];
    
    
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
    
    if (self.lpBlock) {
        self.lpBlock(lpValue, lpInt);
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

-(void)reloadReaderSettingViewWithModel:(LMReadModel)currentModel {
    if (currentModel == LMReaderBackgroundType4) {
        self.backgroundColor = [UIColor colorWithRed:27.f/255 green:27.f/255 blue:27.f/255 alpha:1];
        
        //字号
        self.fontSmallBtn.backgroundColor = [UIColor clearColor];
        self.fontBigBtn.backgroundColor = [UIColor clearColor];
        self.fontSmallBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.fontBigBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.fontSmallBtn.layer.borderColor = [UIColor colorWithRed:80.f/255 green:80.f/255 blue:80.f/255 alpha:1].CGColor;
        self.fontBigBtn.layer.borderColor = [UIColor colorWithRed:80.f/255 green:80.f/255 blue:80.f/255 alpha:1].CGColor;
        
        //背景
        self.bgBtn1.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bgBtn2.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bgBtn3.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bgBtn4.layer.borderColor = [UIColor whiteColor].CGColor;
        if (self.bgInteger == 1) {
            self.bgBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.bgInteger == 2) {
            self.bgBtn2.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.bgInteger == 3) {
            self.bgBtn3.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.bgInteger == 4) {
            self.bgBtn4.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else {
            self.bgBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }
        
        //行距
        self.lineSpaceBtn1.layer.borderColor = [UIColor whiteColor].CGColor;
        self.lineSpaceBtn2.layer.borderColor = [UIColor whiteColor].CGColor;
        self.lineSpaceBtn3.layer.borderColor = [UIColor whiteColor].CGColor;
        self.lineSpaceBtn1.tintColor = [UIColor whiteColor];
        self.lineSpaceBtn2.tintColor = [UIColor whiteColor];
        self.lineSpaceBtn3.tintColor = [UIColor whiteColor];
        self.lineSpaceBtn1.backgroundColor = [UIColor clearColor];
        self.lineSpaceBtn2.backgroundColor = [UIColor clearColor];
        self.lineSpaceBtn3.backgroundColor = [UIColor clearColor];
        if (self.lineSpaceIndex == 1) {
            self.lineSpaceBtn1.tintColor = THEMEORANGECOLOR;
            self.lineSpaceBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.lineSpaceIndex == 2) {
            self.lineSpaceBtn2.tintColor = THEMEORANGECOLOR;
            self.lineSpaceBtn2.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.lineSpaceIndex == 3) {
            self.lineSpaceBtn3.tintColor = THEMEORANGECOLOR;
            self.lineSpaceBtn3.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else {
            self.lineSpaceBtn1.tintColor = THEMEORANGECOLOR;
            self.lineSpaceBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }
    }else {
        self.backgroundColor = [UIColor whiteColor];
        
        //字号
        self.fontSmallBtn.backgroundColor = [UIColor whiteColor];
        self.fontBigBtn.backgroundColor = [UIColor whiteColor];
        self.fontSmallBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.fontBigBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.fontSmallBtn.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.fontBigBtn.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        
        //背景
        self.bgBtn1.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.bgBtn2.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.bgBtn3.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.bgBtn4.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        if (self.bgInteger == 1) {
            self.bgBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.bgInteger == 2) {
            self.bgBtn2.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.bgInteger == 3) {
            self.bgBtn3.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else if (self.bgInteger == 4) {
            self.bgBtn4.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }else {
            self.bgBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
        }
        
        //行距
        self.lineSpaceBtn1.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.lineSpaceBtn2.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.lineSpaceBtn3.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.lineSpaceBtn1.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.lineSpaceBtn2.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.lineSpaceBtn3.layer.borderColor = [UIColor colorWithRed:210.f/255 green:210.f/255 blue:210.f/255 alpha:1].CGColor;
        self.lineSpaceBtn1.backgroundColor = [UIColor whiteColor];
        self.lineSpaceBtn2.backgroundColor = [UIColor whiteColor];
        self.lineSpaceBtn3.backgroundColor = [UIColor whiteColor];
        if (self.lineSpaceIndex == 1) {
            self.lineSpaceBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn1.tintColor = THEMEORANGECOLOR;
        }else if (self.lineSpaceIndex == 2) {
            self.lineSpaceBtn2.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn2.tintColor = THEMEORANGECOLOR;
        }else if (self.lineSpaceIndex == 3) {
            self.lineSpaceBtn3.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn3.tintColor = THEMEORANGECOLOR;
        }else {
            self.lineSpaceBtn1.layer.borderColor = THEMEORANGECOLOR.CGColor;
            self.lineSpaceBtn1.tintColor = THEMEORANGECOLOR;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
