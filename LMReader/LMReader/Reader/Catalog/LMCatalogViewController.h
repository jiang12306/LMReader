//
//  LMCatalogViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMCatalogViewControllerBlock) (BOOL didChange, NSMutableArray* catalogArr, NSInteger selectedIndex);

@interface LMCatalogViewController : LMBaseViewController

@property (nonatomic, assign) NSInteger chapterIndex;//当前章节角标
@property (nonatomic, assign) UInt32 bookId;
@property (nonatomic, copy) LMCatalogViewControllerBlock callBlock;

@property (nonatomic, strong) NSMutableArray* dataArray;//目录 章节列表

@end
