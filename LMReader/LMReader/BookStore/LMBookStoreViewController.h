//
//  LMBookStoreViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum {
    LMBookStoreStateAll = 0,//全部
    LMBookStoreStateFinished = 1,//完结
    LMBookStoreStateLoad = 2,//连载中
}LMBookStoreState;

typedef enum {
    LMBookStoreRangeHot = 1,//人气
    LMBookStoreRangeNew = 2,//最新上架
    LMBookStoreRangeUp = 3,//上升最快
}LMBookStoreRange;

@interface LMBookStoreViewController : LMBaseViewController

@end
