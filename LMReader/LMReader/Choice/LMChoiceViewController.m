//
//  LMChoiceViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMChoiceViewController.h"
#import "LMBaseBookTableViewCell.h"
#import "LMBaseRefreshTableView.h"
#import "LMRangeViewController.h"
#import "LMSpecialChoiceViewController.h"
#import "LMInterestOrEndViewController.h"
#import "LMBookDetailViewController.h"
#import "LMSearchViewController.h"
#import "LMLeftItemView.h"
#import "LMRightItemView.h"
#import "LMTool.h"
#import "UIImageView+WebCache.h"
#import "LMLaunchDetailViewController.h"

@interface LMChoiceViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray* topArr;//顶部广告、书籍部分
@property (nonatomic, strong) UIScrollView* adScrollView;
@property (nonatomic, strong) UIPageControl* pageControl;//
@property (nonatomic, assign) NSInteger currentAdIndex;//当前显示的广告、书籍角标
@property (nonatomic, strong) NSTimer* timer;//
@property (nonatomic, assign) NSInteger adTimeCount;//当前广告、书籍展示时间

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* editorArr;//编辑推荐
@property (nonatomic, strong) NSMutableArray* interestArr;//兴趣推荐
@property (nonatomic, strong) NSMutableArray* hotArr;//热门新书
@property (nonatomic, strong) NSMutableArray* publishArr;//出版图书
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL firstLoad;//首次加载

@end

@implementation LMChoiceViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LMLeftItemView* leftView = [[LMLeftItemView alloc]initWithFrame:CGRectMake(0, 0, 80, 25)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    __weak LMChoiceViewController* weakSelf = self;
    
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
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView setupNoMoreData];
    
    self.topArr = [NSMutableArray array];
    
    self.editorArr = [NSMutableArray array];
    self.interestArr = [NSMutableArray array];
    self.hotArr = [NSMutableArray array];
    self.publishArr = [NSMutableArray array];
    
    self.firstLoad = YES;
}

-(void)viewDidAppear:(BOOL)animated {
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
    
    if (self.firstLoad) {
        [self loadChoiceData];
    }else {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSDate* saveDate = [userDefaults objectForKey:@"LMChoiceViewControllerDate"];
        BOOL shouldReload = NO;
        if (saveDate != nil && ![saveDate isKindOfClass:[NSNull class]]) {
            NSInteger hour = [LMTool convertDateToHourTime:saveDate];
            if (hour > 1 || hour < -1) {
                shouldReload = YES;
            }
        }else {
            shouldReload = YES;
        }
        
        if (shouldReload == YES) {
            [self loadChoiceData];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [self hideNetworkLoadingView];
}

-(void)setupTimer {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCount) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

-(void)startCount {
    if (self.topArr.count == 0) {
        return;
    }
    TopicAd* detailAd = [self.topArr objectAtIndex:self.currentAdIndex];
    Ad* ad;
    if ([detailAd hasBook]) {
        ad = detailAd.book;
    }else {
        ad = detailAd.ad;
    }
    self.adTimeCount ++;
    if (self.adTimeCount >= ad.lT) {
        [self autoscrollToNextAd];
    }
}

//自动跳转到下一个广告
-(void)autoscrollToNextAd {
    self.adTimeCount = 0;
    [self.timer setFireDate:[NSDate distantFuture]];
    if (self.currentAdIndex == self.topArr.count - 1) {
        self.currentAdIndex = 0;
    }else {
        self.currentAdIndex ++;
    }
    self.pageControl.currentPage = self.currentAdIndex;
    [UIView animateWithDuration:0.2 animations:^{
        self.adScrollView.contentOffset = CGPointMake(self.adScrollView.frame.size.width * self.currentAdIndex, 0);
    }];
    [self.timer setFireDate:[NSDate distantPast]];
}

-(void)setupTableHeaderView {
    CGFloat btnHeight = 85;
    CGFloat btnWidth = 50;
    CGFloat btnCenterY = btnHeight / 2;
    CGFloat totalHeaderHeight = btnHeight;
    CGFloat adHeight = 0;
    if (self.topArr != nil && self.topArr.count > 0) {
        adHeight = self.view.frame.size.width * 27 / 64;
        btnCenterY = adHeight + btnHeight / 2;
        totalHeaderHeight = btnHeight + adHeight;
    }
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, totalHeaderHeight)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    if (self.topArr != nil && self.topArr.count > 0) {
        self.adScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, adHeight)];
        self.adScrollView.showsHorizontalScrollIndicator = NO;
        self.adScrollView.showsVerticalScrollIndicator = NO;
        self.adScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.topArr.count, 0);
        self.adScrollView.delegate = self;
        self.adScrollView.pagingEnabled = YES;
        [self.headerView addSubview:self.adScrollView];
        for (NSInteger i = 0; i < self.topArr.count; i ++) {
            TopicAd* topAd = [self.topArr objectAtIndex:i];
            Ad* detailAd;
            if ([topAd.book hasBook]) {
                detailAd = topAd.book;
            }else {
                detailAd = topAd.ad;
            }
            UIImageView* adIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.adScrollView.frame.size.width * i, 0, self.adScrollView.frame.size.width, self.adScrollView.frame.size.height)];
            adIV.tag = i;
            adIV.userInteractionEnabled  = YES;
            NSString* picStr = [detailAd.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [adIV sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"ad_DefaultImage"]];
            [self.adScrollView addSubview:adIV];
            
            CGRect infoFrame = CGRectMake(5, adIV.frame.size.height - 20, 30, 15);
            if (detailAd.pos == 1) {//右上角
                infoFrame = CGRectMake(adIV.frame.size.width - 35, 5, 30, 15);
            }else if (detailAd.pos == 2) {//右下角
                infoFrame = CGRectMake(adIV.frame.size.width - 35, adIV.frame.size.height - 20, 30, 15);
            }else if (detailAd.pos == 3) {//左上角
                infoFrame = CGRectMake(5, 5, 30, 15);
            }else if (detailAd.pos == 4) {//左下角 默认
                
            }
            if (![topAd.book hasBook]) {//广告
                UILabel* infoLab = [[UILabel alloc]initWithFrame:infoFrame];
                infoLab.backgroundColor = [UIColor grayColor];
                infoLab.alpha = 0.8f;
                infoLab.textColor = [UIColor whiteColor];
                infoLab.textAlignment = NSTextAlignmentCenter;
                infoLab.font = [UIFont systemFontOfSize:13];
                infoLab.text = @"广告";
                [adIV addSubview:infoLab];
            }
            
            UITapGestureRecognizer* tapAdGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedAdImageView:)];
            [adIV addGestureRecognizer:tapAdGR];
        }
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.adScrollView.frame.size.height - 20, self.adScrollView.frame.size.width, 20)];
        self.pageControl.numberOfPages = self.topArr.count;
        self.pageControl.currentPage = 0;
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        [self.headerView addSubview:self.pageControl];
        
        self.currentAdIndex = 0;
        self.adTimeCount = 0;
        [self setupTimer];
        [self.timer setFireDate:[NSDate distantPast]];
    }
    
    UIButton* rangeBtn = [self createTitleButtonWithFrame:CGRectMake(0, 0, btnWidth, btnHeight) title:@"排行榜" imageStr:@"choice_Range" selector:@selector(clickedRangeButton:)];
    rangeBtn.center = CGPointMake(self.headerView.frame.size.width / 4, btnCenterY);
    [self.headerView addSubview:rangeBtn];
    
    UIButton* specialBtn = [self createTitleButtonWithFrame:CGRectMake(0, 0, rangeBtn.frame.size.width, rangeBtn.frame.size.height) title:@"精选专题" imageStr:@"choice_Special" selector:@selector(clickedSpecialChoiceButton:)];
    specialBtn.center = CGPointMake(self.headerView.frame.size.width * 2/4, rangeBtn.center.y);
    [self.headerView addSubview:specialBtn];
    
    UIButton* overBtn = [self createTitleButtonWithFrame:CGRectMake(0, 0, rangeBtn.frame.size.width, rangeBtn.frame.size.height) title:@"经典完结" imageStr:@"choice_Over" selector:@selector(clickedOverChoiceButton:)];
    overBtn.center = CGPointMake(self.headerView.frame.size.width * 3/4, rangeBtn.center.y);
    [self.headerView addSubview:overBtn];
    
    self.tableView.tableHeaderView = self.headerView;
}

-(UIButton* )createTitleButtonWithFrame:(CGRect )frame title:(NSString* )titleStr imageStr:(NSString* )imageStr selector:(SEL )selector {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* overIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 15, frame.size.width - 10, frame.size.height - 45)];
    overIV.image = [UIImage imageNamed:imageStr];
    [btn addSubview:overIV];
    
    UILabel* overLab = [[UILabel alloc]initWithFrame:CGRectMake(-10, btn.frame.size.height - 25, btn.frame.size.width + 20, 20)];
    overLab.text = titleStr;
    overLab.textAlignment = NSTextAlignmentCenter;
    overLab.font = [UIFont systemFontOfSize:14];
    [btn addSubview:overLab];
    
    return btn;
}

//点击广告、图书
-(void)tappedAdImageView:(UITapGestureRecognizer* )tapGR {
    UIImageView* iv = (UIImageView* )tapGR.view;
    NSInteger tag = iv.tag;
    TopicAd* topAd = [self.topArr objectAtIndex:tag];
    if ([topAd.book hasBook]) {
        Book* book = topAd.book.book;
        LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
        detailVC.bookId = book.bookId;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else {
        NSString* targetUrlStr = [topAd.ad.to stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        LMLaunchDetailViewController* launchDetailVC = [[LMLaunchDetailViewController alloc]init];
        launchDetailVC.urlString = targetUrlStr;
        [self.navigationController pushViewController:launchDetailVC animated:YES];
    }
}

//排行榜
-(void)clickedRangeButton:(UIButton* )sender {
    LMRangeViewController* rangeVC = [[LMRangeViewController alloc]init];
    [self.navigationController pushViewController:rangeVC animated:YES];
}

//精选专题
-(void)clickedSpecialChoiceButton:(UIButton* )sender {
    LMSpecialChoiceViewController* specialChoiceVC = [[LMSpecialChoiceViewController alloc]init];
    [self.navigationController pushViewController:specialChoiceVC animated:YES];
}

//经典完结
-(void)clickedOverChoiceButton:(UIButton* )sender {
    LMInterestOrEndType type = LMEndType;
    LMInterestOrEndViewController* interestOrEndVC = [[LMInterestOrEndViewController alloc]init];
    interestOrEndVC.type = type;
    [self.navigationController pushViewController:interestOrEndVC animated:YES];
}

//section头部  更多
-(void)clickedSectionButton:(UIButton* )sender {
    LMInterestOrEndType type = LMInterestType;
    if (sender.tag == 0) {//编辑推荐
        type = LMEditorRecommandType;
    }else if (sender.tag == 1) {//兴趣推荐
        type = LMInterestType;
    }else if (sender.tag == 2) {//热门新书
        type = LMHotBookType;
    }else if (sender.tag == 3) {//出版图书
        type = LMPublishBookType;
    }
    LMInterestOrEndViewController* interestOrEndVC = [[LMInterestOrEndViewController alloc]init];
    interestOrEndVC.type = type;
    [self.navigationController pushViewController:interestOrEndVC animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self isEmptyData]) {
        UIView* tempVi = [[UIView alloc]initWithFrame:CGRectZero];
        return tempVi;
    }
    NSString* titleStr = @"编辑推荐";
    if (section == 1) {
        titleStr = @"兴趣推荐";
    }else if (section == 2) {
        titleStr = @"热门新书";
    }else if (section == 3) {
        titleStr = @"出版图书";
    }
    UIView* tempHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    tempHeaderView.backgroundColor = [UIColor colorWithRed:243/255.f green:243/255.f blue:243/255.f alpha:1];
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 40)];
    vi.backgroundColor = [UIColor whiteColor];
    [tempHeaderView addSubview:vi];
    
    UILabel* lab0 = [[UILabel alloc]initWithFrame:CGRectMake(10, (vi.frame.size.height - 20) / 2, 5, 20)];
    lab0.backgroundColor = THEMEORANGECOLOR;
    lab0.layer.cornerRadius = 2.5;
    lab0.layer.masksToBounds = YES;
    [vi addSubview:lab0];
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(lab0.frame.origin.x + lab0.frame.size.width + 10, 0, 200, vi.frame.size.height)];
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont boldSystemFontOfSize:18];
    lab.text = titleStr;
    [vi addSubview:lab];
    
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(vi.frame.size.width - 60, 0, 60, vi.frame.size.height)];
    NSMutableAttributedString* btnStr = [[NSMutableAttributedString alloc]initWithString:@"更多>" attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle), NSForegroundColorAttributeName : [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1], NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    [btn setAttributedTitle:btnStr forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickedSectionButton:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = section;
    [vi addSubview:btn];
    return tempHeaderView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.editorArr.count;
    }else if (section == 1) {
        return self.interestArr.count;
    }else if (section == 2) {
        return self.hotArr.count;
    }else if (section == 3) {
        return self.publishArr.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return baseBookCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMBaseBookTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBaseBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    Book* book;
    BOOL showLine = YES;
    if (section == 0) {
        book = [self.editorArr objectAtIndex:row];
        if (row == self.editorArr.count - 1) {
            showLine = NO;
        }
    }else if (section == 1) {
        book = [self.interestArr objectAtIndex:row];
        if (row == self.interestArr.count - 1) {
            showLine = NO;
        }
    }else if (section == 2) {
        book = [self.hotArr objectAtIndex:row];
        if (row == self.hotArr.count - 1) {
            showLine = NO;
        }
    }else if (section == 3) {
        book = [self.publishArr objectAtIndex:row];
        if (row == self.publishArr.count - 1) {
            showLine = NO;
        }
    }
    [cell setupContentBook:book];
    
    [cell showLineView:showLine];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Book* book;
    if (indexPath.section == 0) {
        book = [self.editorArr objectAtIndex:indexPath.row];
    }else if (indexPath.section == 1) {
        book = [self.interestArr objectAtIndex:indexPath.row];
    }else if (indexPath.section == 2) {
        book = [self.hotArr objectAtIndex:indexPath.row];
    }else if (indexPath.section == 3) {
        book = [self.publishArr objectAtIndex:indexPath.row];
    }
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.bookId = book.bookId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)loadChoiceData {
    self.isRefreshing = YES;
    
    TopicHomeReqBuilder* builder = [TopicHomeReq builder];
    [builder setPage:0];
    [builder setType:0];
    TopicHomeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMChoiceViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:10 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 10) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    TopicHomeRes* res = [TopicHomeRes parseFromData:apiRes.body];
                    
                    NSArray* arr0 = res.ads;
                    if (arr0 != nil && arr0.count > 0) {
                        [weakSelf.topArr removeAllObjects];
                        [weakSelf.topArr addObjectsFromArray:arr0];
                    }
                    
                    NSArray* arr1 = res.interestBooks;
                    if (arr1.count > 0) {
                        
                        self.firstLoad = NO;
                        
                        [weakSelf.interestArr removeAllObjects];
                        [weakSelf.interestArr addObjectsFromArray:arr1];
                        
                        //保存
                        [LMTool archiveChoiceData:apiRes.body];
                    }
                    NSArray* arr3 = res.hotnewBooks;
                    if (arr3.count > 0) {
                        [weakSelf.hotArr removeAllObjects];
                        [weakSelf.hotArr addObjectsFromArray:arr3];
                    }
                    NSArray* arr4 = res.publicedBooks;
                    if (arr4.count > 0) {
                        [weakSelf.publishArr removeAllObjects];
                        [weakSelf.publishArr addObjectsFromArray:arr4];
                    }
                    NSArray* arr5 = res.editorBooks;
                    if (arr5.count > 0) {
                        [weakSelf.editorArr removeAllObjects];
                        [weakSelf.editorArr addObjectsFromArray:arr5];
                    }
                    
                    NSDate* date = [NSDate date];
                    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:date forKey:@"LMChoiceViewControllerDate"];
                    [userDefaults synchronize];
                }
            }
            
        } @catch (NSException *exception) {
            NSData* data = [LMTool unArchiveChoiceData];
            if (data != nil && ![data isKindOfClass:[NSNull class]]) {
                TopicHomeRes* res = [TopicHomeRes parseFromData:data];
                NSArray* arr0 = res.ads;
                if (arr0 != nil && arr0.count > 0) {
                    [weakSelf.topArr removeAllObjects];
                    [weakSelf.topArr addObjectsFromArray:arr0];
                }
                NSArray* arr1 = res.interestBooks;
                if (arr1.count > 0) {
                    
                    self.firstLoad = NO;
                    
                    [weakSelf.interestArr removeAllObjects];
                    [weakSelf.interestArr addObjectsFromArray:arr1];
                }
                NSArray* arr3 = res.hotnewBooks;
                if (arr3.count > 0) {
                    [weakSelf.hotArr removeAllObjects];
                    [weakSelf.hotArr addObjectsFromArray:arr3];
                }
                NSArray* arr4 = res.publicedBooks;
                if (arr4.count > 0) {
                    [weakSelf.publishArr removeAllObjects];
                    [weakSelf.publishArr addObjectsFromArray:arr4];
                }
                NSArray* arr5 = res.editorBooks;
                if (arr5.count > 0) {
                    [weakSelf.editorArr removeAllObjects];
                    [weakSelf.editorArr addObjectsFromArray:arr5];
                }
            }
            
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        weakSelf.isRefreshing = NO;
        [weakSelf.tableView stopRefresh];
        [weakSelf hideReloadButton];
        [weakSelf hideNetworkLoadingView];
        
        [weakSelf setupTableHeaderView];
        [weakSelf.tableView reloadData];
        
    } failureBlock:^(NSError *failureError) {
        NSData* data = [LMTool unArchiveChoiceData];
        if (data != nil && ![data isKindOfClass:[NSNull class]]) {
            TopicHomeRes* res = [TopicHomeRes parseFromData:data];
            NSArray* arr0 = res.ads;
            if (arr0 != nil && arr0.count > 0) {
                [weakSelf.topArr removeAllObjects];
                [weakSelf.topArr addObjectsFromArray:arr0];
            }
            NSArray* arr1 = res.interestBooks;
            if (arr1.count > 0) {
                
                self.firstLoad = NO;
                
                [weakSelf.interestArr removeAllObjects];
                [weakSelf.interestArr addObjectsFromArray:arr1];
            }
            NSArray* arr3 = res.hotnewBooks;
            if (arr3.count > 0) {
                [weakSelf.hotArr removeAllObjects];
                [weakSelf.hotArr addObjectsFromArray:arr3];
            }
            NSArray* arr4 = res.publicedBooks;
            if (arr4.count > 0) {
                [weakSelf.publishArr removeAllObjects];
                [weakSelf.publishArr addObjectsFromArray:arr4];
            }
            NSArray* arr5 = res.editorBooks;
            if (arr5.count > 0) {
                [weakSelf.editorArr removeAllObjects];
                [weakSelf.editorArr addObjectsFromArray:arr5];
            }
        }
        
        weakSelf.isRefreshing = NO;
        [weakSelf.tableView stopRefresh];
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        if (weakSelf.editorArr.count == 0 && weakSelf.interestArr.count == 0 && weakSelf.hotArr.count == 0 && weakSelf.publishArr.count == 0) {
            [weakSelf showReloadButton];
        }else {
            [weakSelf setupTableHeaderView];
            [weakSelf.tableView reloadData];
        }
    }];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self loadChoiceData];
}

-(BOOL)isEmptyData {
    if (self.interestArr.count > 0) {
        return NO;
    }
    if (self.hotArr.count > 0) {
        return NO;
    }
    if (self.publishArr.count > 0) {
        return NO;
    }
    return YES;
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    if (self.isRefreshing) {
        return;
    }
    [self loadChoiceData];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.adScrollView) {
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.adScrollView.frame);
        if (page != self.currentAdIndex) {
            self.currentAdIndex = page;
            self.pageControl.currentPage = self.currentAdIndex;
            self.adTimeCount = 0;
            [self.timer setFireDate:[NSDate distantFuture]];
            [self.timer setFireDate:[NSDate distantPast]];
        }
    }
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
