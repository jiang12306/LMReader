//
//  LMCommentStarView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMCommentStarViewBlock) (NSInteger starCount);

@interface LMCommentStarView : LMBaseAlertView

@property (nonatomic, copy) LMCommentStarViewBlock starBlock;

//是否允许点击评分 默认允许
@property (nonatomic, assign) BOOL cancelStar;
//从1开始
-(void)setupStarWithCount:(NSInteger )starCount;

//从1开始
-(void)setupStarWithFloatCount:(float )starCount;

@end

NS_ASSUME_NONNULL_END
