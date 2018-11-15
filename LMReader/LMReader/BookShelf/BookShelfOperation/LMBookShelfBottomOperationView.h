//
//  LMBookShelfBottomOperationView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMBookShelfBottomOperationViewClickBlock) (NSInteger index);

@interface LMBookShelfBottomOperationView : LMBaseAlertView

@property (nonatomic, copy) LMBookShelfBottomOperationViewClickBlock clickBlock;

@property (nonatomic, copy) NSArray* imgsArray;
@property (nonatomic, copy) NSArray* titleArray;

-(instancetype)initWithFrame:(CGRect)frame imgsArr:(NSArray* )imgsArr titleArr:(NSArray* )titleArr;

-(void)startShow;

@end

NS_ASSUME_NONNULL_END
