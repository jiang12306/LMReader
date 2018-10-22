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

@end

@implementation LMDownloadBookView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(10, 5, frame.size.width - 10 * 2, 5)];
        self.progressView.progressTintColor = [UIColor blackColor];
        self.progressView.trackTintColor = [UIColor whiteColor];
        self.progressView.progress = 0;
        [self addSubview:self.progressView];
        
        self.stateLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.progressView.frame.origin.y + self.progressView.frame.size.height + 5, self.progressView.frame.size.width, frame.size.height - 10)];
        self.stateLab.font = [UIFont systemFontOfSize:14];
        self.stateLab.text = @"0%";
        self.stateLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.stateLab];
        
        self.isShow = NO;
        self.isDownload = NO;
    }
    return self;
}

//新解析方式下  书籍详情界面、阅读器界面共用
-(void)startDownloadNewParseBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList parse:(UrlReadParse* )parse block:(LMDownloadBookViewBlock)callBlock {
    __weak LMDownloadBookView* weakSelf = self;
    self.isDownload = YES;
    __block CGFloat progress = 0;
    NSArray* contentArr = [parse.contentParse componentsSeparatedByString:@","];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger succeedCount = 0;
        NSInteger failedCount = 0;
        for (NSInteger i = 0; i < catalogList.count; i ++) {
            LMReaderBookChapter* subChapter = [catalogList objectAtIndex:i];
            if (![LMTool isExistBookTextWithBookId:bookId chapterId:(UInt32 )subChapter.chapterId]) {//若不存在该章节，则下载
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
                                [LMTool saveBookTextWithBookId:bookId chapterId:(UInt32 )subChapter.chapterId bookText:totalContentStr];
                                
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
                    weakSelf.isDownload = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.progressView.progress = progress;
                        weakSelf.stateLab.text = [NSString stringWithFormat:@"%.2f%% 下载失败", progress * 100];
                        callBlock(!weakSelf.isDownload, progress);
                    });
                    break;
                }
            }else {
                succeedCount ++;
            }
            if (succeedCount == catalogList.count) {
                self.isDownload = NO;
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
                    callBlock(!weakSelf.isDownload, progress);
                });
            }
        }
    });
}

//旧解析方式下 阅读器界面用
-(void)startDownloadBookWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList block:(LMDownloadBookViewBlock)callBlock {
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
            
            if (![LMTool isExistBookTextWithBookId:bookId chapterId:(UInt32 )subChapter.chapterId]) {//若不存在该章节，则下载
                
                NSData* textData = [networkTool postSyncWithCmd:1 ReqData:reqData];
                if (textData != nil && ![textData isKindOfClass:[NSNull class]] && textData.length > 0) {
                    
                    FtBookApiRes* apiRes = [FtBookApiRes parseFromData:textData];
                    if (apiRes.cmd == 8) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {
                            BookChapterSourceRes* res = [BookChapterSourceRes parseFromData:apiRes.body];
                            NSString* originalContent = res.chapter.chapterContent;
                            NSString* textStr = [LMTool replaceSeveralNewLineWithOneNewLineWithText:originalContent];
                            [LMTool saveBookTextWithBookId:bookId chapterId:(UInt32 )subChapter.chapterId bookText:textStr];
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
                    weakSelf.isDownload = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.progressView.progress = progress;
                        weakSelf.stateLab.text = [NSString stringWithFormat:@"%.2f%% 下载失败", progress * 100];
                        callBlock(!weakSelf.isDownload, progress);
                    });
                    break;
                }
            }else {
                succeedCount ++;
            }
            if (succeedCount == catalogList.count) {
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
                    callBlock(!weakSelf.isDownload, progress);
                });
            }
        }
    });
}


//无目录时 下载 图书详情界面用
-(void)startDownloadBookWithBookId:(UInt32 )bookId success:(LMDownloadBookViewBlock )successBlock failure:(LMDownloadBookViewBlockFailure)failureBlock {
    BookChapterReqBuilder* builder = [BookChapterReq builder];
    [builder setBookId:bookId];
    BookChapterReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMDownloadBookView* weakSelf = self;
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 7) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookChapterRes* res = [BookChapterRes parseFromData:apiRes.body];
                    NSArray* arr = res.chapters;
                    if (arr != nil && arr.count > 0) {//旧解析方式
                        NSMutableArray* bookChaptersArr = [NSMutableArray array];
                        for (NSInteger i = 0; i < arr.count; i ++) {
                            Chapter* tempChapter = [arr objectAtIndex:i];
                            LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                            [bookChaptersArr addObject:bookChapter];
                        }
                        
                        [weakSelf startDownloadBookWithBookId:bookId catalogList:arr block:^(BOOL isFinished, CGFloat progress) {
                            
                            successBlock(isFinished, progress);
                        }];
                    }else {//新解析方式
                        NSArray<UrlReadParse* >* bookParseArr = res.book.parses;
                        if (bookParseArr.count > 0) {
                            UrlReadParse* parse = [bookParseArr firstObject];
                            NSString* urlStr = parse.listUrl;
                            NSArray* listArr = [parse.listParse componentsSeparatedByString:@","];
                            [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
                                NSStringEncoding encoding = [LMTool convertEncodingStringWithEncoding:parse.source.htmlcharset];
                                NSString* originStr = [[NSString alloc]initWithData:successData encoding:encoding];
                                NSData* changeData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
                                TFHpple* doc = [[TFHpple alloc] initWithData:changeData isXML:NO];
                                NSString* searchStr = [LMTool convertToHTMLStringWithListArray:listArr];
                                NSArray* elementArr = [doc searchWithXPathQuery:searchStr];
                                NSMutableArray* bookChaptersArr = [NSMutableArray array];
                                for (NSInteger i = 0; i < elementArr.count; i ++) {
                                    if (i < parse.ioffset && parse.ioffset > 0) {
                                        continue;
                                    }
                                    TFHppleElement* element = [elementArr objectAtIndex:i];
                                    LMReaderBookChapter* bookChapter = [[LMReaderBookChapter alloc]init];
                                    
                                    NSString* briefStr = [element objectForKey:@"href"];
                                    NSString* bookChapterUrlStr = [LMTool getChapterUrlStrWithHostUrlStr:urlStr briefStr:briefStr];
                                    
                                    bookChapter.url = bookChapterUrlStr;
                                    bookChapter.title = element.content;
                                    bookChapter.chapterId = i;
                                    [bookChaptersArr addObject:bookChapter];
                                }
                                
                                [weakSelf startDownloadNewParseBookWithBookId:bookId catalogList:bookChaptersArr parse:parse block:^(BOOL isFinished, CGFloat progress) {
                                    
                                    successBlock(isFinished, progress);
                                }];
                                
                            } failureBlock:^(NSError *failureError) {
                                failureBlock(YES);
                            }];
                        }else {
                            failureBlock(YES);
                        }
                    }
                }else {
                    failureBlock(YES);
                }
            }
            
        } @catch (NSException *exception) {
            failureBlock(YES);
        } @finally {
            
        }
        
    } failureBlock:^(NSError *failureError) {
        
        failureBlock(YES);
    }];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
