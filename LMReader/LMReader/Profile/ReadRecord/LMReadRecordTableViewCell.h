//
//  LMReadRecordTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"
#import "LMReadRecordModel.h"

@class LMReadRecordTableViewCell;

@protocol LMReadRecordTableViewCellDelegate <NSObject>

@optional
-(void)didStartScrollCell:(LMReadRecordTableViewCell* )selectedCell;//滑动cell 开始
-(void)didClickCell:(LMReadRecordTableViewCell* )cell deleteButton:(UIButton* )btn;//点击 删除 按钮
-(void)didClickCell:(LMReadRecordTableViewCell* )cell collectButton:(UIButton* )btn;//点击 置顶 按钮

@end;


@interface LMReadRecordTableViewCell : LMBaseTableViewCell

@property (nonatomic, weak) id <LMReadRecordTableViewCellDelegate> delegate;

@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* timeLab;
//
-(void)setupReadRecordWithModel:(LMReadRecordModel* )model;
//显示/不显示 删除 置顶 按钮
-(void)showCollectAndDelete:(BOOL )isShow animation:(BOOL)animation;

@end
