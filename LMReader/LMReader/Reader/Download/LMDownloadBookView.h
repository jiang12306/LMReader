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
#import "LMContentViewController.h"


//最多下载次数
#define LMDownloadBookViewMaxCount 3


typedef void (^LMDownloadBookViewBlock) (BOOL isFinished, BOOL isFailed, NSInteger totalCount, CGFloat progress);

@interface LMDownloadBookView : UIView

@property (nonatomic, assign) BOOL isDownload;//状态 是否正在下载
@property (nonatomic, assign) BOOL isShow;//状态 是否显示

//阅读器界面用
-(void)startDownloadOldParseBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList block:(LMDownloadBookViewBlock )callBlock;

//新解析方式下 阅读器界面用
-(void)startDownloadNewParseBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList parse:(UrlReadParse* )parse block:(LMDownloadBookViewBlock)callBlock;


-(void)showDownloadViewWithFinalFrame:(CGRect )finalFrame;

-(void)hideDownloadViewWithFinalFrame:(CGRect )finalFrame;

//更换背景、文字颜色 日间、夜间模式
-(void)reloadDownloadBookViewWithModel:(LMReadModel )currentModel;

@end
