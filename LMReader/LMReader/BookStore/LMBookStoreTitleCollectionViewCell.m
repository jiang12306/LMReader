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
    self.backgroundColor = [UIColor whiteColor];
    
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.nameLab.textColor = [UIColor blackColor];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLab];
    }
    if (!self.lineLab) {
        self.lineLab = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width - 20) / 2, self.frame.size.height - 3, 20, 3)];
        self.lineLab.layer.cornerRadius = 1.5;
        self.lineLab.layer.masksToBounds = YES;
        self.lineLab.backgroundColor = [UIColor clearColor];
        [self addSubview:self.lineLab];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLab.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.lineLab.frame = CGRectMake((self.frame.size.width - 20) / 2, self.frame.size.height - 3, 20, 3);
}

-(void)setIsClicked:(BOOL)isClicked {
    if (isClicked) {
        self.nameLab.textColor = THEMEORANGECOLOR;
        self.lineLab.backgroundColor = THEMEORANGECOLOR;
    }else {
        self.nameLab.textColor = [UIColor blackColor];
        self.lineLab.backgroundColor = [UIColor clearColor];
    }
    _isClicked = isClicked;
}

@end
