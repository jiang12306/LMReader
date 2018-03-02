//
//  LMInterestOrEndViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMInterestOrEndViewController.h"
#import "LMBaseBookTableViewCell.h"
#import "LMBookDetailViewController.h"
#import "LMBaseRefreshTableView.h"

@interface LMInterestOrEndViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@end

@implementation LMInterestOrEndViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 95;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"兴趣推荐";
    if (self.type == LMEndType) {
        self.title = @"完结经典";
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.page = 0;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    [self loadInterestOrEndDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
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
    bookDetailVC.book = book;
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

//加载数据
-(void)loadInterestOrEndDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    TopicHomeReqBuilder* builder = [TopicHomeReq builder];
    if (self.type == LMInterestType) {
        [builder setType:1];
    }else {
        [builder setType:2];
    }
    [builder setPage:(UInt32)page];
    TopicHomeReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:10 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 10) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                TopicHomeRes* res = [TopicHomeRes parseFromData:apiRes.body];
                NSInteger currentSize = res.psize;
                
                NSArray* arr1;
                if (self.type == LMInterestType) {
                    arr1 = res.interestBooks;
                }else {
                    arr1 = res.finishBooks;
                }
                if (self.page == 0) {//第一页
                    [self.dataArray removeAllObjects];
                }
                if (arr1.count > 0) {
                    [self.dataArray addObjectsFromArray:arr1];
                }
                
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
    
    [self loadInterestOrEndDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadInterestOrEndDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
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
