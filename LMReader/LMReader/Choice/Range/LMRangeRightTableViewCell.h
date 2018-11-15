//
//  LMRangeRightTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/5.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LMRangeRightTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* coverIV;//封面
@property (nonatomic, strong) UIImageView* markIV;//标签 图片
@property (nonatomic, strong) UILabel* nameLab;//书名
@property (nonatomic, strong) UILabel* briefLab;//简介
@property (nonatomic, strong) UIImageView* authorIV;//作者 图片
@property (nonatomic, strong) UILabel* authorLab;//作者

@property (nonatomic, strong) UILabel* stateLab;//状态标签 完结、连载中 等

-(void)setupContentBook:(Book* )book cellHeight:(CGFloat )cellHeight cellWidth:(CGFloat )cellWidth ivWidth:(CGFloat )ivWidth nameFontSize:(CGFloat )nameFontSize briefFontSize:(CGFloat )briefFontSize;

@end

NS_ASSUME_NONNULL_END
