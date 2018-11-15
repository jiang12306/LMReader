//
//  LMProfileTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@interface LMProfileTableViewCell : LMBaseArrowTableViewCell

@property (nonatomic, strong) UILabel* nameLab;//label
@property (nonatomic, strong) UIImageView* coverIV;//imageView

@property (nonatomic, strong) UILabel* markLab;//mark label
@property (nonatomic, strong) UIImageView* markIV;//mark imageView

-(void)setupShowArrowIV:(BOOL )showArrow showMarkLabel:(BOOL )showMarkLab showMarkIV:(BOOL )showMarkIV;

@end
