//
//  LMBaseArrowTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@interface LMBaseArrowTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* arrowIV;

-(void)showArrowImageView:(BOOL )isShow;

@end
