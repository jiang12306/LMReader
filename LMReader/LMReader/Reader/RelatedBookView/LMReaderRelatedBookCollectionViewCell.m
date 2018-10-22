//
//  LMReaderRelatedBookCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderRelatedBookCollectionViewCell.h"

@implementation LMReaderRelatedBookCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectZero];//CGRectMake(0, 0, 55, 75)
        [self addSubview:self.coverIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectZero];//CGRectMake(0, self.coverIV.frame.origin.y + self.coverIV.frame.size.height, self.frame.size.width, 40)
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.nameLab.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.nameLab];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverIV.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width / 3 * 4);
    self.nameLab.frame = CGRectMake(0, self.coverIV.frame.origin.y + self.coverIV.frame.size.height, self.frame.size.width, self.frame.size.height - self.coverIV.frame.size.height);
}

@end
