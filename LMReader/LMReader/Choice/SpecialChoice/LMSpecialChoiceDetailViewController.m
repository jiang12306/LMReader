//
//  LMSpecialChoiceDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceDetailViewController.h"
#import "LMTypeBookStoreTableViewCell.h"
#import "LMBookDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMSpecialChoiceDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIImageView* headerIV;
@property (nonatomic, strong) UIView* otherHeaderView;//briefLab跟detailLab
@property (nonatomic, strong) UILabel* briefLab;//专题简介
@property (nonatomic, strong) UILabel* detailLab;//专题详情
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//

@end

@implementation LMSpecialChoiceDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bookCoverWidth = 105.f;
    self.bookCoverHeight = 145.f;
    self.bookNameFontSize = 15.f;
    self.bookBriefFontSize = 12.f;
    
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
    
    NSString* titleStr = self.chart.name;
    if (titleStr != nil && ![titleStr isKindOfClass:[NSNull class]]) {
        self.title = titleStr;
    }else {
        self.title = @"专题详情";
    }
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMTypeBookStoreTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
    self.headerIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.headerView.frame.size.width - 20 * 2, 80)];
    self.headerIV.layer.cornerRadius = 5;
    self.headerIV.layer.masksToBounds = YES;
    NSString* coverStr = [self.chart.converUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.headerIV sd_setImageWithURL:[NSURL URLWithString:coverStr] placeholderImage:[UIImage imageNamed:@"defaultChoiceDetail"] options:SDWebImageRetryFailed];
    [self.headerIV sd_setImageWithURL:[NSURL URLWithString:coverStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error == nil && image != nil) {
            CGFloat imgWidth = image.size.width;
            CGFloat imgHeight = image.size.height;
            CGFloat headerIVHeight = imgHeight * self.headerIV.frame.size.width / imgWidth;
            
            self.headerIV.frame = CGRectMake(20, 20, self.headerView.frame.size.width - 20 * 2, headerIVHeight);
            CGRect tempFrame = self.otherHeaderView.frame;
            self.otherHeaderView.frame = CGRectMake(0, self.headerIV.frame.origin.y + self.headerIV.frame.size.height + 20, self.headerView.frame.size.width, tempFrame.size.height);
            self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.origin.y + self.otherHeaderView.frame.size.height);
            self.tableView.tableHeaderView = self.headerView;
        }
    }];
    [self.headerView addSubview:self.headerIV];
    
    self.otherHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.headerIV.frame.origin.y + self.headerIV.frame.size.height + 10, self.headerView.frame.size.width, 80)];
    self.otherHeaderView.backgroundColor = [UIColor whiteColor];
    [self.headerView addSubview:self.otherHeaderView];
    
    UILabel* colorLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.headerView.frame.size.width, 10)];
    colorLab.backgroundColor = [UIColor colorWithRed:235.f/255 green:235.f/255 blue:235.f/255 alpha:1];
    [self.otherHeaderView addSubview:colorLab];
    
    self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(20, colorLab.frame.origin.y + colorLab.frame.size.height + 20, self.headerIV.frame.size.width, 20)];
    self.briefLab.font = [UIFont systemFontOfSize:18];
    self.briefLab.text = self.chart.name;
    [self.otherHeaderView addSubview:self.briefLab];
    
    self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(20, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, self.briefLab.frame.size.width, 40)];
    self.detailLab.font = [UIFont systemFontOfSize:15];
    self.detailLab.text = self.chart.abstract;
    self.detailLab.textColor = [UIColor colorWithRed:65.f/255 green:65.f/255 blue:65.f/255 alpha:1];
    self.detailLab.numberOfLines = 0;
    self.detailLab.lineBreakMode = NSLineBreakByCharWrapping;
    [self.otherHeaderView addSubview:self.detailLab];
    
    CGRect detailFrame = self.detailLab.frame;
    CGSize detailSize = [self.detailLab sizeThatFits:CGSizeMake(self.briefLab.frame.size.width, CGFLOAT_MAX)];
    self.detailLab.frame = CGRectMake(detailFrame.origin.x, detailFrame.origin.y, detailFrame.size.width, detailSize.height + 20);
    
    self.otherHeaderView.frame = CGRectMake(0, self.headerIV.frame.origin.y + self.headerIV.frame.size.height, self.headerView.frame.size.width, self.detailLab.frame.origin.y + self.detailLab.frame.size.height);
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.otherHeaderView.frame.origin.y + self.otherHeaderView.frame.size.height);
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.page = 0;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    [self loadSpecialChoiceDetailDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
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
    return self.bookCoverHeight + 20 * 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMTypeBookStoreTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMTypeBookStoreTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Book* book = [self.dataArray objectAtIndex:indexPath.row];
    [cell setupContentBook:book cellHeight:self.bookCoverHeight + 20 * 2 ivWidth:self.bookCoverWidth nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Book* book = [self.dataArray objectAtIndex:indexPath.row];
    
    LMBookDetailViewController* bookDetailVC = [[LMBookDetailViewController alloc]init];
    bookDetailVC.bookId = book.bookId;
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

//加载数据
-(void)loadSpecialChoiceDetailDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    self.isRefreshing = YES;
    
    TopicChartBookReqBuilder* builder = [TopicChartBookReq builder];
    [builder setTcid:self.chart.id];
    [builder setPage:(UInt32)page];
    TopicChartBookReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMSpecialChoiceDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:12 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 12) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    TopicChartBookRes* res = [TopicChartBookRes parseFromData:apiRes.body];
//                    NSInteger currentSize = res.psize;
                    
                    NSArray* arr1 = res.books;
                    if (weakSelf.page == 0) {//第一页
                        [weakSelf.dataArray removeAllObjects];
                    }
                    
                    [weakSelf.dataArray addObjectsFromArray:arr1];
                    
                    if (arr1 == nil || arr1.count == 0) {//最后一页
                        weakSelf.isEnd = YES;
                        [weakSelf.tableView setupNoMoreData];
                    }
                    weakSelf.page ++;
                    [weakSelf.tableView reloadData];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
            weakSelf.isRefreshing = NO;
            [weakSelf hideNetworkLoadingView];
            if (loadMore) {
                [weakSelf.tableView stopLoadMoreData];
            }else {
                [weakSelf.tableView stopRefresh];
            }
        }
    } failureBlock:^(NSError *failureError) {
        weakSelf.isRefreshing = NO;
        [weakSelf hideNetworkLoadingView];
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadSpecialChoiceDetailDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadSpecialChoiceDetailDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
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
