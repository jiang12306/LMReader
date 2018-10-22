//
//  LMSourceAlertView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/23.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

typedef void (^LMSourceAlertViewSureBlock) (BOOL sure);
typedef void (^LMSourceAlertViewCancelBlock) (BOOL cancel);

@interface LMSourceAlertView : LMBaseAlertView

-(instancetype)initWithFrame:(CGRect)frame text:(NSString* )text sourceName:(NSString* )sourceName;

-(void)startShow;

-(void)startHide;

@property (nonatomic, copy) LMSourceAlertViewSureBlock sureBlock;
@property (nonatomic, copy) LMSourceAlertViewCancelBlock cancelBlock;

@end
