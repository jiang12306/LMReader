//
//  LMReadRecordViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReadRecordViewController.h"
#import "LMReadRecordTableViewCell.h"
#import "LMBaseRefreshTableView.h"
#import "LMDatabaseTool.h"
#import "LMBaseNavigationController.h"
#import "LMTool.h"
#import "LMReadRecordModel.h"
#import "LMReaderBookViewController.h"

@interface LMReadRecordViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMReadRecordTableViewCellDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation LMReadRecordViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"阅读记录";
    
    UIView* cleanView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 45, 35)];
    UIButton* cleanItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, cleanView.frame.size.width, cleanView.frame.size.height)];
    cleanItemBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cleanItemBtn setTitle:@"清空" forState:UIControlStateNormal];
    [cleanItemBtn setTitleColor:UIColorFromRGB(0x656565) forState:UIControlStateNormal];
    [cleanItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    [cleanItemBtn addTarget:self action:@selector(clickedCleanButton:) forControlEvents:UIControlEventTouchUpInside];
    [cleanView addSubview:cleanItemBtn];
    UIBarButtonItem* cleanItem = [[UIBarButtonItem alloc]initWithCustomView:cleanView];
    
    self.navigationItem.rightBarButtonItem = cleanItem;
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMReadRecordTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.dataArray = [NSMutableArray array];
    self.page = 0;
    self.size = 20;
    self.isEnd = NO;
    self.isRefreshing = NO;
    
    
    
    //取数据
    [self loadReadRecordDataWithPage:self.page size:self.size loadMoreData:NO];
}

//清空
-(void)clickedCleanButton:(UIButton* )sender {
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    [tool deleteAllReadRecord];
    
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}

-(void)loadReadRecordDataWithPage:(NSInteger )page size:(NSInteger )size loadMoreData:(BOOL )loadMoreData {
    
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    NSArray* arr = [tool queryBookReadRecordWithPage:self.page size:self.size];
    if (arr != nil && arr.count > 0) {
        if (self.page == 0) {
            [self.dataArray removeAllObjects];
        }
        
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:currentDate];
        NSInteger currentHour = [dateComponent hour];
        
        NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970];
        NSMutableArray* todayArray = [NSMutableArray array];
        NSMutableArray* yesterdayArray = [NSMutableArray array];
        NSMutableArray* earlyArray = [NSMutableArray array];
        for (NSInteger i = 0; i < arr.count; i ++) {
            NSDictionary* dic = [arr objectAtIndex:i];
            LMReadRecordModel* model = [[LMReadRecordModel alloc]init];
            model.bookId = [[dic objectForKey:@"bookId"] intValue];
            model.name = [dic objectForKey:@"name"];
            model.chapterId = [dic objectForKey:@"chapterId"];
            model.chapterNo = [[dic objectForKey:@"chapterNo"] intValue];
            model.chapterTitle = [dic objectForKey:@"chapterTitle"];
            model.sourceId = [[dic objectForKey:@"sourceId"] intValue];
            model.offset = [[dic objectForKey:@"offset"] intValue];
            NSDate* date = [dic objectForKey:@"date"];
            model.dateStr = [LMTool convertDateToTime:date];
            model.isCollected = [[LMDatabaseTool sharedDatabaseTool] checkUserBooksIsExistWithBookId:model.bookId];
            model.coverStr = [dic objectForKey:@"cover"];
            
            NSTimeInterval timeStamp = [date timeIntervalSince1970];
            int timeInt = nowTimeinterval - timeStamp; //时间差
            int hour = timeInt / 3600;//小时
            int day = timeInt / (3600 * 24);
            
            if (hour <= currentHour || day < 1) {
                model.dayInteger = 0;
                [todayArray addObject:model];
            }else if (hour >= 24 && day == 1) {
                model.dayInteger = 1;
                [yesterdayArray addObject:model];
            }else {
                model.dayInteger = 2;
                [earlyArray addObject:model];
            }
        }
        if (todayArray.count > 0) {
            [self.dataArray addObject:todayArray];
        }
        if (yesterdayArray.count > 0) {
            [self.dataArray addObject:yesterdayArray];
        }
        if (earlyArray.count > 0) {
            [self.dataArray addObject:earlyArray];
        }
        
        [self.tableView reloadData];
        self.page ++;
    }else {
        self.isEnd = YES;
        [self.tableView setupNoMoreData];
    }
    if (loadMoreData) {
        [self.tableView stopLoadMoreData];
    }else {
        [self.tableView stopRefresh];
    }
    
    if (self.dataArray.count == 0) {
        [self showEmptyLabelWithText:nil];
    }else {
        [self hideEmptyLabel];
    }
    
    self.isRefreshing = NO;
    [self.tableView stopLoadMoreData];
    [self hideNetworkLoadingView];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    vi.backgroundColor = [UIColor whiteColor];
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 20)];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
    [vi addSubview:lab];
    NSString* labText = @"";
    NSArray* arr = [self.dataArray objectAtIndex:section];
    if (arr.count > 0) {
        LMReadRecordModel* model = [arr firstObject];
        if (model.dayInteger == 0) {
            labText = @"今天";
        }else if (model.dayInteger == 1) {
            labText = @"昨天";
        }else {
            labText = @"更早";
        }
    }
    lab.text = labText;
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat tempHeight = 10;
    if (self.dataArray.count - 1 == section) {
        tempHeight = 0.01;
    }
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tempHeight)];
    vi.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255 alpha:1];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* arr = [self.dataArray objectAtIndex:section];
    return arr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.dataArray.count - 1 == section) {
        return 0.01;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMReadRecordTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMReadRecordTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showLineView:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* arr = [self.dataArray objectAtIndex:section];
    LMReadRecordModel* model = [arr objectAtIndex:row];
    [cell setupReadRecordWithModel:model];
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* arr = [self.dataArray objectAtIndex:section];
    LMReadRecordModel* model = [arr objectAtIndex:row];
    NSString* nameStr = model.name;
    UInt32 bookId = model.bookId;
    
    __weak LMReadRecordViewController* weakSelf = self;
    
    LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
    readerBookVC.bookId = bookId;
    readerBookVC.bookCover = model.coverStr;
    readerBookVC.bookName = nameStr;
    readerBookVC.callBlock = ^(BOOL resetOrder) {
        //刷新
        weakSelf.page = 0;
        weakSelf.isEnd = NO;
        [weakSelf.tableView cancelNoMoreData];
        [weakSelf loadReadRecordDataWithPage:weakSelf.page size:weakSelf.size loadMoreData:NO];
    };
    LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
    [self presentViewController:bookNavi animated:YES completion:nil];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadReadRecordDataWithPage:self.page size:self.size loadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadReadRecordDataWithPage:self.page size:self.size  loadMoreData:YES];
}

#pragma mark -LMReadRecordTableViewCellDelegate
-(void)didStartScrollCell:(LMReadRecordTableViewCell* )selectedCell {
    NSInteger section = [self.tableView numberOfSections];
    for (NSInteger j = 0; j < section; j ++) {
        NSInteger rows = [self.tableView numberOfRowsInSection:j];
        for (NSInteger i = 0; i < rows; i ++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            LMReadRecordTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell == selectedCell) {
                continue;
            }
            [cell showCollectAndDelete:NO animation:YES];
        }
    }
}

-(void)didClickCell:(LMReadRecordTableViewCell* )cell deleteButton:(UIButton* )btn {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray* arr = [self.dataArray objectAtIndex:indexPath.section];
    LMReadRecordModel* model = [arr objectAtIndex:indexPath.row];
    [[LMDatabaseTool sharedDatabaseTool]deleteBookReadRecordWithBookId:model.bookId];
    
    [arr removeObject:model];
    if (arr.count == 0) {
        [self.dataArray removeObject:arr];
    }
    [self.tableView reloadData];
}

-(void)didClickCell:(LMReadRecordTableViewCell* )cell collectButton:(UIButton* )btn {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSArray* arr = [self.dataArray objectAtIndex:indexPath.section];
    LMReadRecordModel* model = [arr objectAtIndex:indexPath.row];
    
    [self showNetworkLoadingView];
    
    UserBookStoreOperateType type = UserBookStoreOperateTypeOperateAdd;
    if (model.isCollected) {
        type = UserBookStoreOperateTypeOperateDel;
    }
    UserBookStoreOperateReqBuilder* builder = [UserBookStoreOperateReq builder];
    [builder setBookId:model.bookId];
    [builder setType:type];
    UserBookStoreOperateReq* req = [builder build];
    NSData* reqData = [req data];
    
    __weak LMReadRecordViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:4 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 4) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    if (model.isCollected) {
                        model.isCollected = NO;
                    }else {
                        model.isCollected = YES;
                    }
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    //通知书架界面刷新
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBookShelfViewController" object:nil];
                    
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                }else if (err == ErrCodeErrCannotadddelmodify) {//无法增删改
                    [weakSelf showMBProgressHUDWithText:@"操作失败"];
                }else if (err == ErrCodeErrBooknotexist) {//书本不存在
                    
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
    
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
