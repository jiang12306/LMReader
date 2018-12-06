//
//  LMReaderUserInstructionsView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/12/6.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LMReaderUserInstructionsView : LMBaseAlertView

//设置“换源”、“夜间”按钮位置
-(void)setUpChangeSourcePoint:(CGPoint )sourcePoint nightPoint:(CGPoint )nightPoint;

//设置“书评”、“设置”按钮位置
-(void)setUpCommentPoint:(CGPoint )commentPoint SettingPoint:(CGPoint )settingPoint;

//设置“报错”按钮位置
-(void)setUpErrorPoint:(CGPoint )errorPoint;

//
-(void)startShow;

@end

NS_ASSUME_NONNULL_END
