//
//  LMBookShelfEditViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/29.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"
#import "LMBookShelfViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMBookShelfEditViewControllerBackBlock) (BOOL didBack, BOOL didChanged);

@interface LMBookShelfEditViewController : LMBaseViewController

@property (nonatomic, copy) LMBookShelfEditViewControllerBackBlock backBlock;

@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) LMBookShelfType type;

@end

NS_ASSUME_NONNULL_END
