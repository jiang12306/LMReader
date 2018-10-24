//
//  LMReaderBookViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/13.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderBookViewController.h"
#import "LMContentViewController.h"
#import "LMCatalogViewController.h"
#import "LMNewCatalogViewController.h"
#import "LMChangeSourceViewController.h"
#import "LMTool.h"
#import "LMDatabaseTool.h"
#import <CoreText/CoreText.h>
#import "LMReaderSettingView.h"
#import "LMDownloadBookView.h"
#import "LMReaderRelatedBookAlertView.h"
#import "LMReaderFeedBackAlertView.h"
#import "LMBookDetailViewController.h"
#import "TFHpple.h"
#import "PopoverView.h"
#import "LMSourceTitleView.h"
#import "LMSourceAlertView.h"
#import "MBProgressHUD.h"
#import "LMShareView.h"
#import "LMShareMessage.h"
#import "SDImageCache.h"
#import "LMPageViewController.h"
#import "LMBookCommentDetailViewController.h"
#import "LMBookEditCommentViewController.h"
#import "LMLoginAlertView.h"
#import "LMProfileProtocolViewController.h"
#import "LMLaunchDetailViewController.h"

@interface LMReaderBookViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, LMPageViewControllerDelegate, LMContentViewControllerDelegate>

@property (nonatomic, strong) UIView* naviBarView;//naviBar
@property (nonatomic, strong) UILabel* titleLab;
@property (nonatomic, strong) UIView* toolBarView;//toolBar
@property (nonatomic, strong) UIButton* editCommentBtn;//编辑评论button

@property (nonatomic, strong) LMPageViewController* pageVC;
@property (nonatomic, strong) LMReaderSettingView*  settingView;//设置 视图
@property (nonatomic, strong) LMDownloadBookView* downloadView;//下载 视图
@property (nonatomic, strong) LMSourceTitleView* sourceView;//来源 视图
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) LMReadModel readModel;
@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) CGFloat lineSpaceIndex;/**<行间距角标*/
@property (nonatomic, assign) BOOL isAnimate;//全局动画标识，限制过快点击导致闪退
@property (nonatomic, strong) NSMutableArray* relatedArray;//相关推荐书
@property (nonatomic, assign) BOOL isCollected;//是否已加入书架
@property (nonatomic, assign) BOOL autoLoadNext;//预加载下一章节

@property (nonatomic, copy) NSString* shareCoverUrl;//封面url，分享用

@end

@implementation LMReaderBookViewController

#pragma mark -LMContentViewControllerDelegate
-(void)didClickedAdViewIsBook:(BOOL )isBook bookIdStr:(NSString* )bookIdStr urlStr:(NSString* )urlStr {
    if (isBook) {
        LMBookDetailViewController* bookDetailVC = [[LMBookDetailViewController alloc]init];
        bookDetailVC.bookId = [bookIdStr intValue];
        [self.navigationController pushViewController:bookDetailVC animated:YES];
    }else {
        if ([urlStr rangeOfString:@"itunes.apple.com"].location != NSNotFound) {
            NSString* encodeStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSURL* encodeUrl = [NSURL URLWithString:encodeStr];
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                [[UIApplication sharedApplication] openURL:encodeUrl options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
        }else {
            //打开广告页详情
            LMLaunchDetailViewController* adDetailVC = [[LMLaunchDetailViewController alloc]init];
            adDetailVC.urlString = urlStr;
            [self.navigationController pushViewController:adDetailVC animated:YES];
        }
    }
}

#pragma mark -LMPageViewControllerDelegate
-(void)LMPageViewControllerDidTapScreenCenterToShowOrHideNavigationBar {
    [self tapped:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //设置屏幕常亮
    [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(BOOL)prefersStatusBarHidden {
    BOOL isHiden = self.naviBarView.frame.origin.y < 0;
    if (isHiden) {
        return YES;
    }else {
        return NO;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    [self saveReaderRecorder];//从3D-Touch进入app、回到“书架”页面LMRootViewController控制时，保存阅读进度
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    tap.cancelsTouchesInView = NO;
    UIView* tapVi = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 3, self.view.frame.size.height / 4, self.view.frame.size.width / 3, self.view.frame.size.height / 2)];
    tapVi.backgroundColor = [UIColor clearColor];
    [tapVi addGestureRecognizer:tap];
    [self.view addSubview:tapVi];
    
    //退出app前 保存阅读记录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    //微信分享通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shareNewsSucceed:) name:weChatShareNotifyName object:nil];
    
    self.fd_prefersNavigationBarHidden = YES;
    
    CGFloat naviHeight = 20 + 44;
    CGFloat startY = 20 + 7;
    CGFloat toolBarHeight = 49;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
        startY = 44 + 7;
        toolBarHeight = 83;
    }
    self.naviBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, naviHeight)];
    self.naviBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.naviBarView];
    
    UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(10, startY, 52, 30)];
    UIImage* leftImage = [UIImage imageNamed:@"navigationItem_Back"];
    UIImage* tintImage = [leftImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, leftView.frame.size.width, leftView.frame.size.height)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [leftButton setImage:tintImage forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 40)];
    [leftButton addTarget:self action:@selector(clickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftView addSubview:leftButton];
    [self.naviBarView addSubview:leftView];
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40 - 10, startY, 40, 30)];
    UIButton* rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, rightView.frame.size.width, rightView.frame.size.height)];
    [rightButton addTarget:self action:@selector(clickedRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"rightBarButtonItem_More"] forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(4, 3, 5, 3)];
    [rightView addSubview:rightButton];
    [self.naviBarView addSubview:rightView];
    
    UIView* changeSourceVi = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - rightView.frame.size.width - 10 * 2 - 40, startY, 40, 30)];
    UIButton* changeSourceBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, changeSourceVi.frame.size.width, changeSourceVi.frame.size.height)];
    changeSourceBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [changeSourceBtn addTarget:self action:@selector(clickedChangeSourceButton:) forControlEvents:UIControlEventTouchUpInside];
    [changeSourceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeSourceBtn setTitle:@"换源" forState:UIControlStateNormal];
    [changeSourceVi addSubview:changeSourceBtn];
    [self.naviBarView addSubview:changeSourceVi];
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 80) / 2, startY, 80, 30)];
    self.titleLab.font = [UIFont boldSystemFontOfSize:18];
    self.titleLab.textColor = [UIColor whiteColor];
    self.titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    NSString* titleStr = @"正文阅读";
    if (self.bookName != nil && self.bookName.length > 0) {
        titleStr = self.bookName;
    }
    self.titleLab.text = titleStr;
    [self.naviBarView addSubview:self.titleLab];
    CGFloat maxTitleWidth = (changeSourceVi.frame.origin.x - (self.view.frame.size.width / 2) - 10) * 2;
    CGRect originalTitleFrame = self.titleLab.frame;
    CGSize titleSize = [self.titleLab sizeThatFits:CGSizeMake(CGFLOAT_MAX, originalTitleFrame.size.height)];
    if (titleSize.width > maxTitleWidth) {
        titleSize.width = maxTitleWidth;
    }
    self.titleLab.frame = CGRectMake((self.view.frame.size.width - titleSize.width) / 2, originalTitleFrame.origin.y, titleSize.width, originalTitleFrame.size.height);
    
    self.isCollected = [[LMDatabaseTool sharedDatabaseTool] checkUserBooksIsExistWithBookId:self.bookId];
    self.autoLoadNext =  [LMTool getSystemAutoLoadNextChapterConfig];//预加载下一章节
    self.brightness = [UIScreen mainScreen].brightness;
    [LMTool getReaderConfig:^(CGFloat brightness, CGFloat fontSize, NSInteger bgInteger, CGFloat lineSpace, NSInteger lpIndex) {
        self.fontSize = fontSize;
        [UIScreen mainScreen].brightness = brightness;
        self.lineSpace = lineSpace;
        self.lineSpaceIndex = lpIndex;
        self.readModel = LMReaderBackgroundType1;
        if (bgInteger == 1) {
            self.readModel = LMReaderBackgroundType1;
        }else if (bgInteger == 2) {
            self.readModel = LMReaderBackgroundType2;
        }else if (bgInteger == 3) {
            self.readModel = LMReaderBackgroundType3;
        }else if (bgInteger == 4) {
            self.readModel = LMReaderBackgroundType4;
        }
    }];
    
    self.toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - toolBarHeight, self.view.frame.size.width, toolBarHeight)];
    self.toolBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.toolBarView];
    
    self.editCommentBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 50, self.toolBarView.frame.origin.y - 10 - 50, 50, 50)];
    self.editCommentBtn.backgroundColor = [UIColor colorWithRed:36.f/255 green:36.f/255 blue:36.f/255 alpha:1];
    self.editCommentBtn.layer.cornerRadius = 25;
    self.editCommentBtn.layer.masksToBounds = YES;
    self.editCommentBtn.tintColor = THEMEORANGECOLOR;
    UIImage* editCommentImg = [[UIImage imageNamed:@"editComment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.editCommentBtn setImage:editCommentImg forState:UIControlStateNormal];
    [self.editCommentBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 13, 13, 13)];
    [self.editCommentBtn addTarget:self action:@selector(clickedEditCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editCommentBtn];
    
    NSArray* normalTitleArr = @[@"目录", @"报错", @"下载", @"收藏", @"设置"];
    NSArray* normalImgArr = @[@"toolBarItem_Catalog", @"toolBarItem_FeedBack", @"toolBarItem_Download", @"toolBarItem_Collect", @"toolBarItem_Setting"];
    CGFloat btnWidth = 44;
    CGFloat btnSpaceX = (self.view.frame.size.width - btnWidth * normalTitleArr.count) / (normalTitleArr.count + 1);
    for (NSInteger i = 0; i < normalTitleArr.count; i ++) {
        BOOL isSelected = NO;
        NSString* selectedTitle = nil;
        NSString* normalImg = normalImgArr[i];
        NSString* selectedImg = nil;
        if (i == 3) {
            isSelected = self.isCollected;
            selectedTitle = @"已收藏";
            selectedImg = @"toolBarItem_Collect_Selected";
        }
        CGRect btnFrame = CGRectMake(btnSpaceX * (i + 1) + btnWidth * i, 0, btnWidth, btnWidth);
        UIButton* btn = [self createToolBarButtonWithFrame:btnFrame Title:normalTitleArr[i] selectedTitle:selectedTitle normalImg:normalImg selectedImg:selectedImg isSelected:isSelected tag:i];
        [self.toolBarView addSubview:btn];
    }
    
    __weak LMReaderBookViewController* weakSelf = self;
    
    //隐藏头、尾
    [self setupNaviBarViewAndToolBarViewHidden:YES];
    
    if (self.readerBook != nil) {//从目录页进来，currentChapter等已被赋值
        //获取目录列表
        [self showNetworkLoadingView];
        
        BookChapterReqBuilder* builder = [BookChapterReq builder];
        [builder setBookId:self.bookId];
        BookChapterReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
        [networkTool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 7) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        BookChapterRes* res = [BookChapterRes parseFromData:apiRes.body];
                        NSArray* arr = res.chapters;
                        
                        [LMTool archiveBookCatalogListWithBookId:weakSelf.bookId catalogList:apiRes.body];//保存章节目录
                        
                        if (arr != nil && arr.count > 0) {//旧解析方式
                            NSInteger tempCurrentIndex = 0;
                            NSMutableArray* bookChapterArr = [NSMutableArray array];
                            for (NSInteger i = 0; i < arr.count; i ++) {
                                Chapter* tempChapter = [arr objectAtIndex:i];
                                
                                LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                                if (bookChapter.chapterId == self.readerBook.currentChapter.chapterId) {
                                    NSInteger tempBookOffset = self.readerBook.currentChapter.offset;
                                    bookChapter.offset = tempBookOffset;
                                    self.readerBook.currentChapter = bookChapter;
                                    tempCurrentIndex = i;
                                }
                                [bookChapterArr addObject:bookChapter];
                            }
                            if (tempCurrentIndex == 0) {
                                self.readerBook.currentChapter = [bookChapterArr firstObject];
                            }
                            self.readerBook.chaptersArr = bookChapterArr;
                            //加载章节内容
                            [weakSelf loadOldParseChapterContentWithCurrentChapter:self.readerBook.currentChapter shouldQueryCache:NO successBlock:^(NSString *contentStr) {
                                weakSelf.readerBook.currentChapter.content = contentStr;
                                NSInteger textOffset = weakSelf.readerBook.currentChapter.offset;
                                if (textOffset < 0) {
                                    textOffset = 0;
                                }else if (textOffset >= contentStr.length) {
                                    textOffset = 0;
                                }
                                weakSelf.readerBook.currentChapter.offset = textOffset;
                                NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                                weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                                NSInteger pageIndex = 0;
                                for (NSInteger i = 0; i < pagesArray.count; i ++) {
                                    LMReaderBookPage* page = [pagesArray objectAtIndex:i];
                                    if (page.startLocation >= textOffset) {
                                        pageIndex = i;
                                        break;
                                    }
                                }
                                weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                
                                [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                
                                [weakSelf hideNetworkLoadingView];
                            } failureBlock:^(NSError *error) {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }else {//新解析方式
                            weakSelf.readerBook.isNew = YES;
                            NSArray<UrlReadParse* >* bookParseArr = res.book.parses;
                            NSInteger parseIndex = 0;
                            for (NSInteger i = 0; i < bookParseArr.count; i ++) {
                                UrlReadParse* parse = [bookParseArr objectAtIndex:i];
                                if (weakSelf.readerBook.currentChapter.sourceId == parse.source.id) {
                                    parseIndex = i;
                                    break;
                                }
                            }
                            if (bookParseArr.count > 0) {
                                weakSelf.readerBook.parseArr = [NSArray arrayWithArray:bookParseArr];
                                weakSelf.readerBook.currentParseIndex = parseIndex;
                                UrlReadParse* parse = [bookParseArr objectAtIndex:weakSelf.readerBook.currentParseIndex];
                                //章节列表
                                [weakSelf initLoadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                                    weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                                    LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                    NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:weakSelf.readerBook.currentChapter];//当前章节角标
                                    LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                    realCurrentChapter.chapterId = currentChapter.chapterId;
                                    realCurrentChapter.sourceId = parse.source.id;
                                    realCurrentChapter.offset = currentChapter.offset;
                                    weakSelf.readerBook.currentChapter = realCurrentChapter;
                                    //章节内容
                                    [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                        realCurrentChapter.content = contentStr;
                                        NSInteger textOffset = realCurrentChapter.offset;
                                        if (textOffset < 0) {
                                            textOffset = 0;
                                        }else if (textOffset >= contentStr.length) {
                                            textOffset = 0;
                                        }
                                        realCurrentChapter.offset = textOffset;
                                        NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                                        weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                                        NSInteger pageIndex = 0;
                                        for (NSInteger i = 0; i < pagesArr.count; i ++) {
                                            LMReaderBookPage* page = [pagesArr objectAtIndex:i];
                                            if (page.startLocation >= textOffset) {
                                                pageIndex = i;
                                                break;
                                            }
                                        }
                                        weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                        weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                        
                                        [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                        
                                        [weakSelf hideNetworkLoadingView];
                                    } failureBlock:^(NSError *error) {
                                        [weakSelf hideNetworkLoadingView];
                                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                                    }];
                                    
                                } failureBlock:^(NSError *error) {
                                    [weakSelf hideNetworkLoadingView];
                                    [weakSelf showMBProgressHUDWithText:@"获取失败"];
                                }];
                            }else {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }
                        }
                    }else {
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf showFailedBackAlertController];
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {//网络请求失败，获取之前缓存的目录列表
            @try {
                NSData* data = [LMTool unArchiveBookCatalogListWithBookId:weakSelf.bookId];
                
                BookChapterRes* res = [BookChapterRes parseFromData:data];
                NSArray* arr = res.chapters;
                if (arr != nil && arr.count > 0) {//旧解析方式
                    NSInteger tempCurrentIndex = 0;
                    NSMutableArray* bookChapterArr = [NSMutableArray array];
                    for (NSInteger i = 0; i < arr.count; i ++) {
                        Chapter* tempChapter = [arr objectAtIndex:i];
                        
                        LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                        if (bookChapter.chapterId == self.readerBook.currentChapter.chapterId) {
                            NSInteger tempBookOffset = self.readerBook.currentChapter.offset;
                            bookChapter.offset = tempBookOffset;
                            self.readerBook.currentChapter = bookChapter;
                            tempCurrentIndex = i;
                        }
                        [bookChapterArr addObject:bookChapter];
                    }
                    if (tempCurrentIndex == 0) {
                        self.readerBook.currentChapter = [bookChapterArr firstObject];
                    }
                    self.readerBook.chaptersArr = bookChapterArr;
                    //加载章节内容
                    [weakSelf loadOldParseChapterContentWithCurrentChapter:self.readerBook.currentChapter shouldQueryCache:NO successBlock:^(NSString *contentStr) {
                        weakSelf.readerBook.currentChapter.content = contentStr;
                        NSInteger textOffset = weakSelf.readerBook.currentChapter.offset;
                        if (textOffset < 0) {
                            textOffset = 0;
                        }else if (textOffset >= contentStr.length) {
                            textOffset = 0;
                        }
                        weakSelf.readerBook.currentChapter.offset = textOffset;
                        NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                        weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                        NSInteger pageIndex = 0;
                        for (NSInteger i = 0; i < pagesArray.count; i ++) {
                            LMReaderBookPage* page = [pagesArray objectAtIndex:i];
                            if (page.startLocation >= textOffset) {
                                pageIndex = i;
                                break;
                            }
                        }
                        weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                        weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                        
                        [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                        
                        [weakSelf hideNetworkLoadingView];
                    } failureBlock:^(NSError *error) {
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                    }];
                }else {//新解析方式
                    weakSelf.readerBook.isNew = YES;
                    NSArray<UrlReadParse* >* bookParseArr = res.book.parses;
                    NSInteger parseIndex = 0;
                    for (NSInteger i = 0; i < bookParseArr.count; i ++) {
                        UrlReadParse* parse = [bookParseArr objectAtIndex:i];
                        if (weakSelf.readerBook.currentChapter.sourceId == parse.source.id) {
                            parseIndex = i;
                            break;
                        }
                    }
                    if (bookParseArr.count > 0) {
                        weakSelf.readerBook.parseArr = [NSArray arrayWithArray:bookParseArr];
                        weakSelf.readerBook.currentParseIndex = parseIndex;
                        UrlReadParse* parse = [bookParseArr objectAtIndex:weakSelf.readerBook.currentParseIndex];
                        //章节列表
                        [weakSelf initLoadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                            weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                            LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                            NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:currentChapter];//当前章节角标
                            LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                            realCurrentChapter.chapterId = currentChapter.chapterId;
                            realCurrentChapter.sourceId = parse.source.id;
                            realCurrentChapter.offset = currentChapter.offset;
                            weakSelf.readerBook.currentChapter = realCurrentChapter;
                            //章节内容
                            [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                realCurrentChapter.content = contentStr;
                                NSInteger textOffset = realCurrentChapter.offset;
                                if (textOffset < 0) {
                                    textOffset = 0;
                                }else if (textOffset >= contentStr.length) {
                                    textOffset = 0;
                                }
                                realCurrentChapter.offset = textOffset;
                                NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                                weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                                NSInteger pageIndex = 0;
                                for (NSInteger i = 0; i < pagesArr.count; i ++) {
                                    LMReaderBookPage* page = [pagesArr objectAtIndex:i];
                                    if (page.startLocation >= textOffset) {
                                        pageIndex = i;
                                        break;
                                    }
                                }
                                weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                
                                [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                
                                [weakSelf hideNetworkLoadingView];
                            } failureBlock:^(NSError *error) {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        } failureBlock:^(NSError *error) {
                            //取缓存章节列表
                            NSArray* chaptersList = [LMTool unarchiveNewParseBookCatalogListWithBookId:weakSelf.bookId];
                            if (chaptersList != nil && chaptersList.count > 0) {
                                weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:chaptersList];
                                LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:currentChapter];//当前章节角标
                                LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                realCurrentChapter.chapterId = currentChapter.chapterId;
                                realCurrentChapter.sourceId = parse.source.id;
                                realCurrentChapter.offset = currentChapter.offset;
                                weakSelf.readerBook.currentChapter = realCurrentChapter;
                                //章节内容
                                [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                    realCurrentChapter.content = contentStr;
                                    NSInteger textOffset = realCurrentChapter.offset;
                                    if (textOffset < 0) {
                                        textOffset = 0;
                                    }else if (textOffset >= contentStr.length) {
                                        textOffset = 0;
                                    }
                                    realCurrentChapter.offset = textOffset;
                                    NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                                    weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                                    NSInteger pageIndex = 0;
                                    for (NSInteger i = 0; i < pagesArr.count; i ++) {
                                        LMReaderBookPage* page = [pagesArr objectAtIndex:i];
                                        if (page.startLocation >= textOffset) {
                                            pageIndex = i;
                                            break;
                                        }
                                    }
                                    weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                    weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                    
                                    [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                    
                                    [weakSelf hideNetworkLoadingView];
                                } failureBlock:^(NSError *error) {
                                    [weakSelf hideNetworkLoadingView];
                                    [weakSelf showMBProgressHUDWithText:@"获取失败"];
                                }];
                            }else {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }
                        }];
                    }else {
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf hideNetworkLoadingView];
                [weakSelf showMBProgressHUDWithText:@"获取失败"];
            } @finally {
                
            }
        }];
    }else {
        self.readerBook = [[LMReaderBook alloc]init];
        LMReaderBookChapter* currentBookChapter = [[LMReaderBookChapter alloc]init];
        currentBookChapter.offset = 0;
        self.readerBook.currentChapter = currentBookChapter;
        
        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
        [tool queryBookReadRecordWithBookId:self.bookId recordBlock:^(BOOL hasRecord, UInt32 chapterId, UInt32 sourceId, NSInteger offset) {
            self.readerBook.currentChapter.chapterId = 0;
            self.readerBook.currentChapter.offset = offset;
            if (hasRecord) {
                self.readerBook.currentChapter.chapterId = chapterId;
                self.readerBook.currentChapter.sourceId = sourceId;
            }
        }];
        
        //获取目录列表
        [self showNetworkLoadingView];
        
        BookChapterReqBuilder* builder = [BookChapterReq builder];
        [builder setBookId:self.bookId];
        BookChapterReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
        [networkTool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 7) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        BookChapterRes* res = [BookChapterRes parseFromData:apiRes.body];
                        NSArray* arr = res.chapters;
                        
                        [LMTool archiveBookCatalogListWithBookId:weakSelf.bookId catalogList:apiRes.body];//保存章节目录
                        
                        if (arr != nil && arr.count > 0) {//旧解析方式
                            NSInteger tempCurrentIndex = 0;
                            NSMutableArray* bookChapterArr = [NSMutableArray array];
                            for (NSInteger i = 0; i < arr.count; i ++) {
                                Chapter* tempChapter = [arr objectAtIndex:i];
                                
                                LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                                if (bookChapter.chapterId == self.readerBook.currentChapter.chapterId) {
                                    NSInteger tempBookOffset = self.readerBook.currentChapter.offset;
                                    bookChapter.offset = tempBookOffset;
                                    self.readerBook.currentChapter = bookChapter;
                                    tempCurrentIndex = i;
                                }
                                [bookChapterArr addObject:bookChapter];
                            }
                            if (tempCurrentIndex == 0) {
                                self.readerBook.currentChapter = [bookChapterArr firstObject];
                            }
                            self.readerBook.chaptersArr = bookChapterArr;
                            //加载章节内容
                            [weakSelf loadOldParseChapterContentWithCurrentChapter:self.readerBook.currentChapter shouldQueryCache:NO successBlock:^(NSString *contentStr) {
                                weakSelf.readerBook.currentChapter.content = contentStr;
                                NSInteger textOffset = weakSelf.readerBook.currentChapter.offset;
                                if (textOffset < 0) {
                                    textOffset = 0;
                                }else if (textOffset >= contentStr.length) {
                                    textOffset = 0;
                                }
                                weakSelf.readerBook.currentChapter.offset = textOffset;
                                NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                                weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                                NSInteger pageIndex = 0;
                                for (NSInteger i = 0; i < pagesArray.count; i ++) {
                                    LMReaderBookPage* page = [pagesArray objectAtIndex:i];
                                    if (page.startLocation >= textOffset) {
                                        pageIndex = i;
                                        break;
                                    }
                                }
                                weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                
                                [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                
                                [weakSelf hideNetworkLoadingView];
                            } failureBlock:^(NSError *error) {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }else {//新解析方式
                            weakSelf.readerBook.isNew = YES;
                            NSArray<UrlReadParse* >* bookParseArr = res.book.parses;
                            NSInteger parseIndex = 0;
                            for (NSInteger i = 0; i < bookParseArr.count; i ++) {
                                UrlReadParse* parse = [bookParseArr objectAtIndex:i];
                                if (weakSelf.readerBook.currentChapter.sourceId == parse.source.id) {
                                    parseIndex = i;
                                    break;
                                }
                            }
                            if (bookParseArr.count > 0) {
                                weakSelf.readerBook.parseArr = [NSArray arrayWithArray:bookParseArr];
                                weakSelf.readerBook.currentParseIndex = parseIndex;
                                UrlReadParse* parse = [bookParseArr objectAtIndex:weakSelf.readerBook.currentParseIndex];
                                //章节列表
                                [weakSelf initLoadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                                    weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                                    LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                    NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:weakSelf.readerBook.currentChapter];//当前章节角标
                                    LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                    realCurrentChapter.chapterId = currentChapter.chapterId;
                                    realCurrentChapter.sourceId = parse.source.id;
                                    realCurrentChapter.offset = currentChapter.offset;
                                    weakSelf.readerBook.currentChapter = realCurrentChapter;
                                    //章节内容
                                    [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                        realCurrentChapter.content = contentStr;
                                        NSInteger textOffset = realCurrentChapter.offset;
                                        if (textOffset < 0) {
                                            textOffset = 0;
                                        }else if (textOffset >= contentStr.length) {
                                            textOffset = 0;
                                        }
                                        realCurrentChapter.offset = textOffset;
                                        NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                                        weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                                        NSInteger pageIndex = 0;
                                        for (NSInteger i = 0; i < pagesArr.count; i ++) {
                                            LMReaderBookPage* page = [pagesArr objectAtIndex:i];
                                            if (page.startLocation >= textOffset) {
                                                pageIndex = i;
                                                break;
                                            }
                                        }
                                        weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                        weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                        
                                        [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                        
                                        [weakSelf hideNetworkLoadingView];
                                    } failureBlock:^(NSError *error) {
                                        [weakSelf hideNetworkLoadingView];
                                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                                    }];
                                    
                                } failureBlock:^(NSError *error) {
                                    [weakSelf hideNetworkLoadingView];
                                    [weakSelf showMBProgressHUDWithText:@"获取失败"];
                                }];
                            }else {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }
                        }
                    }else {
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf showFailedBackAlertController];
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {//网络请求失败，获取之前缓存的目录列表
            @try {
                NSData* data = [LMTool unArchiveBookCatalogListWithBookId:weakSelf.bookId];
                
                BookChapterRes* res = [BookChapterRes parseFromData:data];
                NSArray* arr = res.chapters;
                if (arr != nil && arr.count > 0) {//旧解析方式
                    NSInteger tempCurrentIndex = 0;
                    NSMutableArray* bookChapterArr = [NSMutableArray array];
                    for (NSInteger i = 0; i < arr.count; i ++) {
                        Chapter* tempChapter = [arr objectAtIndex:i];
                        
                        LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                        if (bookChapter.chapterId == self.readerBook.currentChapter.chapterId) {
                            NSInteger tempBookOffset = self.readerBook.currentChapter.offset;
                            bookChapter.offset = tempBookOffset;
                            self.readerBook.currentChapter = bookChapter;
                            tempCurrentIndex = i;
                        }
                        [bookChapterArr addObject:bookChapter];
                    }
                    if (tempCurrentIndex == 0) {
                        self.readerBook.currentChapter = [bookChapterArr firstObject];
                    }
                    self.readerBook.chaptersArr = bookChapterArr;
                    //加载章节内容
                    [weakSelf loadOldParseChapterContentWithCurrentChapter:self.readerBook.currentChapter shouldQueryCache:NO successBlock:^(NSString *contentStr) {
                        weakSelf.readerBook.currentChapter.content = contentStr;
                        NSInteger textOffset = weakSelf.readerBook.currentChapter.offset;
                        if (textOffset < 0) {
                            textOffset = 0;
                        }else if (textOffset >= contentStr.length) {
                            textOffset = 0;
                        }
                        weakSelf.readerBook.currentChapter.offset = textOffset;
                        NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                        weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                        NSInteger pageIndex = 0;
                        for (NSInteger i = 0; i < pagesArray.count; i ++) {
                            LMReaderBookPage* page = [pagesArray objectAtIndex:i];
                            if (page.startLocation >= textOffset) {
                                pageIndex = i;
                                break;
                            }
                        }
                        weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                        weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                        
                        [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                        
                        [weakSelf hideNetworkLoadingView];
                    } failureBlock:^(NSError *error) {
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                    }];
                }else {//新解析方式
                    weakSelf.readerBook.isNew = YES;
                    NSArray<UrlReadParse* >* bookParseArr = res.book.parses;
                    NSInteger parseIndex = 0;
                    for (NSInteger i = 0; i < bookParseArr.count; i ++) {
                        UrlReadParse* parse = [bookParseArr objectAtIndex:i];
                        if (weakSelf.readerBook.currentChapter.sourceId == parse.source.id) {
                            parseIndex = i;
                            break;
                        }
                    }
                    if (bookParseArr.count > 0) {
                        weakSelf.readerBook.parseArr = [NSArray arrayWithArray:bookParseArr];
                        weakSelf.readerBook.currentParseIndex = parseIndex;
                        UrlReadParse* parse = [bookParseArr objectAtIndex:weakSelf.readerBook.currentParseIndex];
                        //章节列表
                        [weakSelf initLoadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                            weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                            LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                            NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:currentChapter];//当前章节角标
                            LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                            realCurrentChapter.chapterId = currentChapter.chapterId;
                            realCurrentChapter.sourceId = parse.source.id;
                            realCurrentChapter.offset = currentChapter.offset;
                            weakSelf.readerBook.currentChapter = realCurrentChapter;
                            //章节内容
                            [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                realCurrentChapter.content = contentStr;
                                NSInteger textOffset = realCurrentChapter.offset;
                                if (textOffset < 0) {
                                    textOffset = 0;
                                }else if (textOffset >= contentStr.length) {
                                    textOffset = 0;
                                }
                                realCurrentChapter.offset = textOffset;
                                NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                                weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                                NSInteger pageIndex = 0;
                                for (NSInteger i = 0; i < pagesArr.count; i ++) {
                                    LMReaderBookPage* page = [pagesArr objectAtIndex:i];
                                    if (page.startLocation >= textOffset) {
                                        pageIndex = i;
                                        break;
                                    }
                                }
                                weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                
                                [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                
                                [weakSelf hideNetworkLoadingView];
                            } failureBlock:^(NSError *error) {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        } failureBlock:^(NSError *error) {
                            //取缓存章节列表
                            NSArray* chaptersList = [LMTool unarchiveNewParseBookCatalogListWithBookId:weakSelf.bookId];
                            if (chaptersList != nil && chaptersList.count > 0) {
                                weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:chaptersList];
                                LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:currentChapter];//当前章节角标
                                LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                realCurrentChapter.chapterId = currentChapter.chapterId;
                                realCurrentChapter.sourceId = parse.source.id;
                                realCurrentChapter.offset = currentChapter.offset;
                                weakSelf.readerBook.currentChapter = realCurrentChapter;
                                //章节内容
                                [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                    realCurrentChapter.content = contentStr;
                                    NSInteger textOffset = realCurrentChapter.offset;
                                    if (textOffset < 0) {
                                        textOffset = 0;
                                    }else if (textOffset >= contentStr.length) {
                                        textOffset = 0;
                                    }
                                    realCurrentChapter.offset = textOffset;
                                    NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                                    weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                                    NSInteger pageIndex = 0;
                                    for (NSInteger i = 0; i < pagesArr.count; i ++) {
                                        LMReaderBookPage* page = [pagesArr objectAtIndex:i];
                                        if (page.startLocation >= textOffset) {
                                            pageIndex = i;
                                            break;
                                        }
                                    }
                                    weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                    weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                    
                                    [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                    
                                    [weakSelf hideNetworkLoadingView];
                                } failureBlock:^(NSError *error) {
                                    [weakSelf hideNetworkLoadingView];
                                    [weakSelf showMBProgressHUDWithText:@"获取失败"];
                                }];
                            }else {
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }
                        }];
                    }else {
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf showMBProgressHUDWithText:@"获取失败"];
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf hideNetworkLoadingView];
                [weakSelf showMBProgressHUDWithText:@"获取失败"];
            } @finally {
                
            }
        }];
    }
    
    self.isAnimate = NO;
    
    //加载 推荐的相关书籍
    [self loadRelatedBook];
}

//优先匹配title，其次匹配chapterId，查找当前章节角标
-(NSInteger )queryCurrentChapterIndexWithChaptersArray:(NSArray* )chaptersArray currentChapter:(LMReaderBookChapter* )currentChapter {
    NSInteger currentIndex = 0;
    if (chaptersArray.count > 0) {
        for (NSInteger i = 0; i < chaptersArray.count; i ++) {
            LMReaderBookChapter* bookChapter = [chaptersArray objectAtIndex:i];
            if (currentChapter != nil) {
                NSString* chapterTitle = currentChapter.title;
                if (chapterTitle != nil && ![chapterTitle isKindOfClass:[NSNull class]] && chapterTitle.length > 0) {
                    if ([bookChapter.title isEqualToString:chapterTitle]) {//优先判断标题
                        currentIndex = i;
                        break;
                    }else {//再判断chapterId是否相同
                        if (bookChapter.chapterId == currentChapter.chapterId) {
                            currentIndex = i;
                            break;
                        }
                    }
                }else {
                    if (bookChapter.chapterId == currentChapter.chapterId) {
                        currentIndex = i;
                        break;
                    }
                }
            }else {
                break;
            }
        }
    }
    return currentIndex;
}

-(void)showFailedBackAlertController {
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取小说失败" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* backAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIScreen mainScreen].brightness = self.brightness;
        [self notifyChangeSourceViewControllerDeleteCache];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [controller addAction:backAction];
    [self presentViewController:controller animated:YES completion:nil];
}

//加载相关推荐书籍
-(void)loadRelatedBook {
    BookRelateReqBuilder* builder = [BookRelateReq builder];
    [builder setBookId:self.bookId];
    BookRelateReq* req = [builder build];
    NSData* reqData = [req data];
    __weak LMReaderBookViewController* weakSelf = self;
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:9 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 9) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookRelateRes* res = [BookRelateRes parseFromData:apiRes.body];
                    weakSelf.shareCoverUrl = res.book.pic;
                    UInt32 isAdd = res.haveAdd;
                    if (isAdd) {
                        weakSelf.isCollected = YES;
                    }else {
                        weakSelf.isCollected = NO;
                    }
                    NSArray* arr = res.relateBooks;
                    if (arr.count > 0) {
                        weakSelf.relatedArray = [NSMutableArray arrayWithArray:arr];
                    }
                }
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        
    }];
}

-(void)setupNaviBarViewAndToolBarViewHidden:(BOOL )shouldHidden {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    CGRect naviFrame = self.naviBarView.frame;
    CGRect finalNaviFrame = CGRectMake(0, 0, naviFrame.size.width, naviFrame.size.height);
    CGRect toolBarFrame = self.toolBarView.frame;
    CGRect finalToolFrame = CGRectMake(0, screenRect.size.height - toolBarFrame.size.height, toolBarFrame.size.width, toolBarFrame.size.height);
    CGRect editFrame = self.editCommentBtn.frame;
    CGRect finalEditFrame = CGRectMake(editFrame.origin.x, finalToolFrame.origin.y - editFrame.size.height - 10, editFrame.size.width, editFrame.size.height);
    if (shouldHidden) {
        finalNaviFrame = CGRectMake(0, 0 - finalNaviFrame.size.height, finalNaviFrame.size.width, finalNaviFrame.size.height);
        finalToolFrame = CGRectMake(0, screenRect.size.height, toolBarFrame.size.width, toolBarFrame.size.height);
        finalEditFrame = CGRectMake(editFrame.origin.x, screenRect.size.height, editFrame.size.width, editFrame.size.height);
    }
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.naviBarView.frame = finalNaviFrame;
        self.toolBarView.frame = finalToolFrame;
        self.editCommentBtn.frame = finalEditFrame;
    } completion:^(BOOL finished) {
        
    }];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

//新解析方式 加载章节列表
-(void)initLoadNewParseBookChaptersWithUrlReadParse:(UrlReadParse* )parse successBlock:(void (^) (NSArray* listArray))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    [self showNetworkLoadingView];
    __weak LMReaderBookViewController* weakSelf = self;
    NSString* urlStr = parse.listUrl;
    [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
        @try {
            NSMutableArray* listArr = [NSMutableArray array];
            
            NSArray* listStrArr = [parse.listParse componentsSeparatedByString:@","];
            NSStringEncoding encoding = [LMTool convertEncodingStringWithEncoding:parse.source.htmlcharset];
            NSString* originStr = [[NSString alloc]initWithData:successData encoding:encoding];
            NSData* changeData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
            TFHpple* doc = [[TFHpple alloc] initWithData:changeData isXML:NO];
            NSString* searchStr = [LMTool convertToHTMLStringWithListArray:listStrArr];
            NSArray* elementArr = [doc searchWithXPathQuery:searchStr];
            NSInteger listOffset = 0;//跳过前n章节
            if ([parse hasIoffset]) {
                listOffset = parse.ioffset;
            }
            for (NSInteger i = 0; i < elementArr.count; i ++) {
                if (i < listOffset) {
                    continue;
                }
                TFHppleElement* element = [elementArr objectAtIndex:i];
                LMReaderBookChapter* bookChapter = [[LMReaderBookChapter alloc]init];
                
                NSString* briefStr = [element objectForKey:@"href"];
                NSString* bookChapterUrlStr = [LMTool getChapterUrlStrWithHostUrlStr:urlStr briefStr:briefStr];
                
                bookChapter.url = bookChapterUrlStr;
                bookChapter.title = element.content;
                bookChapter.chapterId = i - listOffset;
                [listArr addObject:bookChapter];
            }
            if (listArr.count > 0) {
                successBlock(listArr);
                //保存新解析方式下章节列表
                [LMTool archiveNewParseBookCatalogListWithBookId:weakSelf.bookId catalogList:listArr];
            }else {
                [self reportParseErrorWithSourceId:parse.source.id chapterName:nil];//上报
                failureBlock(nil);
            }
        } @catch (NSException *exception) {
            [self reportParseErrorWithSourceId:parse.source.id chapterName:nil];//上报
            failureBlock(nil);
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        failureBlock(nil);
    }];
}

//新解析方式 根据章节取内容
-(void)initLoadNewParseChapterContentWithBookChapter:(LMReaderBookChapter* )bookChapter UrlReadParse:(UrlReadParse* )parse successBlock:(void (^) (NSString* contentStr))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    UInt32 bookId = self.bookId;
    UInt32 chapterId = (UInt32 )bookChapter.chapterId;
    if ([LMTool isExistBookTextWithBookId:self.bookId chapterId:chapterId]) {//有缓存，取缓存
        NSString* queryText = [LMTool queryBookTextWithBookId:self.bookId chapterId:chapterId];
        NSString* chapterText = [LMTool filterUselessStringWithText:queryText filterArr:parse.source.filter];
        chapterText = [LMTool replaceSeveralNewLineWithOneNewLineWithText:chapterText];
        if (chapterText != nil && ![chapterText isKindOfClass:[NSNull class]] && chapterText.length > 0) {
            successBlock(chapterText);
            return;
        }
    }
    NSString* urlStr = bookChapter.url;
    [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
        @try {
            NSArray* contentArr = [parse.contentParse componentsSeparatedByString:@","];
            NSStringEncoding encoding = [LMTool convertEncodingStringWithEncoding:parse.source.htmlcharset];//转码
            NSString* originStr = [[NSString alloc]initWithData:successData encoding:encoding];
            originStr = [LMTool replaceBrCharacterWithReturnCharacter:originStr];
            NSData* changeData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
            TFHpple* contentDoc = [[TFHpple alloc]initWithData:changeData isXML:NO];
            NSString* contentSearchStr = [LMTool convertToHTMLStringWithListArray:contentArr];
            TFHppleElement* contentElement = [contentDoc peekAtSearchWithXPathQuery:contentSearchStr];
            NSString* elementText = contentElement.content;
            NSString* totalContentStr = [LMTool filterUselessStringWithText:elementText filterArr:parse.source.filter];
            totalContentStr = [LMTool replaceSeveralNewLineWithOneNewLineWithText:totalContentStr];
            if (totalContentStr != nil && ![totalContentStr isKindOfClass:[NSNull class]]) {
                [LMTool saveBookTextWithBookId:bookId chapterId:chapterId bookText:totalContentStr];//保存
                
                successBlock(totalContentStr);
            }else {
                [self reportParseErrorWithSourceId:parse.source.id chapterName:bookChapter.title];//上报
                failureBlock(nil);
            }
        } @catch (NSException *exception) {
            [self reportParseErrorWithSourceId:parse.source.id chapterName:bookChapter.title];//上报
            failureBlock(nil);
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        failureBlock(failureError);
    }];
}

//旧解析模式下 加载章节内容 queryCache：是否需要优先取缓存，初始化进入阅读器、从换源过来的时候不取缓存
-(void)loadOldParseChapterContentWithCurrentChapter:(LMReaderBookChapter* )currentChapter shouldQueryCache:(BOOL )queryCache successBlock:(void (^) (NSString* contentStr))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    NSString* tempTitleStr = currentChapter.title;
    UInt32 bookId = self.bookId;
    UInt32 chapterNo = (UInt32 )currentChapter.chapterNo;
    UInt32 chapterId = (UInt32 )currentChapter.chapterId;
    UInt32 sourceId = (UInt32 )currentChapter.sourceId;
    if (queryCache) {
        if (currentChapter.sourcesArr.count > 0) {//有源
            if ([LMTool isExistBookTextWithBookId:self.bookId chapterId:chapterId]) {//有缓存，取缓存
                NSString* queryText = [LMTool queryBookTextWithBookId:self.bookId chapterId:chapterId];
                NSString* chapterText = [LMTool replaceSeveralNewLineWithOneNewLineWithText:queryText];
                if (chapterText != nil && ![chapterText isKindOfClass:[NSNull class]] && chapterText.length > 0) {
                    successBlock(chapterText);
                    return;
                }
            }
        }
    }
    BookChapterSourceReqBuilder* builder = [BookChapterSourceReq builder];
    [builder setBookId:self.bookId];
    [builder setChapterNo:chapterNo];
    [builder setChapterTitle:tempTitleStr];
    [builder setSourceId:sourceId];
    BookChapterSourceReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 8) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookChapterSourceRes* res = [BookChapterSourceRes parseFromData:apiRes.body];
                    NSArray* arr = res.sources;
                    if (arr != nil && ![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                        currentChapter.sourcesArr = [NSArray arrayWithArray:arr];
                    }
                    NSString* originalContent = res.chapter.chapterContent;
                    NSString* tempContentText = [LMTool replaceSeveralNewLineWithOneNewLineWithText:originalContent];
                    if (tempContentText != nil && ![tempContentText isKindOfClass:[NSNull class]] && tempContentText.length > 0) {
                        [LMTool saveBookTextWithBookId:bookId chapterId:chapterId bookText:tempContentText];//保存
                        
                        successBlock(tempContentText);
                    }else {
                        failureBlock(nil);
                    }
                }else {
                    failureBlock(nil);
                }
            }
        } @catch (NSException *exception) {
            failureBlock(nil);
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        if (queryCache && [LMTool isExistBookTextWithBookId:self.bookId chapterId:chapterId]) {//有缓存，取缓存
            NSString* queryText = [LMTool queryBookTextWithBookId:self.bookId chapterId:chapterId];
            NSString* chapterText = [LMTool replaceSeveralNewLineWithOneNewLineWithText:queryText];
            if (chapterText != nil && ![chapterText isKindOfClass:[NSNull class]] && chapterText.length > 0) {
                successBlock(chapterText);
            }
        }else {
            failureBlock(failureError);
        }
    }];
}

//创建toolBarView上按钮
-(UIButton* )createToolBarButtonWithFrame:(CGRect )frame Title:(NSString* )title selectedTitle:(NSString* )selectedTitle normalImg:(NSString* )normalImg selectedImg:(NSString* )selectedImg isSelected:(BOOL )isSelected tag:(NSInteger )tag {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    btn.selected = NO;
    btn.tag = tag;
    [btn addTarget:self action:@selector(clickedToolBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    if (selectedImg) {
        [btn setImage:[UIImage imageNamed:selectedImg] forState:UIControlStateSelected];
    }
    [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 13, 21, 13)];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (selectedTitle) {
        [btn setTitle:selectedTitle forState:UIControlStateSelected];
    }
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(24, -22, 0, 0)];
    if (isSelected) {
        btn.selected = YES;
    }else {
        btn.selected = NO;
    }
    return btn;
}

//返回
-(void)clickedBackButton:(UIButton* )sender {
    //回调
    if (self.callBlock) {
        self.callBlock(YES);
    }
    
    NSString* tempText = self.readerBook.currentChapter.content;
    if (tempText != nil && ![tempText isKindOfClass:[NSNull class]] && tempText.length > 0) {
        LMReaderBookPage* bookPage = [self.readerBook.currentChapter.pagesArr objectAtIndex:self.readerBook.currentChapter.currentPage];
        UInt32 sourceId = 0;
        if (self.readerBook.isNew) {
            if (self.readerBook.parseArr != nil && self.readerBook.parseArr.count > 0) {
                UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                sourceId = parse.source.id;
            }else {
                return;
            }
        }else {
            if (self.readerBook.currentChapter != nil) {
                sourceId = (UInt32 )self.readerBook.currentChapter.sourceId;
            }else {
                return;
            }
        }
        ReadLogReqBuilder* builder = [ReadLogReq builder];
        [builder setChapterId:(UInt32 )self.readerBook.currentChapter.chapterId];
        [builder setBookId:self.bookId];
        [builder setIoffset:(UInt32 )bookPage.startLocation];
        [builder setSourceId:sourceId];
        ReadLogReq* req = [builder build];
        NSData* reqData = [req data];
        
        LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
        [networkTool postWithCmd:21 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 21) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {//成功
                        
                    }else {
                        
                    }
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {
            
        }];
        
        //保存阅读记录
        [self saveReaderRecorder];
    }
    
    if (self.relatedArray != nil && self.relatedArray.count > 0) {
        __weak LMReaderBookViewController* weakSelf = self;
        LMReaderRelatedBookAlertView* bookAV = [[LMReaderRelatedBookAlertView alloc]init];
        NSInteger subLength = self.relatedArray.count;
        if (self.relatedArray.count >= 3) {
            subLength = 3;
        }
        NSArray* subRelatedArr = [self.relatedArray subarrayWithRange:NSMakeRange(0, subLength)];
        [bookAV setupAlertViewWithArray:subRelatedArr isCollected:self.isCollected];
        [bookAV startShow];
        bookAV.clickedBookBlock = ^(Book *clickedBook) {
            if (clickedBook) {
                [self pushToBookDetailViewControllerWithBook:clickedBook];
            }
        };
        bookAV.closeBlock = ^(BOOL close) {
            [UIScreen mainScreen].brightness = self.brightness;
            [weakSelf notifyChangeSourceViewControllerDeleteCache];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        bookAV.collectBlock = ^(BOOL collect) {//加入书架
            UserBookStoreOperateType type = UserBookStoreOperateTypeOperateAdd;
            UserBookStoreOperateReqBuilder* builder = [UserBookStoreOperateReq builder];
            [builder setBookId:weakSelf.bookId];
            [builder setType:type];
            UserBookStoreOperateReq* req = [builder build];
            NSData* reqData = [req data];
            
            [self showNetworkLoadingView];
            
            LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
            [tool postWithCmd:4 ReqData:reqData successBlock:^(NSData *successData) {
                @try {
                    FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                    if (apiRes.cmd == 4) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {//成功
                            weakSelf.isCollected = YES;
                            //通知书架界面刷新
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBookShelfViewController" object:nil];
                            
                            [UIScreen mainScreen].brightness = self.brightness;
                            [weakSelf notifyChangeSourceViewControllerDeleteCache];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            
                            UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
                            hud.mode = MBProgressHUDModeText;
                            hud.label.text = @"收藏成功";
                            hud.removeFromSuperViewOnHide = YES;
                            [hud hideAnimated:YES afterDelay:1];
                            
                        }else {
                            [weakSelf showMBProgressHUDWithText:@"操作失败"];
                        }
                    }
                    
                } @catch (NSException *exception) {
                    [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
                } @finally {
                    
                }
                [weakSelf hideNetworkLoadingView];
                
            } failureBlock:^(NSError *failureError) {
                
                [weakSelf hideNetworkLoadingView];
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            }];
        };
    }else {
        [UIScreen mainScreen].brightness = self.brightness;
        [self notifyChangeSourceViewControllerDeleteCache];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//删除源列表界面缓存的最新章节信息
-(void)notifyChangeSourceViewControllerDeleteCache {
    [LMTool deleteArchiveBookSourceDicWithBookId:self.bookId];
}

-(void)pushToBookDetailViewControllerWithBook:(Book* )book {
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.bookId = book.bookId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//微信分享通知
-(void)shareNewsSucceed:(NSNotification* )notify {
    NSDictionary* dic = notify.userInfo;
    if (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
        [self showMBProgressHUDWithText:@"分享失败"];
        return;
    }
    [self showMBProgressHUDWithText:@"分享成功"];
}

-(void)clickedRightBarButton:(UIButton* )sender {
    __weak LMReaderBookViewController* weakSelf = self;
    NSMutableArray* actionArray = [NSMutableArray array];
    PopoverAction* briefAction = [PopoverAction actionWithTitle:@"简介" handler:^(PopoverAction *action) {
        LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
        detailVC.bookId = self.bookId;
        [self.navigationController pushViewController:detailVC animated:YES];
    }];
    PopoverAction* shareAction = [PopoverAction actionWithTitle:@"分享" handler:^(PopoverAction *action) {
        LMShareView* shareView = [[LMShareView alloc]init];
        shareView.shareBlock = ^(LMShareViewType shareType) {
            NSString* shareUrl = [NSString stringWithFormat:@"http://m.yeseshuguan.com/book/%d/?shared=1", weakSelf.bookId];
            NSString* bookCoverUrl = @"";
            NSString* shareTitleStr = [NSString stringWithFormat:@"我正在【%@】APP看《%@》，值得一看", APPNAME, weakSelf.bookName];
            if (weakSelf.shareCoverUrl != nil && weakSelf.shareCoverUrl.length > 0) {
                bookCoverUrl = weakSelf.shareCoverUrl;
            }
            NSString* shareBriefStr = @"";
            if (shareUrl != nil && shareUrl.length > 0) {
                UIImage* tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:bookCoverUrl];
                if (tempImg == nil) {
                     tempImg = [UIImage imageNamed:@"share_AppIcon"];
                }
                NSString* tempImgStr = bookCoverUrl;
                if (tempImg != nil && (shareType == LMShareViewTypeWeChat || shareType == LMShareViewTypeWeChatMoment)) {
                    NSData* imgData = UIImageJPEGRepresentation(tempImg, 0.5);
                    tempImg = [UIImage imageWithData:imgData];
                    if (imgData.length / 1024 > 32) {//图片大于32KB，给默认图
                        tempImg = [UIImage imageNamed:@"share_AppIcon"];
                    }
                }
                if (tempImg == nil) {
                    tempImg = [UIImage imageNamed:@"share_AppIcon"];
                }
                
                if (shareType == LMShareViewTypeWeChat) {
                    [LMShareMessage shareToWeChatWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isMoment:NO img:tempImg];
                }else if (shareType == LMShareViewTypeWeChatMoment) {
                    [LMShareMessage shareToWeChatWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isMoment:YES img:tempImg];
                }else if (shareType == LMShareViewTypeQQ) {
                    [LMShareMessage shareToQQWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isZone:NO imgStr:tempImgStr];
                }else if (shareType == LMShareViewTypeQQZone) {
                    [LMShareMessage shareToQQWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isZone:YES imgStr:tempImgStr];
                }else if (shareType == LMShareViewTypeCopyLink) {
                    [[UIPasteboard generalPasteboard]setString:shareUrl];
                    
                    [weakSelf showMBProgressHUDWithText:@"复制成功"];
                }
            }
        };
        [shareView startShow];
    }];
    PopoverAction* commentAction = [PopoverAction actionWithTitle:@"书评" handler:^(PopoverAction *action) {
        LMBookCommentDetailViewController* commentDetailVC = [[LMBookCommentDetailViewController alloc]init];
        commentDetailVC.bookId = self.bookId;
        commentDetailVC.bookName = self.bookName;
        [self.navigationController pushViewController:commentDetailVC animated:YES];
    }];
    [actionArray addObject:briefAction];
    [actionArray addObject:shareAction];
    [actionArray addObject:commentAction];
    
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.style = PopoverViewStyleDefault;
    popoverView.hideAfterTouchOutside = YES;
    [popoverView showToView:sender withActions:actionArray];
}

//换源
-(void)clickedChangeSourceButton:(UIButton* )sender {
    __weak LMReaderBookViewController* weakSelf = self;
    
    LMChangeSourceViewController* sourceVC = [[LMChangeSourceViewController alloc]init];
    sourceVC.bookId = self.bookId;
    sourceVC.sourceIndex = self.readerBook.currentParseIndex;
    sourceVC.isNew = self.readerBook.isNew;
    if (self.readerBook.isNew) {
        NSArray* tempSourceArray = self.readerBook.parseArr;
        if (tempSourceArray.count > 0) {
            
        }else {
            [self showMBProgressHUDWithText:@"源列表为空"];
            return;
        }
        sourceVC.sourceArr = [NSMutableArray arrayWithArray:self.readerBook.parseArr];
        sourceVC.callBlock = ^(BOOL didChange, NSInteger selectedIndex) {
            if (didChange) {
                [weakSelf showNetworkLoadingView];
                
                [LMTool deleteBookWithBookId:weakSelf.bookId];//删除之前已下载的书本章节
                
                weakSelf.readerBook.currentParseIndex = selectedIndex;
                UrlReadParse* parse = [weakSelf.readerBook.parseArr objectAtIndex:selectedIndex];
                
                [weakSelf uploadChangeSourceWithSourceId:parse.source.id];//上传换源id
                
                //章节列表
                [weakSelf initLoadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                    weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                    NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:weakSelf.readerBook.currentChapter];//当前章节角标
                    LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                    realCurrentChapter.sourceId = parse.source.id;
                    realCurrentChapter.offset = 0;
                    weakSelf.readerBook.currentChapter = realCurrentChapter;
                    //章节内容
                    [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                        realCurrentChapter.content = contentStr;
                        NSInteger textOffset = 0;//换源之后，切换到第一页
                        NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                        weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                        NSInteger pageIndex = 0;
                        weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                        weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                        
                        [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                        
                        self.sourceView.hidden = NO;//换源成功，显示sourceTitleView
                        
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf showMBProgressHUDWithText:@"换源成功"];
                    } failureBlock:^(NSError *error) {
                        
                        self.sourceView.hidden = YES;//换源失败，隐藏sourceTitleView
                        
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                        [weakSelf showMBProgressHUDWithText:@"换源失败"];
                    }];
                } failureBlock:^(NSError *error) {
                    self.sourceView.hidden = YES;//换源失败，隐藏sourceTitleView
                    
                    [weakSelf hideNetworkLoadingView];
                    [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                    [weakSelf showMBProgressHUDWithText:@"获取失败，请尝试切换其它源"];
                }];
            }
        };
    }else {
        NSArray* tempSourceArray = self.readerBook.currentChapter.sourcesArr;
        if (tempSourceArray.count > 0) {
            
        }else {
            [self showMBProgressHUDWithText:@"源列表为空"];
            return;
        }
        sourceVC.sourceArr = [NSMutableArray arrayWithArray:tempSourceArray];
        sourceVC.callBlock = ^(BOOL didChange, NSInteger selectedIndex) {
            if (didChange) {
                [weakSelf showNetworkLoadingView];
                
                [LMTool deleteBookWithBookId:weakSelf.bookId];//删除之前已下载的书本章节
                
                SourceLastChapter* sourceChapter = [tempSourceArray objectAtIndex:selectedIndex];
                weakSelf.readerBook.currentChapter.sourceId = sourceChapter.source.id;
                
                [weakSelf uploadChangeSourceWithSourceId:(UInt32 )weakSelf.readerBook.currentChapter.sourceId];//上传换源id
                
                //获取章节内容
                [weakSelf loadOldParseChapterContentWithCurrentChapter:weakSelf.readerBook.currentChapter shouldQueryCache:NO successBlock:^(NSString *contentStr) {
                    weakSelf.readerBook.currentChapter.content = contentStr;
                    NSInteger textOffset = 0;
                    if (textOffset < 0) {
                        textOffset = 0;
                    }else if (textOffset >= contentStr.length) {
                        textOffset = 0;
                    }
                    weakSelf.readerBook.currentChapter.offset = textOffset;
                    NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                    weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                    NSInteger pageIndex = 0;
                    weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                    weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                    
                    [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                    
                    [weakSelf hideNetworkLoadingView];
                    [weakSelf showMBProgressHUDWithText:@"换源成功"];
                } failureBlock:^(NSError *error) {
                    [weakSelf hideNetworkLoadingView];
                    [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                    [weakSelf showMBProgressHUDWithText:@"换源失败"];
                }];
            }
        };
    }
    [self.navigationController pushViewController:sourceVC animated:YES];
}

//点击toolBar
-(void)clickedToolBarButtonItem:(UIButton* )sender {
    switch (sender.tag) {
        case 0://目录
        {
            __weak LMReaderBookViewController* weakSelf = self;
            if (self.readerBook.isNew) {
                LMNewCatalogViewController* catalogVC = [[LMNewCatalogViewController alloc]init];
                catalogVC.chapterIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
                catalogVC.dataArray = [NSMutableArray arrayWithArray:self.readerBook.chaptersArr];
                catalogVC.callBack = ^(BOOL didChange, NSInteger selectedIndex) {
                    if (didChange) {
                        [weakSelf showNetworkLoadingView];
                        
                        LMReaderBookChapter* bookChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:selectedIndex];
                        weakSelf.readerBook.currentChapter = bookChapter;
                        weakSelf.readerBook.currentChapter.offset = 0;
                        weakSelf.readerBook.currentChapter.currentPage = 0;
                        weakSelf.readerBook.currentChapter.pageChange = 0;
                        if (bookChapter.pagesArr.count > 0) {
                            [weakSelf setupPageViewControllerWithCurrentChapter:bookChapter];
                            [weakSelf hideNetworkLoadingView];
                            return;
                        }else {
                            weakSelf.readerBook.currentChapter.pagesArr = nil;
                            UrlReadParse* parse = [weakSelf.readerBook.parseArr objectAtIndex:weakSelf.readerBook.currentParseIndex];
                            [weakSelf initLoadNewParseChapterContentWithBookChapter:weakSelf.readerBook.currentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                weakSelf.readerBook.currentChapter.content = contentStr;
                                NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                                weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                                
                                [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"切换成功"];
                            } failureBlock:^(NSError *error) {
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }
                    }
                };
                [self.navigationController pushViewController:catalogVC animated:YES];
            }else {
                LMCatalogViewController* catalogVC = [[LMCatalogViewController alloc]init];
                catalogVC.chapterIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
                catalogVC.bookId = (UInt32 )self.readerBook.bookId;
                catalogVC.dataArray = [NSMutableArray arrayWithArray:self.readerBook.chaptersArr];
                catalogVC.callBlock = ^(BOOL didChange, NSMutableArray *catalogArr, NSInteger selectedIndex) {
                    if (catalogArr != nil && ![catalogArr isKindOfClass:[NSNull class]] && catalogArr.count > 0 && weakSelf.readerBook.chaptersArr.count == 0) {
                        weakSelf.readerBook.chaptersArr = [NSMutableArray arrayWithArray:catalogArr];
                    }
                    if (didChange) {
                        [weakSelf showNetworkLoadingView];
                        
                        LMReaderBookChapter* bookChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:selectedIndex];
                        weakSelf.readerBook.currentChapter = bookChapter;
                        weakSelf.readerBook.currentChapter.offset = 0;
                        weakSelf.readerBook.currentChapter.currentPage = 0;
                        weakSelf.readerBook.currentChapter.pageChange = 0;
                        weakSelf.readerBook.currentChapter.pagesArr = nil;
                        if (bookChapter.pagesArr.count > 0) {
                            [weakSelf setupPageViewControllerWithCurrentChapter:bookChapter];
                            [weakSelf hideNetworkLoadingView];
                            return;
                        }else {
                            [weakSelf loadOldParseChapterContentWithCurrentChapter:bookChapter shouldQueryCache:YES successBlock:^(NSString *contentStr) {
                                weakSelf.readerBook.currentChapter.content = contentStr;
                                NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                                weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                                
                                [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"切换成功"];
                            } failureBlock:^(NSError *error) {
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }
                    }
                };
                [self.navigationController pushViewController:catalogVC animated:YES];
            }
        }
            break;
        case 1://报错
        {
            NSString* currentChapterStr = self.readerBook.currentChapter.content;
            if (currentChapterStr != nil && ![currentChapterStr isKindOfClass:[NSNull class]] && currentChapterStr.length > 0) {
                
            }else {
                return;
            }
            __weak LMReaderBookViewController* weakSelf = self;
            
            LMReaderFeedBackAlertView* feedBackAV = [[LMReaderFeedBackAlertView alloc]init];
            feedBackAV.submitBlock = ^(BOOL submit, NSString *text) {
                if (submit) {
                    UInt32 sourceId = 0;
                    if (weakSelf.readerBook.isNew) {
                        if (weakSelf.readerBook.parseArr.count > 0) {
                            UrlReadParse* parse = [weakSelf.readerBook.parseArr objectAtIndex:weakSelf.readerBook.currentParseIndex];
                            sourceId = parse.source.id;
                        }
                    }else {
                        sourceId = (UInt32 )weakSelf.readerBook.currentChapter.sourceId;
                    }
                    NSString* infoStr = [NSString stringWithFormat:@"%@[bid:%d][sid:%d]", text, weakSelf.bookId, sourceId];
                    UInt32 typeInt = 0;
                    FeedbackReqBuilder* builder = [FeedbackReq builder];
                    [builder setType:typeInt];
                    [builder setWords:infoStr];
                    FeedbackReq* req = [builder build];
                    NSData* reqData = [req data];
                    
                    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
                    [tool postWithCmd:16 ReqData:reqData successBlock:^(NSData *successData) {
                        @try {
                            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                            if (apiRes.cmd == 16) {
                                ErrCode err = apiRes.err;
                                if (err == ErrCodeErrNone) {
                                    [weakSelf showMBProgressHUDWithText:@"感谢您的反馈，我们将尽快处理"];
                                }
                            }
                        } @catch (NSException *exception) {
                            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
                        } @finally {
                            
                        }
                        [weakSelf hideNetworkLoadingView];
                        
                    } failureBlock:^(NSError *failureError) {
                        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
                        [weakSelf hideNetworkLoadingView];
                    }];
                }
            };
            [feedBackAV startShow];
        }
            break;
        case 2://下载
        {
            NSString* currentChapterStr = self.readerBook.currentChapter.content;
            if (currentChapterStr != nil && ![currentChapterStr isKindOfClass:[NSNull class]] && currentChapterStr.length > 0) {
                
            }else {
                return;
            }
            CGRect screenRect = [UIScreen mainScreen].bounds;
            if (self.downloadView.isShow == NO) {
                if (self.downloadView.isDownload == NO) {
                    NSArray* catalogArr = [NSArray arrayWithArray:self.readerBook.chaptersArr];
                    if (self.readerBook.isNew) {
                        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                        [self.downloadView startDownloadNewParseBookWithBookId:self.bookId catalogList:catalogArr parse:parse block:^(BOOL isFinished, CGFloat progress) {
                            
                        }];
                    }else {
                        [self.downloadView startDownloadBookWithBookId:self.bookId catalogList:catalogArr block:^(BOOL isFinished, CGFloat progress) {
                            if (isFinished) {
                                //                            NSLog(@"----------isFinished----------");
                            }
                            //                        NSLog(@"---progress---- = %f", progress);
                        }];
                    }
                }
                CGFloat toolBarHeight = 49;
                if ([LMTool isBangsScreen]) {
                    toolBarHeight = 83;
                }
                [self.downloadView showDownloadViewWithFinalFrame:CGRectMake(0, screenRect.size.height - toolBarHeight - 40, self.view.frame.size.width, 40)];
            }else {
                [self.downloadView hideDownloadViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
            }
            
        }
            break;
        case 3://收藏
        {
            __weak LMReaderBookViewController* weakSelf = self;
            UserBookStoreOperateType type = UserBookStoreOperateTypeOperateAdd;
            if (self.isCollected) {
                type = UserBookStoreOperateTypeOperateDel;
            }
            UserBookStoreOperateReqBuilder* builder = [UserBookStoreOperateReq builder];
            [builder setBookId:weakSelf.bookId];
            [builder setType:type];
            UserBookStoreOperateReq* req = [builder build];
            NSData* reqData = [req data];
            
            [self showNetworkLoadingView];
            
            LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
            [tool postWithCmd:4 ReqData:reqData successBlock:^(NSData *successData) {
                @try {
                    FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                    if (apiRes.cmd == 4) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {//成功
                            if (weakSelf.isCollected) {
                                weakSelf.isCollected = NO;
                                sender.selected = NO;
                            }else {
                                weakSelf.isCollected = YES;
                                sender.selected = YES;
                            }
                            //通知书架界面刷新
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBookShelfViewController" object:nil];
                            
                            [weakSelf showMBProgressHUDWithText:@"操作成功"];
                        }else {
                            [weakSelf showMBProgressHUDWithText:@"操作失败"];
                        }
                    }
                    
                } @catch (NSException *exception) {
                    [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
                } @finally {
                    
                }
                [weakSelf hideNetworkLoadingView];
                
            } failureBlock:^(NSError *failureError) {
                
                [weakSelf hideNetworkLoadingView];
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            }];
        }
            break;
        case 4://设置
        {
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            __weak LMReaderBookViewController* weakSelf = self;
            NSString* contentText = self.readerBook.currentChapter.content;
            if (contentText != nil && ![contentText isKindOfClass:[NSNull class]] && contentText.length > 0) {
                
            }else {
                return;
            }
            if (!self.settingView) {
                self.settingView = [[LMReaderSettingView alloc]initWithFrame:CGRectMake(0, screenHeight, self.view.frame.size.width, 250) bringht:self.brightness fontSize:self.fontSize bgInteger:self.readModel lineSpaceIndex:self.lineSpaceIndex];
                [self.view addSubview:self.settingView];
                self.settingView.brightBlock = ^(CGFloat brightValue) {//亮度
                    [UIScreen mainScreen].brightness = brightValue;
                    [LMTool changeReaderConfigWithBackgroundInteger:brightValue];
                };
                self.settingView.fontBlock = ^(CGFloat fontValue, CGFloat lineSpace) {//字号
                    LMReaderBookPage* tempCurrentPage =  [weakSelf.readerBook.currentChapter.pagesArr objectAtIndex:weakSelf.readerBook.currentChapter.currentPage];
                    weakSelf.readerBook.currentChapter.offset = tempCurrentPage.startLocation;
                    //清空之前缓存的章节页，等翻章节时再重新切页
                    for (NSInteger i = 0; i < weakSelf.readerBook.chaptersArr.count; i ++) {
                        LMReaderBookChapter* tempChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:i];
                        if (tempChapter.pagesArr != nil && tempChapter.pagesArr.count > 0) {
                            tempChapter.pagesArr = nil;
                        }
                    }
                    
                    weakSelf.fontSize = fontValue;
                    weakSelf.lineSpace = lineSpace;
                    [LMTool changeReaderConfigWithFontSize:fontValue];
                    
                    [weakSelf showNetworkLoadingView];
                    [weakSelf resetupPageViewControllers];
                    [weakSelf hideNetworkLoadingView];
                };
                self.settingView.bgBlock = ^(NSInteger bgValue) {//背景
                    weakSelf.readModel = bgValue;
                    [LMTool changeReaderConfigWithBackgroundInteger:bgValue];
                    
                    [weakSelf showNetworkLoadingView];
                    [weakSelf resetupPageViewControllers];
                    [weakSelf hideNetworkLoadingView];
                };
                self.settingView.lpBlock = ^(CGFloat lineSpaceValue, NSInteger lpIndex) {//行间距
                    LMReaderBookPage* tempCurrentPage =  [weakSelf.readerBook.currentChapter.pagesArr objectAtIndex:weakSelf.readerBook.currentChapter.currentPage];
                    weakSelf.readerBook.currentChapter.offset = tempCurrentPage.startLocation;
                    //清空之前缓存的章节页，等翻章节时再重新切页
                    for (NSInteger i = 0; i < weakSelf.readerBook.chaptersArr.count; i ++) {
                        LMReaderBookChapter* tempChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:i];
                        if (tempChapter.pagesArr != nil && tempChapter.pagesArr.count > 0) {
                            tempChapter.pagesArr = nil;
                        }
                    }
                    
                    weakSelf.lineSpace = lineSpaceValue;
                    weakSelf.lineSpaceIndex = lpIndex;
                    [LMTool changeReaderConfigWithLineSpace:lineSpaceValue lineSpaceIndex:lpIndex];
                    
                    [weakSelf showNetworkLoadingView];
                    [weakSelf resetupPageViewControllers];
                    [weakSelf hideNetworkLoadingView];
                };
            }
            CGFloat toolBarHeight = 44;
            if ([LMTool isBangsScreen]) {
                toolBarHeight = 83;
            }
            if (self.settingView.isShow) {
                [self.settingView hideSettingViewWithFinalFrame:CGRectMake(0, screenHeight, self.view.frame.size.width, 250)];
            }else {
                [self.settingView showSettingViewWithFinalFrame:CGRectMake(0, screenHeight - toolBarHeight - 250, self.view.frame.size.width, 250)];
            }
        }
            break;
        default:
            break;
    }
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (self.settingView) {
        BOOL isSettingHidden = self.settingView.frame.origin.y >= screenRect.size.height;
        if (!isSettingHidden) {
            [self.settingView hideSettingViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250)];
        }
    }
    //
    [self.downloadView hideDownloadViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
    
    BOOL isNaviHidden = self.naviBarView.frame.origin.y < 0;
    if (isNaviHidden) {
        [self setupNaviBarViewAndToolBarViewHidden:NO];
        
        [self.sourceView startShow];
    }else {
        [self setupNaviBarViewAndToolBarViewHidden:YES];
        
        [self.sourceView startHide];
    }
}

//
-(void)hideAllOtherViews {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (self.settingView) {
        BOOL isSettingHidden = self.settingView.frame.origin.y >= screenRect.size.height;
        if (!isSettingHidden) {
            [self.settingView hideSettingViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250)];
        }
    }
    //
    [self.downloadView hideDownloadViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
    
    BOOL isNaviHidden = self.naviBarView.frame.origin.y < 0;
    if (!isNaviHidden) {
        [self setupNaviBarViewAndToolBarViewHidden:YES];
        
        [self.sourceView startHide];
    }
}

-(LMSourceTitleView *)sourceView {
    if (self.readerBook.isNew && self.readerBook.parseArr.count > 0) {
        __weak LMReaderBookViewController* weakSelf = self;
        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
        LMReaderBookChapter* tempBookChapter = self.readerBook.currentChapter;
        NSString* chapterUrlStr = tempBookChapter.url;
        if (chapterUrlStr != nil && ![chapterUrlStr isKindOfClass:[NSNull class]] && chapterUrlStr.length > 0) {
            
        }else {
            chapterUrlStr = parse.listUrl;
        }
        if (!_sourceView) {
            _sourceView = [[LMSourceTitleView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            [self.view addSubview:_sourceView];
        }
        if (_sourceView) {
            _sourceView.alertText = parse.source.name;
            _sourceView.callBlock = ^(BOOL didClick) {
                LMSourceAlertView* sourceAV = [[LMSourceAlertView alloc]initWithFrame:CGRectZero text:chapterUrlStr sourceName:parse.source.name];
                sourceAV.sureBlock = ^(BOOL sure) {
                    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:chapterUrlStr] options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                    } else {
                        [weakSelf showMBProgressHUDWithText:@"打开出错了。。。"];
                    }
                };
                [sourceAV startShow];
            };
            [self.view bringSubviewToFront:_sourceView];
            return _sourceView;
        }
    }
    return nil;
}

#pragma mark 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.isAnimate) {
        return nil;
    }
    NSString* currentChapterStr = self.readerBook.currentChapter.content;
    if (currentChapterStr != nil && ![currentChapterStr isKindOfClass:[NSNull class]] && currentChapterStr.length > 0) {
        
    }else {
        return nil;
    }
    
    //隐藏头尾
    [self hideAllOtherViews];
    
    NSInteger bookCurrentPage = self.readerBook.currentChapter.currentPage;
    NSArray* bookPagesArray = self.readerBook.currentChapter.pagesArr;
    LMReaderBookPage* bookPage = nil;
    if (bookCurrentPage == 0) {//进入上一章节
        NSInteger chapterIndex = 0;
        NSArray* bookChaptersArray = self.readerBook.chaptersArr;
        if (bookChaptersArray.count > 0) {
            for (NSInteger i = 0; i < bookChaptersArray.count; i ++) {
                LMReaderBookChapter* tempBookChapter = [bookChaptersArray objectAtIndex:i];
                if (tempBookChapter == self.readerBook.currentChapter) {
                    chapterIndex = i;
                    break;
                }
            }
            if (chapterIndex <= 0) {
                [self showMBProgressHUDWithText:@"第一页了"];
                return nil;
            }else {
                NSInteger lastChapterIndex = chapterIndex - 1;
                LMReaderBookChapter* bookChapter = [bookChaptersArray objectAtIndex:lastChapterIndex];
                self.readerBook.currentChapter = bookChapter;
                if (self.readerBook.isNew) {
                    [self showNetworkLoadingView];
                    
                    if (bookChapter.pagesArr.count > 0) {
                        LMReaderBookPage* lastPage = bookChapter.pagesArr.lastObject;
                        NSInteger lastIndex = bookChapter.pagesArr.count - 1;
                        self.readerBook.currentChapter.offset = lastPage.startLocation;
                        self.readerBook.currentChapter.currentPage = lastIndex;
                        self.readerBook.currentChapter.pageChange = lastIndex;
                        
                        [self setupPageViewControllerWithCurrentChapter:bookChapter];
                        
                        [self hideNetworkLoadingView];
//                        [self showMBProgressHUDWithText:@"切换成功"];
                        return nil;
                    }else {
                        __weak LMReaderBookViewController* weakSelf = self;
                        
                        self.readerBook.currentChapter.pagesArr = nil;
                        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                        [self initLoadNewParseChapterContentWithBookChapter:self.readerBook.currentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                            weakSelf.readerBook.currentChapter.content = contentStr;
                            NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                            weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                            LMReaderBookPage* lastPage = bookChapter.pagesArr.lastObject;
                            NSInteger lastIndex = bookChapter.pagesArr.count - 1;
                            weakSelf.readerBook.currentChapter.offset = lastPage.startLocation;
                            weakSelf.readerBook.currentChapter.currentPage = lastIndex;
                            weakSelf.readerBook.currentChapter.pageChange = lastIndex;
                            
                            [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                            
                            [weakSelf hideNetworkLoadingView];
//                            [weakSelf showMBProgressHUDWithText:@"切换成功"];
                        } failureBlock:^(NSError *error) {
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"获取失败"];
                        }];
                    }
                }else {
                    [self showNetworkLoadingView];
                    
                    if (bookChapter.pagesArr.count > 0) {
                        LMReaderBookPage* lastPage = bookChapter.pagesArr.lastObject;
                        NSInteger lastIndex = bookChapter.pagesArr.count - 1;
                        self.readerBook.currentChapter.offset = lastPage.startLocation;
                        self.readerBook.currentChapter.currentPage = lastIndex;
                        self.readerBook.currentChapter.pageChange = lastIndex;
                        
                        [self setupPageViewControllerWithCurrentChapter:bookChapter];
                        
                        [self hideNetworkLoadingView];
//                        [self showMBProgressHUDWithText:@"切换成功"];
                        return nil;
                    }else {
                        __weak LMReaderBookViewController* weakSelf = self;
                        [self loadOldParseChapterContentWithCurrentChapter:bookChapter shouldQueryCache:YES successBlock:^(NSString *contentStr) {
                            weakSelf.readerBook.currentChapter.content = contentStr;
                            NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                            weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                            LMReaderBookPage* lastPage = bookChapter.pagesArr.lastObject;
                            NSInteger lastIndex = bookChapter.pagesArr.count - 1;
                            weakSelf.readerBook.currentChapter.offset = lastPage.startLocation;
                            weakSelf.readerBook.currentChapter.currentPage = lastIndex;
                            weakSelf.readerBook.currentChapter.pageChange = lastIndex;
                            
                            [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                            
                            [weakSelf hideNetworkLoadingView];
//                            [weakSelf showMBProgressHUDWithText:@"切换成功"];
                        } failureBlock:^(NSError *error) {
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"获取失败"];
                        }];
                    }
                }
            }
        }
        return nil;
    }else {//上一页
        self.readerBook.currentChapter.pageChange = bookCurrentPage - 1;
        bookPage = [bookPagesArray objectAtIndex:self.readerBook.currentChapter.pageChange];
    }
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:bookPage.text];
    contentVC.delegate = self;
    contentVC.shouldShowAd = bookPage.showAd;
    contentVC.adType = bookPage.adType;
    contentVC.adFromWhich = bookPage.adFromWhich;
    contentVC.lineSpace = self.lineSpace;
    contentVC.titleStr = self.readerBook.currentChapter.title;
    if (self.readerBook.chaptersArr.count > 0 && self.readerBook.currentChapter != nil) {
        NSInteger contentVCIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
        contentVC.chapterProgress = [NSString stringWithFormat:@"%ld/%ld章", contentVCIndex + 1, self.readerBook.chaptersArr.count];
    }
    if (bookPagesArray.count > 0) {
        NSInteger pageIndex = self.readerBook.currentChapter.pageChange + 1;
        if (pageIndex <= 0) {
            pageIndex = 1;
        }else if (pageIndex >= bookPagesArray.count) {
            pageIndex = bookPagesArray.count;
        }
        contentVC.pageProgress = [NSString stringWithFormat:@"%ld/%ld页", pageIndex, bookPagesArray.count];
    }
    return contentVC;
}

#pragma mark 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.isAnimate) {
        return nil;
    }
    NSString* currentChapterStr = self.readerBook.currentChapter.content;
    if (currentChapterStr != nil && ![currentChapterStr isKindOfClass:[NSNull class]] && currentChapterStr.length > 0) {
        
    }else {
        return nil;
    }
    
    //隐藏头尾
    [self hideAllOtherViews];
    
    NSInteger bookCurrentPage = self.readerBook.currentChapter.currentPage;
    NSArray* bookPagesArray = self.readerBook.currentChapter.pagesArr;
    LMReaderBookPage* bookPage = nil;
    if (bookCurrentPage == bookPagesArray.count - 1) {//进入下一章节
        NSArray* bookChaptersArray = self.readerBook.chaptersArr;
        if (bookChaptersArray.count > 0) {
            NSInteger chapterIndex = 0;
            for (NSInteger i = 0; i < bookChaptersArray.count; i ++) {
                LMReaderBookChapter* tempBookChapter = [bookChaptersArray objectAtIndex:i];
                if (tempBookChapter == self.readerBook.currentChapter) {
                    chapterIndex = i;
                    break;
                }
            }
            if (chapterIndex == bookChaptersArray.count - 1) {
                if (self.readerBook.isNew) {
                    [self showNetworkLoadingView];
                    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                    NewestChapter* newestChapter = [tool queryNewestChapterWithBookId:self.bookId];
                    if ([newestChapter.newestChapterTitle isEqualToString:self.readerBook.currentChapter.title]) {//当前源最新章节等于更新章节标题，不用换源
                        [self hideNetworkLoadingView];
                        [self showMBProgressHUDWithText:@"最后一页了"];
                        
                        return nil;
                    }
                    NSArray* newestSourceArr = newestChapter.sources;
                    if (newestSourceArr.count == 0) {
                        [self hideNetworkLoadingView];
                        [self showMBProgressHUDWithText:@"最后一页了"];
                        
                        return nil;
                    }
                    NSInteger selectedIndex = 0;
                    Source* firstSource = [newestSourceArr firstObject];
                    UInt32 newestIndex = firstSource.id;
                    if (newestIndex == self.readerBook.currentChapter.sourceId) {
                        [self hideNetworkLoadingView];
                        [self showMBProgressHUDWithText:@"最后一页了"];
                        
                        return nil;
                    }
                    for (NSInteger i = 0; i < self.readerBook.parseArr.count; i ++) {
                        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:i];
                        if (newestIndex == parse.source.id) {
                            selectedIndex = i;
                            break;
                        }
                    }
                    
                    [LMTool deleteBookWithBookId:self.bookId];//删除之前已下载的书本章节
                    
                    self.readerBook.currentParseIndex = selectedIndex;
                    UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:selectedIndex];
                    
                    [self uploadChangeSourceWithSourceId:parse.source.id];//上传换源id
                    
                    __weak LMReaderBookViewController* weakSelf = self;
                    //章节列表
                    [self initLoadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                        weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                        NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:weakSelf.readerBook.currentChapter];//当前章节角标
                        if (chapterIndex < weakSelf.readerBook.chaptersArr.count - 1) {//下一章节角标
                            chapterIndex ++;
                        }
                        LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                        realCurrentChapter.sourceId = parse.source.id;
                        realCurrentChapter.offset = 0;
                        weakSelf.readerBook.currentChapter = realCurrentChapter;
                        //章节内容
                        [weakSelf initLoadNewParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                            realCurrentChapter.content = contentStr;
                            NSInteger textOffset = 0;//换源之后，切换到第一页
                            NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                            weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                            NSInteger pageIndex = 0;
                            weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                            weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                            
                            [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                            
                            self.sourceView.hidden = NO;//换源成功，显示sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf hideEmptyLabel];
                            [weakSelf showMBProgressHUDWithText:@"换源成功"];
                        } failureBlock:^(NSError *error) {
                            
                            self.sourceView.hidden = YES;//换源失败，隐藏sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf hideEmptyLabel];
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            [weakSelf showMBProgressHUDWithText:@"换源失败"];
                        }];
                    } failureBlock:^(NSError *error) {
                        self.sourceView.hidden = YES;//换源失败，隐藏sourceTitleView
                        
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf hideEmptyLabel];
                        [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                        [weakSelf showMBProgressHUDWithText:@"获取失败，请尝试切换其它源"];
                    }];
                    
                    [self showEmptyLabelWithCenterPoint:CGPointMake(self.view.center.x, self.view.center.y + 100) text:@"其它源有更新，正在为你切换"];
                    
                }else {
                    [self showMBProgressHUDWithText:@"最后一页了"];
                }
                return nil;
            }else {
                NSInteger nextChapterIndex = chapterIndex + 1;
                LMReaderBookChapter* bookChapter = [bookChaptersArray objectAtIndex:nextChapterIndex];
                self.readerBook.currentChapter = bookChapter;
                if (self.readerBook.isNew) {
                    [self showNetworkLoadingView];
                    
                    if (bookChapter.pagesArr.count > 0) {
                        LMReaderBookPage* firstPage = bookChapter.pagesArr.firstObject;
                        NSInteger firstIndex = 0;
                        self.readerBook.currentChapter.offset = firstPage.startLocation;
                        self.readerBook.currentChapter.currentPage = firstIndex;
                        self.readerBook.currentChapter.pageChange = firstIndex;
                        
                        [self setupPageViewControllerWithCurrentChapter:bookChapter];
                        
                        [self hideNetworkLoadingView];
//                        [self showMBProgressHUDWithText:@"切换成功"];
                        return nil;
                    }else {
                        __weak LMReaderBookViewController* weakSelf = self;
                        
                        self.readerBook.currentChapter.pagesArr = nil;
                        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                        [self initLoadNewParseChapterContentWithBookChapter:self.readerBook.currentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                            weakSelf.readerBook.currentChapter.content = contentStr;
                            NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                            weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                            LMReaderBookPage* firstPage = bookChapter.pagesArr.firstObject;
                            NSInteger firstIndex = 0;
                            weakSelf.readerBook.currentChapter.offset = firstPage.startLocation;
                            weakSelf.readerBook.currentChapter.currentPage = firstIndex;
                            weakSelf.readerBook.currentChapter.pageChange = firstIndex;
                            
                            [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                            
                            [weakSelf hideNetworkLoadingView];
//                            [weakSelf showMBProgressHUDWithText:@"切换成功"];
                        } failureBlock:^(NSError *error) {
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"获取失败"];
                        }];
                    }
                }else {
                    [self showNetworkLoadingView];
                    
                    if (bookChapter.pagesArr.count > 0) {
                        LMReaderBookPage* firstPage = bookChapter.pagesArr.firstObject;
                        NSInteger firstIndex = 0;
                        self.readerBook.currentChapter.offset = firstPage.startLocation;
                        self.readerBook.currentChapter.currentPage = firstIndex;
                        self.readerBook.currentChapter.pageChange = firstIndex;
                        
                        [self setupPageViewControllerWithCurrentChapter:bookChapter];
                        
                        [self hideNetworkLoadingView];
//                        [self showMBProgressHUDWithText:@"切换成功"];
                        return nil;
                    }else {
                        __weak LMReaderBookViewController* weakSelf = self;
                        [self loadOldParseChapterContentWithCurrentChapter:bookChapter shouldQueryCache:YES successBlock:^(NSString *contentStr) {
                            weakSelf.readerBook.currentChapter.content = contentStr;
                            NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:weakSelf.readerBook.currentChapter.offset];//把章节切页
                            weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                            LMReaderBookPage* firstPage = bookChapter.pagesArr.firstObject;
                            NSInteger firstIndex = 0;
                            weakSelf.readerBook.currentChapter.offset = firstPage.startLocation;
                            weakSelf.readerBook.currentChapter.currentPage = firstIndex;
                            weakSelf.readerBook.currentChapter.pageChange = firstIndex;
                            
                            [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                            
                            [weakSelf hideNetworkLoadingView];
//                            [weakSelf showMBProgressHUDWithText:@"切换成功"];
                        } failureBlock:^(NSError *error) {
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"获取失败"];
                        }];
                    }
                }
            }
        }
        return nil;
    }else {//下一页
        //预加载下一章节
        if (self.autoLoadNext) {
            NSArray* bookChaptersArray = self.readerBook.chaptersArr;
            if (bookChaptersArray.count > 0) {
                NSInteger chapterIndex = [bookChaptersArray indexOfObject:self.readerBook.currentChapter];
                if (chapterIndex != bookChaptersArray.count - 1) {//不是最后一章节，预加载下一章节
                    LMReaderBookChapter* nextChapter = [bookChaptersArray objectAtIndex:chapterIndex + 1];
                    if (nextChapter.pagesArr.count > 0) {
                        
                    }else {
                        __weak LMReaderBookViewController* weakSelf = self;
                        if (self.readerBook.isNew) {
                            UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                            [self initLoadNewParseChapterContentWithBookChapter:nextChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                nextChapter.content = contentStr;
                                NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:0];//把章节切页
                                nextChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                            } failureBlock:^(NSError *error) {
                                
                            }];
                        }else {
                            [self loadOldParseChapterContentWithCurrentChapter:nextChapter shouldQueryCache:YES successBlock:^(NSString *contentStr) {
                                nextChapter.content = contentStr;
                                NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:0];//把章节切页
                                nextChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                            } failureBlock:^(NSError *error) {
                                
                            }];
                        }
                    }
                }
            }
        }
        //下一页
        self.readerBook.currentChapter.pageChange = bookCurrentPage + 1;
        bookPage = [bookPagesArray objectAtIndex:self.readerBook.currentChapter.pageChange];
    }
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:bookPage.text];
    contentVC.delegate = self;
    contentVC.shouldShowAd = bookPage.showAd;
    contentVC.adType = bookPage.adType;
    contentVC.adFromWhich = bookPage.adFromWhich;
    contentVC.lineSpace = self.lineSpace;
    contentVC.titleStr = self.readerBook.currentChapter.title;
    if (self.readerBook.chaptersArr.count > 0 && self.readerBook.currentChapter != nil) {
        NSInteger contentVCIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
        contentVC.chapterProgress = [NSString stringWithFormat:@"%ld/%ld章", contentVCIndex + 1, self.readerBook.chaptersArr.count];
    }
    if (bookPagesArray.count > 0) {
        NSInteger pageIndex = self.readerBook.currentChapter.pageChange + 1;
        if (pageIndex >= bookPagesArray.count) {
            pageIndex = bookPagesArray.count;
        }else if (pageIndex <= 0) {
            pageIndex = 1;
        }
        contentVC.pageProgress = [NSString stringWithFormat:@"%ld/%ld页", pageIndex, bookPagesArray.count];
    }
    return contentVC;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    self.isAnimate = YES;
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.readerBook.currentChapter.currentPage = self.readerBook.currentChapter.pageChange;
    }else {
        self.readerBook.currentChapter.pageChange = self.readerBook.currentChapter.currentPage;
    }
    self.isAnimate = NO;
}

-(LMDownloadBookView *)downloadView {
    if (!_downloadView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        _downloadView = [[LMDownloadBookView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
        [self.view addSubview:_downloadView];
    }
    return _downloadView;
}

-(NSArray<LMReaderBookPage* >* )cutBookPageWithChapterContent:(NSString* )chapterContent offset:(NSInteger )offset {
    NSMutableArray* arr = [NSMutableArray array];
    NSString* text = chapterContent;
    NSString* resultStr = [LMTool replaceSeveralNewLineWithOneNewLineWithText:text];
    self.readerBook.currentChapter.content = resultStr;
    NSInteger tempOffset = offset;
    if (tempOffset > resultStr.length) {
        tempOffset = 0;
    }
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle alloc]init];
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.lineSpacing = self.lineSpace;
    
    NSMutableAttributedString* beforeAttributedStr = [[NSMutableAttributedString alloc]initWithString:resultStr attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFang SC" size:self.fontSize], NSParagraphStyleAttributeName : paraStyle, NSKernAttributeName:@(1)}];//[UIFont systemFontOfSize:self.fontSize]
    
    
    //Chiang
    NSMutableArray* tempPageArray = [NSMutableArray array];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:beforeAttributedStr];
    NSLayoutManager* layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    while (YES) {
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:contentLabRect.size];
        [layoutManager addTextContainer:textContainer];
        
        NSRange rang = [layoutManager glyphRangeForTextContainer:textContainer];
        if (rang.length <= 0) {
            break;
        }
        NSInteger loc = rang.location;
        [tempPageArray addObject:@(loc)];
    }
    
    /*
    CTFramesetterRef beforeFrameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) beforeAttributedStr);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, CGRectGetWidth(contentRect), CGRectGetHeight(contentRect)), NULL);
    
    NSInteger beforeOffset = 0;
    NSInteger beforeInnerOffset = 0;
    BOOL hasBeforePage = YES;// 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    NSInteger beforeLoopSign = beforeOffset;
    NSInteger beforeRepeatCount = 0;
    NSMutableArray* tempPageArray = [NSMutableArray array];
    
    while (hasBeforePage) {
        if (beforeLoopSign == beforeOffset) {
            ++beforeRepeatCount;
        }else {
            beforeRepeatCount = 0;
        }
        if (beforeRepeatCount > 1) {//退出循环前检查一下最后一页是否已经加上
            if (tempPageArray.count == 0) {
                [tempPageArray addObject:@(beforeOffset)];
            }else {
                NSUInteger lastOffset = [[tempPageArray lastObject] integerValue];
                if (lastOffset != beforeOffset) {
                    [tempPageArray addObject:@(beforeOffset)];
                }
            }
            break;
        }
        [tempPageArray addObject:@(beforeOffset)];
        
        CTFrameRef frame = CTFramesetterCreateFrame(beforeFrameSetter, CFRangeMake(beforeInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        if ((range.location + range.length) != beforeAttributedStr.length) {
            beforeOffset += range.length;
            beforeInnerOffset += range.length;
        } else {// 已经分完，提示跳出循环
            hasBeforePage = NO;
        }
        if (frame) CFRelease(frame);
    }
    CGPathRelease(path);
    CFRelease(beforeFrameSetter);
    */
     
     
    
    NSInteger chapterIndex = 0;
    if (self.readerBook.chaptersArr.count > 0) {
        chapterIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
    }
    
    BOOL innerAdSwitch = NO;
    BOOL insertAdSwitch = NO;
    NSInteger innerFromWhich = 0;
    NSInteger insertFromWhich = 0;
    NSInteger stepChapterIndex = 5;
    NSInteger stepPageIndex = 2;//前n章节中，少于x页的章节不显示广告
    NSData* adData = [LMTool unArchiveAdvertisementSwitchData];
    if (adData != nil && ![adData isKindOfClass:[NSNull class]] && adData.length > 0) {
        InitSwitchRes* res = [InitSwitchRes parseFromData:adData];
        if ([res hasSkipN] && res.skipN > 0) {
            stepChapterIndex = res.skipN;
        }
        if ([res hasLessM] && res.lessM > 0) {
            stepPageIndex = res.lessM;
        }
        for (AdControl* subControl in res.adControl) {
            if (subControl.adlId == 3 && subControl.state == 1) {
                innerAdSwitch = YES;
                innerFromWhich = subControl.adPt;
            }else if (subControl.adlId == 4 && subControl.state == 1) {
                insertAdSwitch = YES;
                insertFromWhich = subControl.adPt;
            }
        }
    }
    
    for (NSInteger i = 0; i < tempPageArray.count; i ++) {
        NSInteger tempLocation = [[tempPageArray objectAtIndex:i] integerValue];
        LMReaderBookPage* bookPage = [[LMReaderBookPage alloc]init];
        NSInteger textLocation = 0;
        NSInteger textlength = 0;
        if (i == tempPageArray.count - 1) {
            textLocation = tempLocation;
            textlength = resultStr.length - tempLocation;
            if (textlength < 0) {//如果分页时，最后一页位置超过总文字长度，
                textlength = 0;
            }
        }else {
            textLocation = tempLocation;
            NSInteger tempNextLocation = [[tempPageArray objectAtIndex:i + 1] integerValue];
            textlength = tempNextLocation - textLocation;
        }
        NSRange textRange = NSMakeRange(textLocation, textlength);
        bookPage.text = [resultStr substringWithRange:textRange];
        bookPage.startLocation = textLocation;
        bookPage.endLocation = textLocation + textlength;
        
        bookPage.showAd = NO;
        
        LMReaderBookPage* insertBookPage = nil;
        if (innerAdSwitch == YES || insertAdSwitch == YES) {
            if (i == tempPageArray.count - 1 && chapterIndex >= stepChapterIndex && i >= stepPageIndex) {//前n章中，不显示广告；任意章页数小于x均不显示广告
                NSString* lastPageText = [bookPage.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                NSAttributedString* attributeStr = [[NSAttributedString alloc]initWithString:lastPageText attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.fontSize], NSParagraphStyleAttributeName : paraStyle, NSKernAttributeName:@(1)}];
                UILabel* lastPageLab = [[UILabel alloc]initWithFrame:contentLabRect];
                lastPageLab.numberOfLines = 0;
                lastPageLab.attributedText = attributeStr;
                
                CGRect labRect = lastPageLab.frame;
                CGSize labSize = [lastPageLab sizeThatFits:CGSizeMake(labRect.size.width, MAXFLOAT)];
                labRect.size.height = labSize.height;
                
                CGFloat adWidth = contentScreenWidth - 20;//广告图片宽度
                CGFloat totalAdHeight = adWidth * contentTencentInnerAdScale;//广告图片+文字总高度
                if (innerFromWhich == 1) {//自家内嵌广告高度
                    totalAdHeight = adWidth * contentSelfInnerAdScale;
                }else if (innerFromWhich == 2) {//百度内嵌广告高度
                    totalAdHeight = adWidth * contentBaiduInnerAdScale;
                }
                CGFloat textLabHeight = contentLabRect.origin.y + labRect.size.height;
                CGFloat countStartY = contentScreenHeight - 30;
                if ([LMTool isBangsScreen]) {
                    countStartY = contentScreenHeight - 44;
                }
                if (textLabHeight <= countStartY - totalAdHeight - 10) {//能显示内嵌广告
                    if (innerAdSwitch) {
                        bookPage.showAd = YES;
                        bookPage.adType = 1;
                        bookPage.adFromWhich = innerFromWhich;
                    }
                }
                
                {//插入一页空白，显示插屏广告
                    if (insertAdSwitch) {
                        insertBookPage = [[LMReaderBookPage alloc]init];
                        insertBookPage.text = @"";
                        insertBookPage.startLocation = bookPage.startLocation;//纯粹保存阅读记录用
                        insertBookPage.endLocation = bookPage.endLocation;
                        insertBookPage.showAd = YES;
                        insertBookPage.adType = 2;
                        insertBookPage.adFromWhich = insertFromWhich;
                    }
                }
            }
        }
        
        [arr addObject:bookPage];
        if (insertBookPage != nil) {
            [arr addObject:insertBookPage];
        }
    }
    return arr;
}

//显示 如果currentChapter为空，则显示空白
-(void)setupPageViewControllerWithCurrentChapter:(LMReaderBookChapter* )currentChapter {
    //保存阅读记录
    [self saveReaderRecorder];
    
    //初始化设置pageVC
    if (!self.pageVC) {
        self.pageVC = [[LMPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionSpineLocationKey : @1}];
        self.pageVC.doubleSided = YES;
        self.pageVC.gestureDelegate = self;
        self.pageVC.delegate = self;
        self.pageVC.dataSource = self;
        self.pageVC.view.frame = self.view.bounds;
        [self addChildViewController:self.pageVC];
        [self.view insertSubview:self.pageVC.view belowSubview:self.naviBarView];
    }
    BOOL isEmpty = YES;
    NSArray* pagesArray = currentChapter.pagesArr;
    NSInteger index = currentChapter.currentPage;
    if (pagesArray.count > 0 && index < pagesArray.count) {
        isEmpty = NO;
    }
    if (isEmpty == NO) {
        LMReaderBookPage* tempBookPage = [pagesArray objectAtIndex:index];
        LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:tempBookPage.text];//得到第一页
        contentVC.delegate = self;
        contentVC.shouldShowAd = tempBookPage.showAd;
        contentVC.adType = tempBookPage.adType;
        contentVC.adFromWhich = tempBookPage.adFromWhich;
        contentVC.lineSpace = self.lineSpace;
        contentVC.titleStr = currentChapter.title;
        if (self.readerBook.chaptersArr.count > 0 && self.readerBook.currentChapter != nil) {
            NSInteger contentVCIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
            contentVC.chapterProgress = [NSString stringWithFormat:@"%ld/%ld章", contentVCIndex + 1, self.readerBook.chaptersArr.count];
        }
        if (self.readerBook.currentChapter.pagesArr.count > 0) {
            contentVC.pageProgress = [NSString stringWithFormat:@"%ld/%ld页", index + 1, pagesArray.count];
        }
        NSArray *viewControllers = [NSArray arrayWithObject:contentVC];
        [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    }else {//获取失败或者为空的时候，显示空白
        LMContentViewController* contentVC = [[LMContentViewController alloc]init];
        contentVC.delegate = self;
        NSArray *viewControllers = [NSArray arrayWithObject:contentVC];
        [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        [self hideNetworkLoadingView];
        return;
    }
}

//设置完之后重新布局
-(void )resetupPageViewControllers {
    NSString* contentText = self.readerBook.currentChapter.content;
    NSInteger offset = self.readerBook.currentChapter.offset;
    if (offset < 0) {
        offset = 0;
    }else if (offset >= contentText.length) {
        offset = 0;
    }
    self.readerBook.currentChapter.offset = offset;
    NSArray* pagesArray = [self cutBookPageWithChapterContent:contentText offset:offset];
    self.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
    NSInteger pageIndex = 0;
    for (NSInteger i = 0; i < pagesArray.count; i ++) {
        LMReaderBookPage* page = [pagesArray objectAtIndex:i];
        if (offset >= page.startLocation && offset <= page.endLocation) {
            pageIndex = i;
            break;
        }
    }
    self.readerBook.currentChapter.currentPage = pageIndex;
    self.readerBook.currentChapter.pageChange = pageIndex;
    [self setupPageViewControllerWithCurrentChapter:self.readerBook.currentChapter];
}

//退出app 通知
-(void)appWillResignActive:(NSNotification* )notify {
    [self saveReaderRecorder];
}

//保存阅读记录
-(void)saveReaderRecorder {
    NSString* tempContentText = self.readerBook.currentChapter.content;
    if (tempContentText != nil && ![tempContentText isKindOfClass:[NSNull class]] && tempContentText.length > 0) {
        LMReaderBookChapter* bookChapter = self.readerBook.currentChapter;
        UInt32 sourceId = (UInt32 )bookChapter.sourceId;
        if (self.readerBook.isNew) {
            if (self.readerBook.parseArr.count > 0 && self.readerBook.currentParseIndex < self.readerBook.parseArr.count) {
                UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                sourceId = parse.source.id;
            }
        }
        LMReaderBookPage* bookPage = [bookChapter.pagesArr objectAtIndex:bookChapter.currentPage];
        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
        [tool saveBookReadRecordWithBookId:self.bookId bookName:self.bookName chapterId:(UInt32 )bookChapter.chapterId chapterNo:(UInt32 )bookChapter.chapterNo chapterTitle:bookChapter.title sourceId:sourceId offset:bookPage.startLocation];
    }
}

//换源之后提交给后台
-(void)uploadChangeSourceWithSourceId:(UInt32 )sourceId {
    ChangeSourceReqBuilder* builder = [ChangeSourceReq builder];
    [builder setBookId:self.bookId];
    [builder setSourceId:sourceId];
    ChangeSourceReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:30 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 30) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                }
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        
    }];
}

//新解析方式下 获取章节列表或者章节内容失败时上报
-(void)reportParseErrorWithSourceId:(UInt32 )sourceId chapterName:(NSString* )chapterName {
    ReadErrReqBuilder* builder = [ReadErrReq builder];
    [builder setBookId:self.bookId];
    [builder setSourceId:sourceId];
    if (chapterName != nil && ![chapterName isKindOfClass:[NSNull class]] && chapterName.length > 0) {
        [builder setChapterName:chapterName];
    }
    ReadErrReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:33 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 33) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                }
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        
    }];
}

-(void)clickedEditCommentButton:(UIButton* )sender {
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        LMBookEditCommentViewController* editCommentVC = [[LMBookEditCommentViewController alloc]init];
        editCommentVC.bookId = self.bookId;
        [self.navigationController pushViewController:editCommentVC animated:YES];
        return;
    }else {
        __weak LMReaderBookViewController* weakSelf = self;
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        loginAV.loginBlock = ^(BOOL didLogined) {
            if (didLogined) {
                LMBookEditCommentViewController* editCommentVC = [[LMBookEditCommentViewController alloc]init];
                editCommentVC.bookId = weakSelf.bookId;
                [weakSelf.navigationController pushViewController:editCommentVC animated:YES];
            }
        };
        loginAV.protocolBlock = ^(BOOL clickedProtocol) {
            if (clickedProtocol) {
                LMProfileProtocolViewController* protocolVC = [[LMProfileProtocolViewController alloc]init];
                [weakSelf.navigationController pushViewController:protocolVC animated:YES];
            }
        };
        [loginAV startShow];
    }
}

//隐藏“其它源有更新，正在切换”label
//-(void)hideChangeSourceAlertLabel {
//
//}

//显示“其它源有更新，正在切换”label
//-(void)showChangeSourceAlertLabelWithCenterPoint:(CGPoint )centerPoint text:(NSString* )alertText {
//
//}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:weChatShareNotifyName object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
