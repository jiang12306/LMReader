//
//  LMBookShelfListAddCollectionViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LMBookShelfListAddCollectionViewCell;

@protocol LMBookShelfListAddCollectionViewCellDelegate <NSObject>

@optional
-(void)LMBookShelfListAddCollectionViewCellDidClickAdd:(LMBookShelfListAddCollectionViewCell* )addCell;

@end

@interface LMBookShelfListAddCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<LMBookShelfListAddCollectionViewCellDelegate> delegate;


@property (nonatomic, strong) UIButton* addBtn;
@property (nonatomic, strong) UIImageView* addIV;
@property (nonatomic, strong) UILabel* addLab;

-(void)setupListAddCellWithItemWidth:(CGFloat)itemWidth itemHeight:(CGFloat)itemHeight;

@end

NS_ASSUME_NONNULL_END
