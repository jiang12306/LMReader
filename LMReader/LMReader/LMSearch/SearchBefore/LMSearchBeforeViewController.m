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
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMSearchBeforeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray* searchArray;/**<搜索历史*/
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSMutableArray* recommandArray;/**<热门推荐*/
@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//

@end

@implementation LMSearchBeforeViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* headerCellIdentifier = @"headerCellIdentifier";
static NSString* footerCellIdentifier = @"footerCellIdentifier";

-(instancetype)init {
    self = [super init];
    if (self) {
        self.searchArray = [NSMutableArray array];
        self.dataArray = [NSMutableArray array];
        [self.dataArray addObject:self.searchArray];
        
        self.recommandArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bookCoverWidth = 105.f;
    self.bookCoverHeight = 145.f;
    
    CGFloat maxBookWidth = (self.view.frame.size.width - 20 * 4 - 10 * 3) / 3.f;
    self.bookFontScale = (self.view.frame.size.width / 414.f);
    if (self.bookFontScale > 1) {
        self.bookFontScale = 1;
    }
    if (self.bookCoverWidth * self.bookFontScale > maxBookWidth) {
        self.bookFontScale = maxBookWidth / self.bookCoverWidth;
    }
    self.bookCoverWidth *= self.bookFontScale;
    self.bookCoverHeight *= self.bookFontScale;
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    
    LMSearchBeforeCollectionViewFlowLayout *layout = [[LMSearchBeforeCollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMSearchBeforeCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerCellIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerCellIdentifier];
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
                    if (booksArr.count > 0) {
                        if (booksArr.count >= 6) {
                            [weakSelf.recommandArray addObjectsFromArray:[booksArr subarrayWithRange:NSMakeRange(0, 6)]];
                        }else {
                            [weakSelf.recommandArray addObjectsFromArray:booksArr];
                        }
                    }
                    
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

//点击 书本
-(void)tappedBook:(UITapGestureRecognizer* )tapGR {
    UIView* vi = tapGR.view;
    NSInteger targetTag = vi.tag;
    Book* book = [self.recommandArray objectAtIndex:targetTag];
    UInt32 bookId = book.bookId;
    if (self.bookBlock) {
        self.bookBlock(bookId);
    }
}

#pragma mark -UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, 60);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == 1) {
        CGFloat labHeight = 50;
        CGFloat bookItemMaxHeight = 5 + self.bookCoverHeight + 10 + 40 + 10 + 20 + 20;
        return CGSizeMake(self.view.frame.size.width, labHeight + bookItemMaxHeight * 2);
    }
    return CGSizeMake(self.view.frame.size.width, 0);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerCellIdentifier forIndexPath:indexPath];
        for (UIView* vi in headerView.subviews) {
            if (vi.tag == 1) {
                [vi removeFromSuperview];
            }
        }
        
        NSString* text = @"暂无搜索历史";
        if (section == 0) {
            NSArray* arr = nil;
            @try {
                arr = [self.dataArray objectAtIndex:section];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            text = @"暂无搜索历史";
            if (arr != nil && arr.count > 0) {
                text = @"搜索历史";
            }
            UIButton* delBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 100 - 20, 20, 100, 30)];
            delBtn.tag = 1;
            delBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [delBtn setTitleColor:UIColorFromRGB(0x9baee5) forState:UIControlStateNormal];
            [delBtn setTitle:@"清空搜索历史" forState:UIControlStateNormal];
            [delBtn addTarget:self action:@selector(deleteAllSearchHistoryData) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:delBtn];
        }else if (section == 1) {
            text = @"大家都在搜";
        }
        
        UILabel* textLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 130, 30)];
        textLab.tag = 1;
        textLab.font = [UIFont systemFontOfSize:18];
        textLab.text = text;
        textLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
        [headerView addSubview:textLab];
        return headerView;
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerCellIdentifier forIndexPath:indexPath];
        for (UIView* vi in footerView.subviews) {
            if (vi.tag == 1) {
                [vi removeFromSuperview];
            }
        }
        if (section != 1) {
            return footerView;
        }
        UILabel* textLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 30)];
        textLab.tag = 1;
        textLab.font = [UIFont systemFontOfSize:18];
        textLab.text = @"热门推荐";
        textLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
        [footerView addSubview:textLab];
        
        UIView* tempView = [[UIView alloc]initWithFrame:CGRectMake(0, textLab.frame.origin.y + textLab.frame.size.height, footerView.frame.size.width, footerView.frame.size.height)];
        tempView.tag = 1;
        [footerView addSubview:tempView];
        
        CGFloat tempSpaceX = (footerView.frame.size.width - 20 * 2 - (self.bookCoverWidth + 10) * 3) / 2;
        CGFloat itemHeight = 5 + self.bookCoverHeight + 10 + 10 + 20;
        CGFloat itemHeight0 = 0;
        CGFloat itemHeight1 = 0;
        for (NSInteger i = 0; i < self.recommandArray.count; i ++) {
            Book* subBook0 = [self.recommandArray objectAtIndex:i];
            
            CGFloat maxLabHeight = 25;
            
            UILabel* bookNameLab = [[UILabel alloc]initWithFrame:CGRectZero];
            bookNameLab.numberOfLines = 0;
            bookNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
            bookNameLab.font = [UIFont systemFontOfSize:15];
            if (i % 3 == 0) {
                bookNameLab.text = subBook0.name;
                CGSize tempLabSize0 = [bookNameLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                if (tempLabSize0.height > bookNameLab.font.lineHeight * 2) {
                    tempLabSize0.height = bookNameLab.font.lineHeight * 2;
                }
                
                if (i + 1 < self.recommandArray.count) {
                    Book* subBook1 = [self.recommandArray objectAtIndex:i + 1];
                    bookNameLab.text = subBook1.name;
                    CGSize tempLabSize1 = [bookNameLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                    if (tempLabSize1.height > bookNameLab.font.lineHeight * 2) {
                        tempLabSize1.height = bookNameLab.font.lineHeight * 2;
                    }
                    maxLabHeight = MAX(tempLabSize0.height, tempLabSize1.height);
                }
                
                if (i + 2 < self.recommandArray.count) {
                    Book* subBook2 = [self.recommandArray objectAtIndex:i + 2];
                    bookNameLab.text = subBook2.name;
                    CGSize tempLabSize2 = [bookNameLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                    if (tempLabSize2.height > bookNameLab.font.lineHeight * 2) {
                        tempLabSize2.height = bookNameLab.font.lineHeight * 2;
                    }
                    maxLabHeight = MAX(maxLabHeight, tempLabSize2.height);
                }
                
                if (i == 0) {
                    itemHeight0 = itemHeight + maxLabHeight;
                }else if (i == 3) {
                    itemHeight1 = itemHeight + maxLabHeight;
                }
            }
            
            UIView* bookView = [[UIView alloc]initWithFrame:CGRectMake(20 + (i % 3) * (tempSpaceX + self.bookCoverWidth + 10), 20 * (i / 3 + 1) + i / 3 * itemHeight0, self.bookCoverWidth + 10, i < 3 ? itemHeight0 : itemHeight1)];
            bookView.tag = i;
            [tempView addSubview:bookView];
            
            UIImageView* coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.bookCoverWidth, self.bookCoverHeight)];
            coverIV.contentMode = UIViewContentModeScaleAspectFill;
            coverIV.clipsToBounds = YES;
            NSString* coverUrlStr = [subBook0.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [coverIV sd_setImageWithURL:[NSURL URLWithString:coverUrlStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage_Gray"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image && error == nil) {
                    
                }else {
                    coverIV.image = [UIImage imageNamed:@"defaultBookImage"];
                }
            }];
            [bookView addSubview:coverIV];
            
            CGFloat markIVWidth = 50;
            CGFloat markTopSpace = 4;
            if ([UIScreen mainScreen].bounds.size.width <= 320) {
                markIVWidth = 40;
                markTopSpace = 3;
            }
            UIImageView* markIV = [[UIImageView alloc]initWithFrame:CGRectMake(coverIV.frame.origin.x + coverIV.frame.size.width - markIVWidth + markTopSpace, coverIV.frame.origin.y - markTopSpace, markIVWidth, markIVWidth)];
            if ([subBook0 hasMarkUrl]) {
                markIV.hidden = NO;
                
                NSString* markUrlStr = [subBook0.markUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                
                UIImage* markImg = [[SDImageCache sharedImageCache] imageFromCacheForKey:markUrlStr];
                if (markImg != nil) {
                    markIV.image = markImg;
                }else {
                    [markIV sd_setImageWithURL:[NSURL URLWithString:markUrlStr] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        if (error == nil && image != nil) {
                            
                        }
                    }];
                }
            }else {
                markIV.hidden = YES;
            }
            [bookView addSubview:markIV];
            
            UIImageView* authorIV = [[UIImageView alloc]initWithFrame:CGRectMake(coverIV.frame.origin.x, bookView.frame.size.height - 20, 15, 15)];
            authorIV.image = [UIImage imageNamed:@"bookAuthor"];
            [bookView addSubview:authorIV];
            
            UILabel* authorLab = [[UILabel alloc]initWithFrame:CGRectMake(authorIV.frame.origin.x + authorIV.frame.size.width + 5, authorIV.frame.origin.y, coverIV.frame.size.width - authorIV.frame.size.width - 5, authorIV.frame.size.height)];
            authorLab.text = subBook0.author;
            authorLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
            authorLab.font = [UIFont systemFontOfSize:12];
            [bookView addSubview:authorLab];
            
            bookNameLab.text = subBook0.name;
            bookNameLab.frame = CGRectMake(coverIV.frame.origin.x, coverIV.frame.origin.y + coverIV.frame.size.height + 10, self.bookCoverWidth, authorLab.frame.origin.y - coverIV.frame.origin.y - coverIV.frame.size.height - 10 * 2);
            [bookView addSubview:bookNameLab];
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedBook:)];
            [bookView addGestureRecognizer:tap];
        }
        
        return footerView;
    }
    return nil;
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
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray* arr = [self.dataArray objectAtIndex:section];
    
    LMSearchBeforeCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString* text = @"";
    if (section == 0) {
        text = [arr objectAtIndex:row];
    }else if (section == 1) {
        text = [arr objectAtIndex:row];
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
        if (self.historyBlock) {
            self.historyBlock(text);
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
    lab.font = [UIFont systemFontOfSize:15];
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
    CGFloat topInset = 10;
    @try {
        if (section == 0) {
            NSArray* arr = [self.dataArray objectAtIndex:section];
            if (arr != nil && arr.count > 0) {
                
            }else {//无搜索历史时，缩小顶部间距
                topInset = 0;
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    return UIEdgeInsetsMake(topInset, 20, topInset, 20);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
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
