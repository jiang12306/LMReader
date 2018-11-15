//
//  LMBookShelfRightOperationView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMBookShelfRightOperationViewBatchBlock) (BOOL didClick);
typedef void (^LMBookShelfRightOperationViewListBlock) (BOOL didClick);

@interface LMBookShelfRightOperationView : LMBaseAlertView

@property (nonatomic, copy) LMBookShelfRightOperationViewBatchBlock batchBlock;
@property (nonatomic, copy) LMBookShelfRightOperationViewListBlock listBlock;

@property (nonatomic, copy) NSString* labText;

@property (nonatomic, strong) UIButton* batchBtn;//批量管理 button
@property (nonatomic, strong) UIButton* listBtn;//列表模式 button

@property (nonatomic, strong) UIImageView* batchIV;//批量管理 iv
@property (nonatomic, strong) UIImageView* listIV;//列表模式 iv
@property (nonatomic, strong) UILabel* batchLab;//批量管理 lab
@property (nonatomic, strong) UILabel* listLab;//列表模式 lab

- (void)showToView:(UIView *)pointView;

@end

NS_ASSUME_NONNULL_END
