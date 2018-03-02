//
//  LMSpecialChoiceCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/22.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceCollectionViewCell.h"

@implementation LMSpecialChoiceCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.coverIV.layer.cornerRadius = 10;
        self.coverIV.layer.masksToBounds = YES;
        [self addSubview:self.coverIV];
    }
    if (!self.layerView) {
        self.layerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.coverIV.frame.size.height - 40, self.coverIV.frame.size.width, 30)];
        [self.coverIV addSubview:self.layerView];
    }
    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
        self.gradientLayer.bounds = _layerView.bounds;
        self.gradientLayer.borderWidth = 0;
        
        self.gradientLayer.frame = _layerView.bounds;
        self.gradientLayer.colors = [NSArray arrayWithObjects:
                                 (id)[[UIColor clearColor] CGColor],
                                 (id)[[UIColor blackColor] CGColor], nil];
        self.gradientLayer.startPoint = CGPointMake(0, 0.5);
        self.gradientLayer.endPoint = CGPointMake(1, 0.5);
        [self.layerView.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.layerView.frame.size.width - 30, self.layerView.frame.size.height)];
        self.nameLab.textColor = [UIColor whiteColor];
        self.nameLab.textAlignment = NSTextAlignmentRight;
        self.nameLab.font = [UIFont systemFontOfSize:18];
        [self.layerView addSubview:self.nameLab];
    }
}

-(void)layoutSubviews {
    self.coverIV.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (self.nameLab.text) {
        CGSize labSize = [self.nameLab sizeThatFits:CGSizeMake(CGFLOAT_MAX, 30)];
        self.layerView.frame = CGRectMake(self.frame.size.width - labSize.width - 30, self.frame.size.height - 40, labSize.width + 30, 30);
        self.nameLab.frame = CGRectMake(20, 0, self.layerView.frame.size.width - 30, self.layerView.frame.size.height);
    }
    
}

@end
