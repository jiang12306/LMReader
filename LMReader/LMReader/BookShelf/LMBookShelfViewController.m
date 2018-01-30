//
//  LMBookShelfViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfViewController.h"
#import "LMBookShelfTableViewCell.h"

@interface LMBookShelfViewController () <UITableViewDelegate, UITableViewDataSource, LMBookShelfTableViewCellDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation LMBookShelfViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 25)];
    UILabel* nameLab = [[UILabel alloc]initWithFrame:vi.frame];
    nameLab.font = [UIFont systemFontOfSize:20];
    nameLab.textColor = [UIColor blackColor];
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.text = @"Kindle";
    [vi addSubview:nameLab];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:vi];
    
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 160, 25)];
    view.backgroundColor = [UIColor greenColor];
    UILabel* searchLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    searchLab.font = [UIFont systemFontOfSize:18];
    searchLab.textColor = [UIColor blackColor];
    searchLab.textAlignment = NSTextAlignmentCenter;
    searchLab.text = @"搜索";
    [view addSubview:searchLab];
    self.navigationItem.titleView = view;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBookShelfTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.dataArray = [NSMutableArray arrayWithObjects:@"1", @"2",@"3", @"4",@"5", @"6",@"7", @"8",@"9", @"10", nil];
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
    return 60;
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
    
    
}

#pragma mark -LMBookShelfTableViewCellDelegate
-(void)didScrollCell:(LMBookShelfTableViewCell* )selectedCell {
    NSLog(@"------%s", __FUNCTION__);
}

-(void)didClickCell:(LMBookShelfTableViewCell* )cell deleteButton:(UIButton* )btn {
    NSLog(@"------%s", __FUNCTION__);
}

-(void)didClickCell:(LMBookShelfTableViewCell* )cell upsideButton:(UIButton* )btn {
    NSLog(@"------%s", __FUNCTION__);
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
