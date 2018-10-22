//
//  LMRangeDetailViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LMRangeDetailViewController : LMBaseViewController

@property (nonatomic, assign) UInt32 rangeId;
@property (nonatomic, copy) NSString* titleStr;

@property (nonatomic, strong) NSMutableArray* dataArray;

@end
