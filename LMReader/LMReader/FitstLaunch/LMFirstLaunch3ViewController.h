//
//  LMFirstLaunch3ViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^Launch3Block) (BOOL didClick, NSArray* bookArr);

@interface LMFirstLaunch3ViewController : LMBaseViewController

@property (nonatomic, copy) Launch3Block callBlock;

-(void) loadInterestDataWithDic:(NSDictionary* )dic;

@end
