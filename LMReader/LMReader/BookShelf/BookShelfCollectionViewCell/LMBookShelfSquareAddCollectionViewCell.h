//
//  LMBookShelfSquareAddCollectionViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMBookShelfSquareAddCollectionViewCell;

@protocol LMBookShelfSquareAddCollectionViewCellDelegate <NSObject>

@optional
-(void)LMBookShelfSquareAddCollectionViewCellDidClickAdd:(LMBookShelfSquareAddCollectionViewCell* )addCell;

@end

@interface LMBookShelfSquareAddCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<LMBookShelfSquareAddCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) UIButton* addBtn;
@property (nonatomic, strong) UIImageView* addIV;
@property (nonatomic, strong) UILabel* addLab;

-(void)setupSquareAddCellWithIvWidth:(CGFloat )ivWidth ivHeight:(CGFloat )ivHeight;

@end

NS_ASSUME_NONNULL_END
