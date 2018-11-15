//
//  LMChoiceCollectionTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/25.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol LMChoiceCollectionTableViewCellDelegate <NSObject>

@optional
-(void)didClickedChoiceTableViewCellCollectionViewCellOfBook:(id )bookModel;

@end


@interface LMChoiceCollectionTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) id<LMChoiceCollectionTableViewCellDelegate> delegate;

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSMutableArray* itemHeightArray;

@property (nonatomic, assign) CGFloat ivWidth;
@property (nonatomic, assign) CGFloat ivHeight;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat nameFontSize;
@property (nonatomic, assign) CGFloat briefFontSize;

-(void)setupContentBookArray:(NSArray* )bookArray cellHeight:(CGFloat )cellHeight ivWidth:(CGFloat )ivWidth ivHeight:(CGFloat )ivHeight itemWidth:(CGFloat )itemWidth itemHeightArr:(NSArray* )itemHeightArr nameFontSize:(CGFloat )nameFontSize briefFontSize:(CGFloat )briefFontSize;

@end

NS_ASSUME_NONNULL_END
