//
//  LMSpecialChoiceDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceDetailViewController.h"
#import "LMBaseBookTableViewCell.h"
#import "LMBookDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "UIImageView+WebCache.h"

@interface LMSpecialChoiceDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIImageView* headerIV;
@property (nonatomic, strong) UILabel* briefLab;//专题简介
@property (nonatomic, strong) UILabel* detailLab;//专题详情
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@end

@implementation LMSpecialChoiceDetailViewController

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
    self.title = @"专题详情";
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
    self.headerIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.headerView.frame.size.width - 10 * 2, 80)];
    self.headerIV.layer.cornerRadius = 5;
    self.headerIV.layer.masksToBounds = YES;
    [self.headerIV sd_setImageWithURL:[NSURL URLWithString:self.chart.converUrl] placeholderImage:[UIImage imageNamed:@"test1"] options:SDWebImageRetryFailed];
    [self.headerView addSubview:self.headerIV];
    
    self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.headerIV.frame.origin.y + self.headerIV.frame.size.height, self.headerIV.frame.size.width, 40)];
    self.briefLab.font = [UIFont systemFontOfSize:20];
    self.briefLab.text = self.chart.name;
    [self.headerView addSubview:self.briefLab];
    
    self.detailLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, self.briefLab.frame.size.width, 40)];
    self.detailLab.font = [UIFont systemFontOfSize:16];
    self.detailLab.text = self.chart.abstract;
    self.detailLab.numberOfLines = 0;
    self.detailLab.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.headerView addSubview:self.detailLab];
    
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 10 + self.headerIV.frame.size.height + self.briefLab.frame.size.height + self.detailLab.frame.size.height);
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.page = 0;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    [self loadSpecialChoiceDetailDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
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
-(void)loadSpecialChoiceDetailDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    TopicChartBookReqBuilder* builder = [TopicChartBookReq builder];
    [builder setTcid:self.chart.id];
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
