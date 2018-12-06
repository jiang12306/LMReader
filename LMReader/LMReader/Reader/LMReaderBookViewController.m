//
//  LMReaderBookViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/13.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderBookViewController.h"
#import "LMContentViewController.h"
#import "LMBookCatalogViewController.h"
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
#import "AppDelegate.h"
#import "LMReaderRecommandViewController.h"
#import "LMRootViewController.h"
#import "LMReaderUserInstructionsView.h"

@interface LMReaderBookViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, LMPageViewControllerDelegate, LMContentViewControllerDelegate, LMReaderRecommandViewControllerDelegate>

@property (nonatomic, strong) UIView* naviBarView;/**<naviBar*/
@property (nonatomic, strong) UIButton* backBtn;/**<返回 按钮*/
@property (nonatomic, strong) UIButton* moreBtn;/**<右上角...按钮*/
@property (nonatomic, strong) UIButton* changeSourceBtn;/**<换源*/
@property (nonatomic, strong) UILabel* titleLab;/**<标题*/

@property (nonatomic, strong) UIView* toolBarView;/**<toolBar*/
@property (nonatomic, strong) UIButton* brightSmallBtn;/**<调暗*/
@property (nonatomic, strong) UISlider* brightSlider;/**<亮度调节slider*/
@property (nonatomic, strong) UIButton* brightBigBtn;/**<调亮*/
@property (nonatomic, strong) UIButton* catalogToolBtn;/**<toolBar 目录*/
@property (nonatomic, strong) UIButton* nightToolBtn;/**<toolBar 夜间*/
@property (nonatomic, strong) UIButton* setToolBtn;/**<toolBar 设置*/
@property (nonatomic, strong) UIButton* feedbackToolBtn;/**<toolBar 报错*/
@property (nonatomic, strong) UIButton* downloadToolBtn;/**<toolBar 下载*/

@property (nonatomic, strong) UIButton* editCommentBtn;//编辑评论button

@property (nonatomic, strong) LMPageViewController* pageVC;
@property (nonatomic, strong) LMReaderSettingView*  settingView;//设置 视图
@property (nonatomic, strong) LMDownloadBookView* downloadView;//下载 视图
@property (nonatomic, strong) LMSourceTitleView* sourceTV;//来源 视图
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


//阅读完最后一页，切换至最后推荐页
-(void)exchangePageViewControllerToReaderRecommandViewController {
    if (self.pageVC) {
        [self.pageVC removeFromParentViewController];
        [self.pageVC.view removeFromSuperview];
        self.pageVC = nil;
    }
    
//    self.changeSourceBtn.hidden = YES;
    [self setupNaviBarViewHidden:NO];
    [self setupToolBarViewHidden:YES];
    [self setupSettingViewHidden:YES];
    [self setupEditCommentButtonHidden:YES];
    
    LMReaderRecommandViewController* recommandVC = [[LMReaderRecommandViewController alloc]init];
    recommandVC.bookId = self.bookId;
    recommandVC.delegate = self;
    [self addChildViewController:recommandVC];
    [self.view insertSubview:recommandVC.view belowSubview:self.naviBarView];
    
    //
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark -LMReaderRecommandViewControllerDelegate
-(void)readerRecommandViewControllerDidClickedEditCommentButton {
    //写书评
    [self clickedEditCommentButton:nil];
}

-(void)readerRecommandViewControllerDidClickedBookStoreButton {
    //跳转至 书城 页面
    LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
    [rootVC backToTabBarControllerWithViewControllerIndex:2];
}

-(void)readerRecommandViewControllerDidClickedBook:(Book* )clickedBook {
    if (clickedBook != nil && [clickedBook isKindOfClass:[Book class]]) {
        LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
        detailVC.bookId = clickedBook.bookId;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

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
    
    
    if (self.readModel == LMReaderBackgroundType4) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
    }else {
        BOOL isHiden = self.naviBarView.frame.origin.y < 0;
        if (isHiden) {
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        }else {
            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        }
    }
    
    [self reloadTopNaviBarViewAndSourceTitleView];
    [self reloadBottomToolBarViewAndSettingView];
    [self reloadDownloadBookView];
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
    if (self.readModel == LMReaderBackgroundType4) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    [self saveReaderRecorder];//从3D-Touch进入app、回到“书架”页面LMRootViewController控制时，保存阅读进度
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    CGFloat toolBarHeight = 60 + 49;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
        startY = 44 + 7;
        toolBarHeight = 60 + 83;
    }
    self.naviBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, naviHeight)];
    self.naviBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.naviBarView];
    
    UIImage* leftImage = [UIImage imageNamed:@"navigationItem_Back"];
    UIImage* tintImage = [leftImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, startY, 40, 30)];
    self.backBtn.tintColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
    [self.backBtn setImage:tintImage forState:UIControlStateNormal];
    [self.backBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 20, 5, 8)];
    [self.backBtn addTarget:self action:@selector(clickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.naviBarView addSubview:self.backBtn];
    
    self.moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, startY, 50, 30)];
    [self.moreBtn addTarget:self action:@selector(clickedRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
    UIImage* moreImg = [UIImage imageNamed:@"readerBook_More"];
    [self.moreBtn setImage:[moreImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.moreBtn setTintColor:[UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1]];
    [self.moreBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 18, 5, 20)];
    [self.naviBarView addSubview:self.moreBtn];
    
    self.changeSourceBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.moreBtn.frame.origin.x - 40, startY, 40, 30)];
    self.changeSourceBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.changeSourceBtn addTarget:self action:@selector(clickedChangeSourceButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.changeSourceBtn setTitleColor:[UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1] forState:UIControlStateNormal];
    [self.changeSourceBtn setTitle:@"换源" forState:UIControlStateNormal];
    [self.naviBarView addSubview:self.changeSourceBtn];
    
    CGFloat maxTitleWidth = (self.changeSourceBtn.frame.origin.x - (self.view.frame.size.width / 2) - 20) * 2;
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - maxTitleWidth) / 2, startY, maxTitleWidth, 30)];
    self.titleLab.font = [UIFont boldSystemFontOfSize:18];
    self.titleLab.textColor = [UIColor blackColor];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
    NSString* titleStr = @"正文阅读";
    if (self.bookName != nil && self.bookName.length > 0) {
        titleStr = self.bookName;
    }
    self.titleLab.text = titleStr;
    [self.naviBarView addSubview:self.titleLab];
    CGSize titleLabSize = [self.titleLab sizeThatFits:CGSizeMake(9999, 30)];
    if (titleLabSize.width > maxTitleWidth) {
        titleLabSize.width = self.changeSourceBtn.frame.origin.x - self.backBtn.frame.origin.x - self.backBtn.frame.size.width - 20 * 2;
        self.titleLab.frame = CGRectMake(self.backBtn.frame.origin.x + self.backBtn.frame.size.width + 20, startY, titleLabSize.width, 30);
    }
    
    self.toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - toolBarHeight, self.view.frame.size.width, toolBarHeight)];
    self.toolBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.toolBarView];
    
    self.brightSmallBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, 20, 20)];
    [self.brightSmallBtn setImage:[UIImage imageNamed:@"readerSetting_Light_Low"] forState:UIControlStateNormal];
    [self.brightSmallBtn setImageEdgeInsets:UIEdgeInsetsMake(2.5, 5, 2.5, 0)];
    [self.brightSmallBtn addTarget:self action:@selector(clickedBrightSmallButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.brightSmallBtn];
    
    self.brightBigBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.toolBarView.frame.size.width - 20 - 20, 20, 20, 20)];
    [self.brightBigBtn setImage:[UIImage imageNamed:@"readerSetting_Light_High"] forState:UIControlStateNormal];
    [self.brightBigBtn addTarget:self action:@selector(clickedBrightBigButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.brightBigBtn];
    
    self.brightSlider = [[UISlider alloc]initWithFrame:CGRectMake(self.brightSmallBtn.frame.origin.x + self.brightSmallBtn.frame.size.width + 20, self.brightSmallBtn.frame.origin.y, self.brightBigBtn.frame.origin.x - self.brightSmallBtn.frame.origin.x - self.brightSmallBtn.frame.size.width - 20 * 2, 20)];
    self.brightSlider.minimumValue = 0;
    self.brightSlider.maximumValue = 1;
    self.brightSlider.minimumTrackTintColor = THEMEORANGECOLOR;
    [self.brightSlider addTarget:self action:@selector(didSlideBrightSlider:) forControlEvents:UIControlEventValueChanged];
    self.brightSlider.value = self.brightness;
    [self.toolBarView addSubview:self.brightSlider];
    
    UITapGestureRecognizer* sliderTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedBrightSlider:)];
    [self.brightSlider addGestureRecognizer:sliderTap];
    
    self.editCommentBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 50, self.view.frame.size.height - self.settingView.frame.size.height - 10 - 50, 50, 50)];
    self.editCommentBtn.backgroundColor = [UIColor colorWithRed:119.f/255 green:119.f/255 blue:119.f/255 alpha:1];
    self.editCommentBtn.layer.cornerRadius = 25;
    self.editCommentBtn.layer.masksToBounds = YES;
    [self.editCommentBtn setImage:[UIImage imageNamed:@"editComment"] forState:UIControlStateNormal];
    [self.editCommentBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 13, 13, 13)];
    [self.editCommentBtn addTarget:self action:@selector(clickedEditCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editCommentBtn];
    
    NSArray* normalTitleArr = @[@"目录", @"夜间", @"设置", @"报错", @"下载"];
    NSArray* normalImgArr = @[@"toolBarItem_Catalog", @"toolBarItem_Night_Normal", @"toolBarItem_Setting", @"toolBarItem_FeedBack", @"toolBarItem_Download"];
    CGFloat btnWidth = 44;
    CGFloat btnSpaceX = (self.view.frame.size.width - btnWidth * normalTitleArr.count - 7 * 2) / (normalTitleArr.count - 1);
    for (NSInteger i = 0; i < normalTitleArr.count; i ++) {
        BOOL isSelected = NO;
        NSString* selectedTitle = nil;
        NSString* normalImg = normalImgArr[i];
        NSString* selectedImg = nil;
        if (i == 1) {
            selectedImg = @"toolBarItem_Night_Selected";
        }
        CGRect btnFrame = CGRectMake(7 + (btnSpaceX + btnWidth) * i, 60, btnWidth, btnWidth);
        UIButton* btn = [self createToolBarButtonWithFrame:btnFrame Title:normalTitleArr[i] selectedTitle:selectedTitle normalImg:normalImg selectedImg:selectedImg isSelected:isSelected tag:i];
        btn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        [self.toolBarView addSubview:btn];
        if (i == 0) {
            self.catalogToolBtn = btn;
        }else if (i == 1) {
            self.nightToolBtn = btn;
        }else if (i == 2) {
            self.setToolBtn = btn;
        }else if (i == 3) {
            self.feedbackToolBtn = btn;
        }else if (i == 4) {
            self.downloadToolBtn = btn;
        }
    }
    
    __weak LMReaderBookViewController* weakSelf = self;
    
    //隐藏头、尾
    [self hideAllHeaderAndFooterView];
    
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
                                if ([bookChapter.chapterId isEqualToString:self.readerBook.currentChapter.chapterId]) {
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
                                if ([parse hasApi]) {//json解析
                                    //章节列表
                                    [weakSelf initLoadJsonParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                                        weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                                        LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                        NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:weakSelf.readerBook.currentChapter];//当前章节角标
                                        LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                        realCurrentChapter.chapterId = currentChapter.chapterId;
                                        realCurrentChapter.sourceId = parse.source.id;
                                        realCurrentChapter.offset = currentChapter.offset;
                                        weakSelf.readerBook.currentChapter = realCurrentChapter;
                                        
                                        //章节内容
                                        [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                                }else {//html解析
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
                                }
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
                        if ([bookChapter.chapterId isEqualToString:self.readerBook.currentChapter.chapterId]) {
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
                        if ([parse hasApi]) {//json解析
                            //章节列表
                            [weakSelf initLoadJsonParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                                weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                                LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:currentChapter];//当前章节角标
                                LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                realCurrentChapter.chapterId = currentChapter.chapterId;
                                realCurrentChapter.sourceId = parse.source.id;
                                realCurrentChapter.offset = currentChapter.offset;
                                weakSelf.readerBook.currentChapter = realCurrentChapter;
                                //章节内容
                                [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                                    [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                        }else {//html解析
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
                        }
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
        [tool queryBookReadRecordWithBookId:self.bookId recordBlock:^(BOOL hasRecord, NSString* chapterId, UInt32 sourceId, NSInteger offset) {
            self.readerBook.currentChapter.chapterId = @"0";
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
                            weakSelf.readerBook.isNew = NO;
                            NSInteger tempCurrentIndex = 0;
                            NSMutableArray* bookChapterArr = [NSMutableArray array];
                            for (NSInteger i = 0; i < arr.count; i ++) {
                                Chapter* tempChapter = [arr objectAtIndex:i];
                                
                                LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                                if ([bookChapter.chapterId isEqualToString:self.readerBook.currentChapter.chapterId]) {
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
                                //Chiang
                                if ([parse hasApi]) {
                                    [self initLoadJsonParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                                        weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                                        LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                        NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:weakSelf.readerBook.currentChapter];//当前章节角标
                                        LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                        realCurrentChapter.chapterId = currentChapter.chapterId;
                                        realCurrentChapter.sourceId = parse.source.id;
                                        realCurrentChapter.offset = currentChapter.offset;
                                        weakSelf.readerBook.currentChapter = realCurrentChapter;
                                        
                                        //章节内容
                                        [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                                }
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
                        if ([bookChapter.chapterId isEqualToString:self.readerBook.currentChapter.chapterId]) {
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
                        if ([parse hasApi]) {//json解析
                            //章节列表
                            [weakSelf initLoadJsonParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                                weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                                LMReaderBookChapter* currentChapter = weakSelf.readerBook.currentChapter;
                                NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:currentChapter];//当前章节角标
                                LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                                realCurrentChapter.chapterId = currentChapter.chapterId;
                                realCurrentChapter.sourceId = parse.source.id;
                                realCurrentChapter.offset = currentChapter.offset;
                                weakSelf.readerBook.currentChapter = realCurrentChapter;
                                //章节内容
                                [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                                    [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                        }else {//html解析
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
                        }
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

//调低 亮度
-(void)clickedBrightSmallButton:(UIButton* )sender {
    CGFloat value = self.brightSlider.value - 0.1;
    if (value < self.brightSlider.minimumValue) {
        value = self.brightSlider.minimumValue;
    }
    [self.brightSlider setValue:value animated:YES];
    [self didSlideBrightSlider:self.brightSlider];
}

//调高 亮度
-(void)clickedBrightBigButton:(UIButton* )sender {
    CGFloat value = self.brightSlider.value + 0.1;
    if (value > self.brightSlider.maximumValue) {
        value = self.brightSlider.maximumValue;
    }
    [self.brightSlider setValue:value animated:YES];
    [self didSlideBrightSlider:self.brightSlider];
}

//滑动 亮度 slider
-(void)didSlideBrightSlider:(UISlider* )slider {
    float brightFloat = self.brightSlider.value;
    if (brightFloat != self.brightness) {
        self.brightness = brightFloat;
        [UIScreen mainScreen].brightness = self.brightness;
        [LMTool changeReaderConfigWithBrightness:self.brightness];
    }
}

//点击 亮度 slider
-(void)tappedBrightSlider:(UITapGestureRecognizer* )sliderTap {
    UIView* tapVi = sliderTap.view;
    CGPoint touchPoint = [sliderTap locationInView:tapVi];
    CGFloat value = (self.brightSlider.maximumValue - self.brightSlider.minimumValue) * (touchPoint.x / self.brightSlider.frame.size.width );
    [self.brightSlider setValue:value animated:YES];
    [self didSlideBrightSlider:self.brightSlider];
}

-(LMReaderSettingView *)settingView {
    if (!_settingView) {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat settingHeight = 170;
        if ([LMTool isBangsScreen]) {
            settingHeight = 170 + 44;
        }
        _settingView = [[LMReaderSettingView alloc]initWithFrame:CGRectMake(0, screenHeight, self.view.frame.size.width, settingHeight) fontSize:self.fontSize bgInteger:self.readModel lineSpaceIndex:self.lineSpaceIndex];
        [self.view addSubview:_settingView];
    }
    return _settingView;
}

//刷新naviBarView 背景、图片颜色
-(void)reloadTopNaviBarViewAndSourceTitleView {
    if (self.readModel == LMReaderBackgroundType4) {//夜间模式
        self.naviBarView.backgroundColor = [UIColor blackColor];
        self.backBtn.tintColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
        self.moreBtn.tintColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
        [self.changeSourceBtn setTitleColor:[UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1] forState:UIControlStateNormal];
        self.titleLab.textColor = UIColorFromRGB(0xb4b3b3);
        
        self.sourceTV.backgroundColor = [UIColor blackColor];
        
        [self.sourceTV reloadSourceTitleViewWithModel:self.readModel];
    }else {
        self.naviBarView.backgroundColor = [UIColor whiteColor];
        self.backBtn.tintColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.moreBtn.tintColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        [self.changeSourceBtn setTitleColor:[UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1] forState:UIControlStateNormal];
        self.titleLab.textColor = [UIColor blackColor];
        
        self.sourceTV.backgroundColor = [UIColor colorWithRed:220.f/255 green:220.f/255 blue:220.f/255 alpha:1];
        
        [self.sourceTV reloadSourceTitleViewWithModel:self.readModel];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

//刷新toolBarView 背景、图片颜色
-(void)reloadBottomToolBarViewAndSettingView {
    if (self.readModel == LMReaderBackgroundType4) {//夜间模式
        self.toolBarView.backgroundColor = [UIColor blackColor];
        self.catalogToolBtn.tintColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
        self.nightToolBtn.tintColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
        self.setToolBtn.tintColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
        self.feedbackToolBtn.tintColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
        self.downloadToolBtn.tintColor = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
        
        [self.catalogToolBtn setTitleColor:[UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1] forState:UIControlStateNormal];
        [self.nightToolBtn setTitleColor:[UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1] forState:UIControlStateNormal];
        [self.setToolBtn setTitleColor:[UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1] forState:UIControlStateNormal];
        [self.feedbackToolBtn setTitleColor:[UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1] forState:UIControlStateNormal];
        [self.downloadToolBtn setTitleColor:[UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1] forState:UIControlStateNormal];
        
    }else {
        self.toolBarView.backgroundColor = [UIColor whiteColor];
        self.catalogToolBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.nightToolBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.setToolBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.feedbackToolBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        self.downloadToolBtn.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
        
        [self.catalogToolBtn setTitleColor:[UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1] forState:UIControlStateNormal];
        [self.nightToolBtn setTitleColor:[UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1] forState:UIControlStateNormal];
        [self.setToolBtn setTitleColor:[UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1] forState:UIControlStateNormal];
        [self.feedbackToolBtn setTitleColor:[UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1] forState:UIControlStateNormal];
        [self.downloadToolBtn setTitleColor:[UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1] forState:UIControlStateNormal];
    }
    
    BOOL isNightModel = [LMTool getSystemNightShift];
    if (isNightModel) {
        [self.nightToolBtn setImage:[[UIImage imageNamed:@"toolBarItem_Night_Selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.nightToolBtn setTitle:@"日间" forState:UIControlStateNormal];
    }else {
        [self.nightToolBtn setImage:[[UIImage imageNamed:@"toolBarItem_Night_Normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.nightToolBtn setTitle:@"夜间" forState:UIControlStateNormal];
    }
    
    //刷新设置界面
    [self.settingView reloadReaderSettingViewWithModel:self.readModel];
    //刷新下载界面
    if (self.downloadView) {
        [self.downloadView reloadDownloadBookViewWithModel:self.readModel];
    }
}

//刷新 下载界面 颜色
-(void)reloadDownloadBookView {
    if (self.downloadView) {
        [self.downloadView reloadDownloadBookViewWithModel:self.readModel];
    }
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
                        if ([bookChapter.chapterId isEqualToString:currentChapter.chapterId]) {
                            currentIndex = i;
                            break;
                        }
                    }
                }else {
                    if ([bookChapter.chapterId isEqualToString: currentChapter.chapterId]) {
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
                    if (weakSelf.bookCover == nil || weakSelf.bookCover.length == 0) {
                        weakSelf.bookCover = res.book.pic;
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

//隐藏所有顶部、底部视图
-(void)hideAllHeaderAndFooterView {
    [self setupNaviBarViewHidden:YES];
    [self setupToolBarViewHidden:YES];
    [self setupDownloadViewHidden:YES];
    [self setupSettingViewHidden:YES];
    [self setupEditCommentButtonHidden:YES];
    if (self.sourceTV) {
        [self setupSourceTitleViewHidden:YES];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

//naviBarView 动画
-(void)setupNaviBarViewHidden:(BOOL )shouldHidden {
    CGRect naviRect = self.naviBarView.frame;
    if (shouldHidden) {
        if (naviRect.origin.y == 0 - naviRect.size.height) {
            return;
        }
        naviRect.origin.y = 0 - naviRect.size.height;
    }else {
        if (naviRect.origin.y == 0) {
            return;
        }
        naviRect.origin.y = 0;
    }
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.naviBarView.frame = naviRect;
    } completion:^(BOOL finished) {
        
    }];
}

//来源sourceTitleView 动画
-(void)setupSourceTitleViewHidden:(BOOL )shouldHidden {
    if (shouldHidden) {
        if (self.sourceTV.frame.origin.y < 0) {
            return;
        }
        [self.sourceTV startHide];
    }else {
        if (self.sourceTV.frame.origin.y > 0) {
            return;
        }
        [self.sourceTV startShow];
    }
}

//toolBarView 动画
-(void)setupToolBarViewHidden:(BOOL )shouldHidden {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect toolRect = self.toolBarView.frame;
    if (shouldHidden) {
        if (toolRect.origin.y == screenRect.size.height) {
            return;
        }
        toolRect.origin.y = screenRect.size.height;
    }else {
        if (toolRect.origin.y == screenRect.size.height - toolRect.size.height) {
            return;
        }
        toolRect.origin.y = screenRect.size.height - toolRect.size.height;
    }
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.toolBarView.frame = toolRect;
    } completion:^(BOOL finished) {
        
    }];
}

//下载视图 动画
-(void)setupDownloadViewHidden:(BOOL )shouldHidden {
    if (self.downloadView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGRect downloadRect = self.downloadView.frame;
        if (shouldHidden) {
            if (downloadRect.origin.y == screenRect.size.height) {
                return;
            }
            downloadRect.origin.y = screenRect.size.height;
        }else {
            if (downloadRect.origin.y == screenRect.size.height - downloadRect.size.height - self.toolBarView.frame.size.height) {
                return;
            }
            downloadRect.origin.y = screenRect.size.height - downloadRect.size.height - self.toolBarView.frame.size.height;
        }
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            self.downloadView.frame = downloadRect;
        } completion:^(BOOL finished) {
            
        }];
    }
}

//editCommentBtn 动画
-(void)setupEditCommentButtonHidden:(BOOL )shouldHidden {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect editRect = self.editCommentBtn.frame;
    if (shouldHidden) {
        if (editRect.origin.x == screenRect.size.width) {
            return;
        }
        editRect.origin.x = screenRect.size.width;
    }else {
        CGFloat settingX = screenRect.size.width - editRect.size.width - 10;
        if (editRect.origin.x == settingX) {
            return;
        }
        editRect.origin.x = settingX;
    }
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.editCommentBtn.frame = editRect;
    } completion:^(BOOL finished) {
        
    }];
}

//settingView 动画
-(void)setupSettingViewHidden:(BOOL )shouldHidden {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect settingRect = self.settingView.frame;
    if (shouldHidden) {
        if (settingRect.origin.y == screenRect.size.height) {
            return;
        }
        settingRect.origin.y = screenRect.size.height;
    }else {
        if (settingRect.origin.y == screenRect.size.height - settingRect.size.height) {
            return;
        }
        settingRect.origin.y = screenRect.size.height - settingRect.size.height;
    }
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.settingView.frame = settingRect;
    } completion:^(BOOL finished) {
        
    }];
}

//Chiang json解析章节列表
-(void)initLoadJsonParseBookChaptersWithUrlReadParse:(UrlReadParse* )parse successBlock:(void (^) (NSArray* listArray))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    [self showNetworkLoadingView];
    __weak LMReaderBookViewController* weakSelf = self;
    NSString* urlStr = parse.listUrl;
    [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
        @try {
            NSError* jsonError = nil;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:successData options:NSJSONReadingMutableLeaves error:&jsonError];
            if (jsonError != nil || dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
                [self reportParseErrorWithSourceId:parse.source.id chapterName:nil];//上报
                failureBlock(nil);
            }
            
            NSArray* tempArr = [LMTool jsonParseChapterListWithParse:parse originalDic:dic];
            
            if (tempArr.count > 0) {
                successBlock(tempArr);
                //保存新解析方式下章节列表
                [LMTool archiveNewParseBookCatalogListWithBookId:weakSelf.bookId catalogList:tempArr];
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

//Chiang json解析章节内容
-(void)initLoadJsonParseChapterContentWithBookChapter:(LMReaderBookChapter* )bookChapter UrlReadParse:(UrlReadParse* )parse successBlock:(void (^) (NSString* contentStr))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    UInt32 bookId = self.bookId;
    NSString* chapterId = bookChapter.chapterId;
    if ([LMTool isExistBookTextWithBookId:self.bookId chapterId:chapterId]) {//有缓存，取缓存
        NSString* queryText = [LMTool queryBookTextWithBookId:self.bookId chapterId:chapterId];
        NSString* chapterText = [LMTool replaceSeveralNewLineWithOneNewLineWithText:queryText];
        if (chapterText != nil && ![chapterText isKindOfClass:[NSNull class]] && chapterText.length > 0) {
            successBlock(chapterText);
            return;
        }
    }
    NSString* urlStr = bookChapter.url;
    [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
        @try {
            NSError* jsonError = nil;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:successData options:NSJSONReadingMutableLeaves error:&jsonError];
            if (jsonError != nil || dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
                [self reportParseErrorWithSourceId:parse.source.id chapterName:nil];//上报
                failureBlock(nil);
            }
            NSString* totalContentStr = [LMTool jsonParseChapterContentWithParse:parse originalDic:dic];
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
                bookChapter.chapterId = [NSString stringWithFormat:@"%ld", i - listOffset];
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
    NSString* chapterId = bookChapter.chapterId;
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
    NSString* chapterId = currentChapter.chapterId;
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
    [btn setImage:[[UIImage imageNamed:normalImg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    if (selectedImg) {
        [btn setImage:[[UIImage imageNamed:selectedImg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    }
    [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 13, 21, 13)];//44   26
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setTitle:title forState:UIControlStateNormal];
    if (selectedTitle) {
        [btn setTitle:selectedTitle forState:UIControlStateSelected];
    }
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(24, -29, 0, 0)];
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
    
    //如果已经阅读完该书
    BOOL isReadEnd = NO;
    for (UIViewController* subVC in self.childViewControllers) {
        if ([subVC isKindOfClass:[LMReaderRecommandViewController class]]) {
            isReadEnd = YES;
            break;
        }
    }
    if (isReadEnd) {
        [UIScreen mainScreen].brightness = self.brightness;
        [self notifyChangeSourceViewControllerDeleteCache];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    //未加入书架，且获取到相关推荐，弹窗提示
    if (self.isCollected == NO && self.relatedArray != nil && self.relatedArray.count > 0) {
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
    BOOL isRecommandVC = NO;
    for (UIViewController* subVC in self.childViewControllers) {
        if ([subVC isKindOfClass:[LMReaderRecommandViewController class]]) {
            isRecommandVC = YES;
            break;
        }
    }
    
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
    if (isRecommandVC) {
        PopoverAction* shelfAction = [PopoverAction actionWithTitle:@"书架" handler:^(PopoverAction *action) {
            LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
            [rootVC backToTabBarControllerWithViewControllerIndex:0];
        }];
        
        [actionArray addObject:shelfAction];
        [actionArray addObject:shareAction];
    }else {
        [actionArray addObject:briefAction];
        [actionArray addObject:shareAction];
        [actionArray addObject:commentAction];
    }
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
                
                if ([parse hasApi]) {//json解析
                    //章节列表
                    [weakSelf initLoadJsonParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                        weakSelf.readerBook.chaptersArr = [NSArray arrayWithArray:listArray];
                        NSInteger chapterIndex = [weakSelf queryCurrentChapterIndexWithChaptersArray:weakSelf.readerBook.chaptersArr currentChapter:weakSelf.readerBook.currentChapter];//当前章节角标
                        LMReaderBookChapter* realCurrentChapter = [weakSelf.readerBook.chaptersArr objectAtIndex:chapterIndex];
                        realCurrentChapter.sourceId = parse.source.id;
                        realCurrentChapter.offset = 0;
                        weakSelf.readerBook.currentChapter = realCurrentChapter;
                        //章节内容
                        [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                            realCurrentChapter.content = contentStr;
                            NSInteger textOffset = 0;//换源之后，切换到第一页
                            NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                            weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                            NSInteger pageIndex = 0;
                            weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                            weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                            
                            [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                            
                            self.sourceTV.hidden = NO;//换源成功，显示sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"换源成功"];
                        } failureBlock:^(NSError *error) {
                            
                            self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            [weakSelf showMBProgressHUDWithText:@"换源失败"];
                        }];
                    } failureBlock:^(NSError *error) {
                        self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                        
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                        [weakSelf showMBProgressHUDWithText:@"获取失败，请尝试切换其它源"];
                    }];
                }else {//html解析
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
                            
                            self.sourceTV.hidden = NO;//换源成功，显示sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"换源成功"];
                        } failureBlock:^(NSError *error) {
                            
                            self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            [weakSelf showMBProgressHUDWithText:@"换源失败"];
                        }];
                    } failureBlock:^(NSError *error) {
                        self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                        
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                        [weakSelf showMBProgressHUDWithText:@"获取失败，请尝试切换其它源"];
                    }];
                }
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
    if (sender == self.catalogToolBtn) {//目录
        __weak LMReaderBookViewController* weakSelf = self;
        LMBookCatalogViewController* catalogVC = [[LMBookCatalogViewController alloc]init];
        catalogVC.bookId = (UInt32 )self.readerBook.bookId;
        catalogVC.fromWhich = 1;
        catalogVC.bookNameStr = self.bookName;
        catalogVC.chapterIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
        catalogVC.dataArray = [NSMutableArray arrayWithArray:self.readerBook.chaptersArr];
        [self.navigationController pushViewController:catalogVC animated:YES];
        if (self.readerBook.isNew) {
            catalogVC.isNew = YES;
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
                        if ([parse hasApi]) {//json解析
                            [weakSelf initLoadJsonParseChapterContentWithBookChapter:weakSelf.readerBook.currentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                        }else {//html解析
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
                }
            };
        }else {
            catalogVC.isNew = NO;
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
        }
//        [self.navigationController pushViewController:catalogVC animated:YES];
        
    }else if (sender == self.nightToolBtn) {//夜间、日间
        BOOL isNightModel = [LMTool getSystemNightShift];
        
        [LMTool changeSystemNightShift:!isNightModel];
        
        AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
        [appDelegate updateSystemNightShift];
        
        if (isNightModel) {
            if (self.settingView) {
                self.readModel = LMReaderBackgroundType1;
                
                [LMTool changeReaderConfigWithBackgroundInteger:1];
                
                [self reloadTopNaviBarViewAndSourceTitleView];
                [self reloadDownloadBookView];
                
                [self showNetworkLoadingView];
                [self resetupPageViewControllers];
                [self hideNetworkLoadingView];
            }
            self.settingView.bgInteger = 1;
            [self.settingView reloadReaderSettingViewWithModel:self.readModel];
        }else {
            if (self.settingView) {
                self.readModel = LMReaderBackgroundType4;
                
                [LMTool changeReaderConfigWithBackgroundInteger:4];
                
                [self reloadTopNaviBarViewAndSourceTitleView];
                [self reloadDownloadBookView];
                
                [self showNetworkLoadingView];
                [self resetupPageViewControllers];
                [self hideNetworkLoadingView];
            }
            self.settingView.bgInteger = 4;
            [self.settingView reloadReaderSettingViewWithModel:self.readModel];
        }
        [self reloadBottomToolBarViewAndSettingView];
        
    }else if (sender == self.setToolBtn) {//设置
        [self setupToolBarViewHidden:YES];
        [self setupDownloadViewHidden:YES];
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        __weak LMReaderBookViewController* weakSelf = self;
        NSString* contentText = self.readerBook.currentChapter.content;
        if (contentText != nil && ![contentText isKindOfClass:[NSNull class]] && contentText.length > 0) {
            
        }else {
            return;
        }
        if (self.settingView) {
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
                
                [weakSelf reloadTopNaviBarViewAndSourceTitleView];
                [weakSelf reloadBottomToolBarViewAndSettingView];
                [weakSelf reloadDownloadBookView];
                
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
        
        CGFloat settingHeight = self.settingView.frame.size.height;
        [self.settingView showSettingViewWithFinalFrame:CGRectMake(0, screenHeight - settingHeight, self.view.frame.size.width, settingHeight)];
        
    }else if (sender == self.feedbackToolBtn) {//报错
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
                NSString* infoStr = [NSString stringWithFormat:@"%@[bid:%u][sid:%d]", text, weakSelf.bookId, sourceId];
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
    }else if (sender == self.downloadToolBtn) {//下载
        NSString* currentChapterStr = self.readerBook.currentChapter.content;
        if (currentChapterStr != nil && ![currentChapterStr isKindOfClass:[NSNull class]] && currentChapterStr.length > 0) {
            
        }else {
            return;
        }
        if (!self.downloadView) {
            self.downloadView = [[LMDownloadBookView alloc]initWithFrame:CGRectMake(0, self.toolBarView.frame.origin.y - 40, self.view.frame.size.width, 40)];
            [self.downloadView reloadDownloadBookViewWithModel:self.readModel];
            [self.view addSubview:self.downloadView];
        }
        if (self.downloadView.isDownload == NO) {
            __weak LMReaderBookViewController* weakSelf = self;
            NSArray* catalogArr = [NSArray arrayWithArray:self.readerBook.chaptersArr];
            if (self.readerBook.isNew) {
                UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                [self.downloadView startDownloadNewParseBookWithBookId:self.bookId catalogList:catalogArr parse:parse block:^(BOOL isFinished, BOOL isFailed, NSInteger totalCount, CGFloat progress) {
                    if (isFailed && totalCount < LMDownloadBookViewMaxCount) {
                        [weakSelf clickedToolBarButtonItem:weakSelf.downloadToolBtn];
                    }
                }];
            }else {
                [self.downloadView startDownloadOldParseBookWithBookId:self.bookId catalogList:catalogArr block:^(BOOL isFinished, BOOL isFailed, NSInteger totalCount, CGFloat progress) {
                    if (isFinished) {
                        if (isFailed && totalCount < LMDownloadBookViewMaxCount) {
                            [weakSelf clickedToolBarButtonItem:weakSelf.downloadToolBtn];
                        }
                    }
                }];
            }
        }
        [self setupDownloadViewHidden:NO];
    }
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    BOOL isNaviBarHidden = self.naviBarView.frame.origin.y < 0;
    [self setupNaviBarViewHidden:!isNaviBarHidden];
    [self setupToolBarViewHidden:!isNaviBarHidden];
    [self setupSourceTitleViewHidden:!isNaviBarHidden];
    if (self.downloadView) {
        [self setupDownloadViewHidden:!isNaviBarHidden];
    }
    if (self.settingView) {
        [self setupSettingViewHidden:YES];
    }
    [self setupEditCommentButtonHidden:!isNaviBarHidden];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

//来源
-(LMSourceTitleView *)sourceTV {
    if (self.readerBook.isNew && self.readerBook.parseArr.count > 0) {
        __weak LMReaderBookViewController* weakSelf = self;
        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
        LMReaderBookChapter* tempBookChapter = self.readerBook.currentChapter;
        NSString* chapterUrlStr = tempBookChapter.url;
        if (chapterUrlStr != nil && ![chapterUrlStr isKindOfClass:[NSNull class]] && chapterUrlStr.length > 0) {
            
        }else {
            chapterUrlStr = parse.listUrl;
        }
        if (!_sourceTV) {
            _sourceTV = [[LMSourceTitleView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            [self.view addSubview:_sourceTV];
        }
        if (_sourceTV) {
            _sourceTV.alertText = parse.source.name;
            _sourceTV.callBlock = ^(BOOL didClick) {
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
            [_sourceTV reloadSourceTitleViewWithModel:self.readModel];
            [self.view bringSubviewToFront:_sourceTV];
            return _sourceTV;
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
    [self hideAllHeaderAndFooterView];
    
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
                        return nil;
                    }else {
                        __weak LMReaderBookViewController* weakSelf = self;
                        
                        self.readerBook.currentChapter.pagesArr = nil;
                        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                        if ([parse hasApi]) {
                            [self initLoadJsonParseChapterContentWithBookChapter:self.readerBook.currentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                            } failureBlock:^(NSError *error) {
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }else {
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
                            } failureBlock:^(NSError *error) {
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }
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
    [self hideAllHeaderAndFooterView];
    
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
                        //[self showMBProgressHUDWithText:@"最后一页了"];
                        
                        //
                        [self exchangePageViewControllerToReaderRecommandViewController];
                        
                        return nil;
                    }
                    NSArray* newestSourceArr = newestChapter.sources;
                    if (newestSourceArr.count == 0) {
                        [self hideNetworkLoadingView];
                        //[self showMBProgressHUDWithText:@"最后一页了"];
                        
                        //
                        [self exchangePageViewControllerToReaderRecommandViewController];
                        
                        return nil;
                    }
                    NSInteger selectedIndex = 0;
                    Source* firstSource = [newestSourceArr firstObject];
                    UInt32 newestIndex = firstSource.id;
                    if (newestIndex == self.readerBook.currentChapter.sourceId) {
                        [self hideNetworkLoadingView];
                        //[self showMBProgressHUDWithText:@"最后一页了"];
                        
                        //
                        [self exchangePageViewControllerToReaderRecommandViewController];
                        
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
                    if ([parse hasApi]) {//json解析
                        //章节列表
                        [self initLoadJsonParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
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
                            [weakSelf initLoadJsonParseChapterContentWithBookChapter:realCurrentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                realCurrentChapter.content = contentStr;
                                NSInteger textOffset = 0;//换源之后，切换到第一页
                                NSArray* pagesArr = [weakSelf cutBookPageWithChapterContent:contentStr offset:textOffset];//把章节切页
                                weakSelf.readerBook.currentChapter.pagesArr = [NSArray arrayWithArray:pagesArr];
                                NSInteger pageIndex = 0;
                                weakSelf.readerBook.currentChapter.currentPage = pageIndex;
                                weakSelf.readerBook.currentChapter.pageChange = pageIndex;
                                
                                [weakSelf setupPageViewControllerWithCurrentChapter:weakSelf.readerBook.currentChapter];//显示
                                
                                self.sourceTV.hidden = NO;//换源成功，显示sourceTitleView
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf hideEmptyLabel];
                                [weakSelf showMBProgressHUDWithText:@"换源成功"];
                            } failureBlock:^(NSError *error) {
                                
                                self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf hideEmptyLabel];
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                [weakSelf showMBProgressHUDWithText:@"换源失败"];
                            }];
                        } failureBlock:^(NSError *error) {
                            self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf hideEmptyLabel];
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            [weakSelf showMBProgressHUDWithText:@"获取失败，请尝试切换其它源"];
                        }];
                    }else {//html解析
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
                                
                                self.sourceTV.hidden = NO;//换源成功，显示sourceTitleView
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf hideEmptyLabel];
                                [weakSelf showMBProgressHUDWithText:@"换源成功"];
                            } failureBlock:^(NSError *error) {
                                
                                self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf hideEmptyLabel];
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                [weakSelf showMBProgressHUDWithText:@"换源失败"];
                            }];
                        } failureBlock:^(NSError *error) {
                            self.sourceTV.hidden = YES;//换源失败，隐藏sourceTitleView
                            
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf hideEmptyLabel];
                            [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                            [weakSelf showMBProgressHUDWithText:@"获取失败，请尝试切换其它源"];
                        }];
                    }
                    
                    [self showEmptyLabelWithCenterPoint:CGPointMake(self.view.center.x, self.view.center.y + 100) text:@"其它源有更新，正在为你切换"];
                    
                }else {
                    //[self showMBProgressHUDWithText:@"最后一页了"];
                    
                    //
                    [self exchangePageViewControllerToReaderRecommandViewController];
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
                        return nil;
                    }else {
                        __weak LMReaderBookViewController* weakSelf = self;
                        
                        self.readerBook.currentChapter.pagesArr = nil;
                        UrlReadParse* parse = [self.readerBook.parseArr objectAtIndex:self.readerBook.currentParseIndex];
                        if ([parse hasApi]) {
                            [self initLoadJsonParseChapterContentWithBookChapter:self.readerBook.currentChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
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
                            } failureBlock:^(NSError *error) {
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }else {
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
                            } failureBlock:^(NSError *error) {
                                [weakSelf setupPageViewControllerWithCurrentChapter:nil];
                                
                                [weakSelf hideNetworkLoadingView];
                                [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            }];
                        }
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
                            if ([parse hasApi]) {
                                [self initLoadJsonParseChapterContentWithBookChapter:nextChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                    nextChapter.content = contentStr;
                                    NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:0];//把章节切页
                                    nextChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                                } failureBlock:^(NSError *error) {
                                    
                                }];
                            }else {
                                [self initLoadNewParseChapterContentWithBookChapter:nextChapter UrlReadParse:parse successBlock:^(NSString *contentStr) {
                                    nextChapter.content = contentStr;
                                    NSArray* pagesArray = [weakSelf cutBookPageWithChapterContent:contentStr offset:0];//把章节切页
                                    nextChapter.pagesArr = [NSArray arrayWithArray:pagesArray];
                                } failureBlock:^(NSError *error) {
                                    
                                }];
                            }
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
    
    NSMutableAttributedString* beforeAttributedStr = [[NSMutableAttributedString alloc]initWithString:resultStr attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFang SC" size:self.fontSize], NSParagraphStyleAttributeName : paraStyle, NSKernAttributeName:@(1)}];//[UIFont systemFontOfSize:self.fontSize]指定字体，否则容易切页不准
    
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
                NSAttributedString* attributeStr = [[NSAttributedString alloc]initWithString:lastPageText attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFang SC" size:self.fontSize], NSParagraphStyleAttributeName : paraStyle, NSKernAttributeName:@(1)}];
                UITextView* lastPageTV = [[UITextView alloc]initWithFrame:contentLabRect];
                lastPageTV.attributedText = attributeStr;
                
                CGRect labRect = lastPageTV.frame;
                CGSize labSize = [lastPageTV sizeThatFits:CGSizeMake(labRect.size.width, MAXFLOAT)];
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
    
    for (UIViewController* subVC in self.childViewControllers) {
        if ([subVC isKindOfClass:[LMReaderRecommandViewController class]]) {
            [subVC removeFromParentViewController];
            [subVC.view removeFromSuperview];
        }
    }
    //初始化设置pageVC
    if (!self.pageVC) {
        self.pageVC = [[LMPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];//@{UIPageViewControllerOptionSpineLocationKey : @1}
//        self.pageVC.doubleSided = YES;
        self.pageVC.gestureDelegate = self;
        self.pageVC.delegate = self;
        self.pageVC.dataSource = self;
        self.pageVC.view.frame = self.view.bounds;
        [self addChildViewController:self.pageVC];
        [self.view insertSubview:self.pageVC.view belowSubview:self.naviBarView];
        
        if ([LMTool shouldShowReaderUserInstructionsView]) {
            [self setupNaviBarViewHidden:NO];
            [self setupToolBarViewHidden:NO];
            [self setupSettingViewHidden:YES];
            [self setupEditCommentButtonHidden:NO];
            [self setupSourceTitleViewHidden:NO];
            //
            [self setNeedsStatusBarAppearanceUpdate];
            
            CGFloat topHeight = 20 + 44 - 10;
            CGFloat bottomHeight = 49 - 6;
            if ([LMTool isBangsScreen]) {
                topHeight = 44 + 44 - 10;
                bottomHeight = 83 - 6;
            }
            LMReaderUserInstructionsView* readUIV = [[LMReaderUserInstructionsView alloc]init];
            [readUIV setUpChangeSourcePoint:CGPointMake(self.changeSourceBtn.frame.origin.x + self.changeSourceBtn.frame.size.width / 2, topHeight) nightPoint:CGPointMake(self.nightToolBtn.frame.origin.x + self.nightToolBtn.frame.size.width / 2, self.view.frame.size.height - bottomHeight)];
            [readUIV setUpCommentPoint:CGPointMake(self.editCommentBtn.frame.origin.x + self.editCommentBtn.frame.size.width / 2, self.editCommentBtn.frame.origin.y) SettingPoint:CGPointMake(self.setToolBtn.frame.origin.x + self.setToolBtn.frame.size.width / 2, self.view.frame.size.height - bottomHeight)];
            [readUIV setUpErrorPoint:CGPointMake(self.feedbackToolBtn.frame.origin.x + self.feedbackToolBtn.frame.size.width / 2, self.view.frame.size.height - bottomHeight)];
            [readUIV startShow];
        }
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
        
        NSString* progressStr = @"";
        if (self.readerBook.chaptersArr.count > 0 && self.readerBook.currentChapter != nil) {
            NSInteger contentVCIndex = [self.readerBook.chaptersArr indexOfObject:self.readerBook.currentChapter];
            progressStr = [NSString stringWithFormat:@"%.2f", ((float)(contentVCIndex + 1)) / self.readerBook.chaptersArr.count * 100];
        }
        
        LMReaderBookPage* bookPage = [bookChapter.pagesArr objectAtIndex:bookChapter.currentPage];
        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
        [tool saveBookReadRecordWithBookId:self.bookId bookName:self.bookName chapterId:bookChapter.chapterId chapterNo:(UInt32 )bookChapter.chapterNo chapterTitle:bookChapter.title sourceId:sourceId offset:bookPage.startLocation progressStr:progressStr coverStr:self.bookCover];
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
    NSInteger toWhich = 0;
    if (sender == nil) {
        toWhich = 1;
    }
    __weak LMReaderBookViewController* weakSelf = self;
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        LMBookEditCommentViewController* editCommentVC = [[LMBookEditCommentViewController alloc]init];
        editCommentVC.bookId = self.bookId;
        if (toWhich) {//从最后一章节最后页的“写评论”进入，评论完之后跳到书评列表界面
            editCommentVC.commentBlock = ^(BOOL didComment) {
                if (didComment) {
                    LMBookCommentDetailViewController* commentDetailVC = [[LMBookCommentDetailViewController alloc]init];
                    commentDetailVC.bookId = weakSelf.bookId;
                    commentDetailVC.bookName = weakSelf.bookName;
                    [weakSelf.navigationController pushViewController:commentDetailVC animated:YES];
                }
            };
        }
        [self.navigationController pushViewController:editCommentVC animated:YES];
        return;
    }else {
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        loginAV.loginBlock = ^(BOOL didLogined) {
            if (didLogined) {
                LMBookEditCommentViewController* editCommentVC = [[LMBookEditCommentViewController alloc]init];
                editCommentVC.bookId = weakSelf.bookId;
                if (toWhich) {//从最后一章节最后页的“写评论”进入，评论完之后跳到书评列表界面
                    editCommentVC.commentBlock = ^(BOOL didComment) {
                        if (didComment) {
                            LMBookCommentDetailViewController* commentDetailVC = [[LMBookCommentDetailViewController alloc]init];
                            commentDetailVC.bookId = weakSelf.bookId;
                            commentDetailVC.bookName = weakSelf.bookName;
                            [weakSelf.navigationController pushViewController:commentDetailVC animated:YES];
                        }
                    };
                }
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
