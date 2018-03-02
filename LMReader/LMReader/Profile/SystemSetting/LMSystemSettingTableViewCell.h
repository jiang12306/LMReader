//
//  LMSystemSettingTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@class LMSystemSettingTableViewCell;

@protocol LMSystemSettingTableViewCellDelegate <NSObject>

-(void)didClickSwitch:(BOOL )isOn systemSettingCell:(LMSystemSettingTableViewCell* )cell;

@end

@interface LMSystemSettingTableViewCell : LMBaseTableViewCell

@property (nonatomic, weak) id <LMSystemSettingTableViewCellDelegate> delegate;

@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* contentLab;
@property (nonatomic, strong) UISwitch* contentSwitch;

@end
