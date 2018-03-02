//
//  LMInterestOrEndViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum {
    LMInterestType = 0,
    LMEndType = 1,
}LMInterestOrEndType;

@interface LMInterestOrEndViewController : LMBaseViewController

@property (nonatomic, assign) LMInterestOrEndType type;

@end
