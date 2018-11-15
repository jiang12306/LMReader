//
//  LMRangeLeftTypeTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/2.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LMRangeLeftTypeTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* titleLab;

-(void)setupClicked:(BOOL )clicked;

@end

NS_ASSUME_NONNULL_END
