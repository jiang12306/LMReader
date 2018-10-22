//
//  LMChangeSourceViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMChangeSourceViewControllerBlock) (BOOL didChange, NSInteger selectedIndex);

@interface LMChangeSourceViewController : LMBaseViewController

@property (nonatomic, assign) UInt32 bookId;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, strong) NSMutableArray* sourceArr;
@property (nonatomic, assign) NSInteger sourceIndex;
@property (nonatomic, copy) LMChangeSourceViewControllerBlock callBlock;

@end
