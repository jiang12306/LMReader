//
//  LMBookShelfViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfViewController.h"
#import "LMBookShelfTableViewCell.h"
#import "LMReaderViewController.h"
#import "LMBaseNavigationController.h"
#import "LMBookStoreViewController.h"

@interface LMBookShelfViewController () <UITableViewDelegate, UITableViewDataSource, LMBookShelfTableViewCellDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* footerView;//方形+视图
@property (nonatomic, strong) UIButton* rectAddBtn;//方形+按钮
@property (nonatomic, strong) UIButton* cycleAddBtn;//圆形+按钮
@property (nonatomic, strong) UISearchBar* searchBar;//搜索框

@end

@implementation LMBookShelfViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat spaceX = 10;
static CGFloat cellHeight = 60;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
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
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBookShelfTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.tableView.tableFooterView = self.footerView;
    self.cycleAddBtn.hidden = NO;
    
    self.dataArray = [NSMutableArray arrayWithObjects:@"1", @"2",@"3", @"4",@"5", @"6",@"7", @"8",@"9", @"10", @"11",@"12", @"13", @"14",@"15", @"16", nil];
    [self.tableView reloadData];
    if (self.dataArray.count * cellHeight < self.tableView.frame.size.height) {
        self.tableView.tableFooterView = self.footerView;
        self.cycleAddBtn.hidden = YES;
    }else {
        self.tableView.tableFooterView = self.footerView;
        self.rectAddBtn.hidden = YES;
        self.cycleAddBtn.hidden = NO;
    }
}

//书城
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    LMBookStoreViewController* storeVC = [[LMBookStoreViewController alloc]init];
    [self.navigationController pushViewController:storeVC animated:YES];
}

//方形+视图
-(UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
        self.rectAddBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, 15, self.view.frame.size.width - spaceX * 2, 40)];
        self.rectAddBtn.layer.borderColor = [UIColor blackColor].CGColor;
        self.rectAddBtn.layer.borderWidth = 1;
        self.rectAddBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.rectAddBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.rectAddBtn setTitle:@"+ 添加图书" forState:UIControlStateNormal];
        [self.rectAddBtn addTarget:self action:@selector(clickedAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:self.rectAddBtn];
    }
    return _footerView;
}

//圆形+按钮
-(UIButton *)cycleAddBtn {
    if (!_cycleAddBtn) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat btnWidth = 50;
        CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        _cycleAddBtn = [[UIButton alloc]initWithFrame:CGRectMake(spaceX, screenRect.size.height - tabBarHeight - btnWidth - spaceX, btnWidth, btnWidth)];
        _cycleAddBtn.backgroundColor = [UIColor blackColor];
        _cycleAddBtn.layer.cornerRadius = btnWidth/2;
        _cycleAddBtn.layer.masksToBounds = YES;
        _cycleAddBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cycleAddBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cycleAddBtn setTitle:@"+图书" forState:UIControlStateNormal];
        [_cycleAddBtn addTarget:self action:@selector(clickedAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_cycleAddBtn aboveSubview:self.tableView];
    }
    return _cycleAddBtn;
}

//+图书
-(void)clickedAddButton:(UIButton* )sender {
    
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
    LMBookShelfTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBookShelfTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.delegate = self;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LMReaderViewController* readerVC = [[LMReaderViewController alloc]init];
    LMBaseNavigationController* navi = [[LMBaseNavigationController alloc]initWithRootViewController:readerVC];
    [self presentViewController:navi animated:YES completion:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dataArray.count * cellHeight < self.tableView.frame.size.height) {
        self.tableView.tableFooterView = self.footerView;
        self.cycleAddBtn.hidden = YES;
        return;
    }
    if (scrollView == self.tableView) {
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
        NSLog(@"offsetY = %f, height = %f, bottomOffset = %f", contentOffsetY, height, bottomOffset);
        if (bottomOffset <= height) {//滑至底部
            self.rectAddBtn.hidden = NO;
            self.cycleAddBtn.hidden = YES;
        }else {
            self.rectAddBtn.hidden = YES;
            self.cycleAddBtn.hidden = NO;
        }
    }
    [self.tableView rectForSection:0];
}

#pragma mark -LMBookShelfTableViewCellDelegate
-(void)didStartScrollCell:(LMBookShelfTableViewCell* )selectedCell {
    NSInteger section = 0;
    NSInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < rows; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        LMBookShelfTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell == selectedCell) {
            continue;
        }
        [cell showUpsideAndDelete:NO animation:YES];
    }
}

-(void)didClickCell:(LMBookShelfTableViewCell* )cell deleteButton:(UIButton* )btn {
    
}

-(void)didClickCell:(LMBookShelfTableViewCell* )cell upsideButton:(UIButton* )btn {
    
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
