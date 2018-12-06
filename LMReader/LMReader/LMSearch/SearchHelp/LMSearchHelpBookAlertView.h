//
//  LMSearchHelpBookAlertView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/23.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMSearchHelpBookAlertViewSuccessBlock) (BOOL didCommit);

@interface LMSearchHelpBookAlertView : LMBaseAlertView

@property (nonatomic, copy) LMSearchHelpBookAlertViewSuccessBlock commitBlock;

-(void)startShow;
-(void)startHide;

@end

NS_ASSUME_NONNULL_END
