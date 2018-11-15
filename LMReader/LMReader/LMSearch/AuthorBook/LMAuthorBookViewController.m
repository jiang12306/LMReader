//
//  LMAuthorBookViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/14.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMAuthorBookViewController.h"
#import "LMBookDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMTypeBookStoreTableViewCell.h"
#import "LMTool.h"
#import "LMAuthorBookFilterListView.h"

@interface LMAuthorBookViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) LMBaseRefreshTableView* tableView;

@property (nonatomic, strong) UIButton* renQiBtn;
@property (nonatomic, strong) UIButton* shangShengBtn;
@property (nonatomic, strong) UIButton* gengXinBtn;
@property (nonatomic, assign) LMBookStoreState bookState;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//

@end

@implementation LMAuthorBookViewController

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
    
    if (self.author != nil) {
        self.title = self.author;
    }else {
        self.title = @"作者作品";
    }
    
    UIView* filtView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 25)];
    UIButton* filtItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, filtView.frame.size.width, filtView.frame.size.height)];
    [filtItemBtn setImage:[[UIImage imageNamed:@"rightBarButtonItem_Filter"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [filtItemBtn setTintColor:UIColorFromRGB(0x656565)];
    [filtItemBtn addTarget:self action:@selector(clickedFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    [filtView addSubview:filtItemBtn];
    UIBarButtonItem* filtItem = [[UIBarButtonItem alloc]initWithCustomView:filtView];
    
    self.navigationItem.rightBarButtonItem = filtItem;
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    
    CGFloat btnWidth = self.view.frame.size.width / 3;
    CGFloat btnHeight = 40;
    self.shangShengBtn = [self createButtonWithFrame:CGRectMake(0, 0, btnWidth, btnHeight) title:@"周点击" isSelected:YES];
    [self.view addSubview:self.shangShengBtn];
    self.renQiBtn = [self createButtonWithFrame:CGRectMake(self.shangShengBtn.frame.origin.x + self.shangShengBtn.frame.size.width, self.shangShengBtn.frame.origin.y, btnWidth, btnHeight) title:@"按人气" isSelected:NO];
    [self.view addSubview:self.renQiBtn];
    self.gengXinBtn = [self createButtonWithFrame:CGRectMake(self.renQiBtn.frame.origin.x + self.renQiBtn.frame.size.width, self.shangShengBtn.frame.origin.y, btnWidth, btnHeight) title:@"按更新" isSelected:NO];
    [self.view addSubview:self.gengXinBtn];
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, self.renQiBtn.frame.origin.y + self.renQiBtn.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - naviHeight - self.shangShengBtn.frame.size.height) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }else {
        
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMTypeBookStoreTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    self.bookState = LMBookStoreStateAll;
    
    self.page = 0;
    self.isEnd = NO;
    self.dataArray = [NSMutableArray array];
    [self loadAuthorBookWithPage:self.page isRefreshingOrLoadMoreData:NO isRefreshing:YES];
}

-(UIButton* )createButtonWithFrame:(CGRect )frame title:(NSString* )titleStr isSelected:(BOOL )isSelected {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    btn.backgroundColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:THEMEORANGECOLOR forState:UIControlStateSelected];
    if (isSelected) {
        btn.selected = YES;
    }else {
        btn.selected = NO;
    }
    [btn addTarget:self action:@selector(clickedTypeButton:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)clickedTypeButton:(UIButton* )sender {
    if (sender.selected == YES) {
        return;
    }
    
    self.renQiBtn.selected = NO;
    self.shangShengBtn.selected = NO;
    self.gengXinBtn.selected = NO;
    sender.selected = YES;
    
    [self.tableView startRefresh];
}

-(void)clickedFilterButton:(UIButton* )sender {
    LMAuthorBookFilterListView* listView = [[LMAuthorBookFilterListView alloc]initWithFrame:CGRectMake(0, 0, 180, 80)];
    listView.bookState = self.bookState;
    listView.stateBlock = ^(LMBookStoreState state) {
        if (state == self.bookState) {
            return;
        }
        self.bookState = state;
        
        [self.tableView startRefresh];
    };
    [listView showToView:sender];
}

-(void)loadAuthorBookWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore isRefreshing:(BOOL )isRefreshing {
    [self showNetworkLoadingView];
    
    UInt32 isNew = 1;
    if (self.renQiBtn.selected == YES) {
        isNew = 1;
    }else if (self.shangShengBtn.selected == YES) {
        isNew = 3;
    }else if (self.gengXinBtn.selected == YES) {
        isNew = 2;
    }
    UInt32 stateInt = 0;
    if (self.bookState == LMBookStoreStateAll) {
        stateInt = 0;
    }else if (self.bookState == LMBookStoreStateLoad) {
        stateInt = 1;
    }else if (self.bookState == LMBookStoreStateFinished) {
        stateInt = 2;
    }
    
    AuthorBookReqBuilder* builder = [AuthorBookReq builder];
    [builder setBookState:stateInt];
    [builder setIsNew:isNew];
    [builder setPage:(UInt32)page];
    [builder setAuthor:self.author];
    AuthorBookReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMAuthorBookViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:31 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 31) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    AuthorBookRes* res = [AuthorBookRes parseFromData:apiRes.body];
                    
                    NSArray* arr = res.books;
                    if (isRefreshing) {//第一页
                        [weakSelf.dataArray removeAllObjects];
                    }
                    if (arr.count > 0) {
                        [weakSelf.dataArray addObjectsFromArray:arr];
                    }
                    if (arr == nil || arr.count == 0) {//最后一页
                        weakSelf.isEnd = YES;
                        [weakSelf.tableView setupNoMoreData];
                    }
                    [weakSelf.tableView reloadData];
                    
                    if (weakSelf.dataArray.count == 0) {
                        [weakSelf showMBProgressHUDWithText:@"暂无该作者相关书籍"];
                    }
                    weakSelf.page ++;
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
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.bookCoverHeight + 20 * 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
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
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.bookId = book.bookId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadAuthorBookWithPage:self.page isRefreshingOrLoadMoreData:NO isRefreshing:YES];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadAuthorBookWithPage:self.page isRefreshingOrLoadMoreData:YES isRefreshing:NO];
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
