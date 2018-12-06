//
//  LMProfileMessageViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/23.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMProfileMessageViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMProfileMessageTableViewCell.h"
#import "LMProfileMessageModel.h"
#import "LMTool.h"
#import "LMProfileMessageDetailViewController.h"
#import "LMRootViewController.h"

@interface LMProfileMessageViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, assign) UInt32 page;//当前页数
@property (nonatomic, assign) BOOL isEnd;//尾页

@end

@implementation LMProfileMessageViewController

static NSString* cellIdentifier = @"cellIdentifier";

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的消息";
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
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
    [self.tableView registerClass:[LMProfileMessageTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.dataArray = [NSMutableArray array];
    self.page = 0;
    self.isEnd = NO;
    
    
    [self loadProfileMessageDataWithPage:self.page isLoadMoreData:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.dataArray.count > 0) {
        BOOL hasUnread = NO;
        for (NSInteger i = 0; i < self.dataArray.count; i ++) {
            LMProfileMessageModel* subModel = [self.dataArray objectAtIndex:i];
            if (subModel.hasRead == NO) {
                hasUnread = YES;
                break;
            }
        }
        LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
        [rootVC setupShowRedDot:hasUnread index:3];
    }
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
    LMProfileMessageModel* model = [self.dataArray objectAtIndex:row];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMProfileMessageTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMProfileMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    LMProfileMessageModel* model = [self.dataArray objectAtIndex:row];
    
    [cell showLineView:NO];
    [cell setupProfileMessageWithModel:model];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    LMProfileMessageModel* model = [self.dataArray objectAtIndex:row];
    
    LMProfileMessageDetailViewController* messageDetailVC = [[LMProfileMessageDetailViewController alloc]init];
    messageDetailVC.msgId = model.msgId;
    [self.navigationController pushViewController:messageDetailVC animated:YES];
    
    if (model.hasRead == NO) {
        model.hasRead = YES;
        
        UILabel* tempTitleLab = [[UILabel alloc]initWithFrame:CGRectZero];
        tempTitleLab.font = [UIFont systemFontOfSize:15];
        tempTitleLab.numberOfLines = 0;
        tempTitleLab.lineBreakMode = NSLineBreakByCharWrapping;
        tempTitleLab.text = model.titleStr;
        model.titleHeight = [tempTitleLab sizeThatFits:CGSizeMake(self.view.frame.size.width - 20 * 2, CGFLOAT_MAX)].height;
        
        //按时间排序，不按已读状态排序
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        //未读排已读上面
//        NSInteger insertIndex = 0;
//        for (NSInteger i = 0; i < self.dataArray.count; i ++) {
//            LMProfileMessageModel* subModel = [self.dataArray objectAtIndex:i];
//            if (subModel.hasRead == YES) {
//                insertIndex = i;
//                break;
//            }
//        }
//        if (self.dataArray.count > 0) {
//            [self.dataArray removeObjectAtIndex:row];
//            [self.dataArray insertObject:model atIndex:insertIndex];
//        }
//        [self.tableView reloadData];
    }
}

- (void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadProfileMessageDataWithPage:self.page isLoadMoreData:NO];
}

- (void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadProfileMessageDataWithPage:self.page isLoadMoreData:YES];
}

//
-(void)loadProfileMessageDataWithPage:(NSInteger )page isLoadMoreData:(BOOL )loadMore {
    SysMsgListReqBuilder* builder = [SysMsgListReq builder];
    [builder setPage:(UInt32)page];
    SysMsgListReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMProfileMessageViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:46 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 46) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SysMsgListRes* res = [SysMsgListRes parseFromData:apiRes.body];
                    NSArray* arr = res.sysmsgs;
                    
                    if (weakSelf.page == 0) {
                        [weakSelf.dataArray removeAllObjects];
                    }
                    if (arr.count > 0) {
                        weakSelf.page ++;
                        
                        UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
                        tempLab.numberOfLines = 0;
                        tempLab.lineBreakMode = NSLineBreakByTruncatingTail;
                        
                        for (SysMsg* subMsg in arr) {
                            LMProfileMessageModel* model = [[LMProfileMessageModel alloc]init];
                            model.titleStr = subMsg.title;
                            model.msgId = subMsg.id;
                            model.briefStr = subMsg.content;
                            model.hasRead = NO;
                            if (subMsg.isRead) {
                                model.hasRead = YES;
                            }
                            model.timeStr = subMsg.sT;
                            //标题高度
                            if (model.hasRead) {
                                tempLab.font = [UIFont systemFontOfSize:15];
                            }else {
                                tempLab.font = [UIFont boldSystemFontOfSize:15];
                            }
                            tempLab.text = model.titleStr;
                            model.titleHeight = [tempLab sizeThatFits:CGSizeMake(self.view.frame.size.width - 20 * 2, CGFLOAT_MAX)].height;
                            //简介高度
                            tempLab.font = [UIFont systemFontOfSize:12];
                            tempLab.text = model.briefStr;
                            model.briefHeight = [tempLab sizeThatFits:CGSizeMake(self.view.frame.size.width - 20 * 2, CGFLOAT_MAX)].height;
                            if (model.briefHeight > tempLab.font.lineHeight * 2) {
                                model.briefHeight = tempLab.font.lineHeight * 2;
                            }
                            //cell高度
                            NSInteger spaceCount = 0;
                            if (model.titleStr != nil && model.titleStr.length > 0) {
                                spaceCount ++;
                            }
                            if (model.briefStr != nil && model.briefStr.length > 0) {
                                spaceCount ++;
                            }
                            model.cellHeight = 20 + model.titleHeight + model.briefHeight + 20 + spaceCount * 10 + 20;
                            
                            [weakSelf.dataArray addObject:model];
                        }
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

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    self.page = 0;
    [self.tableView stopRefresh];
    [self.tableView stopLoadMoreData];
    [self.tableView cancelNoRefreshData];
    [self.tableView cancelNoMoreData];
    [self loadProfileMessageDataWithPage:self.page isLoadMoreData:NO];
}


@end
