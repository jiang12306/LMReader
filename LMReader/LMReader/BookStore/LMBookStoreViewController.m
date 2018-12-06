//
//  LMBookStoreViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookStoreViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMTool.h"
#import "LMSearchViewController.h"
#import "LMBookDetailViewController.h"
#import "LMBookStoreTitleCollectionViewCell.h"
#import "LMSearchTitleView.h"
#import "LMBookStoreFilterListView.h"
#import "LMTypeBookStoreViewController.h"
#import "LMRightItemView.h"
#import "LMBookStoreUserInstructionsView.h"

@interface LMBookStoreViewController () <UICollectionViewDelegate, UICollectionViewDataSource, LMTypeBookStoreViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* maleTypeArray;//男生 小说类型
@property (nonatomic, strong) NSMutableArray* femaleTypeArray;//女生 小说类型
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, assign) NSInteger currentIndex;//选中的小说角标
@property (nonatomic, assign) GenderType genderType;//性别
@property (nonatomic, assign) LMBookStoreState bookState;//完结 连载中
@property (nonatomic, assign) LMBookStoreRange bookRange;//人气 最新上架

@end

@implementation LMBookStoreViewController

static NSString* cellIdentifier = @"cellIdentifier";

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //防止iOS11 刘海屏tabBar下移34
    UITabBarController* tabBarController = self.tabBarController;
    if (tabBarController) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat tabBarHeight = 49;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
        }
        tabBarController.tabBar.frame = CGRectMake(0, screenRect.size.height - tabBarHeight, screenRect.size.width, tabBarHeight);
    }
    
    //显示书城页用户指引
    if ([LMTool shouldShowBookStoreUserInstructionsView]) {
        CGFloat naviHeight = 20 + 44 - 10;
        if ([LMTool isBangsScreen]) {
            naviHeight = 44 + 44 - 10;
        }
        LMBookStoreUserInstructionsView* storeUIV = [[LMBookStoreUserInstructionsView alloc]init];
        [storeUIV startShowWithFilterPoint:CGPointMake(self.view.frame.size.width - 15, naviHeight)];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView* filtView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 38, 30)];
    UIButton* filtItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, filtView.frame.size.width, filtView.frame.size.height)];
    [filtItemBtn setImage:[[UIImage imageNamed:@"bookStore_RightItem_Filter"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    filtItemBtn.tintColor = UIColorFromRGB(0x656565);
    [filtItemBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 2, 12)];
    [filtItemBtn addTarget:self action:@selector(clickedFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    [filtView addSubview:filtItemBtn];
    UIBarButtonItem* filtItem = [[UIBarButtonItem alloc]initWithCustomView:filtView];
    
    UIView* emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 30)];
    UILabel* emptyLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, emptyView.frame.size.width, emptyView.frame.size.height)];
    [emptyView addSubview:emptyLab];
    UIBarButtonItem* emptyItem = [[UIBarButtonItem alloc]initWithCustomView:emptyView];
    
    self.navigationItem.rightBarButtonItems = @[filtItem, emptyItem];
    
    UIView* leftEmptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 30)];
    UILabel* leftEmptyLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, leftEmptyView.frame.size.width, leftEmptyView.frame.size.height)];
    [leftEmptyView addSubview:leftEmptyLab];
    UIBarButtonItem* leftEmptyItem = [[UIBarButtonItem alloc]initWithCustomView:leftEmptyView];
    self.navigationItem.leftBarButtonItem = leftEmptyItem;
    
    __weak LMBookStoreViewController* weakSelf = self;
    
    LMSearchTitleView* searchView = [[LMSearchTitleView alloc]initWithFrame:CGRectMake(0, 7, self.view.frame.size.width - leftEmptyView.frame.size.width - emptyView.frame.size.width - filtView.frame.size.width, 30)];
    searchView.clickBlock = ^(BOOL didClick) {
        if (didClick) {
            LMSearchViewController* searchVC = [[LMSearchViewController alloc]init];
            [weakSelf.navigationController pushViewController:searchVC animated:YES];
        }
    };
    self.navigationItem.titleView = searchView;
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMBookStoreTitleCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.collectionView];
    
    //scrollView
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.collectionView.frame.origin.y + self.collectionView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.collectionView.frame.origin.y - self.collectionView.frame.size.height)];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(0, 0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view insertSubview:self.scrollView belowSubview:self.collectionView];
    
    self.maleTypeArray = [NSMutableArray array];
    self.femaleTypeArray = [NSMutableArray array];
    self.currentIndex = 0;
    GenderType tempType = GenderTypeGenderMale;
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        if (regUser.user.gender == GenderTypeGenderFemale) {
            tempType = GenderTypeGenderFemale;
        }
    }else {
        tempType = [LMTool getFirstLaunchGenderType];
    }
    
    self.genderType = tempType;
    self.bookState = LMBookStoreStateAll;
    self.bookRange = LMBookStoreRangeUp;
    
    //
    [self initData];
}

-(void)initData {
    //加载数据
    [self loadMaleTypeList];
    [self loadFemaleTypeList];
}

//筛选 状态、排序类型
-(void)clickedFilterButton:(UIButton* )sender {
    LMBookStoreFilterListView* listView = [[LMBookStoreFilterListView alloc]initWithFrame:CGRectMake(0, 0, 225, 200)];
    listView.bookRange = self.bookRange;
    listView.bookState = self.bookState;
    listView.gendType = self.genderType;
    listView.rangeBlock = ^(LMBookStoreRange range) {
        if (self.maleTypeArray.count == 0 || self.femaleTypeArray.count == 0) {
            [self initData];
            return;
        }
        self.bookRange = range;
        
        [self deleteAllTypeBookStoreViewController];
        self.scrollView.contentOffset = CGPointMake(self.currentIndex * self.view.frame.size.width, 0);
        [self createTypeBookStoreViewController];
    };
    listView.stateBlock = ^(LMBookStoreState state) {
        if (self.maleTypeArray.count == 0 || self.femaleTypeArray.count == 0) {
            [self initData];
            return;
        }
        self.bookState = state;
        
        [self deleteAllTypeBookStoreViewController];
        self.scrollView.contentOffset = CGPointMake(self.currentIndex * self.view.frame.size.width, 0);
        [self createTypeBookStoreViewController];
    };
    listView.genderBlock = ^(GenderType gender) {
        if (self.maleTypeArray.count == 0 || self.femaleTypeArray.count == 0) {
            [self initData];
            return;
        }
        if (self.genderType == gender) {
            return;
        }
        self.genderType = gender;
        self.currentIndex = 0;
        
        [self deleteAllTypeBookStoreViewController];
        if (gender == GenderTypeGenderFemale) {
            self.scrollView.contentSize = CGSizeMake(self.femaleTypeArray.count * self.view.frame.size.width, 0);
        }else {
            self.scrollView.contentSize = CGSizeMake(self.maleTypeArray.count * self.view.frame.size.width, 0);
        }
        [self createTypeBookStoreViewController];
    };
    [listView showToView:sender];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    if (self.maleTypeArray.count == 0 || self.femaleTypeArray.count == 0) {
        [self initData];
        return;
    }else {
        self.currentIndex = 0;
        [self.maleTypeArray removeAllObjects];
        [self.femaleTypeArray removeAllObjects];
        [self.collectionView reloadData];
        
        [self initData];
    }
}

#pragma mark -LMTypeBookStoreViewControllerDelegate
-(void)typeBookStoreViewControllerDidClickedBookId:(NSInteger)bookId {
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.bookId = (UInt32 )bookId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(LMTypeBookStoreViewController* )getCurrentTypeBookStoreViewController {
    NSArray* childArr = self.childViewControllers;
    if (childArr.count != 0 && childArr.count > self.currentIndex) {
        LMTypeBookStoreViewController* typeVC = [childArr objectAtIndex:self.currentIndex];
        return typeVC;
    }
    return nil;
}

//
-(void)deleteAllTypeBookStoreViewController {
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMTypeBookStoreViewController class]]) {
            LMTypeBookStoreViewController* typeVC = (LMTypeBookStoreViewController* )vc;
            [typeVC.view removeFromSuperview];
            [typeVC removeFromParentViewController];
        }
    }
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

//
-(void)createTypeBookStoreViewController {
    if (self.maleTypeArray.count == 0 || self.femaleTypeArray.count == 0) {
        return;
    }
    BOOL isContain = NO;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMTypeBookStoreViewController class]]) {
            LMTypeBookStoreViewController* typeVC = (LMTypeBookStoreViewController* )vc;
            if (typeVC.markTag == self.currentIndex) {
                isContain = YES;
                break;
            }
        }
    }
    if (!isContain) {
        LMTypeBookStoreViewController* typeVC = [[LMTypeBookStoreViewController alloc]init];
        typeVC.delegate = self;
        typeVC.markTag = self.currentIndex;
        typeVC.genderType = self.genderType;
        typeVC.bookState = self.bookState;
        typeVC.bookRange = self.bookRange;
        NSArray* tempFiltArray = [NSArray array];
        NSArray* allTypeArr = [NSArray arrayWithArray:self.maleTypeArray];
        if (self.genderType == GenderTypeGenderFemale) {
            allTypeArr = [NSArray arrayWithArray:self.femaleTypeArray];
        }
        if (self.currentIndex != 0) {
            tempFiltArray = [NSArray arrayWithObject:[allTypeArr objectAtIndex:self.currentIndex]];
        }else {
            tempFiltArray = [allTypeArr subarrayWithRange:NSMakeRange(1, allTypeArr.count - 1)];
        }
        typeVC.filterArr = tempFiltArray;
        typeVC.view.frame = CGRectMake(self.scrollView.frame.size.width * self.currentIndex, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [self addChildViewController:typeVC];
        [self.scrollView addSubview:typeVC.view];
    }
    
    [self.collectionView reloadData];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

//加载男生 小说类型 列表
-(void)loadMaleTypeList {
    FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
    [builder setGender:GenderTypeGenderMale];
    FirstBookTypeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookStoreViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            @try {
                [weakSelf hideNetworkLoadingView];
                
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 1) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                        NSArray* arr = res.bookType;
                        
                        if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                            [weakSelf.maleTypeArray removeAllObjects];
                            [weakSelf.maleTypeArray addObject:@"全部"];
                            [weakSelf.maleTypeArray addObjectsFromArray:arr];
                            
                            weakSelf.currentIndex = 0;
                            if (weakSelf.femaleTypeArray.count > 0) {
                                weakSelf.scrollView.contentSize = CGSizeMake(weakSelf.view.frame.size.width * weakSelf.maleTypeArray.count, 0);
                                if (weakSelf.genderType == GenderTypeGenderFemale) {
                                    weakSelf.scrollView.contentSize = CGSizeMake(weakSelf.view.frame.size.width * weakSelf.femaleTypeArray.count, 0);
                                }
                                [weakSelf deleteAllTypeBookStoreViewController];
                                [weakSelf createTypeBookStoreViewController];
                            }
                        }
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
                [weakSelf showReloadButton];
            } @finally {
                
            }
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

//加载女生 小说类型 列表
-(void)loadFemaleTypeList {
    FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
    [builder setGender:GenderTypeGenderFemale];
    FirstBookTypeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookStoreViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            @try {
                [weakSelf hideNetworkLoadingView];
                
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 1) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                        NSArray* arr = res.bookType;
                        
                        if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                            [weakSelf.femaleTypeArray removeAllObjects];
                            [weakSelf.femaleTypeArray addObject:@"全部"];
                            [weakSelf.femaleTypeArray addObjectsFromArray:arr];
                            
                            weakSelf.currentIndex = 0;
                            if (weakSelf.maleTypeArray.count > 0) {
                                weakSelf.scrollView.contentSize = CGSizeMake(weakSelf.view.frame.size.width * weakSelf.maleTypeArray.count, 0);
                                if (weakSelf.genderType == GenderTypeGenderFemale) {
                                    weakSelf.scrollView.contentSize = CGSizeMake(weakSelf.view.frame.size.width * weakSelf.femaleTypeArray.count, 0);
                                }
                                [weakSelf deleteAllTypeBookStoreViewController];
                                [weakSelf createTypeBookStoreViewController];
                            }
                        }
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
                [weakSelf showReloadButton];
            } @finally {
                
            }
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        
        self.currentIndex = page;
        
        //
        [self createTypeBookStoreViewController];
    }
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.genderType == GenderTypeGenderMale) {
        return self.maleTypeArray.count;
    }else if (self.genderType == GenderTypeGenderFemale) {
        return self.femaleTypeArray.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMBookStoreTitleCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    NSString* titleStr = @"";
    if (self.genderType == GenderTypeGenderMale) {
        titleStr = [self.maleTypeArray objectAtIndex:row];
    }else if (self.genderType == GenderTypeGenderFemale) {
        titleStr = [self.femaleTypeArray objectAtIndex:row];
    }
    BOOL didContain = NO;
    if (row == self.currentIndex) {
        didContain = YES;
    }
    
    cell.isClicked = didContain;
    cell.nameLab.text = titleStr;
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    self.currentIndex = indexPath.row;
    
    LMBookStoreTitleCollectionViewCell* cell = (LMBookStoreTitleCollectionViewCell* )[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isClicked == NO) {
        
        [self createTypeBookStoreViewController];
        
        [UIView animateWithDuration:0.1 animations:^{
            self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * self.currentIndex, 0);
        }];
    }
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 40;
    NSInteger row = indexPath.row;
    NSString* text = @"";
    if (self.genderType == GenderTypeGenderMale) {
        text = [self.maleTypeArray objectAtIndex:row];
    }else if (self.genderType == GenderTypeGenderFemale) {
        text = [self.femaleTypeArray objectAtIndex:row];
    }
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, cellHeight)];
    lab.font = [UIFont systemFontOfSize:18];
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(CGFLOAT_MAX, cellHeight)];
    
    CGFloat cellWidth = labSize.width + 18;
    return CGSizeMake(cellWidth, cellHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMTypeBookStoreViewController class]]) {
            LMTypeBookStoreViewController* typeVC = (LMTypeBookStoreViewController* )vc;
            if (typeVC.markTag == self.currentIndex) {
                continue;
            }
            [typeVC.view removeFromSuperview];
            [typeVC removeFromParentViewController];
        }
    }
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
