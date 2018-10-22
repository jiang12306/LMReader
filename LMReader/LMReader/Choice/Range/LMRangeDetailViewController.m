//
//  LMRangeDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRangeDetailViewController.h"
#import "LMTool.h"
#import "LMSubRangeDetailViewController.h"
#import "PopoverView.h"
#import "LMBookStoreTitleCollectionViewCell.h"
#import "LMRootViewController.h"

@interface LMRangeDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, LMSubRangeDetailViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation LMRangeDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";

-(instancetype)init {
    self = [super init];
    if (self) {
        self.currentIndex = 0;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.titleStr != nil) {
        self.title = self.titleStr;
    }else {
        self.title = @"排行榜详情";
    }
    
    UIView* moreItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIButton* moreItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, moreItemView.frame.size.width, moreItemView.frame.size.height)];
    [moreItemBtn setImage:[UIImage imageNamed:@"rightBarButtonItem_More_Black"] forState:UIControlStateNormal];
    [moreItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [moreItemBtn addTarget:self action:@selector(clickedMoreItemButton:) forControlEvents:UIControlEventTouchUpInside];
    [moreItemView addSubview:moreItemBtn];
    UIBarButtonItem* moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreItemView];
    self.navigationItem.rightBarButtonItem = moreItem;
    
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
    
    if (self.dataArray.count > 0) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.dataArray.count, 0);
        [self createSubRangeDetailViewController];
    }
}

-(void)clickedMoreItemButton:(UIButton* )sender {
    NSMutableArray* actionArray = [NSMutableArray array];
    PopoverAction* briefAction = [PopoverAction actionWithTitle:@"书架" handler:^(PopoverAction *action) {
        LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
        [rootVC backToTabBarControllerWithViewControllerIndex:0];
    }];
    [actionArray addObject:briefAction];
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.style = PopoverViewStyleDefault;
    popoverView.hideAfterTouchOutside = YES;
    [popoverView showToView:sender withActions:actionArray];
}

//
-(void)deleteAllSubRangeDetailViewController {
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMSubRangeDetailViewController class]]) {
            LMSubRangeDetailViewController* subVC = (LMSubRangeDetailViewController* )vc;
            [subVC.view removeFromSuperview];
            [subVC removeFromParentViewController];
        }
    }
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

//
-(void)createSubRangeDetailViewController {
    if (self.dataArray.count == 0) {
        return;
    }
    BOOL isContain = NO;
    for (UIViewController* vc in self.childViewControllers) {
        if ([vc isKindOfClass:[LMSubRangeDetailViewController class]]) {
            LMSubRangeDetailViewController* subVC = (LMSubRangeDetailViewController* )vc;
            if (subVC.markTag == self.currentIndex) {
                isContain = YES;
                break;
            }
        }
    }
    if (!isContain) {
        Topic2* topic = [self.dataArray objectAtIndex:self.currentIndex];
        
        LMSubRangeDetailViewController* subVC = [[LMSubRangeDetailViewController alloc]init];
        subVC.delegate = self;
        subVC.markTag = self.currentIndex;
        subVC.rangeId = self.rangeId;
        subVC.titleRangeId = topic.id;
        subVC.view.frame = CGRectMake(self.scrollView.frame.size.width * self.currentIndex, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [self addChildViewController:subVC];
        [self.scrollView addSubview:subVC.view];
    }
    
    [self.collectionView reloadData];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger page = scrollView.contentOffset.x/CGRectGetWidth(self.view.frame);
        
        self.currentIndex = page;
        
        //
        [self createSubRangeDetailViewController];
    }
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMBookStoreTitleCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    Topic2* topic = [self.dataArray objectAtIndex:row];
    NSString* titleStr = topic.name;
    
    BOOL didContain = NO;
    if (row == self.currentIndex) {
        didContain = YES;
    }
    
    cell.isClicked = didContain;
    cell.nameLab.text = titleStr;
    
    if (indexPath.row == self.dataArray.count - 1) {
        if (self.collectionView.contentSize.width < self.view.frame.size.width) {
            CGPoint originPoint = self.collectionView.center;
            self.collectionView.frame = CGRectMake(0, 0, self.collectionView.contentSize.width, self.collectionView.frame.size.height);
            originPoint.x = self.view.frame.size.width / 2;
            self.collectionView.center = originPoint;
        }
    }
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    self.currentIndex = indexPath.row;
    
    LMBookStoreTitleCollectionViewCell* cell = (LMBookStoreTitleCollectionViewCell* )[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isClicked == NO) {
        
        [self createSubRangeDetailViewController];
        
        [UIView animateWithDuration:0.1 animations:^{
            self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * self.currentIndex, 0);
        }];
    }
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 40;
    NSInteger row = indexPath.row;
    Topic2* topic = [self.dataArray objectAtIndex:row];
    NSString* text = topic.name;
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, cellHeight)];
    lab.font = [UIFont systemFontOfSize:16];
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(CGFLOAT_MAX, cellHeight)];
    
    CGFloat cellWidth = labSize.width + 10;
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
    
    [self deleteAllSubRangeDetailViewController];
    [self createSubRangeDetailViewController];
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
