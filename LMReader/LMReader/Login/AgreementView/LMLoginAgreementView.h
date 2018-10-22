//
//  LMLoginAgreementView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/27.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMLoginAgreementViewAgreeBlock) (BOOL didAgree);
typedef void (^LMLoginAgreementViewClickBlock) (BOOL didClick);

@interface LMLoginAgreementView : LMBaseAlertView

@property (nonatomic, copy) LMLoginAgreementViewAgreeBlock agreeBlock;
@property (nonatomic, copy) LMLoginAgreementViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
