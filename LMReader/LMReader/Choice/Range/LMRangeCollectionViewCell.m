//
//  LMRangeCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRangeCollectionViewCell.h"

@implementation LMRangeCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    self.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 50 - 10, 10, 50, 50)];
        self.coverIV.clipsToBounds = YES;
        self.coverIV.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.coverIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.frame.size.width - self.coverIV.frame.size.width - 10 * 3, self.frame.size.height - 10 * 2)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.nameLab.textColor = [UIColor colorWithRed:120.f / 255 green:120.f / 255 blue:120.f / 255 alpha:1];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:self.nameLab];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverIV.frame = CGRectMake(self.frame.size.width - 50 - 10, 10, 50, 50);
    self.nameLab.frame = CGRectMake(10, 10, self.frame.size.width - 50 - 10 * 3, self.frame.size.height - 10 * 2);
}

@end
