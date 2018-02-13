//
//  LMSearchViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMBaseBookTableViewCell.h"
#import "LMAdvertisementTableViewCell.h"

@interface LMSearchViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* resultArray;//搜索结果
@property (nonatomic, strong) NSMutableArray* relatedArray;//相关结果
@property (nonatomic, strong) UITextField* searchTF;//搜索框
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中

@end

@implementation LMSearchViewController

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
    self.title = @"搜索结果";
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMAdvertisementTableViewCell class] forCellReuseIdentifier:adCellIdentifier];
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    self.searchTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, headerView.frame.size.width - 10 * 2, headerView.frame.size.height - 10 * 2)];
    self.searchTF.placeholder = @"搜索小说";
    self.searchTF.layer.borderColor = [UIColor grayColor].CGColor;
    self.searchTF.layer.borderWidth = 1;
    self.searchTF.layer.cornerRadius = 5;
    self.searchTF.layer.masksToBounds = YES;
    self.searchTF.keyboardType = UIKeyboardTypeWebSearch;
    self.searchTF.delegate = self;
    [headerView addSubview:self.searchTF];
    self.tableView.tableHeaderView = headerView;
    
    self.page = 0;
    self.resultArray = [NSMutableArray array];
    self.relatedArray = [NSMutableArray array];
    
    //
    if (self.searchStr.length > 0) {
        [self loadSearchDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        vi.backgroundColor = [UIColor whiteColor];
        return vi;
    }
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    vi.backgroundColor = [UIColor whiteColor];
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, vi.frame.size.width, vi.frame.size.height)];
    lab.font = [UIFont systemFontOfSize:16];
    NSString* str = @"搜索结果";
    if (section == 2) {
        str = @"相关推荐";
    }
    lab.text = str;
    [vi addSubview:lab];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    vi.backgroundColor = [UIColor grayColor];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.resultArray.count;
    }else if (section == 1) {
        return 1;
    }else if (section == 2) {
        return self.relatedArray.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 30;
    }else if (section == 1) {
        return 0;
    }else if (section == 2) {
        return 30;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }else if (section == 1) {
        return 10;
    }else if (section == 2) {
        return 10;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 50;
    }
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
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
        Book* book;
        if (indexPath.section == 0) {
            book = [self.resultArray objectAtIndex:indexPath.row];
        }else if (indexPath.section == 2) {
            book = [self.relatedArray objectAtIndex:indexPath.row];
        }
        
        [cell setupContentBook:book];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}

//
-(void)loadSearchDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    BookSearchReqBuilder* builder = [BookSearchReq builder];
    [builder setPage:(UInt32)page];
    [builder setKw:self.searchStr];
    BookSearchReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:6 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 6) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                BookSearchRes* res = [BookSearchRes parseFromData:apiRes.body];
                NSInteger currentSize = res.psize;
                
                NSArray* arr1 = res.books;
                NSArray* arr2 = res.relateBooks;
                if (self.page == 0) {//第一页
                    [self.resultArray removeAllObjects];
                }
                
                [self.relatedArray removeAllObjects];
                
                [self.resultArray addObjectsFromArray:arr1];
                [self.relatedArray addObjectsFromArray:arr2];
                
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
    
    [self loadSearchDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadSearchDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString* str = [self.searchTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (str.length > 0) {
        self.searchStr = str;
        self.page = 0;
        [self loadSearchDataWithPage:0 isRefreshingOrLoadMoreData:NO];
    }
    [self.searchTF resignFirstResponder];
    return YES;
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
