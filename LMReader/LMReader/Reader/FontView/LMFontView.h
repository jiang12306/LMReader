//
//  LMFontView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LMFontViewDelegate <NSObject>

-(void)fontViewCurrentValue:(CGFloat )fontSize;

@end

@interface LMFontView : UIView

@property (nonatomic, assign) BOOL isShow;//状态 是否显示

@property (nonatomic, weak) id<LMFontViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame currentFontSize:(CGFloat )fontSize;

-(void)showFontViewWithFinalFrame:(CGRect )finalFrame;

-(void)hideFontViewWithFinalFrame:(CGRect )finalFrame;

@end
