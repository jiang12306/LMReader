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
-(void)didScrollCell:(LMBookShelfTableViewCell* )selectedCell;//滑动cell
-(void)didClickCell:(LMBookShelfTableViewCell* )cell deleteButton:(UIButton* )btn;//点击 删除 按钮
-(void)didClickCell:(LMBookShelfTableViewCell* )cell upsideButton:(UIButton* )btn;//点击 置顶 按钮

@end;

@interface LMBookShelfTableViewCell : LMBaseTableViewCell

@property (nonatomic, weak) id<LMBookShelfTableViewCellDelegate> delegate;

-(void)resetScrollViewAnimation:(BOOL )animation;//复原scrollView  animation 默认为NO
-(void)editScrollViewAnimation:(BOOL )animation;//编辑模式，显示 删除 置顶 按钮 animation 默认为NO

@end
