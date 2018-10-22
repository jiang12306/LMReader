//
//  LMProfileBookCommentTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/27.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMCommentStarView.h"

NS_ASSUME_NONNULL_BEGIN

@class LMProfileBookCommentTableViewCell;

@protocol LMProfileBookCommentTableViewCellDelegate <NSObject>

@optional
-(void)bookCommentTableViewCellDidClickedDelete:(LMProfileBookCommentTableViewCell* )cell;//删除
-(void)bookCommentTableViewCellDidClickedLike:(LMProfileBookCommentTableViewCell* )cell;//点赞

@end

@interface LMProfileBookCommentTableViewCell : LMBaseTableViewCell

@property (nonatomic, weak) id<LMProfileBookCommentTableViewCellDelegate> delegate;

@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) LMCommentStarView* starView;
@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UILabel* contentLab;
@property (nonatomic, strong) UIButton* deleteBtn;/**<删除btn*/
@property (nonatomic, strong) UIButton* likeBtn;/**<点赞btn*/
@property (nonatomic, strong) UIImageView* likeIV;/**<点赞个数imageview*/
@property (nonatomic, strong) UILabel* likeLab;/**<点赞个数label*/

-(void)setupContentWith:(CommentBook* )commentBook;

@end

NS_ASSUME_NONNULL_END
