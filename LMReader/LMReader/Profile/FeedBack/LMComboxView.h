//
//  LMComboxView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMBaseAlertView.h"

typedef void (^LMComboxViewBlock) (NSInteger selectedIndex);
typedef void (^LMComboxViewCancelBlock) (BOOL didCancel);

@interface LMComboxView : LMBaseAlertView

@property (nonatomic, copy) LMComboxViewBlock callBlock;
@property (nonatomic, copy) LMComboxViewCancelBlock cancelBlock;

-(instancetype )initWithFrame:(CGRect )frame titleArr:(NSArray* )titleArr cellHeight:(CGFloat )cellHeight selectedIndex:(NSInteger )currentIndex;

-(void)startShow;
-(void)startHide;

@end
