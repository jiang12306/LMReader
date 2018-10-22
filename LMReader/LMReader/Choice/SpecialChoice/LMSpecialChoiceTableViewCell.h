//
//  LMSpecialChoiceTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/3.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMSpecialChoiceModel.h"

@interface LMSpecialChoiceTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* briefLab;
@property (nonatomic, strong) UIImageView* coverIV;

-(void)setupSpecialChoiceModel:(LMSpecialChoiceModel* )model;

@end
