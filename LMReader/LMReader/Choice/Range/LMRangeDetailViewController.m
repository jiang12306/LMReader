//
//  LMRangeDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRangeDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMBaseBookTableViewCell.h"
#import "LMAdvertisementTableViewCell.h"
#import "LMBookDetailViewController.h"

@interface LMRangeDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@end

@implementation LMRangeDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* adCellIdentifier = @"adCellIdentifier";
static CGFloat cellHeight = 95;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.title = @"兴趣推荐或完结推荐";
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMAdvertisementTableViewCell class] forCellReuseIdentifier:adCellIdentifier];
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.page = 0;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    [self loadRangeDetailDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
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
    if (self.dataArray.count == 0) {
        return 0;
    }
    NSInteger adCount = self.dataArray.count / 4;
    return self.dataArray.count + adCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count == 0) {
        
    }else {
        if (indexPath.row != 0 && indexPath.row % 4 == 0) {
            return 50;
        }
    }
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0 && indexPath.row % 4 == 0) {
        LMAdvertisementTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:adCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMAdvertisementTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        
        return cell;
    }else {
        LMBaseBookTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMBaseBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSInteger index = indexPath.row/4;
        
        Book* book = [self.dataArray objectAtIndex:indexPath.row - index];
        
        [cell setupContentBook:book];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row != 0 && indexPath.row % 4 == 0) {
        
    }else {
        NSInteger index = indexPath.row/4;
        
        Book* book = [self.dataArray objectAtIndex:indexPath.row - index];
        
        LMBookDetailViewController* bookDetailVC = [[LMBookDetailViewController alloc]init];
        bookDetailVC.book = book;
        [self.navigationController pushViewController:bookDetailVC animated:YES];
    }
}

//加载数据
-(void)loadRangeDetailDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    TopicChartBookReqBuilder* builder = [TopicChartBookReq builder];
    [builder setTcid:self.rangeId];
    [builder setPage:(UInt32)page];
    TopicChartBookReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:12 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 12) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                TopicChartBookRes* res = [TopicChartBookRes parseFromData:apiRes.body];
                NSInteger currentSize = res.psize;
                
                NSArray* arr1 = res.books;
                if (self.page == 0) {//第一页
                    [self.dataArray removeAllObjects];
                }
                
                [self.dataArray addObjectsFromArray:arr1];
                
                if (arr1.count < currentSize) {//最后一页
                    self.isEnd = YES;
                    [self.tableView setupNoMoreData];
                }
                self.page ++;
                [self.tableView reloadData];
            }
        }
        self.isRefreshing = NO;
        [self hideNetworkLoadingView];
        if (loadMore) {
            [self.tableView stopLoadMoreData];
        }else {
            [self.tableView stopRefresh];
        }
    } failureBlock:^(NSError *failureError) {
        self.isRefreshing = NO;
        [self hideNetworkLoadingView];
        if (loadMore) {
            [self.tableView stopLoadMoreData];
        }else {
            [self.tableView stopRefresh];
        }
    }];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadRangeDetailDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadRangeDetailDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
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
