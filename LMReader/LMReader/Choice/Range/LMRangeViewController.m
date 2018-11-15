//
//  LMRangeViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRangeViewController.h"
#import "LMRangeTitleCollectionViewCell.h"
#import "LMRangeRightTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMBaseRefreshTableView.h"
#import "LMRangeLeftTypeTableViewCell.h"
#import "LMBookDetailViewController.h"
#import "LMTool.h"

@interface LMRangeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* maleArray;
@property (nonatomic, strong) NSMutableArray* femaleArray;

@property (nonatomic, assign) GenderType genderType;/**<性别*/
@property (nonatomic, assign) NSInteger leftTypeIndex;/**<左侧列表选中 脚标*/

@property (nonatomic, strong) LMBaseRefreshTableView* leftTypeTableView;

@property (nonatomic, strong) LMBaseRefreshTableView* rightTableView;
@property (nonatomic, strong) NSMutableArray* rightArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger rangeId;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//

@end

@implementation LMRangeViewController

static NSString* titleCellIdentifier = @"titleCellIdentifier";
static NSString* leftCellIdentifier = @"leftCellIdentifier";
static NSString* rightCellIdentifier = @"rightCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bookCoverWidth = 72.f;
    self.bookCoverHeight = 100.f;
    self.bookNameFontSize = 15.f;
    self.bookBriefFontSize = 12.f;
    
    
    self.title = @"排行榜";
    
    self.view.backgroundColor = [UIColor colorWithRed:235.f/255 green:235.f/255 blue:235.f/255 alpha:1];
    
    //collectionView
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, LMRangeTitleCollectionViewHeight) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMRangeTitleCollectionViewCell class] forCellWithReuseIdentifier:titleCellIdentifier];
    [self.view addSubview:self.collectionView];
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    
    //left tableView
    self.leftTypeTableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, self.collectionView.frame.origin.y + self.collectionView.frame.size.height, LMRangeLeftTableViewWidth, self.view.frame.size.height - self.collectionView.frame.origin.y - self.collectionView.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.leftTypeTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.leftTypeTableView.backgroundColor = [UIColor clearColor];
    self.leftTypeTableView.delegate = self;
    self.leftTypeTableView.dataSource = self;
    self.leftTypeTableView.refreshDelegate = self;
    [self.leftTypeTableView setupNoRefreshData];
    [self.leftTypeTableView setupNoMoreData];
    self.leftTypeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.leftTypeTableView registerClass:[LMRangeLeftTypeTableViewCell class] forCellReuseIdentifier:leftCellIdentifier];
    [self.view addSubview:self.leftTypeTableView];
    
    
    //right tableView
    self.rightTableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(LMRangeLeftTableViewWidth, self.leftTypeTableView.frame.origin.y, self.view.frame.size.width - LMRangeLeftTableViewWidth, self.leftTypeTableView.frame.size.height) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.rightTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.rightTableView.backgroundColor = [UIColor whiteColor];
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    self.rightTableView.refreshDelegate = self;
    self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.rightTableView registerClass:[LMRangeRightTableViewCell class] forCellReuseIdentifier:rightCellIdentifier];
    [self.view addSubview:self.rightTableView];
    
    
    self.leftTypeIndex = 0;
    self.genderType = GenderTypeGenderMale;
    self.maleArray = [NSMutableArray array];
    self.femaleArray = [NSMutableArray array];
    
    self.page = 0;
    self.rightArray = [NSMutableArray array];
    
    //
    [self initRangeData];
}


-(void)initRangeData {
    TopicChartReqBuilder* builder = [TopicChartReq builder];
    [builder setType:3];
    TopicChartReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMRangeViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:11 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 11) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    [weakSelf hideNetworkLoadingView];
                    
                    TopicChartRes* res = [TopicChartRes parseFromData:apiRes.body];
                    NSArray* arr = res.tcs;
                    if (arr.count > 0) {
                        for (NSInteger i = 0; i < arr.count; i ++) {
                            TopicChart* subChart = [arr objectAtIndex:i];
                            if (i == 0) {
                                self.rangeId = subChart.id;
                            }
                            GenderType genderType = subChart.gender;
                            if (genderType == GenderTypeGenderMale) {
                                [weakSelf.maleArray addObject:subChart];
                            }else if (genderType == GenderTypeGenderFemale) {
                                [weakSelf.femaleArray addObject:subChart];
                            }
                        }
                        [weakSelf loadRangeRightDataWithRangeId:self.rangeId Page:weakSelf.page isRefreshingOrLoadMoreData:NO];
                    }else {
                        [weakSelf showEmptyLabelWithText:@"空空如也"];
                    }
                    [weakSelf.leftTypeTableView reloadData];
                    
                    [weakSelf.collectionView reloadData];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf hideNetworkLoadingView];
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    //
    if (self.maleArray.count == 0 || self.femaleArray.count == 0) {
        [self initRangeData];
        return;
    }
    
    if (self.rightArray.count == 0) {
        [self loadRangeRightDataWithRangeId:self.rangeId Page:self.page isRefreshingOrLoadMoreData:NO];
    }
}

-(void)loadRangeRightDataWithRangeId:(NSInteger )rangeid Page:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    
    TopicChartBookReqBuilder* builder = [TopicChartBookReq builder];
    [builder setTcid:(UInt32)rangeid];
    [builder setPage:(UInt32)page];
    [builder setT2Id:0];
    TopicChartBookReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMRangeViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:12 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 12) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    TopicChartBookRes* res = [TopicChartBookRes parseFromData:apiRes.body];
                    
                    NSArray* arr1 = res.books;
                    if (weakSelf.page == 0) {//第一页
                        [weakSelf.rightArray removeAllObjects];
                    }
                    if (arr1.count > 0) {
                        [weakSelf.rightArray addObjectsFromArray:arr1];
                    }else {//最后一页
                        [weakSelf.rightTableView setupNoMoreData];
                    }
                    weakSelf.page ++;
                    [weakSelf.rightTableView reloadData];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            if (page == 0) {
                [weakSelf showReloadButton];
            }
        } @finally {
            
        }
        [weakSelf hideNetworkLoadingView];
        if (loadMore) {
            [weakSelf.rightTableView stopLoadMoreData];
        }else {
            [weakSelf.rightTableView stopRefresh];
        }
        if (weakSelf.rightArray.count == 0) {
            [weakSelf showMBProgressHUDWithText:@"空空如也"];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        if (loadMore) {
            [weakSelf.rightTableView stopLoadMoreData];
        }else {
            [weakSelf.rightTableView stopRefresh];
        }
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        if (page == 0) {
            [weakSelf showReloadButton];
        }
    }];
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMRangeTitleCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:titleCellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    BOOL isSelected = NO;
    if (row == 0) {
        cell.nameLab.text = @"男生";
        if (self.genderType == GenderTypeGenderMale) {
            isSelected = YES;
        }
    }else {
        cell.nameLab.text = @"女生";
        if (self.genderType == GenderTypeGenderFemale) {
            isSelected = YES;
        }
    }
    [cell setupClciked:isSelected];
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        if (self.genderType == GenderTypeGenderMale) {
            return;
        }
        self.genderType = GenderTypeGenderMale;
        self.leftTypeIndex = 0;
        [self.collectionView reloadData];
        
        [self.leftTypeTableView reloadData];
        
        TopicChart* subChart = [self.maleArray firstObject];
        self.rangeId = subChart.id;
        self.page = 0;
        [self.rightTableView cancelNoRefreshData];
        [self.rightTableView cancelNoMoreData];
        [self.rightArray removeAllObjects];
        [self.rightTableView reloadData];
        [self loadRangeRightDataWithRangeId:self.rangeId Page:self.page isRefreshingOrLoadMoreData:NO];
        
    }else if (row == 1) {
        if (self.genderType == GenderTypeGenderFemale) {
            return;
        }
        self.genderType = GenderTypeGenderFemale;
        self.leftTypeIndex = 0;
        [self.collectionView reloadData];
        
        [self.leftTypeTableView reloadData];
        
        TopicChart* subChart = [self.femaleArray firstObject];
        self.rangeId = subChart.id;
        self.page = 0;
        [self.rightTableView cancelNoRefreshData];
        [self.rightTableView cancelNoMoreData];
        [self.rightArray removeAllObjects];
        [self.rightTableView reloadData];
        [self loadRangeRightDataWithRangeId:self.rangeId Page:self.page isRefreshingOrLoadMoreData:NO];
    }
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width / 2, LMRangeTitleCollectionViewHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTypeTableView) {
        if (self.genderType == GenderTypeGenderMale) {
            return self.maleArray.count;
        }else if (self.genderType == GenderTypeGenderFemale) {
            return self.femaleArray.count;
        }
    }else if (tableView == self.rightTableView) {
        return self.rightArray.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTypeTableView) {
        return 60;
    }else if (tableView == self.rightTableView) {
        return self.bookCoverHeight + 20 * 2;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (tableView == self.leftTypeTableView) {
        LMRangeLeftTypeTableViewCell* cell = [self.leftTypeTableView dequeueReusableCellWithIdentifier:leftCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMRangeLeftTypeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftCellIdentifier];
        }
        
        TopicChart* subChart;
        if (self.genderType == GenderTypeGenderMale) {
            subChart = [self.maleArray objectAtIndex:row];
        }else if (self.genderType == GenderTypeGenderFemale) {
            subChart = [self.femaleArray objectAtIndex:row];
        }
        
        NSString* nameStr = subChart.name;
        
        cell.titleLab.text = nameStr;
        if (row == self.leftTypeIndex) {
            [cell setupClicked:YES];
        }else {
            [cell setupClicked:NO];
        }
        [cell showLineView:NO];
        
        return cell;
        
    }else if (tableView == self.rightTableView) {
        LMRangeRightTableViewCell* cell = [self.rightTableView dequeueReusableCellWithIdentifier:rightCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMRangeRightTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rightCellIdentifier];
        }
        [cell showLineView:NO];
        
        Book* book = [self.rightArray objectAtIndex:row];
        [cell setupContentBook:book cellHeight:self.bookCoverHeight + 20 * 2 cellWidth:self.rightTableView.frame.size.width ivWidth:self.bookCoverWidth nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    if (tableView == self.leftTypeTableView) {
        if (row == self.leftTypeIndex) {
            return;
        }
        self.leftTypeIndex = row;
        [self.leftTypeTableView reloadData];
        
        TopicChart* subChart;
        if (self.genderType == GenderTypeGenderMale) {
            subChart = [self.maleArray objectAtIndex:row];
        }else if (self.genderType == GenderTypeGenderFemale) {
            subChart = [self.femaleArray objectAtIndex:row];
        }
        self.rangeId = subChart.id;
        self.page = 0;
        [self.rightTableView cancelNoRefreshData];
        [self.rightTableView cancelNoMoreData];
        [self.rightArray removeAllObjects];
        [self.rightTableView reloadData];
        [self loadRangeRightDataWithRangeId:self.rangeId Page:self.page isRefreshingOrLoadMoreData:NO];
        
    }else if (tableView == self.rightTableView) {
        Book* book = [self.rightArray objectAtIndex:row];
        LMBookDetailViewController* bookDetailVC = [[LMBookDetailViewController alloc]init];
        bookDetailVC.bookId = book.bookId;
        [self.navigationController pushViewController:bookDetailVC animated:YES];
    }
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    if (tv == self.leftTypeTableView) {
        return;
    }else if (tv == self.rightTableView) {
        self.page = 0;
        [self.rightTableView cancelNoMoreData];
        
        [self loadRangeRightDataWithRangeId:self.rangeId Page:self.page isRefreshingOrLoadMoreData:NO];
    }
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (tv == self.leftTypeTableView) {
        return;
    }else if (tv == self.rightTableView) {
        
        [self loadRangeRightDataWithRangeId:self.rangeId Page:self.page isRefreshingOrLoadMoreData:YES];
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
