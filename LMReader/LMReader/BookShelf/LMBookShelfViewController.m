//
//  LMBookShelfViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfViewController.h"
#import "LMBaseNavigationController.h"
#import "LMSearchViewController.h"
#import "LMDatabaseTool.h"
#import "LMTool.h"
#import "LMRootViewController.h"
#import "LMLeftItemView.h"
#import "LMRightItemView.h"
#import "LMBookDetailViewController.h"
#import "LMReaderBookViewController.h"
#import "LMBookShelfModel.h"
#import "GDTNativeExpressAdView.h"
#import "GDTNativeExpressAd.h"
#import "LMBookShelfAdView.h"
#import "LMLaunchDetailViewController.h"
#import <BaiduMobAdSDK/BaiduMobAdView.h>
#import "LMBookShelfSquareCollectionViewCell.h"
#import "LMBookShelfSquareAddCollectionViewCell.h"
#import "LMBookShelfListCollectionViewCell.h"
#import "LMBookShelfListAddCollectionViewCell.h"
#import "LMBaseRefreshCollectionView.h"
#import "LMBookShelfRightOperationView.h"
#import "LMBookShelfBottomOperationView.h"
#import "LMBookShelfEditViewController.h"

@interface LMBookShelfViewController () <GDTNativeExpressAdDelegete, BaiduMobAdViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, LMBaseRefreshCollectionViewDelegate, LMBookShelfSquareCollectionViewCellDelegate, LMBookShelfSquareAddCollectionViewCellDelegate, LMBookShelfListCollectionViewCellDelegate, LMBookShelfListAddCollectionViewCellDelegate>

@property (nonatomic, strong) LMBaseRefreshCollectionView* collectionView;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//
@property (nonatomic, assign) LMBookShelfType type;

@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIButton* cycleAddBtn;//圆形+按钮
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;//
@property (nonatomic, strong) GDTNativeExpressAdView* adView;//

@property (nonatomic, strong) BaiduMobAdView* sharedAdView;/**<百度广告*/

@end

@implementation LMBookShelfViewController

static NSString* squareCellIdentifier = @"squareCellIdentifier";
static NSString* squareAddCellIdentifier = @"squareAddCellIdentifier";
static NSString* listCellIdentifier = @"listCellIdentifier";
static NSString* listAddCellIdentifier = @"listAddCellIdentifier";

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
    
    self.bookCoverWidth = 105.f;
    self.bookCoverHeight = 145.f;
    
    CGFloat maxBookWidth = (self.view.frame.size.width - 20 * 4 - 10 * 3) / 3.f;
    self.bookFontScale = (self.view.frame.size.width / 414.f);
    if (self.bookFontScale > 1) {
        self.bookFontScale = 1;
    }
    if (self.bookCoverWidth * self.bookFontScale > maxBookWidth) {
        self.bookFontScale = maxBookWidth / self.bookCoverWidth;
    }
    self.bookCoverWidth *= self.bookFontScale;
    self.bookCoverHeight *= self.bookFontScale;
    
    self.type = LMBookShelfTypeBatch;
    
    LMLeftItemView* leftView = [[LMLeftItemView alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    __weak LMBookShelfViewController* weakSelf = self;
    
    LMRightItemView* searchView = [[LMRightItemView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    searchView.callBlock = ^(BOOL clicked) {
        if (clicked) {
            LMSearchViewController* searchVC = [[LMSearchViewController alloc]init];
            [weakSelf.navigationController pushViewController:searchVC animated:YES];
        }
    };
    UIBarButtonItem* searchItem = [[UIBarButtonItem alloc]initWithCustomView:searchView];
    
    UIView* exchangeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 30)];
    UIButton* exchangeItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, exchangeView.frame.size.width, exchangeView.frame.size.height)];
    [exchangeItemBtn setImage:[[UIImage imageNamed:@"bookShelf_Exchange"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    exchangeItemBtn.tintColor = UIColorFromRGB(0x656565);
    [exchangeItemBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 5, 13)];
    [exchangeItemBtn addTarget:self action:@selector(clickedExchangeButton:) forControlEvents:UIControlEventTouchUpInside];
    [exchangeView addSubview:exchangeItemBtn];
    UIBarButtonItem* exchangeItem = [[UIBarButtonItem alloc]initWithCustomView:exchangeView];
    
    self.navigationItem.rightBarButtonItems = @[exchangeItem, searchItem];
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[LMBaseRefreshCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.refreshDelegate = self;
    [self.collectionView registerClass:[LMBookShelfSquareCollectionViewCell class] forCellWithReuseIdentifier:squareCellIdentifier];
    [self.collectionView registerClass:[LMBookShelfSquareAddCollectionViewCell class] forCellWithReuseIdentifier:squareAddCellIdentifier];
    [self.collectionView registerClass:[LMBookShelfListCollectionViewCell class] forCellWithReuseIdentifier:listCellIdentifier];
    [self.collectionView registerClass:[LMBookShelfListAddCollectionViewCell class] forCellWithReuseIdentifier:listAddCellIdentifier];
    [self.view addSubview:self.collectionView];
    
    
    self.page = 0;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    //初始化数据
    [self loadDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
    
    //其它地方加书之后通知刷新界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBookShelfViewController:) name:@"refreshBookShelfViewController" object:nil];
}

//刷新书架 通知
-(void)refreshBookShelfViewController:(NSNotification* )notify {
    [self.collectionView startRefresh];
}

//九宫格、列表样式切换
-(void)clickedExchangeButton:(UIButton* )sender {
    NSString* typeStr = @"列表模式";
    if (self.type == LMBookShelfTypeList) {
        typeStr = @"书封模式";
    }
    LMBookShelfRightOperationView* operationView = [[LMBookShelfRightOperationView alloc]initWithFrame:CGRectMake(0, 0, 150, 130)];
    operationView.labText = typeStr;
    operationView.batchBlock = ^(BOOL didClick) {//批量管理
        
        __weak LMBookShelfViewController* weakSelf = self;
        
        LMBookShelfEditViewController* editVC = [[LMBookShelfEditViewController alloc]init];
        editVC.dataArray = self.dataArray;
        editVC.type = self.type;
        editVC.backBlock = ^(BOOL didBack, BOOL didChanged) {
            if (didBack) {
                [weakSelf.collectionView reloadData];
            }
        };
        [self presentViewController:editVC animated:YES completion:^{
            
        }];
    };
    operationView.listBlock = ^(BOOL didClick) {//样式切换
        if (self.type == LMBookShelfTypeList) {
            self.type = LMBookShelfTypeBatch;
        }else {
            self.type = LMBookShelfTypeList;
        }
        [self.collectionView reloadData];
        
        //设置 添加图书 按钮
        CGFloat cellItemHeight = 0;
        CGFloat contentHeight = 0;
        if (self.type == LMBookShelfTypeList) {
            cellItemHeight = self.bookCoverHeight + 20 * 2;
            contentHeight = cellItemHeight * self.dataArray.count;
        }else {
            cellItemHeight = 5 + self.bookCoverHeight + 10 + 20 + 10 + 15;
            NSInteger cellCounts = self.dataArray.count / 3;
            if (self.dataArray.count % 3 == 0) {
                cellCounts += 1;
            }
            contentHeight = cellItemHeight * cellCounts;
        }
        if (contentHeight <= self.collectionView.frame.size.height) {
            self.cycleAddBtn.hidden = YES;
        }else {
            self.cycleAddBtn.hidden = NO;
        }
    };
    [operationView showToView:sender];
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
        [self.view insertSubview:_cycleAddBtn aboveSubview:self.collectionView];
        _cycleAddBtn.center = CGPointMake(screenRect.size.width - 10 - btnWidth / 2, screenRect.size.height - 15 - tabBarHeight - naviHeight - btnWidth / 2);
    }
    return _cycleAddBtn;
}

//+图书
-(void)clickedAddButton:(UIButton* )sender {
    //跳转至 书城 页面
    [[LMRootViewController sharedRootViewController] setCurrentViewControllerIndex:2];
}

-(void)loadDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    if (self.isRefreshing) {
        return;
    }
    
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    /*
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
    */
    
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
                        for (NSInteger i = 0; i < arr.count; i ++) {
                            UserBook* tempUserBook = [arr objectAtIndex:i];
                            LMBookShelfModel* tempModel = [tool queryBookShelfUserBooksWithBookId:tempUserBook.book.bookId];
                            NSString* progressStr = [tool queryBookReadRecordProgressWithBookId:tempUserBook.book.bookId];
                            tempModel.progressStr = progressStr;
                            tempModel.isLastestRecord = NO;
                            if (weakSelf.page == 0 && i == 0 && progressStr != nil && ![progressStr isKindOfClass:[NSNull class]] && progressStr.length > 0) {
                                tempModel.isLastestRecord = YES;
                            }
                            if (tempModel != nil) {
                                [weakSelf.dataArray addObject:tempModel];
                            }
                        }
                    }
                    
                    if (arr == nil || arr.count == 0) {//最后一页
                        weakSelf.isEnd = YES;
                        [weakSelf.collectionView setupNoMoreData];
                        
                        //有些书本地有，服务端无。删除
                        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                        NSMutableArray* deleteArr = [NSMutableArray array];
                        for (LMBookShelfModel* model in weakSelf.dataArray) {
                            [deleteArr addObject:model.userBook];
                        }
                        [tool deleteLocalSurplusBooksWithArray:deleteArr];
                    }
                    weakSelf.page ++;
                    [weakSelf.collectionView reloadData];
                }
            }
        } @catch (NSException *exception) {
            //取数据库 图书
            if (weakSelf.page == 0) {
                LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                NSArray* arr = [tool queryAllBookShelfUserBooks];
                if (arr != nil && arr.count > 0) {
                    [weakSelf.dataArray removeAllObjects];
                    [weakSelf.dataArray addObjectsFromArray:arr];
                    
                    [weakSelf.collectionView reloadData];
                }
            }
            
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            weakSelf.isRefreshing = NO;
            if (loadMore) {
                [weakSelf.collectionView stopLoadMoreData];
            }else {
                [weakSelf.collectionView stopRefresh];
            }
            [weakSelf hideNetworkLoadingView];
            
            //设置 添加图书 按钮
            CGFloat cellItemHeight = 0;
            CGFloat contentHeight = 0;
            if (weakSelf.type == LMBookShelfTypeList) {
                cellItemHeight = self.bookCoverHeight + 20 * 2;
                contentHeight = cellItemHeight * weakSelf.dataArray.count;
            }else {
                cellItemHeight = 5 + self.bookCoverHeight + 10 + 20 + 10 + 15;
                NSInteger cellCounts = weakSelf.dataArray.count / 3;
                if (weakSelf.dataArray.count % 3 == 0) {
                    cellCounts += 1;
                }
                contentHeight = cellItemHeight * cellCounts;
            }
            if (contentHeight <= self.collectionView.frame.size.height) {
                weakSelf.cycleAddBtn.hidden = YES;
            }else {
                weakSelf.cycleAddBtn.hidden = NO;
            }
        }
    } failureBlock:^(NSError *failureError) {
        
        //取数据库 图书
        if (weakSelf.page == 0) {
            LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
            NSArray* arr = [tool queryAllBookShelfUserBooks];
            if (arr != nil && arr.count > 0) {
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:arr];
                
                [weakSelf.collectionView reloadData];
            }
        }
        
        weakSelf.isRefreshing = NO;
        if (loadMore) {
            [weakSelf.collectionView stopLoadMoreData];
        }else {
            [weakSelf.collectionView stopRefresh];
        }
        
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        
    }];
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
//        self.tableView.tableHeaderView = headerView;
        
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
//    self.tableView.tableHeaderView = headerView;
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
//    self.tableView.tableHeaderView = headerView;
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.collectionView.contentSize.height <= self.collectionView.frame.size.height) {
        self.cycleAddBtn.hidden = YES;
        return;
    }
    if (scrollView == self.collectionView) {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
        //设置 添加图书 按钮
        if (bottomOffset <= height) {//滑至底部
            self.cycleAddBtn.hidden = YES;
        }else {
            self.cycleAddBtn.hidden = NO;
        }
    }
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    if (self.type == LMBookShelfTypeList) {
        if (row == self.dataArray.count) {
            LMBookShelfListAddCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:listAddCellIdentifier forIndexPath:indexPath];
            
            [cell setupListAddCellWithItemWidth:self.view.frame.size.width itemHeight:60];
            cell.delegate = self;
            
            return cell;
        }else {
            LMBookShelfListCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:listCellIdentifier forIndexPath:indexPath];
            
            LMBookShelfModel* model = [self.dataArray objectAtIndex:row];
            [cell setupSquareCellWithModel:model ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.view.frame.size.width];
            cell.delegate = self;
            
            return cell;
        }
    }else {
        if (row == self.dataArray.count) {
            LMBookShelfSquareAddCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:squareAddCellIdentifier forIndexPath:indexPath];
            
            [cell setupSquareAddCellWithIvWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight];
            cell.delegate = self;
            
            return cell;
        }else {
            LMBookShelfSquareCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:squareCellIdentifier forIndexPath:indexPath];
            
            CGFloat itemHeight = 5 + self.bookCoverHeight + 10 + 20 + 10 + 15;
            
            LMBookShelfModel* model = [self.dataArray objectAtIndex:row];
            [cell setupSquareCellWithModel:model ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.bookCoverWidth + 5 * 2 itemHeight:itemHeight];
            cell.delegate = self;
            
            return cell;
        }
    }
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    LMBookShelfModel* model = nil;
    
    NSInteger row = indexPath.row;
    if (self.type == LMBookShelfTypeList) {
        if (row == self.dataArray.count) {
            
        }else {
            model = [self.dataArray objectAtIndex:row];
        }
    }else {
        if (row == self.dataArray.count) {
            
        }else {
            model = [self.dataArray objectAtIndex:row];
        }
    }
    
    if (model == nil) {
        return;
    }
    model.markState = 0;
    model.isLastestRecord = NO;
    
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
            model.progressStr = [tool queryBookReadRecordProgressWithBookId:book.bookId];
            
            for (NSInteger i = 0; i < self.dataArray.count; i ++) {
                LMBookShelfModel* tempModel = [self.dataArray objectAtIndex:i];
                tempModel.isLastestRecord = NO;
                UserBook* tempUserBook = tempModel.userBook;
                if (tempUserBook.isTop <= userBook.isTop) {
                    [weakSelf.dataArray insertObject:model atIndex:i];
                    break;
                }
            }
        }
        
        //遍历 设置最近阅读记录
        for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++) {
            LMBookShelfModel* subModel = [weakSelf.dataArray objectAtIndex:i];
            if (subModel.progressStr != nil && ![subModel.progressStr isKindOfClass:[NSNull class]] && subModel.progressStr.length > 0) {
                subModel.isLastestRecord = YES;
                break;
            }
        }
        
        [weakSelf.collectionView reloadData];
    };
    
    LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
    [self presentViewController:bookNavi animated:YES completion:nil];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (self.type == LMBookShelfTypeList) {
        CGFloat itemHeight = self.bookCoverHeight + 20 * 2;
        if (row == self.dataArray.count) {
            itemHeight = 60;
        }
        return CGSizeMake(self.view.frame.size.width, itemHeight);
    }
    
    CGFloat itemHeight = 5 + self.bookCoverHeight + 10 + 20 + 10 + 15;
    if (row == self.dataArray.count && row % 3 == 0) {
        itemHeight = self.bookCoverHeight + 20;
    }
    return CGSizeMake(self.bookCoverWidth + 5 * 2, itemHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.type == LMBookShelfTypeList) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    CGFloat tempSpaceX = 20 - 5;
    CGFloat tempSpaceY = 20;
    return UIEdgeInsetsMake(tempSpaceY, tempSpaceX, tempSpaceY, tempSpaceX);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.type == LMBookShelfTypeList) {
        return 0;
    }
    return 20;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (self.type == LMBookShelfTypeList) {
        return 0;
    }
    return 20 - 5;
}


#pragma mark -LMBaseRefreshCollectionViewDelegate
-(void)refreshCollectionViewDidStartRefresh:(LMBaseRefreshCollectionView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.collectionView cancelNoMoreData];
    
    [self loadDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshCollectionViewDidStartLoadMoreData:(LMBaseRefreshCollectionView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
}

#pragma mark -LMBookShelfSquareCollectionViewCellDelegate
-(void)LMBookShelfSquareCollectionViewCellDidLongPress:(LMBookShelfSquareCollectionViewCell *)pressedCell {
    NSString* topStr = @"置顶";
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:pressedCell];
    LMBookShelfModel* model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.userBook.isTop) {
        topStr = @"取消置顶";
    }
    LMBookShelfBottomOperationView* bottomOperationView = [[LMBookShelfBottomOperationView alloc]initWithFrame:CGRectZero imgsArr:@[@"bookShelf_Operation_Top", @"bookShelf_Operation_Detail.png", @"bookShelf_Operation_Delete.png"] titleArr:@[topStr, @"书籍详情", @"删除"]];
    bottomOperationView.clickBlock = ^(NSInteger index) {
        if (index == 0) {
            [self longPressOperationUpsideBoookWithBookModel:model];
        }else if (index == 1) {
            [self longPressOperationOpenBookDetailWithBookModel:model];
        }else if (index == 2) {
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"确定删除？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self longPressOperationDeleteBookWithBookModel:model indexPath:indexPath];
            }];
            [alertController addAction:deleteAction];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    };
    [bottomOperationView startShow];
}

#pragma mark -LMBookShelfSquareAddCollectionViewCellDelegate
-(void)LMBookShelfSquareAddCollectionViewCellDidClickAdd:(LMBookShelfSquareAddCollectionViewCell *)addCell {
    //跳转至 书城 页面
    [[LMRootViewController sharedRootViewController] setCurrentViewControllerIndex:2];
}

#pragma mark -LMBookShelfListCollectionViewCellDelegate
-(void)LMBookShelfListCollectionViewCellDidLongPress:(LMBookShelfListCollectionViewCell *)pressedCell {
    NSString* topStr = @"置顶";
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:pressedCell];
    LMBookShelfModel* model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.userBook.isTop) {
        topStr = @"取消置顶";
    }
    LMBookShelfBottomOperationView* bottomOperationView = [[LMBookShelfBottomOperationView alloc]initWithFrame:CGRectZero imgsArr:@[@"bookShelf_Operation_Top", @"bookShelf_Operation_Detail.png", @"bookShelf_Operation_Delete.png"] titleArr:@[topStr, @"书籍详情", @"删除"]];
    bottomOperationView.clickBlock = ^(NSInteger index) {
        if (index == 0) {
            [self longPressOperationUpsideBoookWithBookModel:model];
        }else if (index == 1) {
            [self longPressOperationOpenBookDetailWithBookModel:model];
        }else if (index == 2) {
            [self longPressOperationDeleteBookWithBookModel:model indexPath:indexPath];
        }
    };
    [bottomOperationView startShow];
}

#pragma mark -LMBookShelfListAddCollectionViewCellDelegate
-(void)LMBookShelfListAddCollectionViewCellDidClickAdd:(LMBookShelfListAddCollectionViewCell *)addCell {
    //跳转至 书城 页面
    [[LMRootViewController sharedRootViewController] setCurrentViewControllerIndex:2];
}

//底部弹窗 置顶、取消置顶操作
-(void)longPressOperationUpsideBoookWithBookModel:(LMBookShelfModel* )model {
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
                        
                        //遍历 设置最近阅读记录
                        for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++) {
                            LMBookShelfModel* subModel = [weakSelf.dataArray objectAtIndex:i];
                            if (subModel.progressStr != nil && ![subModel.progressStr isKindOfClass:[NSNull class]] && subModel.progressStr.length > 0) {
                                subModel.isLastestRecord = YES;
                                break;
                            }
                        }
                        
                        [weakSelf.collectionView reloadData];
                        
                    }else {//置顶
                        [dbTool setUpside:YES book:userBook.book];
                        
                        UserBookBuilder* builder = [UserBook builder];
                        [builder setIsTop:1];
                        [builder setBook:userBook.book];
                        UserBook* upsideUserBook = [builder build];
                        
                        [weakSelf.dataArray removeObject:model];
                        
                        model.userBook = upsideUserBook;
                        
                        [weakSelf.dataArray insertObject:model atIndex:0];
                        
                        //遍历 设置最近阅读记录
                        for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++) {
                            LMBookShelfModel* subModel = [weakSelf.dataArray objectAtIndex:i];
                            if (subModel.progressStr != nil && ![subModel.progressStr isKindOfClass:[NSNull class]] && subModel.progressStr.length > 0) {
                                subModel.isLastestRecord = YES;
                                break;
                            }
                        }
                        
                        [weakSelf.collectionView reloadData];
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

//底部弹窗 跳转至书籍详情
-(void)longPressOperationOpenBookDetailWithBookModel:(LMBookShelfModel* )model {
    LMBookDetailViewController* bookDetailVC = [[LMBookDetailViewController alloc]init];
    bookDetailVC.bookId = model.userBook.book.bookId;
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

//底部弹窗 删除书
-(void)longPressOperationDeleteBookWithBookModel:(LMBookShelfModel* )model indexPath:(NSIndexPath* )indexPath {
    [self showNetworkLoadingView];
    
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
                    
                    //遍历 设置最近阅读记录
                    for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++) {
                        LMBookShelfModel* subModel = [weakSelf.dataArray objectAtIndex:i];
                        if (subModel.progressStr != nil && ![subModel.progressStr isKindOfClass:[NSNull class]] && subModel.progressStr.length > 0) {
                            subModel.isLastestRecord = YES;
                            break;
                        }
                    }
                    [weakSelf.collectionView reloadData];
//                    [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
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


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshBookShelfViewController" object:nil];
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
