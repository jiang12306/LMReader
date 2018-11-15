//
//  LMProfileCenterTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@interface LMProfileCenterTableViewCell : LMBaseArrowTableViewCell

@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* contentLab;

-(void)setupShowContentLabel:(BOOL )show;

@end
