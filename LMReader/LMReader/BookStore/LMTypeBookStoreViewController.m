//
//  LMTypeBookStoreViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/24.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMTypeBookStoreViewController.h"
#import "LMBaseBookTableViewCell.h"
#import "LMBaseRefreshTableView.h"
#import "LMTool.h"

@interface LMTypeBookStoreViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* upsideView;//top 视图
@property (nonatomic, strong) UIButton* upsideBtn;//top button
@property (nonatomic, assign) UInt32 page;//当前页数
@property (nonatomic, assign) BOOL isEnd;//尾页

@end

@implementation LMTypeBookStoreViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat naviHeight = 20 + 44;
    CGFloat tabBarHeight = 49;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
        tabBarHeight = 83;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight -tabBarHeight - 40) style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.estimatedRowHeight = 0;//修复iOS11上拉刷新时会跳动问题
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    self.tableView.tableHeaderView = headerVi;
    
    UIView* footerVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    self.tableView.tableFooterView = footerVi;
    
    //置顶按钮
    [self.view addSubview:self.upsideView];
    self.upsideView.hidden = YES;
    
    self.dataArray = [NSMutableArray array];
    self.page = 0;
    self.isEnd = NO;
    
    //
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:NO];
}

//置顶按钮
-(UIView *)upsideView {
    if (!_upsideView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat btnWidth = 50;
        CGFloat tabBarHeight = 49;
        CGFloat naviHeight = 64;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
            naviHeight = 88;
        }
        _upsideView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnWidth)];
        _upsideView.layer.cornerRadius = btnWidth/2;
        _upsideView.layer.masksToBounds = YES;
        self.upsideBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnWidth)];
        [self.upsideBtn setImage:[UIImage imageNamed:@"bookStore_Top"] forState:UIControlStateNormal];
        [self.upsideBtn addTarget:self action:@selector(clickedUpsideButton:) forControlEvents:UIControlEventTouchUpInside];
        [_upsideView addSubview:self.upsideBtn];
        _upsideView.center = CGPointMake(screenRect.size.width - 10 - btnWidth / 2, screenRect.size.height - 15 - tabBarHeight - naviHeight - btnWidth / 2 - 40);
    }
    return _upsideView;
}

//回到顶部
-(void)clickedUpsideButton:(UIButton* )sender {
    if (self.dataArray.count == 0) {
        return;
    }
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self.tableView startRefresh];
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
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(typeBookStoreViewControllerDidClickedBookId:)]) {
        [self.delegate typeBookStoreViewControllerDidClickedBookId:book.bookId];
    }
}

//根据类型筛选
-(void)loadBookStoreDataWithPage:(NSInteger )page isLoadMoreData:(BOOL )loadMore {
    UInt32 isNew = 1;
    if (self.bookRange == LMBookStoreRangeNew) {
        isNew = 2;
    }else if (self.bookRange == LMBookStoreRangeUp) {
        isNew = 3;
    }
    BookStoreReqBuilder* builder = [BookStoreReq builder];
    [builder setBookTypeArray:self.filterArr];
    [builder setPage:(UInt32)page];
    if (self.bookState == LMBookStoreStateLoad) {
        [builder setIsFinished:1];
    }else if (self.bookState == LMBookStoreStateFinished) {
        [builder setIsFinished:2];
    }
    [builder setIsNew:isNew];
    BookStoreReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMTypeBookStoreViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:5 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 5) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookStoreRes* res = [BookStoreRes parseFromData:apiRes.body];
                    NSArray* arr = res.books;
                    
                    if (weakSelf.page == 0) {
                        [weakSelf.dataArray removeAllObjects];
                    }
                    if (arr.count > 0) {
                        weakSelf.page ++;
                        [weakSelf.dataArray addObjectsFromArray:arr];
                    }
                    if (arr == nil || arr.count == 0) {//最后一页  改
                        weakSelf.isEnd = YES;
                        [weakSelf.tableView setupNoMoreData];
                    }
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            if (loadMore) {
                [weakSelf.tableView stopLoadMoreData];
            }else {
                [weakSelf.tableView stopRefresh];
            }
            [weakSelf.tableView reloadData];
            [weakSelf hideNetworkLoadingView];
            if (weakSelf.page == 0 && weakSelf.dataArray.count == 0) {
                [weakSelf showReloadButton];
                [weakSelf showMBProgressHUDWithText:@"暂无数据"];
            }
        }
    } failureBlock:^(NSError *failureError) {
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        if (weakSelf.page == 0 && weakSelf.dataArray.count == 0) {
            [weakSelf showReloadButton];
        }
    }];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:YES];
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        if (self.tableView.contentOffset.y > baseBookCellHeight) {
            self.upsideView.hidden = NO;
        }else {
            self.upsideView.hidden = YES;
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
