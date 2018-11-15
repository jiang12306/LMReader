//
//  LMBookCatalogViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/17.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookCatalogViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMCatalogTableViewCell.h"
#import "LMReaderBook.h"
#import "TFHpple.h"
#import "LMTool.h"
#import "LMReaderBookViewController.h"
#import "LMBaseNavigationController.h"

@interface LMBookCatalogViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, assign) BOOL isDecend;/**<倒序，取角标用*/

@property (nonatomic, copy) NSArray* parseArray;/**<新解析方式下 UrlReadParse元素数组*/

@property (nonatomic, strong) UIView* referenceView;
@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanY;
@property (nonatomic, assign) BOOL isPan;

@end

@implementation LMBookCatalogViewController

static NSString* cellIdentifier = @"cellIdentifier";

-(instancetype)init {
    self = [super init];
    if (self) {
        self.dataArray = [NSMutableArray array];
        self.parseArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.bookNameStr != nil && self.bookNameStr.length > 0) {
        self.title = self.bookNameStr;
    }else {
        self.title = @"目录";
    }
    self.isDecend = NO;
    
    if (self.fromWhich == 2) {//从书籍详情界面过来
        
        [self loadBookCatalogList];
        
    }else {
        if (self.dataArray.count > 0) {
            //延迟时间加载，否则由于tableView数据量大容易界面延迟push
            [self showNetworkLoadingView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1), dispatch_get_main_queue(), ^{
                
                [self setupTableView];
                
                [self hideNetworkLoadingView];
            });
        }else {
            [self loadBookCatalogList];
        }
    }
}

-(void)loadBookCatalogList {
    [self showNetworkLoadingView];
    __weak LMBookCatalogViewController* weakSelf = self;
    
    BookChapterReqBuilder* builder = [BookChapterReq builder];
    [builder setBookId:self.bookId];
    BookChapterReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 7) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookChapterRes* res = [BookChapterRes parseFromData:apiRes.body];
                    NSArray* arr = res.chapters;
                    if (arr != nil && arr.count > 0) {
                        if (weakSelf.dataArray.count > 0) {
                            [weakSelf.dataArray removeAllObjects];
                        }
                        for (NSInteger i = 0; i < arr.count; i ++) {
                            Chapter* tempChapter = [arr objectAtIndex:i];
                            
                            LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                            
                            [weakSelf.dataArray addObject:bookChapter];
                        }
                        
                        weakSelf.isNew = NO;
                        if (weakSelf.tableView != nil) {
                            [weakSelf.tableView reloadData];
                        }else {
                            [weakSelf setupTableView];
                        }
                        
                        [weakSelf hideNetworkLoadingView];
                        
                    }else {
                        weakSelf.isNew = YES;
                        self.parseArray = res.book.parses;
                        if (self.parseArray.count == 0) {
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"获取失败"];
                            return;
                        }else {
                            [weakSelf.dataArray removeAllObjects];
                        }
                        
                        UrlReadParse* parse = [self.parseArray firstObject];
                        
                        //章节列表
                        [weakSelf initLoadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                            [weakSelf hideNetworkLoadingView];
                            
                            [weakSelf.dataArray addObjectsFromArray:listArray];
                            
                            if (weakSelf.tableView != nil) {
                                [weakSelf.tableView reloadData];
                            }else {
                                [weakSelf setupTableView];
                            }
                            
                        } failureBlock:^(NSError *error) {
                            [weakSelf hideNetworkLoadingView];
                            [weakSelf showMBProgressHUDWithText:@"获取失败"];
                        }];
                    }
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf.tableView stopRefresh];
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

//新解析方式 加载章节列表
-(void)initLoadNewParseBookChaptersWithUrlReadParse:(UrlReadParse* )parse successBlock:(void (^) (NSArray* listArray))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    [self showNetworkLoadingView];
    __weak LMBookCatalogViewController* weakSelf = self;
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
                bookChapter.sourceId = parse.source.id;
                [listArr addObject:bookChapter];
            }
            if (listArr.count > 0) {
                successBlock(listArr);
                //保存新解析方式下章节列表
                [LMTool archiveNewParseBookCatalogListWithBookId:weakSelf.bookId catalogList:listArr];
            }else {
                failureBlock(nil);
            }
        } @catch (NSException *exception) {
            failureBlock(nil);
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        failureBlock(nil);
    }];
}

//加载视图
-(void)setupTableView {
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    [self.view addSubview:headerView];
    
    UIButton* rangeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 40, 20, 40, 20)];
    rangeBtn.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    rangeBtn.layer.cornerRadius = 2;
    rangeBtn.layer.masksToBounds = YES;
    rangeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rangeBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
    [rangeBtn setTitle:@"倒序" forState:UIControlStateNormal];
    [rangeBtn setTitle:@"正序" forState:UIControlStateSelected];
    rangeBtn.selected = NO;
    [rangeBtn addTarget:self action:@selector(clickedRangeAscendButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:rangeBtn];
    
    UILabel* cataLab = [[UILabel alloc]initWithFrame:CGRectMake(20, rangeBtn.frame.origin.y, 40, 20)];
    cataLab.font = [UIFont systemFontOfSize:18];
    cataLab.text = @"目录";
    [headerView addSubview:cataLab];
    
    UILabel* cataCountLab = [[UILabel alloc]initWithFrame:CGRectMake(cataLab.frame.origin.x + cataLab.frame.size.width + 10, rangeBtn.frame.origin.y, rangeBtn.frame.origin.x - cataLab.frame.origin.x - cataLab.frame.size.width - 20 * 2, 20)];
    cataCountLab.font = [UIFont systemFontOfSize:15];
    cataCountLab.text = [NSString stringWithFormat:@"共%ld章", self.dataArray.count];
    cataCountLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
    [headerView addSubview:cataCountLab];
    
//    CGFloat naviHeight = 20 + 44;
//    if ([LMTool isBangsScreen]) {
//        naviHeight = 44 + 44;
//    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, headerView.frame.origin.y + headerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - headerView.frame.size.height) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMCatalogTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    if (self.fromWhich == 2) {//从书籍详情界面过来
        [self.tableView setupNoMoreData];
    }else {
        [self.tableView setupNoRefreshData];
        [self.tableView setupNoMoreData];
    }
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.tableView];
    
    self.referenceView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 30, self.tableView.frame.origin.y, 30, 30)];
    self.referenceView.backgroundColor = [UIColor clearColor];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanReferenceView:)];
    self.panGestureRecognizer.delegate = self;
    [self.referenceView addGestureRecognizer:self.panGestureRecognizer];
    [self.view insertSubview:self.referenceView aboveSubview:self.tableView];
    
    UIView* bgCatalogView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, self.referenceView.frame.size.width - 10, self.referenceView.frame.size.height)];
    bgCatalogView.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    bgCatalogView.layer.cornerRadius = 1;
    bgCatalogView.layer.masksToBounds = YES;
    [self.referenceView addSubview:bgCatalogView];
    
    UIImageView* catalogIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, bgCatalogView.frame.size.width - 10, bgCatalogView.frame.size.height - 10)];
    catalogIV.tintColor = [UIColor colorWithRed:130.f/255 green:130.f/255 blue:130.f/255 alpha:1];
    UIImage* tempImg = [UIImage imageNamed:@"catalog_Index"];
    catalogIV.image = [tempImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    catalogIV.contentMode = UIViewContentModeScaleAspectFit;
    [bgCatalogView addSubview:catalogIV];
    
    //
    if (self.fromWhich == 2) {
        
    }else {
        [self scrollToCurrentRow];
    }
}

//KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:@"contentOffset"]) {
        if (self.isPan) {
            return;
        }
        CGRect startFrame = self.referenceView.frame;
        CGFloat contentOffsetY = self.tableView.contentOffset.y;
        CGFloat contentSizeHeight = self.tableView.contentSize.height;
        
        CGFloat topViewHeight = 60;
        CGFloat bottomHeight = startFrame.size.height;
        if ([LMTool isBangsScreen]) {
            bottomHeight += 44;
        }
        CGFloat endY = self.view.frame.size.height - bottomHeight;
        CGFloat maxViewHeight = self.tableView.frame.size.height - bottomHeight;
        CGFloat startY = topViewHeight + contentOffsetY / contentSizeHeight * maxViewHeight;
        if (startY < topViewHeight) {
            startY = topViewHeight;
        }else if (startY > endY) {
            startY = endY;
        }
        startFrame.origin.y = startY;
        self.referenceView.frame = startFrame;
    }
}

//拖拽右侧滑块
-(void)didPanReferenceView:(UIPanGestureRecognizer* )panGR {
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.isPan = YES;
        self.startPanY = [panGR locationInView:self.referenceView].y;
    }else if (panGR.state == UIGestureRecognizerStateChanged) {
        CGRect startFrame = self.referenceView.frame;
        startFrame.origin.y = startFrame.origin.y + [panGR locationInView:self.referenceView].y - self.startPanY;
        
        CGFloat topViewHeight = 60;
        CGFloat bottomHeight = startFrame.size.height;
        if ([LMTool isBangsScreen]) {
            bottomHeight += 44;
        }
        CGFloat endY = self.view.frame.size.height - bottomHeight;
        CGFloat maxViewHeight = self.tableView.frame.size.height - bottomHeight;
        if (startFrame.origin.y < topViewHeight) {
            startFrame.origin.y = topViewHeight;
        }else if (startFrame.origin.y > endY) {
            startFrame.origin.y = endY;
        }
        
        self.referenceView.frame = startFrame;
        CGFloat pointY = (self.referenceView.frame.origin.y - topViewHeight) / maxViewHeight * (self.tableView.contentSize.height - self.tableView.frame.size.height);
        if (pointY > self.tableView.contentSize.height - self.tableView.frame.size.height) {
            pointY = self.tableView.contentSize.height - self.tableView.frame.size.height;
        }
//        NSLog(@"pointY = %f,   contentHeight = %f", pointY, self.tableView.contentSize.height);
        if (self.dataArray.count > 0) {
            self.tableView.contentOffset = CGPointMake(0, pointY);
        }
    }else if (panGR.state == UIGestureRecognizerStateEnded) {
        self.isPan = NO;
    }
}

//
-(void)clickedRangeAscendButton:(UIButton* )sender {
    if (self.dataArray.count == 0) {
        return;
    }
    if (sender.selected == NO) {
        sender.selected = YES;
        self.isDecend = YES;
    }else {
        sender.selected = NO;
        self.isDecend = NO;
    }
    NSArray* arr = [NSArray arrayWithArray:self.dataArray];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[[arr reverseObjectEnumerator]allObjects]];
    [self.tableView reloadData];
    
    [self scrollToTop];
}

//滚动至顶部
-(void)scrollToTop {
    if (self.dataArray.count == 0) {
        return;
    }
    NSInteger index = self.chapterIndex;
    if (self.isDecend) {
        index = 0;
    }
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//滚动至当前章节
-(void)scrollToCurrentRow {
    if (self.dataArray.count == 0) {
        return;
    }
//    if (self.fromWhich == 2) {
//        return;
//    }
    
    NSInteger index = self.chapterIndex;
    if (self.isDecend) {
        index = self.dataArray.count - self.chapterIndex - 1;
    }
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
        tempLab.font = [UIFont systemFontOfSize:15];
        tempLab.lineBreakMode = NSLineBreakByCharWrapping;
        tempLab.numberOfLines = 0;
        
        
        LMReaderBookChapter* chapter = [self.dataArray objectAtIndex:indexPath.row];
        NSString* name = [NSString stringWithFormat:@"%@", chapter.title];
        tempLab.text = name;
        CGSize tempLabSize = [tempLab sizeThatFits:CGSizeMake(self.view.frame.size.width - 20 * 2, 9999)];
        if (tempLabSize.height < 20) {
            tempLabSize.height = 20;
        }
        return tempLabSize.height + 20 * 2;
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMCatalogTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMCatalogTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showArrowImageView:NO];
    [cell showLineView:NO];
    
    @try {
        LMReaderBookChapter* chapter = [self.dataArray objectAtIndex:indexPath.row];
        NSString* name = [NSString stringWithFormat:@"%@", chapter.title];
        
        BOOL isClicked = NO;
        if (self.fromWhich == 2) {
            
        }else {
            if (self.isDecend) {
                NSInteger index = self.dataArray.count - self.chapterIndex - 1;
                if (indexPath.row == index) {
                    isClicked = YES;
                }
            }else {
                if (indexPath.row == self.chapterIndex) {
                    isClicked = YES;
                }
            }
        }
        
        [cell setContentWithNameStr:name isClicked:isClicked];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    @try {
        if (self.fromWhich == 2) {//从书籍详情界面过来
            NSMutableArray* blockArr = [NSMutableArray array];
            NSArray* arr = [NSArray arrayWithArray:self.dataArray];
            
            NSInteger index = indexPath.row;
            if (self.isDecend) {
                index = self.dataArray.count - index - 1;
                if (index < 0 || index > self.dataArray.count - 1) {//谨防数组越界
                    index = 0;
                }
                [blockArr addObjectsFromArray:[[arr reverseObjectEnumerator]allObjects]];
            }else {
                [blockArr addObjectsFromArray:arr];
            }
            
            LMReaderBookChapter* currentChapter = [self.dataArray objectAtIndex:indexPath.row];
            //    currentChapter.sourceId =//在LMReaderBookChapter转换时已经赋值过
            currentChapter.offset = 0;
            
            LMReaderBook* readerBook = [[LMReaderBook alloc]init];
            readerBook.bookId = self.bookId;
            readerBook.bookName = self.bookNameStr;
            readerBook.isNew = self.isNew;
            readerBook.chaptersArr = [NSArray arrayWithArray:blockArr];
            readerBook.currentChapter = currentChapter;
//            readerBook.progress =
//            readerBook.parseArr =
//            readerBook.currentParseIndex = 0;
            LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
            readerBookVC.bookId = self.bookId;
            readerBookVC.bookName = self.bookNameStr;
            readerBookVC.readerBook = readerBook;
            LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
            [self presentViewController:bookNavi animated:YES completion:nil];
        }else {
            BOOL didChange = YES;
            if (self.isDecend) {
                NSInteger index = self.dataArray.count - self.chapterIndex - 1;
                if (indexPath.row == index) {
                    didChange = NO;
                }
            }else {
                if (indexPath.row == self.chapterIndex) {
                    didChange = NO;
                }
            }
            if (self.callBack) {
                NSInteger index = indexPath.row;
                if (self.isDecend) {
                    index = self.dataArray.count - index - 1;
                    if (index < 0 || index > self.dataArray.count - 1) {//谨防数组越界
                        index = 0;
                    }
                }
                self.callBack(didChange, index);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    if (self.fromWhich == 2) {
        if (self.dataArray.count) {
            
            [self loadBookCatalogList];
            return;
        }
    }else {
        
    }
    [self.tableView stopRefresh];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    [self.tableView stopLoadMoreData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentOffset" context:nil];
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
