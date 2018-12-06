//
//  LMReaderBookViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/13.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"
#import "LMReaderBook.h"

typedef void (^LMReaderBookViewControllerBlock) (BOOL resetOrder);

@interface LMReaderBookViewController : LMBaseViewController

@property (nonatomic, assign) UInt32 bookId;
@property (nonatomic, copy) NSString* bookName;
@property (nonatomic, copy) NSString* bookCover;
@property (nonatomic, copy) LMReaderBookViewControllerBlock callBlock;

@property (nonatomic, strong) LMReaderBook* readerBook;

@end
