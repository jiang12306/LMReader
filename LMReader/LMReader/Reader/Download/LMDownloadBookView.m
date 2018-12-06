//
//  LMDownloadBookView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMDownloadBookView.h"
#import "LMNetworkTool.h"
#import "LMTool.h"

@interface LMDownloadBookView ()

@property (nonatomic, strong) UILabel* stateLab;
@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, assign) NSInteger downloadCount;/**<总的下载次数，不超过3次*/

@end

@implementation LMDownloadBookView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(20, 5, frame.size.width - 20 * 2, 5)];
        self.progressView.progressTintColor = THEMEORANGECOLOR;
        self.progressView.trackTintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.progressView.progress = 0;
        [self addSubview:self.progressView];
        
        self.stateLab = [[UILabel alloc]initWithFrame:CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y + self.progressView.frame.size.height, self.progressView.frame.size.width, frame.size.height - 5)];
        self.stateLab.font = [UIFont systemFontOfSize:15];
        self.stateLab.text = @"0%";
        self.stateLab.textColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.stateLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.stateLab];
        
        self.isShow = NO;
        self.isDownload = NO;
        self.downloadCount = 0;
    }
    return self;
}

//新解析方式下  书籍详情界面、阅读器界面共用
-(void)startDownloadNewParseBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList parse:(UrlReadParse* )parse block:(LMDownloadBookViewBlock)callBlock {
    
    //防止死循环
    if (self.downloadCount >= LMDownloadBookViewMaxCount) {
        self.isDownload = NO;
        CGFloat progress = self.progressView.progress;
        self.stateLab.text = [NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];//[NSString stringWithFormat:@"%.2f%% 下载失败", progress * 100];
        callBlock(!self.isDownload, YES, self.downloadCount, progress);
    }
    
    __weak LMDownloadBookView* weakSelf = self;
    self.isDownload = YES;
    __block CGFloat progress = 0;
    if ([parse hasApi]) {//json解析
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger succeedCount = 0;
            NSInteger failedCount = 0;
            for (NSInteger i = 0; i < catalogList.count; i ++) {
                LMReaderBookChapter* subChapter = [catalogList objectAtIndex:i];
                if (![LMTool isExistBookTextWithBookId:bookId chapterId:subChapter.chapterId]) {//若不存在该章节，则下载
                    NSString* chapterUrlStr = subChapter.url;
                    if (chapterUrlStr != nil && chapterUrlStr.length > 0) {
                        NSString *encodedUrlStr = [chapterUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        NSData* successData = [NSData dataWithContentsOfURL:[NSURL URLWithString:encodedUrlStr]];
                        
                        if (successData != nil && ![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
                            @try {
                                NSError* jsonError = nil;
                                NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:successData options:NSJSONReadingMutableLeaves error:&jsonError];
                                if (jsonError != nil || dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
                                    failedCount ++;
                                }
                                NSString* totalContentStr = [LMTool jsonParseChapterContentWithParse:parse originalDic:dic];
                                if (totalContentStr != nil && ![totalContentStr isKindOfClass:[NSNull class]]) {
                                    [LMTool saveBookTextWithBookId:bookId chapterId:subChapter.chapterId bookText:totalContentStr];
                                    
                                    succeedCount ++;
                                }else {
                                    failedCount ++;
                                }
                                progress = ((CGFloat)i)/catalogList.count;
                                if (i == catalogList.count - 1) {
                                    progress = 1;
                                    weakSelf.isDownload = NO;
                                }
                                
                            } @catch (NSException *exception) {
                                failedCount ++;
                            } @finally {
                                
                            }
                        }else {
                            failedCount ++;
                        }
                    }else {
                        failedCount ++;
                    }
                    if (failedCount > 0) {
                        weakSelf.downloadCount ++;
                        weakSelf.isDownload = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.progressView.progress = progress;
                            weakSelf.stateLab.text = [NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];//[NSString stringWithFormat:@"%.2f%% 下载失败", progress * 100];
                            callBlock(!weakSelf.isDownload, YES, weakSelf.downloadCount, progress);
                        });
                        break;
                    }
                }else {
                    succeedCount ++;
                }
                if (succeedCount == catalogList.count) {
                    weakSelf.downloadCount ++;
                    weakSelf.isDownload = NO;
                    progress = 1;
                }
                if (i % 10 == 0 || progress == 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.progressView.progress = progress;
                        NSString* stateStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                        if (progress == 1) {
                            stateStr = @"100% 已完成";
                        }
                        weakSelf.stateLab.text = stateStr;
                        callBlock(!weakSelf.isDownload, NO, weakSelf.downloadCount, progress);
                    });
                }
            }
        });
    }else {//html解析
        NSArray* contentArr = [parse.contentParse componentsSeparatedByString:@","];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger succeedCount = 0;
            NSInteger failedCount = 0;
            for (NSInteger i = 0; i < catalogList.count; i ++) {
                LMReaderBookChapter* subChapter = [catalogList objectAtIndex:i];
                if (![LMTool isExistBookTextWithBookId:bookId chapterId:subChapter.chapterId]) {//若不存在该章节，则下载
                    NSString* chapterUrlStr = subChapter.url;
                    if (chapterUrlStr != nil && chapterUrlStr.length > 0) {
                        NSString *encodedUrlStr = [chapterUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        NSData* successData = [NSData dataWithContentsOfURL:[NSURL URLWithString:encodedUrlStr]];
                        
                        if (successData != nil && ![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
                            @try {
                                NSStringEncoding encoding = [LMTool convertEncodingStringWithEncoding:parse.source.htmlcharset];//转码
                                NSString* originStr = [[NSString alloc]initWithData:successData encoding:encoding];
                                originStr = [LMTool replaceBrCharacterWithReturnCharacter:originStr];
                                NSData* changeData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
                                TFHpple* contentDoc = [[TFHpple alloc] initWithData:changeData isXML:NO];
                                NSString* contentSearchStr = [LMTool convertToHTMLStringWithListArray:contentArr];
                                TFHppleElement* contentElement = [contentDoc peekAtSearchWithXPathQuery:contentSearchStr];
                                NSString* originalContent =  contentElement.content;
                                originalContent = [LMTool filterUselessStringWithText:originalContent filterArr:parse.source.filter];
                                NSString* totalContentStr = [LMTool replaceSeveralNewLineWithOneNewLineWithText:originalContent];
                                if (totalContentStr != nil && ![totalContentStr isKindOfClass:[NSNull class]]) {
                                    [LMTool saveBookTextWithBookId:bookId chapterId:subChapter.chapterId bookText:totalContentStr];
                                    
                                    succeedCount ++;
                                }else {
                                    failedCount ++;
                                }
                                progress = ((CGFloat)i)/catalogList.count;
                                if (i == catalogList.count - 1) {
                                    progress = 1;
                                    weakSelf.isDownload = NO;
                                }
                                
                            } @catch (NSException *exception) {
                                failedCount ++;
                            } @finally {
                                
                            }
                        }else {
                            failedCount ++;
                        }
                    }else {
                        failedCount ++;
                    }
                    if (failedCount > 0) {
                        weakSelf.downloadCount ++;
                        weakSelf.isDownload = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.progressView.progress = progress;
                            weakSelf.stateLab.text = [NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];//[NSString stringWithFormat:@"%.2f%% 下载失败", progress * 100];
                            callBlock(!weakSelf.isDownload, YES, weakSelf.downloadCount, progress);
                        });
                        break;
                    }
                }else {
                    succeedCount ++;
                }
                if (succeedCount == catalogList.count) {
                    weakSelf.downloadCount ++;
                    weakSelf.isDownload = NO;
                    progress = 1;
                }
                if (i % 10 == 0 || progress == 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.progressView.progress = progress;
                        NSString* stateStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                        if (progress == 1) {
                            stateStr = @"100% 已完成";
                        }
                        weakSelf.stateLab.text = stateStr;
                        callBlock(!weakSelf.isDownload, NO, weakSelf.downloadCount, progress);
                    });
                }
            }
        });
    }
}

//旧解析方式下 阅读器、书籍详情界面共用
-(void)startDownloadOldParseBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList block:(LMDownloadBookViewBlock)callBlock {
    
    //防止死循环
    if (self.downloadCount >= LMDownloadBookViewMaxCount) {
        self.isDownload = NO;
        CGFloat progress = self.progressView.progress;
        self.stateLab.text = [NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];//[NSString stringWithFormat:@"%.2f%% 下载失败", progress * 100];
        callBlock(!self.isDownload, YES, self.downloadCount, progress);
    }
    
    __weak LMDownloadBookView* weakSelf = self;
    self.isDownload = YES;
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat progress = 0;
        NSInteger succeedCount = 0;
        NSInteger failedCount = 0;
        for (NSInteger i = 0; i < catalogList.count; i ++) {
            LMReaderBookChapter* subChapter = [catalogList objectAtIndex:i];
            BookChapterSourceReqBuilder* builder = [BookChapterSourceReq builder];
            [builder setBookId:bookId];
            [builder setChapterNo:(UInt32 )subChapter.chapterNo];
            [builder setChapterTitle:subChapter.title];
            [builder setSourceId:(UInt32 )subChapter.sourceId];
            BookChapterSourceReq* req = [builder build];
            NSData* reqData = [req data];
            
            if (![LMTool isExistBookTextWithBookId:bookId chapterId:subChapter.chapterId]) {//若不存在该章节，则下载
                
                NSData* textData = [networkTool postSyncWithCmd:1 ReqData:reqData];
                if (textData != nil && ![textData isKindOfClass:[NSNull class]] && textData.length > 0) {
                    
                    FtBookApiRes* apiRes = [FtBookApiRes parseFromData:textData];
                    if (apiRes.cmd == 8) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {
                            BookChapterSourceRes* res = [BookChapterSourceRes parseFromData:apiRes.body];
                            NSString* originalContent = res.chapter.chapterContent;
                            NSString* textStr = [LMTool replaceSeveralNewLineWithOneNewLineWithText:originalContent];
                            [LMTool saveBookTextWithBookId:bookId chapterId:subChapter.chapterId bookText:textStr];
                        }else {
                            
                        }
                    }
                    
                    progress = ((CGFloat)i)/catalogList.count;
                    if (i == catalogList.count - 1) {
                        progress = 1;
                        weakSelf.isDownload = NO;
                    }
                    succeedCount ++;
                }else {
                    failedCount ++;
                    weakSelf.downloadCount ++;
                    weakSelf.isDownload = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.progressView.progress = progress;
                        weakSelf.stateLab.text = [NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];//[NSString stringWithFormat:@"%.2f%% 下载失败", progress * 100];
                        callBlock(!weakSelf.isDownload, YES, weakSelf.downloadCount, progress);
                    });
                    break;
                }
            }else {
                succeedCount ++;
            }
            if (succeedCount == catalogList.count) {
                weakSelf.downloadCount ++;
                weakSelf.isDownload = NO;
                progress = 1;
            }
            
            if (succeedCount % 10 == 0 || progress == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.progressView.progress = progress;
                    NSString* stateStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                    if (progress == 1) {
                        stateStr = @"100% 已完成";
                    }
                    weakSelf.stateLab.text = stateStr;
                    callBlock(!weakSelf.isDownload, NO, weakSelf.downloadCount, progress);
                });
            }
        }
    });
}


-(void)showDownloadViewWithFinalFrame:(CGRect )finalFrame {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = finalFrame;
    } completion:^(BOOL finished) {
        self.isShow = YES;
    }];
}

-(void)hideDownloadViewWithFinalFrame:(CGRect )finalFrame {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = finalFrame;
    } completion:^(BOOL finished) {
        self.isShow = NO;
    }];
}

//更换背景、文字颜色 日间、夜间模式
-(void)reloadDownloadBookViewWithModel:(LMReadModel )currentModel {
    if (currentModel == LMReaderBackgroundType4) {
        self.backgroundColor = [UIColor blackColor];
        
        self.progressView.progressTintColor = THEMEORANGECOLOR;
        self.progressView.trackTintColor = [UIColor whiteColor];
        
        self.stateLab.textColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
    }else {
        self.backgroundColor = [UIColor whiteColor];
        
        self.progressView.progressTintColor = THEMEORANGECOLOR;
        self.progressView.trackTintColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
        
        self.stateLab.textColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
