//
//  LMLoginViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMLoginViewControllerBlock) (LoginedRegUser* loginUser);

@interface LMLoginViewController : LMBaseViewController

@property (nonatomic, copy) LMLoginViewControllerBlock userBlock;

@end
