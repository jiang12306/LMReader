//
//  LMReaderRecommandTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/12/3.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LMReaderRecommandTableViewCellDelegate <NSObject>

@optional
-(void)didClickedReaderRecommandTableViewCellCollectionViewCellOfBook:(id )clickedBook;

@end

@interface LMReaderRecommandTableViewCell : LMBaseTableViewCell  <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) id<LMReaderRecommandTableViewCellDelegate> delegate;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* dataArray;

@property (nonatomic, assign) CGFloat ivWidth;
@property (nonatomic, assign) CGFloat ivHeight;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat nameFontSize;
@property (nonatomic, assign) CGFloat briefFontSize;

-(void)setupContentBookArray:(NSArray* )bookArray cellHeight:(CGFloat )cellHeight ivWidth:(CGFloat )ivWidth ivHeight:(CGFloat )ivHeight itemWidth:(CGFloat )itemWidth nameFontSize:(CGFloat )nameFontSize briefFontSize:(CGFloat )briefFontSize;

@end

NS_ASSUME_NONNULL_END
