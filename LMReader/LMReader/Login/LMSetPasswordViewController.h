//
//  LMSetPasswordViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"
#import "LMRegisterViewController.h"

@interface LMSetPasswordViewController : LMBaseViewController

@property (nonatomic, copy) NSString* phoneStr;
@property (nonatomic, copy) NSString* verifyStr;
@property (nonatomic, assign) LMRegisterType type;

@end
