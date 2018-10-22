//
//  LMBookCommentDetailViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LMBookCommentDetailViewController : LMBaseViewController

@property (nonatomic, assign) UInt32 bookId;
@property (nonatomic, copy) NSString* bookName;

@end

NS_ASSUME_NONNULL_END
