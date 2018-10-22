//
//  LMTypeBookStoreViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/24.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"
#import "LMBookStoreViewController.h"

@protocol LMTypeBookStoreViewControllerDelegate <NSObject>

@optional
-(void)typeBookStoreViewControllerDidClickedBookId:(NSInteger )bookId;

@end

@interface LMTypeBookStoreViewController : LMBaseViewController

@property (nonatomic, assign) NSInteger markTag;//标记用

@property (nonatomic, assign) GenderType genderType;//性别
@property (nonatomic, assign) LMBookStoreState bookState;//完结 连载中
@property (nonatomic, assign) LMBookStoreRange bookRange;//人气 最新上架
@property (nonatomic, copy) NSArray* filterArr;


@property (nonatomic, weak) id<LMTypeBookStoreViewControllerDelegate> delegate;

@end
