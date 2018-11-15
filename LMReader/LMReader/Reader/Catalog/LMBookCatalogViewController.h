//
//  LMBookCatalogViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/17.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMBookCatalogViewControllerBlock) (BOOL didChange, NSInteger selectedIndex);

@interface LMBookCatalogViewController : LMBaseViewController

@property (nonatomic, assign) NSInteger fromWhich;/**<1.从阅读界面过来；2.从书籍详情界面过来*/
@property (nonatomic, assign) BOOL isNew;

@property (nonatomic, copy) NSString* bookNameStr;/**<书名*/
@property (nonatomic, assign) UInt32 bookId;

@property (nonatomic, copy) LMBookCatalogViewControllerBlock callBack;
@property (nonatomic, assign) NSInteger chapterIndex;
@property (nonatomic, strong) NSMutableArray* dataArray;//目录 章节列表

@end
