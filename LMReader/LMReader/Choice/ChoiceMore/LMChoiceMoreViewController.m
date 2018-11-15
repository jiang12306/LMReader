//
//  LMChoiceMoreViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/26.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMChoiceMoreViewController.h"
#import "LMTypeBookStoreTableViewCell.h"
#import "LMBookDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMTool.h"

@interface LMChoiceMoreViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//

@end

@implementation LMChoiceMoreViewController

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
    
    if (self.moreName != nil && self.moreName.length > 0) {
        self.title = self.moreName;
    }else {
        self.title = @"更多";
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
    
    self.page = 1;
    self.isEnd = NO;
    self.isRefreshing = NO;
    self.dataArray = [NSMutableArray array];
    
    [self loadChoiceMoreDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
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
-(void)loadChoiceMoreDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    
    [self showNetworkLoadingView];
    
    self.isRefreshing = YES;
    
    SelfDefinedMoreReqBuilder* builder = [SelfDefinedMoreReq builder];
    [builder setSelfId:self.moreId];
    [builder setPage:(UInt32)page];
    SelfDefinedMoreReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMChoiceMoreViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:44 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 44) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SelfDefinedMoreRes* res = [SelfDefinedMoreRes parseFromData:apiRes.body];
                    
                    NSArray* arr1 = res.books;
                    if (weakSelf.page == 1) {//第一页
                        [weakSelf.dataArray removeAllObjects];
                        if (arr1.count == 0) {
                            [weakSelf showMBProgressHUDWithText:@"空空如也"];
                        }
                    }
                    if (arr1.count > 0) {
                        [weakSelf hideEmptyLabel];
                        
                        [weakSelf.dataArray addObjectsFromArray:arr1];
                    }else {//最后一页
                        weakSelf.isEnd = YES;
                        [weakSelf.tableView setupNoMoreData];
                    }
                    if (weakSelf.dataArray.count == 0) {
                        [weakSelf showEmptyLabelWithText:nil];
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
    self.page = 1;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadChoiceMoreDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadChoiceMoreDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
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
