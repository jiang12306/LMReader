//
//  LMProfileBookCommentViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/27.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileBookCommentViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMTool.h"
#import "UIImageView+WebCache.h"
#import "LMProfileBookCommentTableViewCell.h"
#import "LMBookCommentTableViewCell.h"

@interface LMProfileBookCommentViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMProfileBookCommentTableViewCellDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;//
@property (nonatomic, assign) NSInteger page;

@end

@implementation LMProfileBookCommentViewController

static NSString* cellIdentifier = @"cellIdentifier";

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的评论";
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMProfileBookCommentTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.page = 0;
    self.dataArray = [NSMutableArray array];
    
    [self loadBookCommentWithPage:self.page loadMore:NO];
}

-(void)loadBookCommentWithPage:(NSInteger )page loadMore:(BOOL )loadMore {
    AboutMyCommentReqBuilder* builder = [AboutMyCommentReq builder];
    [builder setPage:(UInt32 )page];
    AboutMyCommentReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMProfileBookCommentViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:39 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 39) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    AboutMyCommentRes* res = [AboutMyCommentRes parseFromData:apiRes.body];
                    if (page == 0) {
                        [self.dataArray removeAllObjects];
                    }
                    NSArray* arr = res.commentBook;
                    if (arr.count > 0) {
                        [self.dataArray addObjectsFromArray:arr];
                    }else {
                        [self.tableView setupNoMoreData];
                    }
                    
                    self.page ++;
                    
                    [self.tableView reloadData];
                }else if (err == ErrCodeErrNotlogined) {
                    [weakSelf showMBProgressHUDWithText:@"您尚未登录"];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf hideNetworkLoadingView];
            if (loadMore) {
                [weakSelf.tableView stopLoadMoreData];
            }else {
                [weakSelf.tableView stopRefresh];
            }
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
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
    NSInteger row = indexPath.row;
    CommentBook* commentBook = [self.dataArray objectAtIndex:row];
    Comment* comment = commentBook.comment;
    NSString* commentStr = comment.text;
    if (commentStr != nil && commentStr.length > 0) {
        CGFloat contentHeight = [LMBookCommentTableViewCell caculateLabelHeightWithWidth:self.view.frame.size.width - 10 * 2 text:commentStr font:[UIFont systemFontOfSize:CommentContentFontSize] maxLines:0];
        
        return CommentNameLabHeight + CommentStarViewHeight + contentHeight + CommentLikeBtnHeight + 10 * 5;
    }else {
        return CommentNameLabHeight + CommentStarViewHeight + CommentLikeBtnHeight + 10 * 4;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    LMProfileBookCommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMProfileBookCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    
    CommentBook* commentBook = [self.dataArray objectAtIndex:row];
    
    [cell setupContentWith:commentBook];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    [self.tableView cancelNoMoreData];
    [self loadBookCommentWithPage:self.page loadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    [self loadBookCommentWithPage:self.page loadMore:YES];
}

#pragma mark -LMBookCommentTableViewCellDelegate
-(void)bookCommentTableViewCellDidClickedLike:(LMProfileBookCommentTableViewCell *)cell {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    CommentBook* commentBook = [self.dataArray objectAtIndex:row];
    Comment* comment = commentBook.comment;
    CommentDoType type = CommentDoTypeCommentUp;
    if (comment.isUp) {
        return;
    }
    CommentDoReqBuilder* builder = [CommentDoReq builder];
    [builder setType:type];
    [builder setCommentId:comment.id];
    CommentDoReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMProfileBookCommentViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:38 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            [weakSelf hideNetworkLoadingView];
            
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 38) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                    
                    //刷新
                    self.page = 0;
                    
                    [self loadBookCommentWithPage:self.page loadMore:NO];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

-(void)bookCommentTableViewCellDidClickedDelete:(LMProfileBookCommentTableViewCell *)cell {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    CommentBook* commentBook = [self.dataArray objectAtIndex:row];
    CommentDoType type = CommentDoTypeCommentDel;
    Comment* comment = commentBook.comment;
    
    CommentDoReqBuilder* builder = [CommentDoReq builder];
    [builder setType:type];
    [builder setCommentId:comment.id];
    CommentDoReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMProfileBookCommentViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:38 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            [weakSelf hideNetworkLoadingView];
            
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 38) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                    
                    //
                    [weakSelf.dataArray removeObjectAtIndex:row];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
