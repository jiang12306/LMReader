//
//  LMChangeSourceTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/24.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@interface LMChangeSourceTableViewCell : LMBaseArrowTableViewCell

@property (nonatomic, strong) UILabel* coverLab;
@property (nonatomic, strong) UILabel* sourceLab;
@property (nonatomic, strong) UILabel* updateTimeLab;
@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* stateLab;

-(void)setupSourceWithSource:(Source* )source nameStr:(NSString* )nameStr isClicked:(BOOL )isClicked;

@end
