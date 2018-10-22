//
//  LMReaderSettingView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMReaderSettingViewFontBlock) (CGFloat fontValue, CGFloat lineSpace);
typedef void (^LMReaderSettingViewBrightBlock) (CGFloat brightValue);
typedef void (^LMReaderSettingViewBackgroundBlock) (NSInteger bgValue);
typedef void (^LMReaderSettingViewLineSpaceBlock) (CGFloat lineSpaceValue, NSInteger lpIndex);

@interface LMReaderSettingView : UIView

@property (nonatomic, assign) BOOL isShow;//状态 是否显示
@property (nonatomic, copy) LMReaderSettingViewFontBlock fontBlock;
@property (nonatomic, copy) LMReaderSettingViewBrightBlock brightBlock;
@property (nonatomic, copy) LMReaderSettingViewBackgroundBlock bgBlock;
@property (nonatomic, copy) LMReaderSettingViewLineSpaceBlock lpBlock;

-(instancetype)initWithFrame:(CGRect )frame bringht:(CGFloat )bright fontSize:(CGFloat )fontSize bgInteger:(NSInteger )bgInteger lineSpaceIndex:(NSInteger )lineSpaceIndex;
-(void)showSettingViewWithFinalFrame:(CGRect )finalFrame;
-(void)hideSettingViewWithFinalFrame:(CGRect )finalFrame;

@end
