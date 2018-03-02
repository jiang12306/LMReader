//
//  LMBookStoreViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookStoreViewController.h"
#import "LMBaseBookTableViewCell.h"
#import "LMBaseRefreshTableView.h"
#import "LMTool.h"
#import "LMSearchBarView.h"
#import "LMSearchViewController.h"
#import "LMBookDetailViewController.h"

typedef enum {
    LMBookStoreStateAll = 0,//全部
    LMBookStoreStateFinished = 1,//完结
    LMBookStoreStateLoad = 2,//连载中
}LMBookStoreState;

typedef enum {
    LMBookStoreRangeHot = 1,//人气
    LMBookStoreRangeNew = 2,//最新上架
}LMBookStoreRange;

@interface LMBookStoreViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMSearchBarViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIView* headerView;//tableHeaderView
@property (nonatomic, strong) UIView* filterView;//类型筛选 视图
@property (nonatomic, strong) UIView* filterBottomView;//完结 人气 部分视图
@property (nonatomic, strong) UIView* upsideView;//top 视图
@property (nonatomic, strong) UIButton* upsideBtn;//top button
@property (nonatomic, strong) NSMutableArray* typeArray;//类型
@property (nonatomic, strong) NSMutableArray* maleTypeArray;//男生 小说类型
@property (nonatomic, strong) NSMutableArray* femaleTypeArray;//女生 小说类型
@property (nonatomic, strong) NSMutableArray* filterTypeArray;//选中的小说类型
@property (nonatomic, assign) GenderType genderType;//性别
@property (nonatomic, assign) LMBookStoreState bookState;//完结 连载中
@property (nonatomic, assign) LMBookStoreRange bookRange;//人气 最新上架
@property (nonatomic, assign) UInt32 page;//当前页数
@property (nonatomic, assign) BOOL isEnd;//尾页

@end

@implementation LMBookStoreViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 100;
CGFloat filterBtnHeight = 40;
CGFloat filterBtnMargin = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 30)];
    UIImage* rightImage = [UIImage imageNamed:@"navigationItem_More"];
    UIButton* rightButton = [[UIButton alloc]initWithFrame:rightView.frame];
    [rightButton setImage:rightImage forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(5, 45, 5, 0)];
    [rightButton addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitle:@"筛选" forState:UIControlStateNormal];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 15)];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightView addSubview:rightButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    
    LMSearchBarView* titleView = [[LMSearchBarView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 80 - rightView.frame.size.width - 60, 25)];
    titleView.delegate = self;
    self.navigationItem.titleView = titleView;
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBaseBookTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.maleTypeArray = [NSMutableArray array];
    self.femaleTypeArray = [NSMutableArray array];
    self.typeArray = [NSMutableArray array];
    self.filterTypeArray = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    self.page = 0;
    self.isEnd = NO;
    
    self.genderType = GenderTypeGenderOther;
    self.bookState = LMBookStoreStateAll;
    self.bookRange = LMBookStoreRangeHot;
    
    //置顶按钮
    [self.view addSubview:self.upsideView];
    
    //加载数据
    [self loadMaleTypeList];
    [self loadFemaleTypeList];
}

//筛选
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    
}

//筛选 视图
-(void)createTableHeaderView {
    if (!self.headerView) {
        self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160)];
        self.headerView.backgroundColor = [UIColor whiteColor];
    }
    NSArray* genderArr = @[@"全部", @"男生", @"女生"];
    for (NSInteger i = 0; i < genderArr.count; i ++) {
        BOOL selected = NO;
        if (i == 0) {
            selected = YES;
        }
        UIButton* btn = [self createHeaderButtonWithFrame:CGRectMake(filterBtnMargin*(i + 1) + 40*i, 0, 40, filterBtnHeight) title:genderArr[i] tag:10 + i selector:@selector(clickedGenderButton:) selected:selected];
        [self.headerView addSubview:btn];
    }
    UIButton* allTypeBtn = [self createHeaderButtonWithFrame:CGRectMake(filterBtnMargin, 40, 40, filterBtnHeight) title:@"全部" tag:20 selector:@selector(clickedTypeButton:) selected:YES];
    [self.headerView addSubview:allTypeBtn];
    
    self.filterView = [[UIView alloc]initWithFrame:CGRectMake(filterBtnMargin * 2 + 40, allTypeBtn.frame.origin.y, self.headerView.frame.size.width - filterBtnMargin * 2 - 40, 40)];
    [self.headerView addSubview:self.filterView];
    
    self.filterBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.filterView.frame.origin.y + self.filterView.frame.size.height, self.headerView.frame.size.width, 80)];
    [self.headerView addSubview:self.filterBottomView];
    
    NSArray* stateArr = @[@"全部", @"完结", @"连载中"];
    for (NSInteger i = 0; i < stateArr.count; i ++) {
        BOOL selected = NO;
        CGFloat tempBtnWidth = 40;
        if (i == 0) {
            selected = YES;
        }else if (i == 2) {
            tempBtnWidth = 60;
        }
        UIButton* btn = [self createHeaderButtonWithFrame:CGRectMake(filterBtnMargin*(i + 1) + 40*i, 0, tempBtnWidth, filterBtnHeight) title:stateArr[i] tag:100 + i selector:@selector(clickedStateButton:) selected:selected];
        [self.filterBottomView addSubview:btn];
    }
    
    NSArray* rangeArr = @[@"人气", @"最新上架"];
    for (NSInteger i = 0; i < rangeArr.count; i ++) {
        BOOL selected = NO;
        CGFloat tempBtnWidth = 40;
        if (i == 0) {
            selected = YES;
        }else if (i == 1) {
            tempBtnWidth = 80;
        }
        UIButton* btn = [self createHeaderButtonWithFrame:CGRectMake(filterBtnMargin*(i + 1) + 40*i, 40, tempBtnWidth, filterBtnHeight) title:rangeArr[i] tag:200 + i selector:@selector(clickedRangeButton:) selected:selected];
        [self.filterBottomView addSubview:btn];
    }
}

//button
-(UIButton* )createHeaderButtonWithFrame:(CGRect )frame title:(NSString* )title tag:(NSInteger )tag selector:(SEL )selector selected:(BOOL )selected {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:31/255.f green:192/255.f blue:210/255.f alpha:1] forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.selected = selected;
    btn.tag = tag;
    return btn;
}

//小说类型 视图
-(void)setupTypeFilterView {
    for (UIView* vi in self.filterView.subviews) {
        [vi removeFromSuperview];
    }
    CGFloat marginX = 0;
    CGFloat marginY = 0;
    NSInteger lines = 1;
    for (NSInteger i = 0; i < self.typeArray.count; i ++) {
        NSString* titleStr = [self.typeArray objectAtIndex:i];
        CGSize titleSize = [titleStr sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]}];
        titleSize.width += 4;
        if (marginX + titleSize.width > self.filterView.frame.size.width) {//超过宽度 放下一行
            marginX = 0;
            marginY += filterBtnHeight;
            lines += 1;
        }
        UIButton* btn = [self createHeaderButtonWithFrame:CGRectMake(marginX, marginY, titleSize.width, filterBtnHeight) title:titleStr tag:21 + i selector:@selector(clickedTypeButton:) selected:NO];
        marginX += btn.frame.size.width + 10;
        
        
        [self.filterView addSubview:btn];
    }
    CGRect filterFrame = self.filterView.frame;
    self.filterView.frame = CGRectMake(filterFrame.origin.x, filterFrame.origin.y, filterFrame.size.width, lines * filterBtnHeight);
    self.filterBottomView.frame = CGRectMake(0, self.filterView.frame.origin.y + self.filterView.frame.size.height, self.headerView.frame.size.width, 80);
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 120 + self.filterView.frame.size.height);
    self.tableView.tableHeaderView = self.headerView;
}

//选择 性别
-(void)clickedGenderButton:(UIButton* )sender {
    UIButton* allGenderBtn = (UIButton* )[self.headerView viewWithTag:10];//全部
    UIButton* maleBtn = (UIButton* )[self.headerView viewWithTag:11];//男生
    UIButton* femaleBtn = (UIButton* )[self.headerView viewWithTag:12];//女生
    UIButton* allTypeBtn = (UIButton* )[self.headerView viewWithTag:20];
    allTypeBtn.selected = YES;
    switch (sender.tag) {
        case 10://全部
        {
            if (self.genderType == GenderTypeGenderOther) {
                return;
            }
            self.genderType = GenderTypeGenderOther;
            allGenderBtn.selected = YES;
            maleBtn.selected = NO;
            femaleBtn.selected = NO;
            [self.typeArray removeAllObjects];
            [self.typeArray addObjectsFromArray:self.maleTypeArray];
            [self.typeArray addObjectsFromArray:self.femaleTypeArray];
        }
            break;
        case 11://男生
        {
            if (self.genderType == GenderTypeGenderMale) {
                return;
            }
            self.genderType = GenderTypeGenderMale;
            allGenderBtn.selected = NO;
            maleBtn.selected = YES;
            femaleBtn.selected = NO;
            [self.typeArray removeAllObjects];
            [self.typeArray addObjectsFromArray:self.maleTypeArray];
        }
            break;
        case 12://女生
        {
            if (self.genderType == GenderTypeGenderFemale) {
                return;
            }
            self.genderType = GenderTypeGenderFemale;
            allGenderBtn.selected = NO;
            maleBtn.selected = NO;
            femaleBtn.selected = YES;
            [self.typeArray removeAllObjects];
            [self.typeArray addObjectsFromArray:self.femaleTypeArray];
        }
            break;
        default:
            break;
    }
    [self setupTypeFilterView];
    
    self.page = 0;
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:NO];
}

//小说 类型
-(void)clickedTypeButton:(UIButton* )sender {
    if (sender.tag == 20) {//全部类型
        if (sender.selected == YES) {
            return;
        }
        sender.selected = YES;
        [self.filterTypeArray removeAllObjects];
        if (self.typeArray.count > 0) {
            [self.filterTypeArray addObjectsFromArray:self.typeArray];
        }
        for (NSInteger i = 0; i < self.typeArray.count; i ++) {
            UIButton* typeBtn = (UIButton* )[self.filterView viewWithTag:21 + i];
            typeBtn.selected = NO;
        }
    }else {
        UIButton* allTypeBtn = (UIButton* )[self.headerView viewWithTag:20];
        allTypeBtn.selected = NO;
        
        if (sender.selected == YES) {
            sender.selected = NO;
            NSString* titleStr = [sender titleForState:UIControlStateNormal];
            [self.filterTypeArray removeObject:titleStr];
        }else {
            sender.selected = YES;
            NSString* titleStr = [sender titleForState:UIControlStateNormal];
            [self.filterTypeArray addObject:titleStr];
        }
    }
    
    self.page = 0;
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:NO];
}

//小说状态
-(void)clickedStateButton:(UIButton* )sender {
    UIButton* allStateBtn = (UIButton* )[self.filterBottomView viewWithTag:100];//全部
    UIButton* finishedStateBtn = (UIButton* )[self.filterBottomView viewWithTag:101];//完结
    UIButton* loadStateBtn = (UIButton* )[self.filterBottomView viewWithTag:102];//连载中
    switch (sender.tag) {
        case 100:
        {
            if (self.bookState == LMBookStoreStateAll) {
                return;
            }
            self.bookState = LMBookStoreStateAll;
            allStateBtn.selected = YES;
            finishedStateBtn.selected = NO;
            loadStateBtn.selected = NO;
        }
            break;
        case 101:
        {
            if (self.bookState == LMBookStoreStateFinished) {
                return;
            }
            self.bookState = LMBookStoreStateFinished;
            allStateBtn.selected = NO;
            finishedStateBtn.selected = YES;
            loadStateBtn.selected = NO;
        }
            break;
        case 102:
        {
            if (self.bookState == LMBookStoreStateLoad) {
                return;
            }
            self.bookState = LMBookStoreStateLoad;
            allStateBtn.selected = NO;
            finishedStateBtn.selected = NO;
            loadStateBtn.selected = YES;
        }
            break;
        default:
            break;
    }
    
    self.page = 0;
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:NO];
}

//人气 最新上架
-(void)clickedRangeButton:(UIButton* )sender {
    UIButton* hotBtn = (UIButton* )[self.filterBottomView viewWithTag:200];//人气
    UIButton* isNewBtn = (UIButton* )[self.filterBottomView viewWithTag:201];//最新上架
    switch (sender.tag) {
        case 200:
        {
            if (self.bookRange == LMBookStoreRangeHot) {
                return;
            }
            self.bookRange = LMBookStoreRangeHot;
            hotBtn.selected = YES;
            isNewBtn.selected = NO;
        }
            break;
        case 201:
        {
            if (self.bookRange == LMBookStoreRangeNew) {
                return;
            }
            self.bookRange = LMBookStoreRangeNew;
            hotBtn.selected = NO;
            isNewBtn.selected = YES;
        }
            break;
        default:
            break;
    }
    
    self.page = 0;
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:NO];
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
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    CGFloat offsetY = -64;
    if ([LMTool isIPhoneX]) {
        offsetY = -88;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentOffset = CGPointMake(0, offsetY);
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
    LMBaseBookTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBaseBookTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Book* book = [self.dataArray objectAtIndex:indexPath.row];
    [cell setupContentBook:book];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Book* book = [self.dataArray objectAtIndex:indexPath.row];
    
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.book = book;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//加载男生 小说类型 列表
-(void)loadMaleTypeList {
    FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
    [builder setGender:GenderTypeGenderMale];
    FirstBookTypeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [[LMNetworkTool sharedNetworkTool] postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 1) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                    NSArray* arr = res.bookType;
                    
                    if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                        [self.maleTypeArray removeAllObjects];
                        [self.maleTypeArray addObjectsFromArray:arr];
                        [self.typeArray addObjectsFromArray:arr];
                        [self.filterTypeArray addObjectsFromArray:self.typeArray];
                        if (self.femaleTypeArray.count > 0) {
                            [self createTableHeaderView];
                            [self setupTypeFilterView];
                            
                            [self loadBookStoreDataWithPage:0 isLoadMoreData:NO];
                        }
                    }
                }
            }
        }
        [self hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
    }];
}

//加载女生 小说类型 列表
-(void)loadFemaleTypeList {
    FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
    [builder setGender:GenderTypeGenderFemale];
    FirstBookTypeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [[LMNetworkTool sharedNetworkTool] postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 1) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                    NSArray* arr = res.bookType;
                    
                    if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                        [self.femaleTypeArray removeAllObjects];
                        [self.femaleTypeArray addObjectsFromArray:arr];
                        [self.typeArray addObjectsFromArray:arr];
                        [self.filterTypeArray addObjectsFromArray:self.typeArray];
                        if (self.maleTypeArray.count > 0) {
                            [self createTableHeaderView];
                            [self setupTypeFilterView];
                            
                            [self loadBookStoreDataWithPage:0 isLoadMoreData:NO];
                        }
                    }
                }
            }
        }
        [self hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
    }];
}

//根据类型筛选
-(void)loadBookStoreDataWithPage:(NSInteger )page isLoadMoreData:(BOOL )loadMore {
    if (self.filterTypeArray.count == 0) {
        return;
    }
    
    self.isEnd = NO;
    
    UInt32 isNew = 1;
    if (self.bookRange == LMBookStoreRangeNew) {
        isNew = 2;
    }
    BookStoreReqBuilder* builder = [BookStoreReq builder];
    [builder setBookTypeArray:self.filterTypeArray];
    [builder setPage:(UInt32)page];
    if (self.bookState == LMBookStoreStateLoad) {
        [builder setIsFinished:1];
    }else if (self.bookState == LMBookStoreStateFinished) {
        [builder setIsFinished:2];
    }
    [builder setIsNew:isNew];
    BookStoreReq* req = [builder build];
    
    NSData* reqData = [req data];
    
    [[LMNetworkTool sharedNetworkTool] postWithCmd:5 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 5) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookStoreRes* res = [BookStoreRes parseFromData:apiRes.body];
                    NSArray* arr = res.books;
                    NSInteger currentSize = res.psize;
                    
                    if (self.page == 0) {
                        [self.dataArray removeAllObjects];
                    }
                    
                    [self.dataArray addObjectsFromArray:arr];
                    
                    if (arr.count < currentSize) {//最后一页
                        self.isEnd = YES;
                        [self.tableView setupNoMoreData];
                    }
                    self.page ++;
                    [self.tableView reloadData];
                }
            }
        }
        if (loadMore) {
            [self.tableView stopLoadMoreData];
        }else {
            [self.tableView stopRefresh];
        }
        [self hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        if (loadMore) {
            [self.tableView stopLoadMoreData];
        }else {
            [self.tableView stopRefresh];
        }
        [self hideNetworkLoadingView];
    }];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadBookStoreDataWithPage:self.page isLoadMoreData:YES];
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
