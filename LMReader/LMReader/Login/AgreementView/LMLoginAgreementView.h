//
//  LMLoginAgreementView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/27.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    LMLoginAgreementViewTypeRegister = 1,//注册
    LMLoginAgreementViewTypeLogin = 2,//登录
}LMLoginAgreementViewType;

typedef void (^LMLoginAgreementViewAgreeBlock) (BOOL didAgree);
typedef void (^LMLoginAgreementViewClickBlock) (BOOL didClick);

@interface LMLoginAgreementView : LMBaseAlertView

@property (nonatomic, assign) LMLoginAgreementViewType agreeType;

@property (nonatomic, copy) LMLoginAgreementViewAgreeBlock agreeBlock;
@property (nonatomic, copy) LMLoginAgreementViewClickBlock clickBlock;

-(instancetype)initWithFrame:(CGRect)frame agreeType:(LMLoginAgreementViewType )agreeType;

@end

NS_ASSUME_NONNULL_END
