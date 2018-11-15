//
//  LMSpecialChoiceViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceViewController.h"
#import "LMSpecialChoiceDetailViewController.h"
#import "LMSpecialChoiceTableViewCell.h"
#import "LMSpecialChoiceModel.h"
#import "LMTool.h"

@interface LMSpecialChoiceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation LMSpecialChoiceViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"精选专题";
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMSpecialChoiceTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.dataArray = [NSMutableArray array];
    [self initSpecialChoiceData];
}

-(void)initSpecialChoiceData {
    TopicChartReqBuilder* builder = [TopicChartReq builder];
    [builder setType:2];
    TopicChartReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMSpecialChoiceViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:11 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 11) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    TopicChartRes* res = [TopicChartRes parseFromData:apiRes.body];
                    NSArray* arr = res.tcs;
                    
                    CGFloat ivHeight = self.view.frame.size.width * 27 / 64;
                    for (TopicChart* chart in arr) {
                        LMSpecialChoiceModel* model = [[LMSpecialChoiceModel alloc]init];
                        model.topicChart = chart;
                        model.ivHeight = ivHeight;
                        model.cellHeight = ivHeight;
                        NSInteger spaceCount = 0;
                        NSString* titleStr = chart.name;
                        if (titleStr != nil && titleStr.length > 0) {
                             model.titleHeight = [LMSpecialChoiceModel caculateSpecialChoiceModelTextHeightWithText:titleStr width:self.view.frame.size.width - 20 * 2 font:[UIFont systemFontOfSize:18] maxLines:0];
                            spaceCount ++;
                        }
                        NSString* briefStr = chart.abstract;
                        if (briefStr != nil && briefStr.length > 0) {
                            model.briefHeight = [LMSpecialChoiceModel caculateSpecialChoiceModelTextHeightWithText:briefStr width:self.view.frame.size.width - 20 * 2 font:[UIFont systemFontOfSize:15] maxLines:3];
                            spaceCount ++;
                        }
                        model.cellHeight += 20 * 2 + 10 * spaceCount + model.titleHeight + model.briefHeight;
                        
                        [weakSelf.dataArray addObject:model];
                    }
                    
                    [weakSelf.tableView reloadData];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        [weakSelf hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
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
    LMSpecialChoiceModel* model = [self.dataArray objectAtIndex:indexPath.row];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMSpecialChoiceTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMSpecialChoiceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showLineView:NO];
    
    LMSpecialChoiceModel* model = [self.dataArray objectAtIndex:indexPath.row];
    [cell setupSpecialChoiceModel:model];
    
    return cell;
}

#pragma mark -UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LMSpecialChoiceModel* model = [self.dataArray objectAtIndex:indexPath.row];
    TopicChart* chart = model.topicChart;
    
    LMSpecialChoiceDetailViewController* choiceDetailVC = [[LMSpecialChoiceDetailViewController alloc]init];
    choiceDetailVC.chart = chart;
    [self.navigationController pushViewController:choiceDetailVC animated:YES];
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
