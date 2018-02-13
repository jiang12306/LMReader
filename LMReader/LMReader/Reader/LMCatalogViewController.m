//
//  LMCatalogViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMCatalogViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMCatalogTableViewCell.h"
#import "LMTool.h"

@interface LMCatalogViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;


@end

@implementation LMCatalogViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 44;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.title = @"目录";
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    UIButton* rightItemBtn = [[UIButton alloc]initWithFrame:rightView.frame];
    rightItemBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    rightItemBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightItemBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [rightItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightItemBtn setTitle:@"xx" forState:UIControlStateNormal];
    [rightItemBtn addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:rightItemBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMCatalogTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    
    if (self.dataArray.count == 0) {
        [self loadCatalogList];
    }
    
}

-(void)loadCatalogList {
    [self showNetworkLoadingView];
    
    BookChapterReqBuilder* builder = [BookChapterReq builder];
    [builder setBookId:self.bookId];
    BookChapterReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 7) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                BookChapterRes* res = [BookChapterRes parseFromData:apiRes.body];
                NSArray* arr = res.chapters;
                if (arr != nil && arr.count > 0) {
                    [self.dataArray addObjectsFromArray:arr];
                    [self.tableView reloadData];
                }
            }
        }
        [self hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
        
    }];
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
    LMCatalogTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMCatalogTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Chapter* chapter = [self.dataArray objectAtIndex:indexPath.row];
    NSString* num = [NSString stringWithFormat:@"%u", chapter.chapterNo];
    NSString* name = [NSString stringWithFormat:@"%@", chapter.chapterTitle];
    NSString* time = [LMTool convertTimeStampToTime:chapter.updatedAt];
    
    [cell setContentWithNumberStr:num nameStr:name timeStr:time];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Chapter* chapter = [self.dataArray objectAtIndex:indexPath.row];
    
    self.callBlock(chapter);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    if (self.dataArray.count) {
        [self.tableView stopRefresh];
        return;
    }
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
//    [self.tableView stopLoadMoreData];
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
