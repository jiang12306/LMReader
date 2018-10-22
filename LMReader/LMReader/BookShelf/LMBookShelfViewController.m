//
//  LMBookShelfViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfViewController.h"
#import "LMBookShelfTableViewCell.h"
#import "LMBaseNavigationController.h"
#import "LMBaseRefreshTableView.h"
#import "LMSearchViewController.h"
#import "LMDatabaseTool.h"
#import "LMTool.h"
#import "LMRootViewController.h"
#import "LMLeftItemView.h"
#import "LMRightItemView.h"
#import "LMBookShelfDetailAlertView.h"
#import "LMBookDetailViewController.h"
#import "LMDownloadBookView.h"
#import "LMReaderBookViewController.h"
#import "LMBookShelfModel.h"
#import "LMBaseBookTableViewCell.h"
#import "GDTNativeExpressAdView.h"
#import "GDTNativeExpressAd.h"
#import "LMBookShelfAdView.h"
#import "LMLaunchDetailViewController.h"
#import <BaiduMobAdSDK/BaiduMobAdView.h>

@interface LMBookShelfViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMBookShelfTableViewCellDelegate , GDTNativeExpressAdDelegete, BaiduMobAdViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* footerView;//方形+视图
@property (nonatomic, strong) UIButton* rectAddBtn;//方形+按钮
@property (nonatomic, strong) UIButton* cycleAddBtn;//圆形+按钮
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中
@property (nonatomic, strong) LMDownloadBookView* downloadView;

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;//
@property (nonatomic, strong) GDTNativeExpressAdView* adView;//

@property (nonatomic, strong) BaiduMobAdView* sharedAdView;/**<百度广告*/

@end

@implementation LMBookShelfViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat spaceX = 10;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //防止iOS11 刘海屏tabBar下移34
    UITabBarController* tabBarController = self.tabBarController;
    if (tabBarController) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat tabBarHeight = 49;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
        }
        tabBarController.tabBar.frame = CGRectMake(0, screenRect.size.height - tabBarHeight, screenRect.size.width, tabBarHeight);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LMLeftItemView* leftView = [[LMLeftItemView alloc]initWithFrame:CGRectMake(0, 0, 80, 25)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    __weak LMBookShelfViewController* weakSelf = self;
    
    LMRightItemView* rightView = [[LMRightItemView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    rightView.callBlock = ^(BOOL clicked) {
        if (clicked) {
            LMSearchViewController* searchVC = [[LMSearchViewController alloc]init];
            [weakSelf.navigationController pushViewController:searchVC animated:YES];
        }
    };
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }else {
        
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBookShelfTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.tableFooterView = self.footerView;
    
    self.page = 0;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    //初始化数据
    [self loadDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
    
    //其它地方加书之后通知刷新界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBookShelfViewController:) name:@"refreshBookShelfViewController" object:nil];
}

-(void)refreshBookShelfViewController:(NSNotification* )notify {
    [self.tableView startRefresh];
}

//方形+视图
-(UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        self.rectAddBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, 15, self.view.frame.size.width - spaceX * 2, 40)];
        self.rectAddBtn.backgroundColor = [UIColor colorWithRed:233/255.f green:233/255.f blue:233/255.f alpha:1];
        self.rectAddBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.rectAddBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.rectAddBtn setTitle:@"+ 添加图书" forState:UIControlStateNormal];
        [self.rectAddBtn addTarget:self action:@selector(clickedAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:self.rectAddBtn];
        
        self.rectAddBtn.hidden = YES;
    }
    return _footerView;
}

//圆形+按钮
-(UIButton *)cycleAddBtn {
    if (!_cycleAddBtn) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat btnWidth = 50;
        CGFloat tabBarHeight = 49;
        CGFloat naviHeight = 64;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
            naviHeight = 88;
        }
        _cycleAddBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnWidth)];
        _cycleAddBtn.backgroundColor = [UIColor blackColor];
        _cycleAddBtn.layer.cornerRadius = btnWidth / 2;
        _cycleAddBtn.layer.masksToBounds = YES;
        [_cycleAddBtn setImage:[UIImage imageNamed:@"cycleAddButton"] forState:UIControlStateNormal];
        [_cycleAddBtn addTarget:self action:@selector(clickedAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_cycleAddBtn aboveSubview:self.tableView];
        _cycleAddBtn.center = CGPointMake(screenRect.size.width - 10 - btnWidth / 2, screenRect.size.height - 15 - tabBarHeight - naviHeight - btnWidth / 2);
    }
    return _cycleAddBtn;
}

//+图书
-(void)clickedAddButton:(UIButton* )sender {
    //跳转至 书城 页面
    [[LMRootViewController sharedRootViewController] setCurrentViewControllerIndex:2];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return baseBookCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMBookShelfTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBookShelfTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.delegate = self;
    
    LMBookShelfModel* model = [self.dataArray objectAtIndex:indexPath.row];
    [cell setupBookShelfModel:model];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    LMBookShelfTableViewCell* clickedCell = (LMBookShelfTableViewCell* )[self.tableView cellForRowAtIndexPath:indexPath];
    [clickedCell showUpsideAndDelete:NO animation:YES];
    
    LMBookShelfModel* model = [self.dataArray objectAtIndex:indexPath.row];
    model.markState = 0;
    
    UserBook* userBook = model.userBook;
    Book* book = userBook.book;
    
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    [tool clearNewestMarkWithBookId:book.bookId];
    
    __weak LMBookShelfViewController* weakSelf = self;
    
    LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
    readerBookVC.bookId = book.bookId;
    readerBookVC.bookName = book.name;
    
    readerBookVC.callBlock = ^(BOOL resetOrder) {
        
        if (weakSelf.dataArray != nil && weakSelf.dataArray.count > 1) {
            [weakSelf.dataArray removeObject:model];
            
            for (NSInteger i = 0; i < self.dataArray.count; i ++) {
                LMBookShelfModel* tempModel = [self.dataArray objectAtIndex:i];
                UserBook* tempUserBook = tempModel.userBook;
                if (tempUserBook.isTop <= userBook.isTop) {
                    [weakSelf.dataArray insertObject:model atIndex:i];
                    break;
                }
            }
        }
        
        [weakSelf.tableView reloadData];
    };
    
    LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
    [self presentViewController:bookNavi animated:YES completion:nil];
}

-(void)loadDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    if (self.isRefreshing) {
        return;
    }
    
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    //解压广告开关
    NSData* adData = [LMTool unArchiveAdvertisementSwitchData];
    if (adData != nil && ![adData isKindOfClass:[NSNull class]] && adData.length > 0) {
        InitSwitchRes* res = [InitSwitchRes parseFromData:adData];
        BOOL showHeaderAd = NO;
        NSInteger adType = 0;
        for (AdControl* subControl in res.adControl) {
            if (subControl.adlId == 2 && subControl.state == 1) {//显示顶部开关
                showHeaderAd = YES;
                
                adType = subControl.adPt;
                break;
            }
        }
        if (showHeaderAd) {
            if (adType == 1) {//自家开屏广告
                UIView* tempHeaderVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 54 + 20)];
                LMBookShelfAdView* adView = [[LMBookShelfAdView alloc]initWithFrame:CGRectMake(0, 0, tempHeaderVi.frame.size.width, tempHeaderVi.frame.size.height) imgFrame:CGRectMake(10, 10, 70, 54)];
                __weak LMBookShelfAdView* weakAdView = adView;
                adView.loadBlock = ^(BOOL loadSucceed) {
                    if (loadSucceed) {
                        [weakAdView startShow];
                        
                        self.tableView.tableHeaderView = tempHeaderVi;
                    }
                };
                adView.closeBlock = ^(BOOL didClose) {
                    if (didClose) {
                        UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
                        
                        self.tableView.tableHeaderView = headerView;
                    }
                };
                adView.clickBlock = ^(BOOL isBook, NSString * _Nonnull bookIdStr, NSString * _Nonnull urlStr) {
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
                };
                [tempHeaderVi addSubview:adView];
            }else if (adType == 2) {//百度广告
                UIView* tempHeaderVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 0.15)];
                
                if (self.sharedAdView) {
                    [self.sharedAdView removeFromSuperview];
                    self.sharedAdView.delegate = nil;
                    self.sharedAdView = nil;
                }
                //使用嵌入广告的方法实例。
                self.sharedAdView = [[BaiduMobAdView alloc] init];
                self.sharedAdView.AdUnitTag = @"5919989";
                self.sharedAdView.AdType = BaiduMobAdViewTypeBanner;
                self.sharedAdView.frame = CGRectMake(0, 0, tempHeaderVi.frame.size.width, tempHeaderVi.frame.size.height);
                [tempHeaderVi addSubview:self.sharedAdView];
                
                self.sharedAdView.delegate = self;
                [self.sharedAdView start];
                
                self.tableView.tableHeaderView = tempHeaderVi;
            }else {//广点通 开屏广告(adType == 0)
                self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:tencentGDTAPPID placementId:tencentGDTBookShelfPlacementID adSize:CGSizeMake(self.view.frame.size.width, 54 + 20)];//高度：图片70宽度除以广点通后台最小图片宽高比例数1.3+上下间距
                self.nativeExpressAd.delegate = self;
                [self.nativeExpressAd loadAd:1];
            }
        }
    }
    
    
    UserBookStoreReqBuilder* builder = [UserBookStoreReq builder];
    [builder setPage:(UInt32)page];
    UserBookStoreReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMBookShelfViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:3 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 3) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    UserBookStoreRes* res = [UserBookStoreRes parseFromData:apiRes.body];
                    
                    NSArray* arr = res.userBooks;
                    if (weakSelf.page == 0) {//第一页
                        [weakSelf.dataArray removeAllObjects];
                    }
                    if (arr.count > 0) {
                        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                        //存入数据库
                        [tool saveUserBooksWithArray:arr];
                        
                        NSArray* queryArr = [tool queryBookShelfUserBooksWithPage:weakSelf.page size:arr.count];
                        [weakSelf.dataArray addObjectsFromArray:queryArr];
                    }
                    //设置 添加图书 按钮
                    if (weakSelf.dataArray.count * baseBookCellHeight + weakSelf.tableView.tableHeaderView.frame.size.height < weakSelf.tableView.frame.size.height) {
                        weakSelf.rectAddBtn.hidden = NO;
                        weakSelf.cycleAddBtn.hidden = YES;
                    }else {
                        weakSelf.rectAddBtn.hidden = YES;
                        weakSelf.cycleAddBtn.hidden = NO;
                    }
                    
                    if (arr == nil || arr.count == 0) {//最后一页
                        weakSelf.isEnd = YES;
                        [weakSelf.tableView setupNoMoreData];
                        
                        //有些书本地有，服务端无。删除
                        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                        NSMutableArray* deleteArr = [NSMutableArray array];
                        for (LMBookShelfModel* model in weakSelf.dataArray) {
                            [deleteArr addObject:model.userBook];
                        }
                        [tool deleteLocalSurplusBooksWithArray:deleteArr];
                    }
                    weakSelf.page ++;
                    [weakSelf.tableView reloadData];
                }
            }
        } @catch (NSException *exception) {
            //取数据库 图书
            if (weakSelf.page == 0) {
                LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                NSArray* arr = [tool queryBookShelfUserBooksWithPage:0 size:0];
                if (arr != nil && arr.count > 0) {
                    [weakSelf.dataArray removeAllObjects];
                    [weakSelf.dataArray addObjectsFromArray:arr];
                    //设置 添加图书 按钮
                    if (weakSelf.dataArray.count * baseBookCellHeight + weakSelf.tableView.tableHeaderView.frame.size.height < weakSelf.tableView.frame.size.height) {
                        weakSelf.rectAddBtn.hidden = NO;
                        weakSelf.cycleAddBtn.hidden = YES;
                    }else {
                        weakSelf.rectAddBtn.hidden = YES;
                        weakSelf.cycleAddBtn.hidden = NO;
                    }
                    [weakSelf.tableView reloadData];
                }
            }
            
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            weakSelf.isRefreshing = NO;
            if (loadMore) {
                [weakSelf.tableView stopLoadMoreData];
            }else {
                [weakSelf.tableView stopRefresh];
            }
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        //取数据库 图书
        if (weakSelf.page == 0) {
            LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
            NSArray* arr = [tool queryBookShelfUserBooksWithPage:0 size:0];
            if (arr != nil && arr.count > 0) {
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:arr];
                //设置 添加图书 按钮
                if (weakSelf.dataArray.count * baseBookCellHeight + weakSelf.tableView.tableHeaderView.frame.size.height < weakSelf.tableView.frame.size.height) {
                    weakSelf.rectAddBtn.hidden = NO;
                    weakSelf.cycleAddBtn.hidden = YES;
                }else {
                    weakSelf.rectAddBtn.hidden = YES;
                    weakSelf.cycleAddBtn.hidden = NO;
                }
                [weakSelf.tableView reloadData];
            }
        }
        
        weakSelf.isRefreshing = NO;
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSInteger section = 0;
    NSInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < rows; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        LMBookShelfTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell showUpsideAndDelete:NO animation:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dataArray.count * baseBookCellHeight + self.tableView.tableHeaderView.frame.size.height < self.tableView.frame.size.height) {
        self.rectAddBtn.hidden = NO;
        self.cycleAddBtn.hidden = YES;
        return;
    }
    if (scrollView == self.tableView) {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
//        NSLog(@"offsetY = %f, height = %f, contentSize = %f, bottomOffset = %f", contentOffsetY, height, scrollView.contentSize.height, bottomOffset);
        if (bottomOffset <= height) {//滑至底部
            self.rectAddBtn.hidden = NO;
            self.cycleAddBtn.hidden = YES;
        }else {
            self.rectAddBtn.hidden = YES;
            self.cycleAddBtn.hidden = NO;
        }
    }
}

#pragma mark -LMBookShelfTableViewCellDelegate
-(void)didStartScrollCell:(LMBookShelfTableViewCell* )selectedCell {
    NSInteger section = 0;
    NSInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < rows; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        LMBookShelfTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell == selectedCell) {
            continue;
        }
        [cell showUpsideAndDelete:NO animation:YES];
    }
}

-(void)didClickCell:(LMBookShelfTableViewCell* )cell deleteButton:(UIButton* )btn {
    [self showNetworkLoadingView];
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LMBookShelfModel* model = [self.dataArray objectAtIndex:indexPath.row];
    UserBook* userBook = model.userBook;
    UserBookStoreOperateType type = UserBookStoreOperateTypeOperateDel;
    
    UserBookStoreOperateReqBuilder* builder = [UserBookStoreOperateReq builder];
    [builder setBookId:userBook.book.bookId];
    [builder setType:type];
    UserBookStoreOperateReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMBookShelfViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:4 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 4) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    //删除数据库 书
                    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                    [tool deleteUserBookWithBook:userBook.book];
                    
                    //删除数据库 阅读记录
                    [tool deleteBookReadRecordWithBookId:userBook.book.bookId];
                    
                    //删除缓存的目录列表
                    [LMTool deleteArchiveBookCatalogListWithBookId:userBook.book.bookId];
                    [LMTool deleteArchiveBookNewParseCatalogListWithBookId:userBook.book.bookId];
                    
                    //删除缓存的book
                    [LMTool deleteBookWithBookId:userBook.book.bookId];
                    
                    
                    [weakSelf.dataArray removeObjectAtIndex:indexPath.row];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }else if (err == ErrCodeErrCannotadddelmodify) {//无法增删改
                    
                }else if (err == ErrCodeErrBooknotexist) {//书本不存在
                    
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
        
        
    } failureBlock:^(NSError *failureError) {
        
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

-(void)didClickCell:(LMBookShelfTableViewCell* )cell upsideButton:(UIButton* )btn {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LMBookShelfModel* model = [self.dataArray objectAtIndex:indexPath.row];
    UserBook* userBook = model.userBook;
    UInt32 isTop = userBook.isTop;
    UserBookStoreOperateType type = UserBookStoreOperateTypeOperateTop;
    if (isTop) {
        type = UserBookStoreOperateTypeOperateUntop;
    }
    UserBookStoreOperateReqBuilder* builder = [UserBookStoreOperateReq builder];
    [builder setBookId:userBook.book.bookId];
    [builder setType:type];
    UserBookStoreOperateReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookShelfViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:4 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 4) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    LMDatabaseTool* dbTool = [LMDatabaseTool sharedDatabaseTool];
                    if (type == UserBookStoreOperateTypeOperateUntop) {//取消置顶
                        [dbTool setUpside:NO book:userBook.book];
                        
                        UserBookBuilder* builder = [UserBook builder];
                        [builder setIsTop:0];
                        [builder setBook:userBook.book];
                        UserBook* upsideUserBook = [builder build];
                        
                        [weakSelf.dataArray removeObject:model];
                        for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++) {
                            LMBookShelfModel* tempModel = [weakSelf.dataArray objectAtIndex:i];
                            UserBook* tempUserBook = tempModel.userBook;
                            
                            if (tempUserBook.isTop == 0) {
                                model.userBook = upsideUserBook;
                                [weakSelf.dataArray insertObject:model atIndex:i];
                                break;
                            }
                        }
                        
                        [weakSelf.tableView reloadData];
                        
                    }else {//置顶
                        [dbTool setUpside:YES book:userBook.book];
                        
                        UserBookBuilder* builder = [UserBook builder];
                        [builder setIsTop:1];
                        [builder setBook:userBook.book];
                        UserBook* upsideUserBook = [builder build];
                        
                        [weakSelf.dataArray removeObject:model];
                        
                        model.userBook = upsideUserBook;
                        [weakSelf.dataArray insertObject:model atIndex:0];
                        
                        [weakSelf.tableView reloadData];
                    }
                    
                    
                }else if (err == ErrCodeErrCannotadddelmodify) {//无法增删改
                    
                }else if (err == ErrCodeErrBooknotexist) {//书本不存在
                    
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

-(void)didClickCell:(LMBookShelfTableViewCell *)cell briefButton:(UIButton *)btn {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LMBookShelfModel* model = [self.dataArray objectAtIndex:indexPath.row];
    UserBook* userBook = model.userBook;
    Book* book = userBook.book;
    
    __weak LMBookShelfViewController* weakSelf = self;
    
    LMBookShelfDetailAlertView* bookView = [[LMBookShelfDetailAlertView alloc]init];
//    __weak LMBookShelfDetailAlertView* weakBookView = bookView;
    [bookView setupContentsWithBook:userBook];
    bookView.downloadBlock = ^(BOOL download) {
//        if (self.downloadView.isDownload == NO) {
//            [weakBookView setupDownloadTitleWithString:@"下载中"];
        [weakSelf showMBProgressHUDWithText:@"下载中"];
        
        [weakSelf.downloadView startDownloadBookWithBookId:book.bookId success:^(BOOL isFinished, CGFloat progress) {
            if (isFinished) {
//                [weakBookView setupDownloadTitleWithString:@"已下载"];
            }
        } failure:^(BOOL netFailed) {
            if (netFailed) {
//                [weakBookView setupDownloadTitleWithString:@"下载失败"];
            }
        }];
//        }
    };
    bookView.readBlock = ^(BOOL read) {
        LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
        readerBookVC.bookId = book.bookId;
        readerBookVC.bookName = book.name;
        
        readerBookVC.callBlock = ^(BOOL resetOrder) {
            [weakSelf.dataArray removeObject:model];
            
            model.markState = 0;
            LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
            [tool clearNewestMarkWithBookId:book.bookId];
            
            for (NSInteger i = 0; i < self.dataArray.count; i ++) {
                LMBookShelfModel* tempModel = [self.dataArray objectAtIndex:i];
                UserBook* tempUserBook = tempModel.userBook;

                if (tempUserBook.isTop <= userBook.isTop) {
                    [weakSelf.dataArray insertObject:model atIndex:i];
                    break;
                }
            }
            
            [weakSelf.tableView reloadData];
        };
        
        LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
        [self presentViewController:bookNavi animated:YES completion:nil];
    };
    bookView.detailBlock = ^(BOOL detail) {
        LMBookDetailViewController* bookDetailVC = [[LMBookDetailViewController alloc]init];
        bookDetailVC.bookId = book.bookId;
        [weakSelf.navigationController pushViewController:bookDetailVC animated:YES];
    };
    [bookView startShow];
}

-(LMDownloadBookView *)downloadView {
    if (!_downloadView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        _downloadView = [[LMDownloadBookView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
        [self.view addSubview:_downloadView];
    }
    return _downloadView;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshBookShelfViewController" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GDTNativeExpressAdDelegete
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (views != nil && views.count > 0) {
        self.adView = [views firstObject];
        self.adView.controller = self;
        [self.adView render];
        
        CGRect adRect = self.adView.frame;
        adRect.origin.x = 0;
        adRect.origin.y = 0;
        self.adView.frame = adRect;
        
        UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.adView.frame.size.height + 1)];
        headerView.backgroundColor = [UIColor clearColor];
        UIView* lineVi = [[UIView alloc]initWithFrame:CGRectMake(10, headerView.frame.size.height - 1, headerView.frame.size.width - 10, 1)];
        lineVi.backgroundColor = [UIColor colorWithRed:224/255.f green:224/255.f blue:224/255.f alpha:1];
        [headerView addSubview:lineVi];
        [headerView addSubview:self.adView];
        self.tableView.tableHeaderView = headerView;
        
        //上报腾讯广告显示
        AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
        [builder setAdlId:2];
        [builder setAdPt:0];
        AdShowedLogReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:42 ReqData:reqData successBlock:^(NSData *successData) {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 42) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    [LMTool archiveAdvertisementSwitchData:apiRes.body];
                }
            }
        } failureBlock:^(NSError *failureError) {
            
        }];
    }
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    NSLog(@"Express Ad Load Fail : %@",error);
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    NSLog(@"--------%s-------",__FUNCTION__);
    
    [self.adView removeFromSuperview];
    self.adView = nil;
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
}


#pragma mark -BaiduMobAdViewDelegate
- (NSString *)publisherId {
    return baiduAdPublisherId;
}

-(BOOL) enableLocation {
    return NO;
}

-(void) willDisplayAd:(BaiduMobAdView*) adview {
    NSLog(@"delegate: will display ad");
    
    //上报百度广告显示
    AdShowedLogReqBuilder* builder = [AdShowedLogReq builder];
    [builder setAdlId:2];
    [builder setAdPt:2];
    AdShowedLogReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:42 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 42) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                [LMTool archiveAdvertisementSwitchData:apiRes.body];
            }
        }
    } failureBlock:^(NSError *failureError) {
        
    }];
}

-(void) failedDisplayAd:(BaiduMobFailReason) reason {
    NSLog(@"delegate: failedDisplayAd %d", reason);
}

- (void)didAdImpressed {
    NSLog(@"delegate: didAdImpressed");
}

- (void)didAdClicked {
    NSLog(@"delegate: didAdClicked");
}

- (void)didAdClose {
    NSLog(@"delegate: didAdClose");
    
    [self.sharedAdView removeFromSuperview];
    self.sharedAdView.delegate = nil;
    self.sharedAdView = nil;
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
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
