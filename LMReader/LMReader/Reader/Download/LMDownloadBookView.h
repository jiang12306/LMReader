//
//  LMDownloadBookView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "LMReaderBook.h"

typedef void (^LMDownloadBookViewBlock) (BOOL isFinished, CGFloat progress);
typedef void (^LMDownloadBookViewBlockFailure) (BOOL netFailed);

@interface LMDownloadBookView : UIView

@property (nonatomic, assign) BOOL isDownload;//状态 是否正在下载
@property (nonatomic, assign) BOOL isShow;//状态 是否显示

//阅读器界面用
-(void)startDownloadBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList block:(LMDownloadBookViewBlock )callBlock;

//新解析方式下 阅读器界面用
-(void)startDownloadNewParseBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList parse:(UrlReadParse* )parse block:(LMDownloadBookViewBlock)callBlock;

//无目录时 下载 图书详情界面用
-(void)startDownloadBookWithBookId:(UInt32 )bookId success:(LMDownloadBookViewBlock )successBlock failure:(LMDownloadBookViewBlockFailure)failureBlock;

-(void)showDownloadViewWithFinalFrame:(CGRect )finalFrame;

-(void)hideDownloadViewWithFinalFrame:(CGRect )finalFrame;

@end
