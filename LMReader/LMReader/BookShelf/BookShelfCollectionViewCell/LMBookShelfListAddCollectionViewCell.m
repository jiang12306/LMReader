//
//  LMBookShelfListAddCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfListAddCollectionViewCell.h"

@implementation LMBookShelfListAddCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.addBtn) {
        self.addBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 10, self.frame.size.width - 20 * 2, self.frame.size.height - 10 * 2)];
        self.addBtn.layer.cornerRadius = 5;
        self.addBtn.layer.masksToBounds = YES;
        self.addBtn.layer.borderColor = [UIColor colorWithRed:232.f/255 green:232.f/255 blue:232.f/255 alpha:1].CGColor;
        self.addBtn.layer.borderWidth = 1.f;
        [self.addBtn addTarget:self action:@selector(clickedAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.addBtn];
    }
    if (!self.addIV) {
        self.addIV = [[UIImageView alloc]initWithFrame:CGRectMake((self.addBtn.frame.size.width - 20) / 2 - 30, (self.addBtn.frame.size.height - 20) / 2, 20, 20)];
        self.addIV.image = [UIImage imageNamed:@"bookShelfSquareAdd"];
        [self.addBtn addSubview:self.addIV];
    }
    if (!self.addLab) {
        self.addLab = [[UILabel alloc]initWithFrame:CGRectMake(self.addIV.frame.origin.x + self.addIV.frame.size.width, self.addIV.frame.origin.y, 70, self.addIV.frame.size.height)];
        self.addLab.font = [UIFont systemFontOfSize:15];
        self.addLab.textColor = THEMEORANGECOLOR;
        self.addLab.textAlignment = NSTextAlignmentCenter;
        self.addLab.text = @"添加图书";
        [self.addBtn addSubview:self.addLab];
    }
}

-(void)clickedAddButton:(UIButton* )sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(LMBookShelfListAddCollectionViewCellDidClickAdd:)]) {
        [self.delegate LMBookShelfListAddCollectionViewCellDidClickAdd:self];
    }
}

-(void)setupListAddCellWithItemWidth:(CGFloat)itemWidth itemHeight:(CGFloat)itemHeight {
    self.addBtn.frame = CGRectMake(20, 10, itemWidth - 20 * 2, itemHeight - 10 * 2);
    self.addIV.frame = CGRectMake((self.addBtn.frame.size.width - 20) / 2 - 35, (self.addBtn.frame.size.height - 20) / 2, 20, 20);
    self.addLab.frame = CGRectMake(self.addIV.frame.origin.x + self.addIV.frame.size.width, self.addIV.frame.origin.y, 70, self.addIV.frame.size.height);
}

@end
