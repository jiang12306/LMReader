//
//  LMBaseBookTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "Ftbook.pb.h"

@interface LMBaseBookTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* coverIV;//封面
@property (nonatomic, strong) UILabel* nameLab;//书名
@property (nonatomic, strong) UILabel* authorLab;//作者
@property (nonatomic, strong) UILabel* type1Lab;//类型1
@property (nonatomic, strong) UILabel* type2Lab;//类型2
@property (nonatomic, strong) UILabel* type3Lab;//类型3  最多显示3种类型
@property (nonatomic, strong) UILabel* readersLab;//阅读人数
@property (nonatomic, strong) UILabel* briefLab;//简介

-(void)setupContentBook:(Book* )book;

@end
