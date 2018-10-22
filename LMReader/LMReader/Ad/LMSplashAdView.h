//
//  LMSplashAdView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/9.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMSplashAdViewClickBlock) (BOOL isBook, NSString* bookIdStr, NSString* urlStr);

@interface LMSplashAdView : UIView

@property (nonatomic, copy) LMSplashAdViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
