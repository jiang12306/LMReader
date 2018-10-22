//
//  LMAuthorBookFilterListView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/18.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"
#import "LMBookStoreViewController.h"

typedef void (^LMAuthorBookFilterListViewStateBlock) (LMBookStoreState state);

@interface LMAuthorBookFilterListView : LMBaseAlertView

@property (nonatomic, strong) UIButton* allBtn;//全部 button
@property (nonatomic, strong) UIButton* finishBtn;//完结 button
@property (nonatomic, strong) UIButton* loadBtn;//连载中 button

@property (nonatomic, assign) LMBookStoreRange bookRange;
@property (nonatomic, assign) LMBookStoreState bookState;

@property (nonatomic, copy) LMAuthorBookFilterListViewStateBlock stateBlock;

- (void)showToView:(UIView *)pointView;

@end
