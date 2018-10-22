//
//  LMPageViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/20.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LMPageViewControllerDelegate <NSObject>

@optional
-(void)LMPageViewControllerDidTapScreenCenterToShowOrHideNavigationBar;

@end

@interface LMPageViewController : UIPageViewController

@property (nonatomic, weak) id<LMPageViewControllerDelegate> gestureDelegate;

@end

NS_ASSUME_NONNULL_END
