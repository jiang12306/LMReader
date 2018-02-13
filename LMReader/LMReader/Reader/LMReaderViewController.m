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

@interface LMReaderViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, LMFontViewDelegate>

@property (nonatomic, strong) UIPageViewController* pageVC;
@property (nonatomic, strong) LMFontView* fontView;//字体 视图
@property (nonatomic, strong) NSMutableArray* toolTitleArray;
@property (nonatomic, strong) Chapter* currentChapter;//当前章节
@property (nonatomic, strong) NSMutableArray* sourceArray;//所有源头
@property (nonatomic, strong) UILabel* contentLab;//计算高度用
@property (nonatomic, assign) NSRange currentRange;//当前文本位置
@property (nonatomic, assign) NSInteger perPage;//每页字数
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) LMReadModel readModel;

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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:@"LMReaderConfig.plist"];
    NSMutableDictionary* configDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    self.fontSize = [[configDic objectForKey:@"readerFont"] floatValue];
    NSInteger modelInteger = [[configDic objectForKey:@"readerModelDay"] integerValue];
    if (modelInteger) {//白天模式
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
    
//    self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
//    self.pageVC.delegate = self;
//    self.pageVC.dataSource = self;
//    LMBaseViewController *initialViewController = [self viewControllerAtIndex:0];//得到第一页
//    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
//    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
//    self.pageVC.view.frame = self.view.bounds;
//    [self addChildViewController:self.pageVC];
//    [self.view addSubview:self.pageVC.view];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
    
    //初始化
    self.currentRange = NSMakeRange(0, 0);
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
}

//换源
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    LMChangeSourceViewController* sourceVC = [[LMChangeSourceViewController alloc]init];
    [self presentViewController:sourceVC animated:YES completion:nil];
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
    NSString* text = self.currentChapter.chapterContent;
    if (self.currentRange.location <= 0) {//起始位置为0，则为第一页
        //To Do....
        return nil;
    }
    NSRange beforeRange;
    NSString* beforeText;
    
    if (self.currentRange.location <= self.perPage) {//剩余文本小于一页，全部显示
        beforeRange = NSMakeRange(0, self.currentRange.location);
        self.currentRange = beforeRange;//ok
    }else {
        beforeRange = NSMakeRange(self.currentRange.location - self.perPage, self.perPage);
        beforeText = [text substringWithRange:beforeRange];
        CGFloat beforeHeight = [self caculateTextHeightWithString:beforeText fontSize:self.fontSize];
        if (beforeHeight == contentRect.size.height){
            self.currentRange = beforeRange;
            self.perPage = self.currentRange.length;
        }else if (beforeHeight < contentRect.size.height) {//能显示
            for (NSInteger i = beforeRange.location; i >= 0; i --) {
                beforeRange = NSMakeRange(i, self.currentRange.location - i);
                beforeText = [text substringWithRange:beforeRange];
                beforeHeight = [self caculateTextHeightWithString:beforeText fontSize:self.fontSize];
                if (beforeHeight == contentRect.size.height) {
                    self.currentRange = beforeRange;
                    self.perPage = self.currentRange.length;
                }else if (beforeHeight > contentRect.size.height) {//该页能显示下
                    self.currentRange = NSMakeRange(beforeRange.location + 1, beforeRange.length - 1);
                    self.perPage = self.currentRange.length;
                    break;
                }else {
                    if (i == 0) {
                        self.currentRange = NSMakeRange(0, beforeRange.length);
                        self.perPage = self.currentRange.length;
                        break;
                    }
                }
            }
        }else {
            for (NSInteger i = beforeRange.location; i <= beforeRange.location + beforeRange.length; i ++) {
                beforeRange = NSMakeRange(i, self.currentRange.location - i);
                beforeText = [text substringWithRange:beforeRange];
                beforeHeight = [self caculateTextHeightWithString:beforeText fontSize:self.fontSize];
                if (beforeHeight <= contentRect.size.height) {//该页能显示下
                    self.currentRange = beforeRange;
                    self.perPage =  self.currentRange.length;
                    break;
                }
            }
        }
    }
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[text substringWithRange:self.currentRange]];
    return contentVC;
}

#pragma mark 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSString* text = self.currentChapter.chapterContent;
    NSInteger totalLength = text.length;
    if (self.currentRange.location + self.currentRange.length >= totalLength) {//已经至最后一页，加载下一章节
        //To Do....
        return nil;
    }
    NSInteger referLength = self.currentRange.location + self.currentRange.length + self.perPage;//预估下一页文本长度
    NSRange nextRange = NSMakeRange(self.currentRange.location + self.currentRange.length, self.perPage);
    if (referLength >= totalLength) {//剩余文本小于一页，全部显示
        nextRange = NSMakeRange(self.currentRange.location + self.currentRange.length, totalLength - self.currentRange.location - self.currentRange.length);
        self.currentRange = nextRange;
    }
    NSString* nextText = [text substringWithRange:nextRange];
    CGFloat nextHeight = [self caculateTextHeightWithString:nextText fontSize:self.fontSize];
    if (nextHeight == contentRect.size.height) {
        self.currentRange = nextRange;
        self.perPage = self.currentRange.length;
    }else if (nextHeight < contentRect.size.height) {//能显示下
        for (NSInteger i = nextRange.location + nextRange.length; i <= totalLength; i ++) {
            nextRange = NSMakeRange(nextRange.location, i - nextRange.location);
            nextText = [text substringWithRange:nextRange];
            nextHeight = [self caculateTextHeightWithString:nextText fontSize:self.fontSize];
            if (nextHeight == contentRect.size.height) {//该页能显示下
                self.currentRange = nextRange;
                self.perPage = self.currentRange.length;
                break;
            }else if (nextHeight > contentRect.size.height) {
                self.currentRange = NSMakeRange(nextRange.location, nextRange.length - 1);
                self.perPage = self.currentRange.length;
                break;
            }
        }
    }else {
        for (NSInteger i = nextRange.location + nextRange.length; i > nextRange.location; i --) {
            nextRange = NSMakeRange(nextRange.location, i - nextRange.location);
            nextText = [text substringWithRange:nextRange];
            nextHeight = [self caculateTextHeightWithString:nextText fontSize:self.fontSize];
            if (nextHeight <= contentRect.size.height) {//该页能显示下
                self.currentRange = nextRange;
                self.perPage = self.currentRange.length;
                break;
            }
        }
    }
    
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[text substringWithRange:self.currentRange]];
    return contentVC;
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
    NSUInteger textLength = [text length];//总字数
    CGFloat totalTextHeight = [self caculateTextHeightWithString:text fontSize:fontSize];
    if (totalTextHeight <= contentRect.size.height) {//只有一页
        self.currentRange = NSMakeRange(0, textLength);
    }else {
        NSInteger totalPages = ceilf(totalTextHeight/contentRect.size.height);//理论上 总页数
        self.perPage = textLength/totalPages;//理论上每页 字数
        NSRange perRange = NSMakeRange(self.currentRange.location, self.perPage);
        NSString* perStr = [text substringWithRange:perRange];
        CGFloat perHeight = [self caculateTextHeightWithString:perStr fontSize:fontSize];
        if (perHeight == contentRect.size.height) {
            self.currentRange = perRange;
            self.perPage = self.currentRange.length;
        }else if (perHeight < contentRect.size.height) {//该页能显示下
            for (NSInteger i = perRange.location + perRange.length; i < textLength; i ++) {
                perRange = NSMakeRange(perRange.location, i - perRange.location);
                perStr = [text substringWithRange:perRange];
                perHeight = [self caculateTextHeightWithString:perStr fontSize:fontSize];
                if (perHeight == contentRect.size.height) {//该页能显示下
                    self.currentRange = NSMakeRange(perRange.location, perRange.length);
                    self.perPage = self.currentRange.length;
                    break;
                }else if (perHeight > contentRect.size.height) {
                    self.currentRange = NSMakeRange(perRange.location, perRange.length - 1);
                    self.perPage = self.currentRange.length;
                    break;
                }
            }
        }else {//该页显示不下
            for (NSInteger i = perRange.location + perRange.length; i > perRange.location; i --) {
                perRange = NSMakeRange(perRange.location, i - perRange.location);
                perStr = [text substringWithRange:perRange];
                perHeight = [self caculateTextHeightWithString:perStr fontSize:fontSize];
                if (perHeight <= contentRect.size.height) {//该页能显示下
                    self.currentRange = perRange;
                    self.perPage = self.currentRange.length;
                    break;
                }
            }
        }
    }
    //初始化设置pageVC
    if (!self.pageVC) {
        self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        self.pageVC.delegate = self;
        self.pageVC.dataSource = self;
        self.pageVC.view.frame = self.view.bounds;
        [self addChildViewController:self.pageVC];
        [self.view addSubview:self.pageVC.view];
    }
    LMContentViewController* contentVC = [[LMContentViewController alloc]initWithReadModel:self.readModel fontSize:self.fontSize content:[text substringWithRange:self.currentRange]];//得到第一页
    NSArray *viewControllers = [NSArray arrayWithObject:contentVC];
    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

//根据文本计算高度
-(CGFloat )caculateTextHeightWithString:(NSString* )textStr fontSize:(CGFloat )fontSize {
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:contentRect];
        self.contentLab.numberOfLines = 0;
        self.contentLab.lineBreakMode = NSLineBreakByCharWrapping;
    }
    self.contentLab.font = [UIFont systemFontOfSize:fontSize];
    self.contentLab.text = textStr;
    CGSize textSize = [self.contentLab sizeThatFits:CGSizeMake(self.contentLab.frame.size.width, CGFLOAT_MAX)];
    return textSize.height;
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
