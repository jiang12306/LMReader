//
//  LMBookEditCommentViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMBookEditCommentViewControllerBlock) (BOOL didComment);

@interface LMBookEditCommentViewController : LMBaseViewController

@property (nonatomic, assign) UInt32 bookId;
@property (nonatomic, copy) LMBookEditCommentViewControllerBlock commentBlock;/**<评论完回调*/

@end

NS_ASSUME_NONNULL_END
