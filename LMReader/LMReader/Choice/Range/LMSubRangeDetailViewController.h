//
//  LMSubRangeDetailViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

@protocol LMSubRangeDetailViewControllerDelegate <NSObject>

@optional
-(void)LMSubRangeDetailViewControllerDidClickedBookId:(NSInteger )bookId;

@end


@interface LMSubRangeDetailViewController : LMBaseViewController

@property (nonatomic, assign) UInt32 rangeId;//排行榜id
@property (nonatomic, assign) UInt32 titleRangeId;//各大网站排行榜id

@property (nonatomic, assign) NSInteger markTag;//角标标记用

@property (nonatomic, weak) id<LMSubRangeDetailViewControllerDelegate> delegate;

@end
