//
//  LMReadPreferencesCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/20.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReadPreferencesCollectionViewCell.h"

@implementation LMReadPreferencesCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.backgroundColor = THEMEORANGECOLOR;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 20)];
        self.nameLab.textColor = [UIColor whiteColor];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        CGFloat fontSize = 18;
        if (screenRect.size.width == 320) {
            fontSize = 15;
        }
        self.nameLab.font = [UIFont systemFontOfSize:fontSize];
        [self addSubview:self.nameLab];
    }
}

-(void)setClicked:(BOOL)isClicked genderType:(GenderType)genderType {
    UIColor* maleColor =  [UIColor colorWithRed:74.f/255 green:178.f/255 blue:252.f/255 alpha:1];
    UIColor* femaleColor = [UIColor colorWithRed:251.f/255 green:126.f/255 blue:164.f/255 alpha:1];
    UIColor* textColor = [UIColor whiteColor];
    UIColor* bgColor = maleColor;
    UIColor* layerColor = maleColor;
    if (isClicked) {
        textColor = [UIColor whiteColor];
        if (genderType == GenderTypeGenderFemale) {
            bgColor = femaleColor;
            layerColor = femaleColor;
        }else {
            bgColor = maleColor;
            layerColor = maleColor;
        }
    }else {
        bgColor = [UIColor whiteColor];
        if (genderType == GenderTypeGenderFemale) {
            textColor = femaleColor;
            layerColor = femaleColor;
        }else {
            textColor = maleColor;
            layerColor = maleColor;
        }
    }
    self.nameLab.textColor = textColor;
    self.backgroundColor = bgColor;
    self.layer.borderColor = layerColor.CGColor;
}

@end
