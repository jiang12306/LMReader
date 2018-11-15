//
//  LMSearchBeforeCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/14.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchBeforeCollectionViewCell.h"

@implementation LMSearchBeforeCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.nameLab) {
        self.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.nameLab.font = [UIFont systemFontOfSize:15];
        self.nameLab.textColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
        [self addSubview:self.nameLab];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLab.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
