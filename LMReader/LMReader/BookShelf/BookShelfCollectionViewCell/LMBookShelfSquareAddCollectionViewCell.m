//
//  LMBookShelfSquareAddCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfSquareAddCollectionViewCell.h"

@implementation LMBookShelfSquareAddCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.addBtn) {
        self.addBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width - 5 * 2, self.frame.size.height - 5 * 2)];
        self.addBtn.layer.cornerRadius = 1;
        self.addBtn.layer.masksToBounds = YES;
        self.addBtn.layer.borderColor = [UIColor colorWithRed:232.f/255 green:232.f/255 blue:232.f/255 alpha:1].CGColor;
        self.addBtn.layer.borderWidth = 1.f;
        [self.addBtn addTarget:self action:@selector(clickedAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.addBtn];
    }
    if (!self.addIV) {
        self.addIV = [[UIImageView alloc]initWithFrame:CGRectMake((self.addBtn.frame.size.width - 25) / 2, (self.addBtn.frame.size.height - 25) / 2, 25, 25)];
        self.addIV.image = [UIImage imageNamed:@"bookShelfSquareAdd"];
        [self.addBtn addSubview:self.addIV];
    }
    if (!self.addLab) {
        self.addLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.addIV.frame.origin.y + self.addIV.frame.size.height, self.frame.size.width, 30)];
        self.addLab.font = [UIFont systemFontOfSize:15];
        self.addLab.textColor = THEMEORANGECOLOR;
        self.addLab.textAlignment = NSTextAlignmentCenter;
        self.addLab.text = @"添加图书";
        [self.addBtn addSubview:self.addLab];
    }
}

-(void)clickedAddButton:(UIButton* )sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(LMBookShelfSquareAddCollectionViewCellDidClickAdd:)]) {
        [self.delegate LMBookShelfSquareAddCollectionViewCellDidClickAdd:self];
    }
}

-(void)setupSquareAddCellWithIvWidth:(CGFloat)ivWidth ivHeight:(CGFloat)ivHeight {
    self.addBtn.frame = CGRectMake(5, 5, ivWidth, ivHeight);
    self.addIV.frame = CGRectMake((self.addBtn.frame.size.width - 25) / 2, (self.addBtn.frame.size.height - 25) / 2, 25, 25);
    self.addLab.frame = CGRectMake(0, self.addIV.frame.origin.y + self.addIV.frame.size.height, self.addBtn.frame.size.width, 30);
}

@end
