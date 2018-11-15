//
//  LMChoiceCollectionTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/25.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMChoiceCollectionTableViewCell.h"
#import "LMChoiceTableViewCellCollectionViewCell.h"

@implementation LMChoiceCollectionTableViewCell

static NSString* cellIdentifier = @"cellIdentifier";

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubview];
    }
    return self;
}

-(void)setupSubview {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    self.dataArray = [NSMutableArray array];
    self.itemHeightArray = [NSMutableArray array];
    
    if (!self.collectionView) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 0) collectionViewLayout:layout];
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.scrollEnabled = NO;
        [self.collectionView registerClass:[LMChoiceTableViewCellCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        [self.contentView addSubview:self.collectionView];
    }
}

-(void)setupContentBookArray:(NSArray *)bookArray cellHeight:(CGFloat)cellHeight ivWidth:(CGFloat)ivWidth ivHeight:(CGFloat)ivHeight itemWidth:(CGFloat)itemWidth itemHeightArr:(nonnull NSArray *)itemHeightArr nameFontSize:(CGFloat )nameFontSize briefFontSize:(CGFloat )briefFontSize {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:bookArray];
    
    [self.itemHeightArray removeAllObjects];
    [self.itemHeightArray addObjectsFromArray:itemHeightArr];
    
    self.itemWidth = itemWidth;
    self.ivWidth = ivWidth;
    self.ivHeight = ivHeight;
    self.nameFontSize = 17;
    self.briefFontSize = 14;
    if (nameFontSize) {
        self.nameFontSize = nameFontSize;
    }
    if (briefFontSize) {
        self.briefFontSize = briefFontSize;
    }
    
    self.collectionView.frame = CGRectMake(0, 0, screenRect.size.width, cellHeight);
    
    [self.collectionView reloadData];
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMChoiceTableViewCellCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    Book* book = [self.dataArray objectAtIndex:row];
    NSInteger index = row / 3;
    NSNumber* heightNum = [self.itemHeightArray objectAtIndex:index];
    CGFloat itemHeight = heightNum.floatValue;
    [cell setupWithBook:book ivWidth:self.ivWidth ivHeight:self.ivHeight itemWidth:self.itemWidth itemHeight:itemHeight nameFontSize:self.nameFontSize briefFontSize:self.briefFontSize];
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    Book* book = [self.dataArray objectAtIndex:row];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickedChoiceTableViewCellCollectionViewCellOfBook:)]) {
        [self.delegate didClickedChoiceTableViewCellCollectionViewCellOfBook:book];
    }
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger index = row / 3;
    NSNumber* heightNum = [self.itemHeightArray objectAtIndex:index];
    CGFloat itemHeight = heightNum.floatValue;
    return CGSizeMake(self.itemWidth, itemHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat spaceX = 20 - 5;
    CGFloat spaceY = 20;
    return UIEdgeInsetsMake(spaceY, spaceX, spaceY, spaceX);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20 - 5;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
