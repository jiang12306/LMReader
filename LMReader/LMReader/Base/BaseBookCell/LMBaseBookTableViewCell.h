//
//  LMBaseBookTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

static CGFloat baseBookCellHeight = 120;

@interface LMBaseBookTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* coverIV;//封面
@property (nonatomic, strong) UILabel* nameLab;//书名
@property (nonatomic, strong) UILabel* authorLab;//作者
@property (nonatomic, strong) UILabel* typeLab;//类型
@property (nonatomic, strong) UILabel* stateLab;//状态 完结 连载中...
@property (nonatomic, strong) UILabel* readersLab;//阅读人数
@property (nonatomic, strong) UILabel* briefLab;//简介

-(void)setupContentBook:(Book* )book;

@end
