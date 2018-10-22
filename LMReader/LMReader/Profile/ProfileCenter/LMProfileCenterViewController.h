//
//  LMProfileCenterViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

//登录已过期回调
typedef void (^LMProfileCenterViewControllerBlock) (BOOL isOutTime);

@interface LMProfileCenterViewController : LMBaseViewController

@property (nonatomic, strong) LoginedRegUser* loginedUser;
@property (nonatomic, copy) LMProfileCenterViewControllerBlock loginBlock;

@end
