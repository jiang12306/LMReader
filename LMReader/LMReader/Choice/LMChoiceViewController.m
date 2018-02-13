//
//  LMChoiceViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMChoiceViewController.h"
#import "LMBaseBookTableViewCell.h"
#import "LMBookStoreViewController.h"
#import "LMRangeViewController.h"
#import "LMSpecialChoiceViewController.h"
#import "LMInterestOrEndViewController.h"
#import "LMBookDetailViewController.h"
#import "LMSearchViewController.h"
#import "LMSearchBarView.h"

@interface LMChoiceViewController () <UITableViewDelegate, UITableViewDataSource, LMSearchBarViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* interestArr;//兴趣推荐
@property (nonatomic, strong) NSMutableArray* overArr;//完结
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation LMChoiceViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 25)];
    UILabel* leftItemLab = [[UILabel alloc]initWithFrame:leftView.frame];
    leftItemLab.font = [UIFont systemFontOfSize:20];
    leftItemLab.textColor = [UIColor whiteColor];
    leftItemLab.textAlignment = NSTextAlignmentCenter;
    leftItemLab.text = APPNAME;
    [leftView addSubview:leftItemLab];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    UIButton* rightItemBtn = [[UIButton alloc]initWithFrame:rightView.frame];
    rightItemBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    rightItemBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightItemBtn setTitle:@"书城" forState:UIControlStateNormal];
    [rightItemBtn addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightItemBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    LMSearchBarView* titleView = [[LMSearchBarView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - leftView.frame.size.width - rightView.frame.size.width - 60, 25)];
    titleView.delegate = self;
    self.navigationItem.titleView = titleView;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    CGFloat btnHeight = 70;
    CGFloat btnWidth = 70;
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    UIButton* rangeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight + 30)];
    [rangeBtn addTarget:self action:@selector(clickedRangeButton:) forControlEvents:UIControlEventTouchUpInside];
    [rangeBtn setImage:[UIImage imageNamed:@"choice_Range"] forState:UIControlStateNormal];
    [rangeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 0)];
    rangeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rangeBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [rangeBtn setTitle:@"排行榜" forState:UIControlStateNormal];
    [rangeBtn setTitleEdgeInsets:UIEdgeInsetsMake(65, -70, 0, 0)];
    rangeBtn.center = CGPointMake(self.headerView.frame.size.width/4, self.headerView.frame.size.height/2);
    [self.headerView addSubview:rangeBtn];
    
    UIButton* specialBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, rangeBtn.frame.size.width, rangeBtn.frame.size.height)];
    [specialBtn addTarget:self action:@selector(clickedSpecialChoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    [specialBtn setImage:[UIImage imageNamed:@"choice_Special"] forState:UIControlStateNormal];
    [specialBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 0)];
    specialBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [specialBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [specialBtn setTitle:@"精选专题" forState:UIControlStateNormal];
    [specialBtn setTitleEdgeInsets:UIEdgeInsetsMake(65, -70, 0, 0)];
    specialBtn.center = CGPointMake(self.headerView.frame.size.width*3/4, self.headerView.frame.size.height/2);
    [self.headerView addSubview:specialBtn];
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.interestArr = [NSMutableArray array];
    self.overArr = [NSMutableArray array];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadChoiceData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self hideNetworkLoadingView];
}

//书城
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    LMBookStoreViewController* storeVC = [[LMBookStoreViewController alloc]init];
    [self.navigationController pushViewController:storeVC animated:YES];
}

//排行榜
-(void)clickedRangeButton:(UIButton* )sender {
    LMRangeViewController* rangeVC = [[LMRangeViewController alloc]init];
    [self.navigationController pushViewController:rangeVC animated:YES];
}

//精选专题
-(void)clickedSpecialChoiceButton:(UIButton* )sender {
    LMSpecialChoiceViewController* specialChoiceVC = [[LMSpecialChoiceViewController alloc]init];
    [self.navigationController pushViewController:specialChoiceVC animated:YES];
}

//section头部  更多
-(void)clickedSectionButton:(UIButton* )sender {
    LMInterestOrEndViewController* interestOrEndVC = [[LMInterestOrEndViewController alloc]init];
    [self.navigationController pushViewController:interestOrEndVC animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString* titleStr = @"兴趣推荐";
    if (section == 1) {
        titleStr = @"完结经典";
    }
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    vi.backgroundColor = THEMECOLOR;
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, vi.frame.size.height)];
    lab.textColor = [UIColor whiteColor];
    lab.font = [UIFont systemFontOfSize:18];
    lab.text = [NSString stringWithFormat:@"•%@", titleStr];
    [vi addSubview:lab];
    
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(vi.frame.size.width - 60, 0, 60, vi.frame.size.height)];
    NSMutableAttributedString* btnStr = [[NSMutableAttributedString alloc]initWithString:@"更多>" attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle), NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [btn setAttributedTitle:btnStr forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickedSectionButton:) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:btn];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.interestArr.count;
    }else if (section == 1) {
        return self.overArr.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMBaseBookTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBaseBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Book* book;
    if (indexPath.section == 0) {
        book = [self.interestArr objectAtIndex:indexPath.row];
    }else if (indexPath.section == 1) {
        book = [self.overArr objectAtIndex:indexPath.row];
    }
    [cell setupContentBook:book];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Book* book;
    if (indexPath.section == 0) {
        book = [self.interestArr objectAtIndex:indexPath.row];
    }else if (indexPath.section == 1) {
        book = [self.overArr objectAtIndex:indexPath.row];
    }
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.book = book;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)loadChoiceData {
    [self showNetworkLoadingView];
    self.isRefreshing = YES;
    
    TopicHomeReqBuilder* builder = [TopicHomeReq builder];
    [builder setPage:0];
    [builder setType:0];
    TopicHomeReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:10 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 10) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                TopicHomeRes* res = [TopicHomeRes parseFromData:apiRes.body];
                NSArray* arr1 = res.interestBooks;
                if (arr1.count > 0) {
                    [self.interestArr removeAllObjects];
                    [self.interestArr addObjectsFromArray:arr1];
                }
                NSArray* arr2 = res.finishBooks;
                if (arr2.count > 0) {
                    [self.overArr removeAllObjects];
                    [self.overArr addObjectsFromArray:arr1];
                }
                
                [self.tableView reloadData];
            }
        }
        self.isRefreshing = NO;
        [self hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        self.isRefreshing = NO;
        [self hideNetworkLoadingView];
    }];
}

#pragma mark -LMSearchBarViewDelegate
-(void)searchBarViewDidStartSearch:(NSString *)inputText {
    if (inputText.length > 0) {
        LMSearchViewController* searchVC = [[LMSearchViewController alloc]init];
        searchVC.searchStr = inputText;
        [self.navigationController pushViewController:searchVC animated:YES];
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
