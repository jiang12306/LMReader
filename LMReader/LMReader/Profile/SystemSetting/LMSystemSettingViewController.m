//
//  LMSystemSettingViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSystemSettingViewController.h"
#import "LMSystemSettingTableViewCell.h"

@interface LMSystemSettingViewController () <UITableViewDelegate, UITableViewDataSource, LMSystemSettingTableViewCellDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* titleArray;
@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation LMSystemSettingViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"系统设置";
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMSystemSettingTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    UIButton* loginOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 15, footerView.frame.size.width - 10 * 2, 35)];
    loginOutBtn.layer.cornerRadius = 5;
    loginOutBtn.layer.masksToBounds = YES;
    loginOutBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [loginOutBtn addTarget:self action:@selector(clickedLoginOutButton:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:loginOutBtn];
    
    self.tableView.tableFooterView = footerView;
    
    self.titleArray = [NSMutableArray arrayWithObjects:@"更新提醒", @"清理缓存", @"夜间模式", @"Wifi下自动下载书架图书", @"预加载下一章节", nil];
    self.dataArray = [NSMutableArray arrayWithObjects:@1, @"2.3MB", @1, @0, @0, nil];
    [self.tableView reloadData];
}

//退出登录
-(void)clickedLoginOutButton:(UIButton* )sender {
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMSystemSettingTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMSystemSettingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    cell.nameLab.text = [self.titleArray objectAtIndex:row];
    if (row == 1) {
        cell.contentSwitch.hidden = YES;
        cell.contentLab.hidden = NO;
        
        cell.contentLab.text = [self.dataArray objectAtIndex:row];
    }else {
        cell.contentSwitch.hidden = NO;
        cell.contentLab.hidden = YES;
        
        NSInteger stateInteger = [[self.dataArray objectAtIndex:row] integerValue];
        if (stateInteger > 0) {
            cell.contentSwitch.on = YES;
        }else {
            cell.contentSwitch.on = NO;
        }
    }
    cell.delegate = self;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    if (row == 1) {
        //To Do...
    }
}

#pragma mark -LMSystemSettingTableViewCellDelegate
-(void)didClickSwitch:(BOOL)isOn systemSettingCell:(LMSystemSettingTableViewCell *)cell {
    
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
