//
//  AppDelegate.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString* userId;

//更新 夜间、日间模式
-(void)updateSystemNightShift;

//夜间模式时，将layer置顶
-(void)bringSystemNightShiftToFront;

//夜间模式时，将layer放底下 否则会覆盖广告
-(void)sendSystemNightShiftToback;

@end

