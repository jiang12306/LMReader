//
//  LMFirstLaunch2ViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^Launch2Block) (NSDictionary* blockDic);

@interface LMFirstLaunch2ViewController : LMBaseViewController

@property (nonatomic, copy) Launch2Block callBlock;

@end
