//
//  LMCheckVerifyCodeViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef void (^LMCheckVerifyCodeViewControllerBlock) (NSString* bindPhoneStr);

@interface LMCheckVerifyCodeViewController : LMBaseViewController

@property (nonatomic, assign) SmsType type;

@property (nonatomic, assign) BOOL bindPhone;//只需要绑定手机，不用跳到设置密码界面，需要block回调
@property (nonatomic, copy) LMCheckVerifyCodeViewControllerBlock bindBlock;

@end
