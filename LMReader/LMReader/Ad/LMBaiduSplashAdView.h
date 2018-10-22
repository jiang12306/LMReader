//
//  LMBaiduSplashAdView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/16.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMBaiduSplashAdViewLoadBlock) (BOOL loadSucceed);
typedef void (^LMBaiduSplashAdViewCloseBlock) (BOOL didClose);
typedef void (^LMBaiduSplashAdViewClickBlock) (BOOL isBook, NSString* bookIdStr, NSString* urlStr);

@interface LMBaiduSplashAdView : UIView

@property (nonatomic, copy) LMBaiduSplashAdViewLoadBlock loadBlock;
@property (nonatomic, copy) LMBaiduSplashAdViewCloseBlock closeBlock;
@property (nonatomic, copy) LMBaiduSplashAdViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
