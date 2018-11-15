//
//  LMBookStoreFilterListView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/22.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"
#import "LMBookStoreViewController.h"

typedef void (^LMBookStoreFilterListViewGenderBlock) (GenderType gender);
typedef void (^LMBookStoreFilterListViewRangeBlock) (LMBookStoreRange range);
typedef void (^LMBookStoreFilterListViewStateBlock) (LMBookStoreState state);

@interface LMBookStoreFilterListView : LMBaseAlertView


@property (nonatomic, strong) UIButton* maleBtn;//男 button
@property (nonatomic, strong) UIButton* femaleBtn;//女 button

@property (nonatomic, strong) UIButton* hotBtn;//按人气 button
@property (nonatomic, strong) UIButton* timeBtn;//按更新时间 button
@property (nonatomic, strong) UIButton* upBtn;//按上升最快 button

@property (nonatomic, strong) UIButton* allBtn;//全部 button
@property (nonatomic, strong) UIButton* finishBtn;//完结 button
@property (nonatomic, strong) UIButton* loadBtn;//连载中 button

@property (nonatomic, assign) GenderType gendType;
@property (nonatomic, assign) LMBookStoreRange bookRange;
@property (nonatomic, assign) LMBookStoreState bookState;

@property (nonatomic, copy) LMBookStoreFilterListViewGenderBlock genderBlock;
@property (nonatomic, copy) LMBookStoreFilterListViewRangeBlock rangeBlock;
@property (nonatomic, copy) LMBookStoreFilterListViewStateBlock stateBlock;

- (void)showToView:(UIView *)pointView;

@end
