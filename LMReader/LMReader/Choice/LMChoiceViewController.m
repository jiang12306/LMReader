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

@interface LMChoiceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UISearchBar* searchBar;//搜索框

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
    
    UIView* titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - leftView.frame.size.width - rightView.frame.size.width - 40, 25)];
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, titleView.frame.size.width, titleView.frame.size.height)];
    self.searchBar.placeholder = @"搜索小说";
    self.searchBar.layer.borderColor = [UIColor whiteColor].CGColor;
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.cornerRadius = 5;
    self.searchBar.layer.masksToBounds = YES;
    [titleView addSubview:self.searchBar];
    self.navigationItem.titleView = titleView;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    CGFloat btnHeight = 40;
    CGFloat btnWidth = 68;
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    UIButton* rangeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight + 30)];
    [rangeBtn addTarget:self action:@selector(clickedRangeButton:) forControlEvents:UIControlEventTouchUpInside];
    [rangeBtn setImage:[UIImage imageNamed:@"choice_Range"] forState:UIControlStateNormal];
    [rangeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 0)];
    rangeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rangeBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [rangeBtn setTitle:@"排行榜" forState:UIControlStateNormal];
    [rangeBtn setTitleEdgeInsets:UIEdgeInsetsMake(68, -34, 0, 0)];
    rangeBtn.center = CGPointMake(self.headerView.frame.size.width/4, self.headerView.frame.size.height/2);
    [self.headerView addSubview:rangeBtn];
    
    UIButton* specialBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, rangeBtn.frame.size.width, rangeBtn.frame.size.height)];
    [specialBtn addTarget:self action:@selector(clickedSpecialChoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    [specialBtn setImage:[UIImage imageNamed:@"choice_Special"] forState:UIControlStateNormal];
    [specialBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 30, 0)];
    specialBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [specialBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [specialBtn setTitle:@"精选专题" forState:UIControlStateNormal];
    [specialBtn setTitleEdgeInsets:UIEdgeInsetsMake(68, -34, 0, 0)];
    specialBtn.center = CGPointMake(self.headerView.frame.size.width*3/4, self.headerView.frame.size.height/2);
    [self.headerView addSubview:specialBtn];
    
    rangeBtn.backgroundColor = [UIColor greenColor];
    specialBtn.backgroundColor = [UIColor greenColor];
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.dataArray = [NSMutableArray arrayWithObjects:@"1", @"2",@"3", @"4",@"5", @"6",@"7", @"8",@"9", @"10", @"11",@"12", @"13", @"14",@"15", @"16", nil];
    [self.tableView reloadData];
    
    
}

//书城
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    LMBookStoreViewController* storeVC = [[LMBookStoreViewController alloc]init];
    [self.navigationController pushViewController:storeVC animated:YES];
}

//
-(void)clickedRangeButton:(UIButton* )sender {
    
}

//
-(void)clickedSpecialChoiceButton:(UIButton* )sender {
    
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
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMBaseBookTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBaseBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
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
