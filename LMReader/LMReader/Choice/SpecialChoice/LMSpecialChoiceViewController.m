//
//  LMSpecialChoiceViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceViewController.h"
#import "LMSpecialChoiceDetailViewController.h"
#import "LMSpecialChoiceCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface LMSpecialChoiceViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* dataArray;

@end

@implementation LMSpecialChoiceViewController

static NSString* cellId = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"精选专题";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMSpecialChoiceCollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.collectionView];
    
    self.dataArray = [NSMutableArray array];
    [self initSpecialChoiceData];
}

-(void)initSpecialChoiceData {
    TopicChartReqBuilder* builder = [TopicChartReq builder];
    [builder setType:2];
    TopicChartReq* req = [builder build];
    NSData* reqData = [req data];
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:11 ReqData:reqData successBlock:^(NSData *successData) {
        FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
        if (apiRes.cmd == 11) {
            ErrCode err = apiRes.err;
            if (err == ErrCodeErrNone) {
                TopicChartRes* res = [TopicChartRes parseFromData:apiRes.body];
                NSArray* arr = res.tcs;
                if (arr.count > 0) {
                    [self.dataArray addObjectsFromArray:arr];
                }
                
                [self.collectionView reloadData];
            }
        }
        [self hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
    }];
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMSpecialChoiceCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    TopicChart* chart = [self.dataArray objectAtIndex:indexPath.row];
    NSString* urlStr = chart.converUrl;
    
    [cell.coverIV sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"firstLaunch1"] options:SDWebImageRefreshCached];
    cell.nameLab.text = chart.name;
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TopicChart* chart = [self.dataArray objectAtIndex:indexPath.row];
    
    LMSpecialChoiceDetailViewController* choiceDetailVC = [[LMSpecialChoiceDetailViewController alloc]init];
    choiceDetailVC.chart = chart;
    [self.navigationController pushViewController:choiceDetailVC animated:YES];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = (self.view.frame.size.width - 30)/2;
    return (CGSize){cellWidth, cellWidth * 3 /4};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
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
