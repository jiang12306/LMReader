//
//  LMBookStoreTitleCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/22.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookStoreTitleCollectionViewCell.h"

@implementation LMBookStoreTitleCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.nameLab) {
        self.backgroundColor = [UIColor whiteColor];
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        self.nameLab.textColor = [UIColor blackColor];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLab];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLab.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(void)setIsClicked:(BOOL)isClicked {
    if (isClicked) {
        self.nameLab.textColor = THEMEORANGECOLOR;
    }else {
        self.nameLab.textColor = [UIColor blackColor];
    }
    _isClicked = isClicked;
}

@end
