//
//  LMProfileMessageTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/26.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMProfileMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LMProfileMessageTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UILabel* briefLab;
@property (nonatomic, strong) UILabel* timeLab;

-(void)setupProfileMessageWithModel:(LMProfileMessageModel* )model;

@end

NS_ASSUME_NONNULL_END
