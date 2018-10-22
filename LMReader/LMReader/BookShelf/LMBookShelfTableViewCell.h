//
//  LMBookShelfTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMBookShelfModel.h"

@class LMBookShelfTableViewCell;

@protocol LMBookShelfTableViewCellDelegate <NSObject>

@optional
-(void)didStartScrollCell:(LMBookShelfTableViewCell* )selectedCell;//滑动cell 开始
-(void)didClickCell:(LMBookShelfTableViewCell* )cell deleteButton:(UIButton* )btn;//点击 删除 按钮
-(void)didClickCell:(LMBookShelfTableViewCell* )cell upsideButton:(UIButton* )btn;//点击 收藏 按钮
-(void)didClickCell:(LMBookShelfTableViewCell* )cell briefButton:(UIButton* )btn;//点击 书籍详情 按钮

@end;

@interface LMBookShelfTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UIImageView* coverIV;//小说封面
@property (nonatomic, strong) UILabel* nameLab;//书名 label
@property (nonatomic, strong) UILabel* lastChapterLab;//最新章节 label
@property (nonatomic, strong) UILabel* statusLab;//状态 label
@property (nonatomic, strong) UIButton* briefBtn;//书籍简介 button
@property (nonatomic, strong) UILabel* markLab;//更新红点标记

@property (nonatomic, weak) id<LMBookShelfTableViewCellDelegate> delegate;

//显示/不显示 删除 置顶 按钮
-(void)showUpsideAndDelete:(BOOL )isShow animation:(BOOL)animation;

-(void)setupBookShelfModel:(LMBookShelfModel* )model;

@end
