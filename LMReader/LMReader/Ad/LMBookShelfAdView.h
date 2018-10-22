//
//  LMBookShelfAdView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMBookShelfAdViewLoadBlock) (BOOL loadSucceed);
typedef void (^LMBookShelfAdViewCloseBlock) (BOOL didClose);
typedef void (^LMBookShelfAdViewClickBlock) (BOOL isBook, NSString* bookIdStr, NSString* urlStr);

@interface LMBookShelfAdView : UIView

-(instancetype)initWithFrame:(CGRect)frame imgFrame:(CGRect )imgFrame;

-(void)startShow;

@property (nonatomic, copy) LMBookShelfAdViewLoadBlock loadBlock;
@property (nonatomic, copy) LMBookShelfAdViewCloseBlock closeBlock;
@property (nonatomic, copy) LMBookShelfAdViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
