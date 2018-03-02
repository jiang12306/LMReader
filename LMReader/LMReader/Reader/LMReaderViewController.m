//
//  LMReaderViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/31.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderViewController.h"
#import "LMContentViewController.h"
#import "LMCatalogViewController.h"
#import "LMChangeSourceViewController.h"
#import "LMTool.h"
#import "LMFontView.h"
#import "LMDatabaseTool.h"
#import <CoreText/CoreText.h>

@interface LMReaderViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, LMFontViewDelegate>

@property (nonatomic, strong) UIPageViewController* pageVC;
@property (nonatomic, strong) LMFontView* fontView;//字体 视图
@property (nonatomic, strong) NSMutableArray* toolTitleArray;
@property (nonatomic, strong) Chapter* currentChapter;//当前章节
@property (nonatomic, strong) NSMutableArray* sourceArray;//所有源头
@property (nonatomic, assign) NSRange currentRange;//当前文本位置
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) LMReadModel readModel;

@property (nonatomic, strong) NSMutableArray* pageArray;//总页数
@property (nonatomic, assign) NSInteger currentPage;//
@property (nonatomic, assign) NSInteger pageChange;

@end

@implementation LMReaderViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(ios 11.0, *)) {
        
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    
    self.title = @"正文阅读";
    
    UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 52, 30)];//12,24
    UIImage* leftImage = [UIImage imageNamed:@"navigationItem_Back"];
    UIImage* tintImage = [leftImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* leftButton = [[UIButton alloc]initWithFrame:leftView.frame];
    [leftButton setTintColor:BACKCOLOR];
    [leftButton setImage:tintImage forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 40)];
    [leftButton addTarget:self action:@selector(clickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton setTitleColor:BACKCOLOR forState:UIControlStateNormal];
    [leftView addSubview:leftButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 30)];
    UIImage* rightImage = [UIImage imageNamed:@"navigationItem_More"];
    UIImage* tintLeftImage = [rightImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* rightButton = [[UIButton alloc]initWithFrame:rightView.frame];
    [rightButton setTintColor:BACKCOLOR];
    [rightButton setImage:tintLeftImage forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(5, 45, 5, 0)];
    [rightButton addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitle:@"换源" forState:UIControlStateNormal];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 15)];
    [rightButton setTitleColor:BACKCOLOR forState:UIControlStateNormal];
    [rightView addSubview:rightButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController.toolbar setBarStyle:UIBarStyleDefault];
    [self.navigationController.toolbar setTranslucent:YES];
    
    self.toolTitleArray = [NSMutableArray array];
    self.sourceArray = [NSMutableArray array];
    self.pageArray = [NSMutableArray array];
    
    __block NSInteger modelInt;
    [LMTool getReaderConfig:^(CGFloat fontSize, NSInteger modelInteger) {
        self.fontSize = fontSize;
        modelInt = modelInteger;
    }];
    if (modelInt) {//白天模式
        [self.toolTitleArray addObject:@"夜间"];
        self.readModel = LMReadModelDay;
    }else {
        self.readModel = LMReadModelNight;
        [self.toolTitleArray addObject:@"白天"];
    }
    [self.toolTitleArray addObjectsFromArray:@[@"字体", @"目录", @"下载", @"分享"]];
    
    NSMutableArray* itemsArr = [NSMutableArray array];
    for (NSInteger i = 0; i < self.toolTitleArray.count; i ++) {
        UIBarButtonItem* leftSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* item = [self createBarButtonItemWithTitle:self.toolTitleArray[i] tag:i];
        UIBarButtonItem* rightSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [itemsArr addObjectsFromArray:@[leftSpaceItem, item, rightSpaceItem]];
    }
    self.toolbarItems = itemsArr;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
    
    //初始化
    self.currentRange = NSMakeRange(100, 0);
//    self.currentRange = NSMakeRange(0, 0);
    
    //
    [self loadCatalogListWithBookId:self.book.bookId];
}

//创建toolBar上按钮
-(UIBarButtonItem* )createBarButtonItemWithTitle:(NSString* )title tag:(NSInteger )tag {
    UIView* itemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    itemView.tag = tag;
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, itemView.frame.size.width, itemView.frame.size.height)];
    btn.selected = NO;
    btn.tag = tag;
    [btn addTarget:self action:@selector(clickedToolBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"nightMode"] forState:UIControlStateNormal];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 20, 10)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(24, -22, 0, 0)];
    [itemView addSubview:btn];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:itemView];
    item.tag = tag;
    return item;
}

//返回
-(void)clickedBackButton:(UIButton* )sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //保存阅读记录
//    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
//    tool saveBookReadRecordWithBookId: chapterId: offset:
}

//换源
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    NSLog(@"self.sourceArr = %@", self.sourceArray);
    LMChangeSourceViewController* sourceVC = [[LMChangeSourceViewController alloc]init];
    sourceVC.sourceArr = [self.sourceArray mutableCopy];
    [self.navigationController pushViewController:sourceVC animated:YES];
}

//点击toolBar
-(void)clickedToolBarButtonItem:(UIButton* )sender {
    switch (sender.tag) {
        case 0://夜间
        {
            if (sender.selected == NO) {
                //夜间 模式
                sender.selected = YES;
                [self.toolTitleArray replaceObjectAtIndex:0 withObject:@"白天"];
                [sender setTitle:self.toolTitleArray[0] forState:UIControlStateSelected];
                self.readModel = LMReadModelNight;
                [LMTool changeReaderConfigWithReaderModelDay:self.readModel fontSize:self.fontSize];
                
                [self setupPageViewControllersWithText:self.currentChapter.chapterContent fontSize:self.fontSize];
            }else {
                //白天 模式
                sender.selected = NO;
                [self.toolTitleArray replaceObjectAtIndex:0 withObject:@"夜间"];
                [sender setTitle:self.toolTitleArray[0] forState:UIControlStateNormal];
                self.readModel = LMReadModelDay;
                [LMTool changeReaderConfigWithReaderModelDay:YES fontSize:self.fontSize];
                
                [self setupPageViewControllersWithText:self.currentChapter.chapterContent fontSize:self.fontSize];
            }
        }
            break;
        case 1://字体
        {
            CGRect screenRect = [UIScreen mainScreen].bounds;
            if (self.fontView.isShow == NO) {
                [self.fontView showFontViewWithFinalFrame:CGRectMake(0, self.navigationController.toolbar.frame.origin.y - 40, self.view.frame.size.width, 40)];
            }else {
                [self.fontView hideFontViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
            }
        }
            break;
        case 2://目录
        {
            __weak LMReaderViewController* weakSelf = self;
            
            LMCatalogViewController* catalogVC = [[LMCatalogViewController alloc]init];
            catalogVC.bookId = self.book.bookId;
            catalogVC.callBlock = ^(Chapter *selectedChapter) {
                [weakSelf loadBookContentWithChapter:selectedChapter];
            };
            [self.navigationController pushViewController:catalogVC animated:YES];
        }
            break;
        case 3://下载
            
            break;
        case 4://分享
            
            break;
        default:
            break;
    }
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
//    CGPoint tapPoint = [tapGR locationInView:self.view];
//    NSLog(@"x = %f, y = %f", tapPoint.x, tapPoint.y);
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [self.fontView hideFontViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
    
    BOOL isHiden = self.navigationController.toolbar.isHidden;
    if (isHiden) {
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        [self.fontView hideFontViewWithFinalFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
    }
}

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate
#pragma mark 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSString* totalText = self.currentChapter.chapterContent;
    
    if (self.currentPage == 0) {//进入上一章节
        
    }else if (self.currentPage == 1) {//预加载上一章节
        
    }else {
        self.pageChange --;
        
        NSInteger tempBefore = [[self.pageArray objectAtIndex:self.pageChange - 1] integerValue];
        NSInteger tempCurrent = [[self.pageArray objectAtIndex:self.pageChange] integerValue];
        self.currentRange = NSMakeRange(tempBefore, tempCurrent - tempBefore);
    }
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[totalText substringWithRange:self.currentRange]];
    return contentVC;
    
    
    
    
    
    /*
    NSString* totalText = self.currentChapter.chapterContent;
    NSInteger tempBeforeLocation = self.currentRange.location;
    if (tempBeforeLocation == 0) {//进入上一章节
        return nil;
    }
    NSString* tempText = [totalText substringToIndex:tempBeforeLocation];
    
    NSLog(@"-----------------------");
    NSMutableString* descStr = [[NSMutableString alloc]init];
    for (int i=0; i<tempText.length; i++) {
        [descStr appendString:[tempText substringWithRange:NSMakeRange(tempText.length-i-1, 1)]];
    }
    NSLog(@"+++++++++++++++++++++++");
    
    NSMutableAttributedString* attributedStr = [[NSMutableAttributedString alloc]initWithString:descStr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]}];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attributedStr);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, CGRectGetWidth(contentRect), CGRectGetHeight(contentRect)), NULL);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CFRange tempRange = CTFrameGetVisibleStringRange(frame);
    NSRange range = NSMakeRange(tempBeforeLocation - tempRange.length, tempRange.length);
    if (tempRange.location + tempRange.length >= attributedStr.length) {//第一页，预加载上一章节
            NSLog(@"第一页，预加载上一章节");
        range = NSMakeRange(0, tempBeforeLocation);
    }
    
    if (frame) {
        CFRelease(frame);
    }
    CGPathRelease(path);
    CFRelease(frameSetter);
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[tempText substringWithRange:range]];
    self.currentRange = range;
    return contentVC;
     */
}

#pragma mark 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSString* totalText = self.currentChapter.chapterContent;
    
    if (self.currentPage == self.pageArray.count - 1) {//进入下一章节
        
    }else if (self.currentPage == self.pageArray.count - 2) {//预加载下一章节
        
    }else {
        self.pageChange ++;
        
        NSInteger tempNext = [[self.pageArray objectAtIndex:self.pageChange + 1] integerValue];
        NSInteger tempCurrent = [[self.pageArray objectAtIndex:self.pageChange] integerValue];
        self.currentRange = NSMakeRange(tempCurrent, tempNext - tempCurrent);
    }
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[totalText substringWithRange:self.currentRange]];
    return contentVC;
    
    
    
    
    
    
    /*
    NSString* totalText = self.currentChapter.chapterContent;
    NSInteger tempAfterLocation = self.currentRange.location + self.currentRange.length;
    if (tempAfterLocation >= totalText.length) {//进入下一章节
        return nil;
    }
    NSString* tempText = [totalText substringFromIndex:tempAfterLocation];
    NSMutableAttributedString* attributedStr = [[NSMutableAttributedString alloc]initWithString:tempText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]}];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attributedStr);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, CGRectGetWidth(contentRect), CGRectGetHeight(contentRect)), NULL);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           0, 0), path, NULL);
    CFRange tempRange = CTFrameGetVisibleStringRange(frame);
    NSRange range = NSMakeRange(tempAfterLocation, tempRange.length);
    if (tempRange.location + tempRange.length >= attributedStr.length) {//最后一页，预加载下一章节
        NSLog(@"最后一页，预加载下一章节");
    }
    
    if (frame) {
        CFRelease(frame);
    }
    CGPathRelease(path);
    CFRelease(frameSetter);
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[totalText substringWithRange:range]];
    self.currentRange = range;
    return contentVC;
     */
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSLog(@"333333333333333333333");
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        NSLog(@"111111111111111111111");
        self.currentPage = self.pageChange;
    }else {
        NSLog(@"222222222222222222222");
        self.pageChange = self.currentPage;
    }
}

-(LMFontView *)fontView {
    if (!_fontView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat fontSize = self.fontSize;
        _fontView = [[LMFontView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40) currentFontSize:fontSize];
        _fontView.delegate = self;
        [self.view addSubview:_fontView];
    }
    return _fontView;
}

#pragma mark -LMFontViewDelegate
-(void)fontViewCurrentValue:(CGFloat)fontSize {
    self.fontSize = fontSize;
    
    BOOL day = NO;
    if (self.readModel == LMReadModelDay) {
        YES;
    }
    [LMTool changeReaderConfigWithReaderModelDay:day fontSize:self.fontSize];
    
    [self setupPageViewControllersWithText:self.currentChapter.chapterContent fontSize:self.fontSize];
}


//根据bookid获取 目录 章节列表
-(void)loadCatalogListWithBookId:(UInt32 )bookId {
    [self showNetworkLoadingView];
    
    BookChapterReqBuilder* builder = [BookChapterReq builder];
    [builder setBookId:bookId];
    BookChapterReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 7) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                BookChapterRes* res = [BookChapterRes parseFromData:apiRes.body];
                NSArray* arr = res.chapters;
                if (arr != nil && arr.count > 0) {
                    Chapter* firstChapter = [arr objectAtIndex:0];
                    
                    [self loadBookContentWithChapter:firstChapter];
                }
            }
        }
        [self hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
        
    }];
}

//根据章节获取小说文本内容
-(void)loadBookContentWithChapter:(Chapter* )chapter {
    [self showNetworkLoadingView];
    
    BookChapterSourceReqBuilder* builder = [BookChapterSourceReq builder];
    [builder setBookId:self.book.bookId];
    [builder setChapterNo:chapter.chapterNo];
    [builder setChapterTitle:chapter.chapterTitle];
    [builder setSourceId:chapter.source.id];
    BookChapterSourceReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
    [networkTool postWithCmd:8 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 8) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                BookChapterSourceRes* res = [BookChapterSourceRes parseFromData:apiRes.body];
                NSArray* arr = res.sources;
                
                [self.sourceArray removeAllObjects];
                
                if (arr != nil && ![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                    [self.sourceArray addObjectsFromArray:arr];
                }
                self.currentChapter = res.chapter;
                
                [self setupPageViewControllersWithText:self.currentChapter.chapterContent fontSize:self.fontSize];
                
            }
        }
        [self hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
    }];
}

//
-(void )setupPageViewControllersWithText:(NSString* )text fontSize:(CGFloat )fontSize {
    
    NSInteger tempOffset = self.currentRange.location;
    NSString* tempText = [text substringToIndex:tempOffset];
    NSMutableString* beforeText = [[NSMutableString alloc]init];
    for (int i=0; i<tempText.length; i++) {
        [beforeText appendString:[tempText substringWithRange:NSMakeRange(tempText.length-i-1, 1)]];
    }
    NSMutableAttributedString* beforeAttributedStr = [[NSMutableAttributedString alloc]initWithString:beforeText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]}];
    CTFramesetterRef beforeFrameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) beforeAttributedStr);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, CGRectGetWidth(contentRect), CGRectGetHeight(contentRect)), NULL);
    
    NSInteger beforeOffset = 0;
    NSInteger beforeInnerOffset = 0;
    BOOL hasBeforePage = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    NSInteger beforeLoopSign = beforeOffset;
    NSInteger beforeRepeatCount = 0;
    NSInteger beforeObject = 0;
    
    if (tempOffset > 0) {
        
        while (hasBeforePage) {
            if (beforeLoopSign == beforeOffset) {
                ++beforeRepeatCount;
            }else {
                beforeRepeatCount = 0;
            }
            if (beforeRepeatCount > 1) {
                // 退出循环前检查一下最后一页是否已经加上
                if (_pageArray.count == 0) {
                    [_pageArray addObject:@(beforeOffset)];
                }
                else {
                    
                    NSUInteger lastOffset = [[_pageArray lastObject] integerValue];
                    
                    if (lastOffset != beforeOffset) {
                        [_pageArray addObject:@(beforeOffset)];
                    }
                }
                break;
            }
            beforeObject = beforeOffset != 0 ? (tempOffset - beforeOffset) : 0;
            
            [_pageArray addObject:@(beforeObject)];
            //        [_pageArray addObject:@(beforeOffset)];
            
            CTFrameRef frame = CTFramesetterCreateFrame(beforeFrameSetter, CFRangeMake(beforeInnerOffset, 0), path, NULL);
            CFRange range = CTFrameGetVisibleStringRange(frame);
            if ((range.location + range.length) != beforeAttributedStr.length) {
                beforeOffset += range.length;
                beforeInnerOffset += range.length;
            } else {
                // 已经分完，提示跳出循环
                hasBeforePage = NO;
            }
            if (frame) CFRelease(frame);
        }
        CFRelease(beforeFrameSetter);
    }
    
    
    NSString* afterText = [text substringFromIndex:tempOffset];
    NSMutableAttributedString* afterAttributedStr = [[NSMutableAttributedString alloc]initWithString:afterText attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]}];
    CTFramesetterRef afterFrameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) afterAttributedStr);
    
    NSInteger afterOffset = 0;
    NSInteger afterInnerOffset = 0;
    BOOL hasAfterPage = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    NSInteger afterLoopSign = afterOffset;
    NSInteger afterRepeatCount = 0;
    
    while (hasAfterPage) {
        if (afterLoopSign == afterOffset) {
            ++afterRepeatCount;
        }else {
            afterRepeatCount = 0;
        }
        if (afterRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
            if (_pageArray.count == 0) {
                [_pageArray addObject:@(afterOffset + tempOffset)];
            }
            else {
                NSUInteger lastOffset = [[_pageArray lastObject] integerValue];
                if (lastOffset != afterOffset) {
                    [_pageArray addObject:@(afterOffset + tempOffset)];
                }
            }
            break;
        }
        
        [_pageArray addObject:@(afterOffset + tempOffset)];
        
        CTFrameRef frame = CTFramesetterCreateFrame(afterFrameSetter, CFRangeMake(afterInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        if ((range.location + range.length) != afterAttributedStr.length) {
            afterOffset += range.length;
            afterInnerOffset += range.length;
        } else {
            // 已经分完，提示跳出循环
            hasAfterPage = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(afterFrameSetter);
    
    
    NSLog(@"self.pageArray = %@", self.pageArray);
    
    
    
    
    
    //初始化设置pageVC
    if (!self.pageVC) {
        self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        self.pageVC.delegate = self;
        self.pageVC.dataSource = self;
        self.pageVC.view.frame = self.view.bounds;
        [self addChildViewController:self.pageVC];
        [self.view addSubview:self.pageVC.view];
    }
    
    for (NSInteger i = 0; i < self.pageArray.count ; i ++) {
        NSNumber* num = [self.pageArray objectAtIndex:i];
        if (num.integerValue == self.currentRange.location) {
            self.currentPage = i;
            break;
        }
    }
    
    if (self.currentPage == self.pageArray.count - 1) {
        NSInteger tempCurrent = [[self.pageArray objectAtIndex:self.currentPage] integerValue];
        self.currentRange = NSMakeRange(tempCurrent, text.length - tempCurrent);
    }else {
        NSInteger tempNext = [[self.pageArray objectAtIndex:self.currentPage + 1] integerValue];
        NSInteger tempCurrent = [[self.pageArray objectAtIndex:self.currentPage] integerValue];
        self.currentRange = NSMakeRange(tempCurrent, tempNext - tempCurrent);
    }
    self.pageChange = self.currentPage;
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[text substringWithRange:self.currentRange]];//得到第一页
    NSArray *viewControllers = [NSArray arrayWithObject:contentVC];
    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    return;
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
