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
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
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

-(void)loadReadRecordDataWithPage:(NSInteger )page size:(NSInteger )size loadMoreData:(BOOL )loadMoreData {
    
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    NSArray* arr = [tool queryBookReadRecordWithPage:self.page size:self.size];
    if (arr != nil && arr.count > 0) {
        if (self.page == 0) {
            [self.dataArray removeAllObjects];
        }
        for (NSDictionary* dic in arr) {
            LMReadRecordModel* model = [[LMReadRecordModel alloc]init];
            model.bookId = [[dic objectForKey:@"bookId"] intValue];
            model.name = [dic objectForKey:@"name"];
            model.chapterId = [[dic objectForKey:@"chapterId"] intValue];
            model.chapterNo = [[dic objectForKey:@"chapterNo"] intValue];
            model.chapterTitle = [dic objectForKey:@"chapterTitle"];
            model.sourceId = [[dic objectForKey:@"sourceId"] intValue];
            model.offset = [[dic objectForKey:@"offset"] intValue];
            NSDate* date = [dic objectForKey:@"date"];
            model.dateStr = [LMTool convertDateToTime:date];
            model.isCollected = [[LMDatabaseTool sharedDatabaseTool] checkUserBooksIsExistWithBookId:model.bookId];
            
            [self.dataArray addObject:model];
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
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMReadRecordTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMReadRecordTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    LMReadRecordModel* model = [self.dataArray objectAtIndex:row];
    [cell setupReadRecordWithModel:model];
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    LMReadRecordModel* model = [self.dataArray objectAtIndex:row];
    NSString* nameStr = model.name;
    UInt32 bookId = model.bookId;
    
    __weak LMReadRecordViewController* weakSelf = self;
    
    LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
    readerBookVC.bookId = bookId;
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
    NSInteger section = 0;
    NSInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < rows; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        LMReadRecordTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell == selectedCell) {
            continue;
        }
        [cell showCollectAndDelete:NO animation:YES];
    }
}

-(void)didClickCell:(LMReadRecordTableViewCell* )cell deleteButton:(UIButton* )btn {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LMReadRecordModel* model = [self.dataArray objectAtIndex:indexPath.row];
    [[LMDatabaseTool sharedDatabaseTool]deleteBookReadRecordWithBookId:model.bookId];
    
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)didClickCell:(LMReadRecordTableViewCell* )cell collectButton:(UIButton* )btn {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LMReadRecordModel* model = [self.dataArray objectAtIndex:indexPath.row];
    
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
