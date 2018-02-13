//
//  LMBookShelfTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@class LMBookShelfTableViewCell;

@protocol LMBookShelfTableViewCellDelegate <NSObject>

@optional
-(void)didStartScrollCell:(LMBookShelfTableViewCell* )selectedCell;//滑动cell 开始
-(void)didClickCell:(LMBookShelfTableViewCell* )cell deleteButton:(UIButton* )btn;//点击 删除 按钮
-(void)didClickCell:(LMBookShelfTableViewCell* )cell upsideButton:(UIButton* )btn;//点击 置顶 按钮

@end;

@interface LMBookShelfTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* coverIV;//小说封面
@property (nonatomic, strong) UILabel* nameLab;//书名 label
@property (nonatomic, strong) UILabel* timeLab;//更新时间 label
@property (nonatomic, strong) UILabel* briefLab;//简介 label
@property (nonatomic, strong) UILabel* updateLab;//更新标识 label

@property (nonatomic, weak) id<LMBookShelfTableViewCellDelegate> delegate;

//显示/不显示 删除 置顶 按钮
-(void)showUpsideAndDelete:(BOOL )isShow animation:(BOOL)animation;

-(void)setupContentUserBook:(UserBook* )userBook;

@end
