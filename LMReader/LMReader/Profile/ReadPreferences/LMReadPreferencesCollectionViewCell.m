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
    self.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 20)];
        self.nameLab.textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
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
    UIColor* textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
    UIColor* bgColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255 alpha:1];
    if (isClicked) {
        textColor = [UIColor whiteColor];
        bgColor = THEMEORANGECOLOR;
    }
    self.nameLab.textColor = textColor;
    self.backgroundColor = bgColor;
}

@end
