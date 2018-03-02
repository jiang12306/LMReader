//
//  LMRegisterViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum {
    LMRegisterTypeNewRegister = 0,//新用户注册
    LMRegisterTypeForgetPassword = 1,//忘记密码
}LMRegisterType;

@interface LMRegisterViewController : LMBaseViewController

@property (nonatomic, assign) LMRegisterType type;

@end
