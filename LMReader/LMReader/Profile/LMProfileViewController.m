//
//  LMProfileViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileViewController.h"
#import "LMProfileTableViewCell.h"

@interface LMProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIImageView* avatorIV;
@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* timeLab;

@end

@implementation LMProfileViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMProfileTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    CGFloat spaceX = 10;
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    headerView.backgroundColor = [UIColor grayColor];
    self.avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceX, 40, 60, 50)];
    self.avatorIV.image = [UIImage imageNamed:@"navigationItem_Back"];
    [headerView addSubview:self.avatorIV];
    self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.avatorIV.frame.origin.x + self.avatorIV.frame.size.width + spaceX, self.avatorIV.frame.origin.y, self.view.frame.size.width - self.avatorIV.frame.size.width - spaceX*4 - 20, 20)];
    self.nameLab.font = [UIFont systemFontOfSize:16];
    self.nameLab.text = @"昵称";
    [headerView addSubview:self.nameLab];
    self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height - 20, self.nameLab.frame.size.width, self.nameLab.frame.size.height)];
    self.timeLab.font = [UIFont systemFontOfSize:16];
    self.timeLab.text = @"相伴200天";
    [headerView addSubview:self.timeLab];
    UIImageView* arrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 10 - 20, self.avatorIV.frame.origin.y + spaceX, 15, 20)];
    arrowIV.image = [UIImage imageNamed:@"navigationItem_Back"];
    arrowIV.layer.borderWidth = 1;
    arrowIV.layer.borderColor = [UIColor grayColor].CGColor;
    [headerView addSubview:arrowIV];
    self.tableView.tableHeaderView = headerView;
    
    self.dataArray = [NSMutableArray arrayWithObjects:@[@"阅读记录", @"阅读偏好", @"系统设置"], @[@"意见反馈", @"关于我们", @"版权声明"], nil];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* arr = [self.dataArray objectAtIndex:section];
    return arr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMProfileTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMProfileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray* arr = [self.dataArray objectAtIndex:indexPath.section];
    cell.nameLab.text = [arr objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        switch (row) {
            case 0:
                
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            default:
                break;
        }
    }else if (section == 1) {
        switch (row) {
            case 0:
                
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            default:
                break;
        }
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
