//
//  LMRangeTitleCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRangeTitleCollectionViewCell.h"

@implementation LMRangeTitleCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    self.backgroundColor = [UIColor whiteColor];
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.nameLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLab];
    }
    if (!self.lineLab) {
        self.lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 2 - 5, 20, 2)];
        self.lineLab.backgroundColor = THEMEORANGECOLOR;
        [self addSubview:self.lineLab];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLab.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.lineLab.frame = CGRectMake((self.frame.size.width - 20) / 2, self.frame.size.height - 2 - 5, 20, 2);
}

-(void)setupClciked:(BOOL)isClicked {
    if (isClicked) {
        self.nameLab.textColor = THEMEORANGECOLOR;
        self.lineLab.hidden = NO;
    }else {
        self.nameLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.lineLab.hidden = YES;
    }
}

@end
