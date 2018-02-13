//
//  LMBookDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/11.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMAdvertisementTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMBookDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* relatedArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIView* footerView;
@property (nonatomic, strong) UILabel* briefLab;//小说简介
@property (nonatomic, strong) UIButton* showMoreBtn;//展开按钮
@property (nonatomic, strong) UIButton* addBtn;//加入书架 按钮
@property (nonatomic, strong) UIButton* downloadBtn;//下载 按钮
@property (nonatomic, strong) UIButton* readBtn;//开始阅读 按钮

@end

@implementation LMBookDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 50;
static CGFloat briefHeight = 50;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"书籍详情";
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    [self.tableView setupNoRefreshData];
    [self.tableView setupNoMoreData];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMAdvertisementTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    [self loadBookDetailData];
}

-(void)loadBookDetailData {
    [self showNetworkLoadingView];
    
    BookRelateReqBuilder* builder = [BookRelateReq builder];
    [builder setBookId:self.book.bookId];
    BookRelateReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:9 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 9) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                BookRelateRes* res = [BookRelateRes parseFromData:apiRes.body];
                UInt32 isAdd = res.haveAdd;
                if (isAdd == 1) {//已加入到书架
                    
                }else {//未加入到书架
                    
                }
                [self setupHeaderViewWithState:isAdd];
                
                NSArray* arr = res.relateBooks;
                if (arr.count > 0) {
                    self.relatedArray = [NSMutableArray arrayWithArray:arr];
                    [self setupFooterView];
                }
            }
        }
        
        [self hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
    }];
}

//头视图
-(void)setupHeaderViewWithState:(BOOL )isAdd {
    CGFloat headerSpaceY = 10;
    CGFloat labHeight = 30;
    CGFloat ivWidth = 60;
    CGFloat ivHeight = 90;
    if (!self.headerView) {
        self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerSpaceY + 75 + labHeight * 2)];
    }
    for (UIView* subvi in self.headerView.subviews) {
        [subvi removeFromSuperview];
    }
    NSString* picStr = self.book.pic;
    UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(headerSpaceY, headerSpaceY, ivWidth, ivHeight)];
    iv.userInteractionEnabled = YES;
    [iv sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"firstLaunch1"]];
    [self.headerView addSubview:iv];
    
    UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width + headerSpaceY, iv.frame.origin.y, self.view.frame.size.width - ivWidth - headerSpaceY * 3, 20)];
    nameLab.font = [UIFont systemFontOfSize:20];
    nameLab.text = self.book.name;
    [self.headerView addSubview:nameLab];
    
    UILabel* authorLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height, 100, 20)];
    authorLab.textColor = [UIColor grayColor];
    authorLab.font = [UIFont systemFontOfSize:14];
    authorLab.text = [NSString stringWithFormat:@"作者：%@", self.book.author];
    [self.headerView addSubview:authorLab];
    CGRect authorFrame = authorLab.frame;
    CGSize authorSize = [authorLab sizeThatFits:CGSizeMake(9999, authorFrame.size.height)];
    authorLab.frame = CGRectMake(authorFrame.origin.x, authorFrame.origin.y, authorSize.width, authorFrame.size.height);
    
    for (NSInteger i = 0; i < self.book.bookType.count; i ++) {
//        NSString* typeStr = [self.book.bookType objectAtIndex:i];
        
        
    }
    
    UILabel* timeLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, authorLab.frame.origin.y + authorLab.frame.size.height, nameLab.frame.size.width, 20)];
    timeLab.font = [UIFont systemFontOfSize:14];
    timeLab.text = [NSString stringWithFormat:@"%@ 第%u章 %@", [LMTool convertTimeStampToTime:self.book.lastChapter.updatedAt], self.book.lastChapter.chapterNo, self.book.lastChapter.chapterTitle];
    [self.headerView addSubview:timeLab];
    
    self.addBtn = [[UIButton alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, timeLab.frame.origin.y + timeLab.frame.size.height, (nameLab.frame.size.width - 20)/3, 30)];
    self.addBtn.layer.borderColor = THEMECOLOR.CGColor;
    self.addBtn.layer.borderWidth = 1;
    self.addBtn.layer.cornerRadius = 3;
    self.addBtn.layer.masksToBounds = YES;
    [self.addBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [self.addBtn setTitle:@"加入书架" forState:UIControlStateNormal];
    [self.headerView addSubview:self.addBtn];
    
    self.downloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.addBtn.frame.origin.x + self.addBtn.frame.size.width + 10, self.addBtn.frame.origin.y, self.addBtn.frame.size.width, self.addBtn.frame.size.height)];
    self.downloadBtn.layer.borderColor = THEMECOLOR.CGColor;
    self.downloadBtn.layer.borderWidth = 1;
    self.downloadBtn.layer.cornerRadius = 3;
    self.downloadBtn.layer.masksToBounds = YES;
    [self.downloadBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    [self.headerView addSubview:self.downloadBtn];
    
    self.readBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.downloadBtn.frame.origin.x + self.downloadBtn.frame.size.width + 10, self.addBtn.frame.origin.y, self.addBtn.frame.size.width, self.addBtn.frame.size.height)];
    self.readBtn.layer.borderColor = THEMECOLOR.CGColor;
    self.readBtn.layer.borderWidth = 1;
    self.readBtn.layer.cornerRadius = 3;
    self.readBtn.layer.masksToBounds = YES;
    [self.readBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
    [self.readBtn setTitle:@"开始阅读" forState:UIControlStateNormal];
    [self.headerView addSubview:self.readBtn];
    
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(10, iv.frame.origin.y + iv.frame.size.height, 200, labHeight)];
    lab1.font = [UIFont systemFontOfSize:18];
    lab1.textColor = THEMECOLOR;
    lab1.text = @"⎮ 小说简介";
    [self.headerView addSubview:lab1];
    
    self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(10, lab1.frame.origin.y + lab1.frame.size.height, self.headerView.frame.size.width - headerSpaceY * 2, briefHeight)];
    self.briefLab.font = [UIFont systemFontOfSize:16];
    self.briefLab.numberOfLines = 0;
    self.briefLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.briefLab.text = self.book.abstract;
    [self.headerView addSubview:self.briefLab];
    
    CGRect briefFrame = self.briefLab.frame;
    CGSize briefSize = [self.briefLab sizeThatFits:CGSizeMake(briefFrame.size.width, CGFLOAT_MAX)];
    CGRect headerViewFrame = self.headerView.frame;
    if (briefSize.height > briefHeight) {
        self.briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefHeight);
        self.showMoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, self.headerView.frame.size.width - 20, 20)];
        self.showMoreBtn.selected = NO;
        [self.showMoreBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [self.showMoreBtn setTitle:@"展开" forState:UIControlStateNormal];
        [self.showMoreBtn setTitle:@"收起" forState:UIControlStateSelected];
        [self.showMoreBtn addTarget:self action:@selector(clickedShowMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.showMoreBtn];
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + headerSpaceY + 20;
    }else {
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefSize.height);
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + headerSpaceY;
    }
    
    self.headerView.frame = headerViewFrame;
    self.tableView.tableHeaderView = self.headerView;
}

//尾视图
-(void)setupFooterView {
    CGFloat ivWidth = (self.view.frame.size.width/3);
    CGFloat ivHeight = ivWidth*1.5;
    CGFloat ivSpaceX = (self.view.frame.size.width - ivWidth * 2)/3;
    CGFloat ivSpaceY = 30;
    CGFloat labHeight = 30;
    if (!self.footerView) {
        self.footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, labHeight + ivHeight * 2 + labHeight * 2)];
    }
    for (UIView* subvi in self.footerView.subviews) {
        [subvi removeFromSuperview];
    }
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, labHeight)];
    lab1.font = [UIFont systemFontOfSize:18];
    lab1.textColor = THEMECOLOR;
    lab1.text = @"⎮ 相关推荐";
    [self.footerView addSubview:lab1];
    
    for (NSInteger i = 0; i < self.relatedArray.count; i ++) {
        Book* tempBook = [self.relatedArray objectAtIndex:i];
        NSString* picStr = tempBook.pic;
        UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(ivSpaceX + (ivSpaceX + ivWidth)*(i%2), ivSpaceY + (ivSpaceY + ivHeight)*(i/2), ivWidth, ivHeight)];
        iv.tag = i;
        iv.userInteractionEnabled = YES;
        [iv sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"firstLaunch1"]];
        [self.footerView addSubview:iv];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedBookImageView:)];
        [iv addGestureRecognizer:tap];
        
        UILabel* lab2 = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x, iv.frame.origin.y + ivHeight, ivWidth, labHeight)];
        lab2.font = [UIFont systemFontOfSize:16];
        lab2.textAlignment = NSTextAlignmentCenter;
        lab2.text = tempBook.name;
        [self.footerView addSubview:lab2];
    }
    
    self.tableView.tableFooterView = self.footerView;
}

//点击 相关推荐 书籍
-(void)clickedBookImageView:(UITapGestureRecognizer* )tapGR {
    UIImageView* iv = (UIImageView* )tapGR.view;
    NSInteger tag = iv.tag;
    Book* selectedBook = [self.relatedArray objectAtIndex:tag];
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.book = selectedBook;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//展开 收起来
-(void)clickedShowMoreButton:(UIButton* )sender {
    CGRect briefFrame = self.briefLab.frame;
    CGSize briefSize = [self.briefLab sizeThatFits:CGSizeMake(briefFrame.size.width, CGFLOAT_MAX)];
    CGRect headerViewFrame = self.headerView.frame;
    if (self.showMoreBtn.selected == NO) {
        //展开
        self.showMoreBtn.selected = YES;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefSize.height);
        self.showMoreBtn.frame = CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, self.headerView.frame.size.width - 20, 20);
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10 + 20;
    }else {
        //收缩
        self.showMoreBtn.selected = NO;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefHeight);
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10 + 20;
        self.showMoreBtn.frame = CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, self.headerView.frame.size.width - 20, 20);
    }
    self.headerView.frame = headerViewFrame;
    self.tableView.tableHeaderView = self.headerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    vi.backgroundColor = [UIColor grayColor];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    vi.backgroundColor = [UIColor grayColor];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMAdvertisementTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMAdvertisementTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    
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
