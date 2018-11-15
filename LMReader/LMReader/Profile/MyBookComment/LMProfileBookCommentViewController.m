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
#import "LMProfileBookCommentModel.h"

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
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
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
                        NSDate *currentDate = [NSDate date];
                        NSCalendar *calendar = [NSCalendar currentCalendar];
                        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
                        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:currentDate];
                        NSInteger currentHour = [dateComponent hour];
                        
                        NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                        
                        NSMutableArray* todayArray = [NSMutableArray array];
                        NSMutableArray* yesterdayArray = [NSMutableArray array];
                        NSMutableArray* earlyArray = [NSMutableArray array];
                        if (page != 0) {
                            if (self.dataArray.count == 1) {
                                NSMutableArray* firstArray = [self.dataArray firstObject];
                                if (firstArray.count > 0) {
                                    LMProfileBookCommentModel* firstModel = [firstArray firstObject];
                                    if (firstModel.dayInteger == 0) {
                                        todayArray = [self.dataArray firstObject];
                                    }else if (firstModel.dayInteger == 1) {
                                        yesterdayArray = [self.dataArray firstObject];
                                    }else {
                                        earlyArray = [self.dataArray firstObject];
                                    }
                                }
                            }else if (self.dataArray.count == 2) {
                                NSMutableArray* firstArray = [self.dataArray firstObject];
                                if (firstArray.count > 0) {
                                    LMProfileBookCommentModel* firstModel = [firstArray firstObject];
                                    if (firstModel.dayInteger == 0) {
                                        todayArray = [self.dataArray firstObject];
                                    }else if (firstModel.dayInteger == 1) {
                                        yesterdayArray = [self.dataArray firstObject];
                                    }else {
                                        earlyArray = [self.dataArray firstObject];
                                    }
                                }
                                NSMutableArray* secondArray = [self.dataArray objectAtIndex:1];
                                if (secondArray.count > 0) {
                                    LMProfileBookCommentModel* firstModel = [secondArray firstObject];
                                    if (firstModel.dayInteger == 0) {
                                        todayArray = [self.dataArray objectAtIndex:1];
                                    }else if (firstModel.dayInteger == 1) {
                                        yesterdayArray = [self.dataArray objectAtIndex:1];
                                    }else {
                                        earlyArray = [self.dataArray objectAtIndex:1];
                                    }
                                }
                            }else if (self.dataArray.count == 3) {
                                todayArray = [self.dataArray firstObject];
                                yesterdayArray = [self.dataArray objectAtIndex:1];
                                earlyArray = [self.dataArray objectAtIndex:2];
                            }
                        }
                        for (NSInteger i = 0; i < arr.count; i ++) {
                            CommentBook* commentBook = [arr objectAtIndex:i];
                            LMProfileBookCommentModel* model = [[LMProfileBookCommentModel alloc]init];
                            NSString* timeStr = commentBook.comment.cT;
                            NSDate* date = [dateFormatter dateFromString:timeStr];
                            NSTimeInterval timeStamp = [date timeIntervalSince1970];
                            int timeInt = nowTimeinterval - timeStamp; //时间差
                            int hour = timeInt / 3600;//小时
                            int day = timeInt / (3600 * 24);
                            
                            model.commentBook = commentBook;
                            model.dayInteger = day;
                            if (hour <= currentHour) {
                                [todayArray addObject:model];
                            }else if (hour > 24 && day == 1) {
                                [yesterdayArray addObject:model];
                            }else {
                                [earlyArray addObject:model];
                            }
                        }
                        if (page == 0) {
                            if (todayArray.count > 0) {
                                [self.dataArray addObject:todayArray];
                            }
                            if (yesterdayArray.count > 0) {
                                [self.dataArray addObject:yesterdayArray];
                            }
                            if (earlyArray.count > 0) {
                                [self.dataArray addObject:earlyArray];
                            }
                        }
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
    vi.backgroundColor = [UIColor whiteColor];
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 20)];
    lab.font = [UIFont systemFontOfSize:12];
    lab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
    [vi addSubview:lab];
    NSString* labText = @"";
    NSArray* arr = [self.dataArray objectAtIndex:section];
    if (arr.count > 0) {
        LMProfileBookCommentModel* model = [arr firstObject];
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
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* arr = [self.dataArray objectAtIndex:section];
    LMProfileBookCommentModel* model = [arr objectAtIndex:row];
    CommentBook* commentBook = model.commentBook;
    Comment* comment = commentBook.comment;
    NSString* commentStr = comment.text;
    if (commentStr != nil && commentStr.length > 0) {
        CGFloat contentHeight = [LMBookCommentTableViewCell caculateLabelHeightWithWidth:self.view.frame.size.width - 20 * 2 text:commentStr font:[UIFont systemFontOfSize:CommentContentFontSize] maxLines:0];
        
        return 20 + CommentNameLabHeight + 10 + CommentStarViewHeight + 10 + contentHeight + 10 + CommentLikeBtnHeight + 20;
    }else {
        return 20 + CommentNameLabHeight + 10 + CommentStarViewHeight + 10 + CommentLikeBtnHeight + 20;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    LMProfileBookCommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMProfileBookCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showLineView:NO];
    cell.delegate = self;
    
    NSArray* arr = [self.dataArray objectAtIndex:section];
    LMProfileBookCommentModel* model = [arr objectAtIndex:row];
    CommentBook* commentBook = model.commentBook;
    
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
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* arr = [self.dataArray objectAtIndex:section];
    LMProfileBookCommentModel* model = [arr objectAtIndex:row];
    CommentBook* commentBook = model.commentBook;
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
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* arr = [self.dataArray objectAtIndex:section];
    LMProfileBookCommentModel* model = [arr objectAtIndex:row];
    CommentBook* commentBook = model.commentBook;
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
                    NSMutableArray* mutableArr = [weakSelf.dataArray objectAtIndex:section];
                    [mutableArr removeObjectAtIndex:row];
                    if (mutableArr.count == 0) {
                        [weakSelf.dataArray removeObject:mutableArr];
                    }
                    
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
