//
//  LMSearchBeforeViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/14.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchBeforeViewController.h"
#import "LMSearchBeforeCollectionViewCell.h"
#import "LMSearchBeforeCollectionViewFlowLayout.h"
#import "LMTool.h"

@interface LMSearchBeforeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray* searchArray;/**<搜索历史*/
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UICollectionView* collectionView;

@end

@implementation LMSearchBeforeViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* headerCellIdentifier = @"headerCellIdentifier";

-(instancetype)init {
    self = [super init];
    if (self) {
        self.searchArray = [NSMutableArray array];//[NSMutableArray arrayWithObjects:@"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", @"ihwenfliwne", @"哦IE你覅文", nil];//
        self.dataArray = [NSMutableArray array];
        [self.dataArray addObject:self.searchArray];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    LMSearchBeforeCollectionViewFlowLayout *layout = [[LMSearchBeforeCollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 40);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor colorWithRed:248.f/255 green:248.f/255 blue:248.f/255 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMSearchBeforeCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerCellIdentifier];
    [self.view addSubview:self.collectionView];
    
    //
    [self loadSearchBeforeData];
}

-(void)resetupSearchHistoryDataWithArray:(NSArray *)historyArr {
    [self.searchArray removeAllObjects];
    if (historyArr != nil && ![historyArr isKindOfClass:[NSNull class]] && historyArr.count > 0) {
        [self.searchArray addObjectsFromArray:historyArr];
    }
    [self.dataArray replaceObjectAtIndex:0 withObject:self.searchArray];
    [self.collectionView reloadData];
}

-(void)loadSearchBeforeData {
    __weak LMSearchBeforeViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:32 ReqData:nil successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 32) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SearchInitRes* res = [SearchInitRes parseFromData:apiRes.body];
                    
                    NSArray* wordsArr = res.sKw;
                    [weakSelf.dataArray addObject:wordsArr];
                    NSArray* booksArr = res.interestBooks;
                    [weakSelf.dataArray addObject:booksArr];
                    
                    [weakSelf.collectionView reloadData];
                }
            }
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    } failureBlock:^(NSError *failureError) {
        
    }];
}

//清空搜索历史
-(void)deleteAllSearchHistoryData {
    if (self.cleanBlock) {
        self.cleanBlock(YES);
    }
    [self.searchArray removeAllObjects];
    [self.dataArray replaceObjectAtIndex:0 withObject:self.searchArray];
    [self.collectionView reloadData];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerCellIdentifier forIndexPath:indexPath];
    for (UIView* vi in headerView.subviews) {
        if (vi.tag == 1) {
            [vi removeFromSuperview];
        }
    }
    if (section != 0) {
        UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        lineView.tag = 1;
        lineView.backgroundColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:1];
        [headerView addSubview:lineView];
    }
    
    UILabel* lab0 = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 5, 20)];
    lab0.layer.cornerRadius = 2.5;
    lab0.layer.masksToBounds = YES;
    lab0.tag = 1;
    lab0.backgroundColor = THEMEORANGECOLOR;
    [headerView addSubview:lab0];
    
    NSString* text = @"搜索历史";
    if (section == 0) {
        text = @"搜索历史";
        UIButton* delBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100, 10, 90, 30)];
        delBtn.tag = 1;
        delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [delBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [delBtn setTitle:@"清空搜索历史" forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(deleteAllSearchHistoryData) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:delBtn];
    }else if (section == 1) {
        text = @"大家都在搜";
    }else if (section == 2) {
        text = @"热门推荐";
    }
    
    UILabel* textLab = [[UILabel alloc]initWithFrame:CGRectMake(lab0.frame.origin.x + lab0.frame.size.width + 10, 10, 100, 30)];
    textLab.tag = 1;
    textLab.font = [UIFont boldSystemFontOfSize:18];
    textLab.text = text;
    [headerView addSubview:textLab];
    return headerView;
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray* arr = [self.dataArray objectAtIndex:section];
    return arr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMSearchBeforeCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSArray* arr = [self.dataArray objectAtIndex:section];
    NSString* text = @"";
    if (section == 0) {
        text = [arr objectAtIndex:row];
    }else if (section == 1) {
        text = [arr objectAtIndex:row];
    }else if (section == 2) {
        Book* book = [arr objectAtIndex:row];
        text = book.name;
    }
    cell.nameLab.text = text;
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* arr = [self.dataArray objectAtIndex:section];
    if (section == 0) {
        NSString* text = [arr objectAtIndex:row];
        if (self.historyBlock) {
            self.historyBlock(text);
        }
    }else if (section == 1) {
        NSString* text = [arr objectAtIndex:row];
//        if (self.stringBlock) {
//            self.stringBlock(text);
//        }
        if (self.historyBlock) {
            self.historyBlock(text);
        }
    }else if (section == 2) {
        Book* book = [arr objectAtIndex:row];
        UInt32 bookId = book.bookId;
        if (self.bookBlock) {
            self.bookBlock(bookId);
        }
    }
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSArray* arr = [self.dataArray objectAtIndex:section];
    NSString* text = @"";
    if (section == 0) {
        text = [arr objectAtIndex:row];
    }else if (section == 1) {
        text = [arr objectAtIndex:row];
    }else if (section == 2) {
        Book* book = [arr objectAtIndex:row];
        text = book.name;
    }
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 20)];
    lab.font = [UIFont systemFontOfSize:16];
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)];
    
    CGFloat cellWidth = labSize.width + 10;
    if (cellWidth > self.view.frame.size.width - 10) {
        cellWidth = self.view.frame.size.width - 10;
    }
    CGFloat cellHeight = 30;
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
