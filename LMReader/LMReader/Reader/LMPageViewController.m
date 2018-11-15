//
//  LMPageViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/20.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMPageViewController.h"
#import "LMContentViewController.h"

@interface LMPageViewController () <UIGestureRecognizerDelegate>

@end

@implementation LMPageViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        for (UIGestureRecognizer* gr in self.gestureRecognizers) {
            gr.delegate = self;
        }
    }
    return self;
}

-(instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<UIPageViewControllerOptionsKey,id> *)options {
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        for (UIGestureRecognizer* gr in self.gestureRecognizers) {
            gr.delegate = self;
        }
    }
    return self;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.viewControllers) {
            UIViewController* vc = [self.viewControllers firstObject];
            if ([vc isKindOfClass:[LMContentViewController class]]) {
                LMContentViewController* contentVC = (LMContentViewController*)vc;
                CGPoint touchPoint = [touch locationInView:self.view];
                if (contentVC.adView != nil) {//腾讯广告
                    if (CGRectContainsPoint(contentVC.adView.frame, touchPoint)) {
                        return NO;
                    }
                }else if (contentVC.ownerAdView != nil) {//自家广告
                    if (CGRectContainsPoint(contentVC.ownerAdView.frame, touchPoint)) {
                        return NO;
                    }
                }else if (contentVC.initerstitialAdContainer != nil) {//百度插页广告  容器
                    if (CGRectContainsPoint(contentVC.initerstitialAdContainer.frame, touchPoint)) {
                        return NO;
                    }
                }else if (contentVC.sharedAdView != nil) {//百度内嵌广告  横幅
                    if (CGRectContainsPoint(contentVC.sharedAdView.frame, touchPoint)) {
                        return NO;
                    }
                }
                CGRect tapRect = CGRectMake(self.view.frame.size.width / 3, self.view.frame.size.height / 4, self.view.frame.size.width / 3, self.view.frame.size.height / 2);
                if (CGRectContainsPoint(tapRect, touchPoint)) {
                    if (self.gestureDelegate != nil && [self.gestureDelegate respondsToSelector:@selector(LMPageViewControllerDidTapScreenCenterToShowOrHideNavigationBar)]) {
                        [self.gestureDelegate LMPageViewControllerDidTapScreenCenterToShowOrHideNavigationBar];
                        return NO;
                    }
                }
            }
        }
    }else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return YES;
}



@end
