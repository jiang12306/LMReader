//
//  LMReaderContentAdView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMReaderContentAdViewLoadBlock) (BOOL loadSucceed);
typedef void (^LMReaderContentAdViewCloseBlock) (BOOL didClose);
typedef void (^LMReaderContentAdViewClickBlock) (BOOL isBook, NSString* bookIdStr, NSString* urlStr);

@interface LMReaderContentAdView : UIView

-(instancetype)initWithFrame:(CGRect)frame adType:(NSInteger)adType;/**<adType：1.内嵌；2.插页*/
-(void)startShow;

@property (nonatomic, copy) LMReaderContentAdViewLoadBlock loadBlock;
@property (nonatomic, copy) LMReaderContentAdViewCloseBlock closeBlock;
@property (nonatomic, copy) LMReaderContentAdViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
