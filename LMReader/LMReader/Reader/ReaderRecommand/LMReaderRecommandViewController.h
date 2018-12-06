//
//  LMReaderRecommandViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/30.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LMReaderRecommandViewControllerDelegate <NSObject>

@optional
-(void)readerRecommandViewControllerDidClickedEditCommentButton;
-(void)readerRecommandViewControllerDidClickedBookStoreButton;
-(void)readerRecommandViewControllerDidClickedBook:(Book* )clickedBook;

@end

@interface LMReaderRecommandViewController : LMBaseViewController

@property (nonatomic, assign) UInt32 bookId;

@property (nonatomic, weak) id<LMReaderRecommandViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
