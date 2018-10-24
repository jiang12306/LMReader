//
//  LMBookDetailCatalogViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/14.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookDetailCatalogViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMCatalogTableViewCell.h"
#import "LMReaderBook.h"
#import "LMTool.h"
#import "TFHpple.h"
#import "LMBaseNavigationController.h"
#import "LMReaderBookViewController.h"
@interface LMBookDetailCatalogViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, assign) BOOL isDecend;/**<倒序，取角标用*/
@property (nonatomic, strong) NSMutableArray* dataArray;//目录 章节列表
@property (nonatomic, assign) BOOL isNewParse;/**<是否是新解析方式*/
@property (nonatomic, copy) NSArray* parseArray;/**<新解析方式下 UrlReadParse元素数组*/

@property (nonatomic, strong) UIView* referenceView;
@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanY;

@end

@implementation LMBookDetailCatalogViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 44;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"目录";
    self.isDecend = NO;
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    UIButton* rightItemBtn = [[UIButton alloc]initWithFrame:rightView.frame];
    [rightItemBtn setImage:[UIImage imageNamed:@"catalog_Decend"] forState:UIControlStateNormal];
    [rightItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 12.5, 0, 12.5)];
    [rightItemBtn addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    rightItemBtn.selected = NO;
    [rightView addSubview:rightItemBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMCatalogTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.tableView setupNoMoreData];
    [self.view addSubview:self.tableView];
    
    self.referenceView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 30, self.tableView.frame.origin.y, 30, 30)];
    self.referenceView.backgroundColor = [UIColor colorWithRed:220.f/255 green:220.f/255 blue:220.f/255 alpha:1];
    self.referenceView.layer.cornerRadius = 1;
    self.referenceView.layer.masksToBounds = YES;
    self.referenceView.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.referenceView.layer.borderWidth = 0.5f;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanReferenceView:)];
    self.panGestureRecognizer.delegate = self;
    [self.referenceView addGestureRecognizer:self.panGestureRecognizer];
    [self.view insertSubview:self.referenceView aboveSubview:self.tableView];
    UIImageView* catalogIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.referenceView.frame.size.height - 10, self.referenceView.frame.size.height - 10)];
    catalogIV.tintColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1];
    UIImage* tempImg = [UIImage imageNamed:@"catalog_Index"];
    catalogIV.image = [tempImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.referenceView addSubview:catalogIV];
    
    self.dataArray = [NSMutableArray array];
    
    //
    [self loadCatalogList];
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGRect startFrame = self.referenceView.frame;
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat contentSizeHeight = self.tableView.contentSize.height;
        
        CGFloat bottomHeight = startFrame.size.height;
        if ([LMTool isBangsScreen]) {
            bottomHeight += 44;
        }
        CGFloat maxViewHeight = self.view.frame.size.height - bottomHeight;
        CGFloat startY = contentOffsetY / contentSizeHeight * maxViewHeight;
        if (startY < 0) {
            startY = 0;
        }else if (startY > maxViewHeight) {
            startY = maxViewHeight;
        }
        startFrame.origin.y = startY;
        self.referenceView.frame = startFrame;
    }
}

-(void)didPanReferenceView:(UIPanGestureRecognizer* )panGR {
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.startPanY = [panGR locationInView:self.referenceView].y;
    }else if (panGR.state == UIGestureRecognizerStateChanged) {
        CGRect startFrame = self.referenceView.frame;
        startFrame.origin.y = startFrame.origin.y + [panGR locationInView:self.referenceView].y - self.startPanY;
        CGFloat bottomHeight = startFrame.size.height;
        if ([LMTool isBangsScreen]) {
            bottomHeight += 44;
        }
        CGFloat maxViewHeight = self.view.frame.size.height - bottomHeight;
        if (startFrame.origin.y < 0) {
            startFrame.origin.y = 0;
        }else if (startFrame.origin.y > maxViewHeight) {
            startFrame.origin.y = maxViewHeight;
        }
        
        self.referenceView.frame = startFrame;
        CGFloat pointY = self.referenceView.frame.origin.y / maxViewHeight * self.tableView.contentSize.height;
        if (pointY > self.tableView.contentSize.height) {
            pointY = self.tableView.contentSize.height;
        }
        if (self.dataArray.count > 0) {
            self.tableView.contentOffset = CGPointMake(0, pointY);
        }
    }
}

//
-(void)clickedRightBarButtonItem:(UIButton* )sender {
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

-(void)loadCatalogList {
    [self showNetworkLoadingView];
    __weak LMBookDetailCatalogViewController* weakSelf = self;
    
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
                        [weakSelf hideNetworkLoadingView];
                        [weakSelf.tableView reloadData];
                        weakSelf.isNewParse = NO;
                    }else {
                        weakSelf.isNewParse = YES;
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
                            
                            [weakSelf.tableView reloadData];
                            
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
    __weak LMBookDetailCatalogViewController* weakSelf = self;
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

//滚动至顶部
-(void)scrollToTop {
    if (self.dataArray.count == 0) {
        return;
    }
    NSInteger index = 0;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMCatalogTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMCatalogTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    LMReaderBookChapter* chapter = [self.dataArray objectAtIndex:indexPath.row];
    NSString* num = @"";//[NSString stringWithFormat:@"%ld", chapter.chapterNo];
    NSString* name = [NSString stringWithFormat:@"%@", chapter.title];
    NSString* time = @"";
    NSInteger lastRow = self.dataArray.count - 1;
    if (self.isDecend) {
        lastRow = 0;
    }
//    if (indexPath.row == lastRow) {
//        time = [LMTool convertTimeStampToTime:chapter.updateTime];
//    }
    
    BOOL isClicked = NO;
    [cell setContentWithNumberStr:num nameStr:name timeStr:time isClicked:isClicked];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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
    readerBook.bookName = self.bookName;
    readerBook.isNew = self.isNewParse;
    readerBook.chaptersArr = [NSArray arrayWithArray:blockArr];
    readerBook.currentChapter = currentChapter;
//    readerBook.progress =
//    readerBook.parseArr =
//    readerBook.currentParseIndex = 0;
    
    LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
    readerBookVC.bookId = self.bookId;
    readerBookVC.bookName = self.bookName;
    readerBookVC.readerBook = readerBook;
    LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
    [self presentViewController:bookNavi animated:YES completion:nil];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    if (self.dataArray.count) {
        
        [self loadCatalogList];
        
        return;
    }
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    //    [self.tableView stopLoadMoreData];
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
