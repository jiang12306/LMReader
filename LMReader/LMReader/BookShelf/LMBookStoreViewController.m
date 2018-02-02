//
//  LMBookStoreViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookStoreViewController.h"
#import "LMBaseBookTableViewCell.h"

@interface LMBookStoreViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIView* upsideView;
@property (nonatomic, strong) UIButton* upsideBtn;
@property (nonatomic, strong) NSMutableArray* filterArray;

@end

@implementation LMBookStoreViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 100;
CGFloat filterBtnHeight = 40;
CGFloat filterBtnMargin = 15;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 30)];
    UIImage* rightImage = [UIImage imageNamed:@"navigationItem_More"];
    UIButton* rightButton = [[UIButton alloc]initWithFrame:rightView.frame];
    [rightButton setImage:rightImage forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(5, 45, 5, 0)];
    [rightButton addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [rightButton setTitle:@"筛选" forState:UIControlStateNormal];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 15)];
    [rightButton setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [rightView addSubview:rightButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    UIView* titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
    titleView.backgroundColor = [UIColor greenColor];
    UILabel* searchLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleView.frame.size.width, titleView.frame.size.height)];
    searchLab.font = [UIFont systemFontOfSize:18];
    searchLab.textColor = [UIColor blackColor];
    searchLab.textAlignment = NSTextAlignmentCenter;
    searchLab.text = @"搜索";
    [titleView addSubview:searchLab];
    self.navigationItem.titleView = titleView;
    
    self.filterArray = [NSMutableArray arrayWithObjects:@[@"全部", @"男生", @"女生"], @[@"全部", @"玄幻", @"现代言情", @"武侠", @"仙侠", @"奇幻", @"更多"], @[@"全部", @"完结", @"连载中"], @[@"人气", @"最新上架"], nil];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    //置顶按钮
    [self.view addSubview:self.upsideView];
    
    //加载数据
    [self loadDataWithPage:0];
}

//筛选
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    self.tableView.tableHeaderView = [self createTableHeaderView];
}

//筛选 视图
-(UIView *)createTableHeaderView {
    if (!self.headerView) {
        self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        self.headerView.backgroundColor = [UIColor grayColor];
    }
    for (UIView* vi in self.headerView.subviews) {
        [vi removeFromSuperview];
    }
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, filterBtnHeight * self.filterArray.count);
    
    for (NSInteger i = 0; i < self.filterArray.count; i ++) {
        NSArray* typeArr = [self.filterArray objectAtIndex:i];
        
        for (NSInteger j = 0; j < typeArr.count; j ++) {
            UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 0, 20)];
            [self.headerView addSubview:btn];
            
        }
        
    }
    
    
    return self.headerView;
}

//置顶按钮
-(UIView *)upsideView {
    if (!_upsideView) {
        CGFloat btnWidth = 50;
        CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        _upsideView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - btnWidth - 10, self.view.frame.size.height - tabBarHeight - btnWidth - 10, btnWidth, btnWidth)];
        _upsideView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _upsideView.layer.cornerRadius = btnWidth/2;
        _upsideView.layer.masksToBounds = YES;
        self.upsideBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnWidth)];
        self.upsideBtn.layer.borderColor = [UIColor blackColor].CGColor;
        self.upsideBtn.layer.borderWidth = 1;
        self.upsideBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.upsideBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.upsideBtn setTitle:@"^Top" forState:UIControlStateNormal];
        [self.upsideBtn addTarget:self action:@selector(clickedUpsideButton:) forControlEvents:UIControlEventTouchUpInside];
        [_upsideView addSubview:self.upsideBtn];
    }
    return _upsideView;
}

//回到顶部
-(void)clickedUpsideButton:(UIButton* )sender {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)loadDataWithPage:(NSInteger )page {
    self.dataArray = [NSMutableArray array];
    [self.dataArray addObjectsFromArray:@[@"1", @"2", @"3", @"4", @"5", @"6"]];
    [self.tableView reloadData];
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
    
    cell.nameLab.text = [self.dataArray objectAtIndex:indexPath.row];
    
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
