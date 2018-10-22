//
//  LMNewCatalogViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/17.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMNewCatalogViewControllerBlock) (BOOL didChange, NSInteger selectedIndex);

@interface LMNewCatalogViewController : LMBaseViewController

@property (nonatomic, copy) LMNewCatalogViewControllerBlock callBack;
@property (nonatomic, assign) NSInteger chapterIndex;
@property (nonatomic, strong) NSMutableArray* dataArray;//目录 章节列表

@end
