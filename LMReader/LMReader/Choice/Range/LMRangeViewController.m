//
//  LMRangeViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRangeViewController.h"
#import "LMRangeCollectionViewCell.h"
#import "LMRangeDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMRangeViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* maleArray;
@property (nonatomic, strong) NSMutableArray* femaleArray;

@end

@implementation LMRangeViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* headerCellIdentifier = @"headerCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"各家排行榜";
    
    self.maleArray = [NSMutableArray array];
    self.femaleArray = [NSMutableArray array];
    
    //
    [self initRangeData];
}

-(void)setupCollectionView {
    if (self.collectionView) {
        return;
    }
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 60);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMRangeCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerCellIdentifier];
    [self.view addSubview:self.collectionView];
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
                    TopicChartRes* res = [TopicChartRes parseFromData:apiRes.body];
                    NSArray* arr = res.tcs;
                    if (arr.count > 0) {
                        for (TopicChart* subChart in arr) {
                            GenderType genderType = subChart.gender;
                            if (genderType == GenderTypeGenderMale) {
                                [weakSelf.maleArray addObject:subChart];
                            }else if (genderType == GenderTypeGenderFemale) {
                                [weakSelf.femaleArray addObject:subChart];
                            }
                        }
                    }else {
                        [weakSelf showEmptyLabelWithText:@"空空如也"];
                    }
                    [weakSelf setupCollectionView];
                    
                    [weakSelf.collectionView reloadData];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        [weakSelf hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    //
    [self initRangeData];
}

#pragma mark -UICollectionViewDataSource
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerCellIdentifier forIndexPath:indexPath];
    for (UIView* vi in headerView.subviews) {
        if (vi.tag == 1) {
            [vi removeFromSuperview];
        }
    }
    
    NSString* text = @"男生";
    UIColor* textColor = [UIColor blackColor];
    UIColor* lineColor = [UIColor colorWithRed:200.f / 255 green:200.f / 255 blue:200.f / 255 alpha:1];
    UIImage* dotImg = [UIImage imageNamed:@"range_Dot_Male"];
    if (section == 1) {
        text = @"女生";
        textColor = [UIColor colorWithRed:180.f / 255 green:100.f / 255 blue:200.f / 255 alpha:1];
        lineColor = [UIColor colorWithRed:180.f / 255 green:100.f / 255 blue:200.f / 255 alpha:1];
        dotImg = [UIImage imageNamed:@"range_Dot_Female"];
    }
    
    UILabel* textLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 60, 30)];
    textLab.tag = 1;
    textLab.backgroundColor = [UIColor whiteColor];
    textLab.textAlignment = NSTextAlignmentCenter;
    textLab.font = [UIFont systemFontOfSize:18];
    textLab.textColor = textColor;
    textLab.text = text;
    textLab.center = CGPointMake(headerView.frame.size.width / 2, headerView.frame.size.height / 2 + 10);
    [headerView addSubview:textLab];
    
    UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(headerView.frame.size.width / 6, textLab.frame.origin.y + textLab.frame.size.height / 2, headerView.frame.size.width * 2 / 3, 1)];
    lineView.tag = 1;
    lineView.backgroundColor = lineColor;
    [headerView insertSubview:lineView belowSubview:textLab];
    
    UIImageView* dotIV1 = [[UIImageView alloc]initWithFrame:CGRectMake(textLab.frame.origin.x - 5, lineView.center.y - 2.5, 5, 5)];
    dotIV1.tag = 1;
    dotIV1.image = dotImg;
    [headerView addSubview:dotIV1];
    
    UIImageView* dotIV2 = [[UIImageView alloc]initWithFrame:CGRectMake(textLab.frame.origin.x + textLab.frame.size.width, lineView.center.y - 2.5, 5, 5)];
    dotIV2.tag = 1;
    dotIV2.image = dotImg;
    [headerView addSubview:dotIV2];
    
    return headerView;
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.maleArray.count;
    }else if (section == 1) {
        return self.femaleArray.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMRangeCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    TopicChart* subChart;
    if (section == 0) {
        subChart = [self.maleArray objectAtIndex:row];
    }else if (section == 1) {
        subChart = [self.femaleArray objectAtIndex:row];
    }
    
    NSString* nameStr = subChart.name;
    NSString* imgStr = [subChart.converUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    cell.nameLab.text = nameStr;
    [cell.coverIV sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"defaultChoice"] options:SDWebImageRefreshCached];
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    TopicChart* subChart;
    if (section == 0) {
        subChart = [self.maleArray objectAtIndex:row];
    }else if (section == 1) {
        subChart = [self.femaleArray objectAtIndex:row];
    }
    
    LMRangeDetailViewController* rangeDetailVC = [[LMRangeDetailViewController alloc]init];
    rangeDetailVC.rangeId = subChart.id;
    rangeDetailVC.titleStr = subChart.name;
    [rangeDetailVC.dataArray addObjectsFromArray:subChart.topic2S];
    [self.navigationController pushViewController:rangeDetailVC animated:YES];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat cellWidth = (screenWidth - 31) / 2;
    CGFloat cellHeight = 70;
    return CGSizeMake(cellWidth, cellHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
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
