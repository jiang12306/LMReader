//
//  LMSearchBeforeViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/14.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMSearchBeforeViewControllerCleanHistoryBlock) (BOOL didClean);
typedef void (^LMSearchBeforeViewControllerHistoryBlock) (NSString* selectedStr);
typedef void (^LMSearchBeforeViewControllerStringBlock) (NSString* selectedStr);
typedef void (^LMSearchBeforeViewControllerBookBlock) (UInt32 selectedBookId);

@interface LMSearchBeforeViewController : LMBaseViewController

@property (nonatomic, copy) LMSearchBeforeViewControllerCleanHistoryBlock cleanBlock;/**<清空搜索历史*/
@property (nonatomic, copy) LMSearchBeforeViewControllerHistoryBlock historyBlock;/**<点击搜索历史回调*/
@property (nonatomic, copy) LMSearchBeforeViewControllerStringBlock stringBlock;/**<点击推荐搜索字符串回调*/
@property (nonatomic, copy)LMSearchBeforeViewControllerBookBlock bookBlock;/**<点击书本回调*/

-(void)resetupSearchHistoryDataWithArray:(NSArray* )historyArr;

@end
