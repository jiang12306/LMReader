//
//  LMReaderSettingView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMContentViewController.h"

typedef void (^LMReaderSettingViewFontBlock) (CGFloat fontValue, CGFloat lineSpace);
typedef void (^LMReaderSettingViewBackgroundBlock) (NSInteger bgValue);
typedef void (^LMReaderSettingViewLineSpaceBlock) (CGFloat lineSpaceValue, NSInteger lpIndex);

@interface LMReaderSettingView : UIView

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) NSInteger bgInteger;
@property (nonatomic, assign) NSInteger lineSpaceIndex;

@property (nonnull, strong) UILabel* fontLab;/**<*/
@property (nonnull, strong) UIButton* fontSmallBtn;/**<*/
@property (nonnull, strong) UILabel* currentFontLab;/**<*/
@property (nonnull, strong) UIButton* fontBigBtn;/**<*/
@property (nonnull, strong) UILabel* bgLab;
@property (nonnull, strong) UIButton* bgBtn1;
@property (nonnull, strong) UIButton* bgBtn2;
@property (nonnull, strong) UIButton* bgBtn3;
@property (nonnull, strong) UIButton* bgBtn4;
@property (nonnull, strong) UILabel* lineSpaceLab;
@property (nonnull, strong) UIButton* lineSpaceBtn1;
@property (nonnull, strong) UIButton* lineSpaceBtn2;
@property (nonnull, strong) UIButton* lineSpaceBtn3;

@property (nonatomic, assign) BOOL isShow;//状态 是否显示
@property (nonatomic, copy) LMReaderSettingViewFontBlock fontBlock;
@property (nonatomic, copy) LMReaderSettingViewBackgroundBlock bgBlock;
@property (nonatomic, copy) LMReaderSettingViewLineSpaceBlock lpBlock;

-(instancetype)initWithFrame:(CGRect )frame fontSize:(CGFloat )fontSize bgInteger:(NSInteger )bgInteger lineSpaceIndex:(NSInteger )lineSpaceIndex;
-(void)showSettingViewWithFinalFrame:(CGRect )finalFrame;
-(void)hideSettingViewWithFinalFrame:(CGRect )finalFrame;

//切换背景
-(void)didClickBackgroundButton:(UIButton* )sender;

//刷新所有控件颜色
-(void)reloadReaderSettingViewWithModel:(LMReadModel )currentModel;

@end
