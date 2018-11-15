//
//  LMBookCommentTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"
#import "LMCommentStarView.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat CommentAvatorIVWidth = 50;
static CGFloat CommentNameFontSize = 15;
static CGFloat CommentContentFontSize = 12;
static CGFloat CommentNameLabHeight = 25;
static CGFloat CommentStarViewHeight = 15;
static CGFloat CommentLikeBtnHeight = 15;

@class LMBookCommentTableViewCell;

@protocol LMBookCommentTableViewCellDelegate <NSObject>

@optional
-(void)bookCommentTableViewCellDidClickedLikeButton:(LMBookCommentTableViewCell* )cell;//点赞

@end

@interface LMBookCommentTableViewCell : LMBaseTableViewCell

@property (nonatomic, weak) id<LMBookCommentTableViewCellDelegate> delegate;

@property (nonatomic, strong) UIImageView* avatorIV;
@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* timeLab;
@property (nonatomic, strong) UILabel* contentLab;
@property (nonatomic, strong) LMCommentStarView* starView;
@property (nonatomic, strong) UIButton* likeBtn;/**<点赞btn*/
@property (nonatomic, strong) UIImageView* likeIV;/**<点赞个数imageview*/
@property (nonatomic, strong) UILabel* likeLab;/**<点赞个数label*/

-(void)setupContentWithComment:(Comment* )comment;

//计算label高度
+(CGFloat )caculateLabelHeightWithWidth:(CGFloat )width text:(NSString* )text font:(UIFont* )font maxLines:(NSInteger )maxLines;

@end

NS_ASSUME_NONNULL_END
