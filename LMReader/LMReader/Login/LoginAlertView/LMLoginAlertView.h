//
//  LMLoginAlertView.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/8/1.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseAlertView.h"

typedef void (^LMLoginAlertViewBlock) (BOOL didLogined);
typedef void (^LMLoginAlertViewProtocolBlock) (BOOL clickedProtocol);

@interface LMLoginAlertView : LMBaseAlertView

@property (nonatomic, copy) LMLoginAlertViewBlock loginBlock;
@property (nonatomic, copy) LMLoginAlertViewProtocolBlock protocolBlock;

-(void)startShow;
-(void)startHide;

@end
