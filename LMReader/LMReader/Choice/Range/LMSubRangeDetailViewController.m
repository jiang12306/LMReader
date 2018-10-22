//
//  LMSubRangeDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSubRangeDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMBaseBookTableViewCell.h"
#import "LMBookDetailViewController.h"
#import "LMTool.h"

@interface LMSubRangeDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@end

@implementation LMSubRangeDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* adCellIdentifier = @"adCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat naviHeight = 20 + 44;
    CGFloat titleViewHeight = 40;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight - titleViewHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    self.tableView.tableHeaderView = headerVi;
    
    CGFloat footerViHeight = 0.01;
//    if ([LMTool isBangsScreen]) {
//        footerViHeight = 44;
//    }
    UIView* footerVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerViHeight)];
    self.tableView.tableFooterView = footerVi;
    
    self.page = 0;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    [self loadSubRangeDetailDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    vi.backgroundColor = [UIColor whiteColor];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    vi.backgroundColor = [UIColor whiteColor];
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
    return baseBookCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMBaseBookTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBaseBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Book* book = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell setupContentBook:book];
    
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
-(void)loadSubRangeDetailDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    self.isRefreshing = YES;
    
    TopicChartBookReqBuilder* builder = [TopicChartBookReq builder];
    [builder setTcid:self.rangeId];
    [builder setPage:(UInt32)page];
    [builder setT2Id:self.titleRangeId];
    TopicChartBookReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMSubRangeDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:12 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 12) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    TopicChartBookRes* res = [TopicChartBookRes parseFromData:apiRes.body];
                    
                    NSArray* arr1 = res.books;
                    if (weakSelf.page == 0) {//第一页
                        [weakSelf.dataArray removeAllObjects];
                    }
                    if (arr1.count > 0) {
                        [weakSelf.dataArray addObjectsFromArray:arr1];
                    }else {//最后一页
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
            
        }
        weakSelf.isRefreshing = NO;
        [weakSelf hideNetworkLoadingView];
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
        if (weakSelf.dataArray.count == 0) {
            [weakSelf showMBProgressHUDWithText:@"空空如也"];
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
    
    [self loadSubRangeDetailDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadSubRangeDetailDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
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
