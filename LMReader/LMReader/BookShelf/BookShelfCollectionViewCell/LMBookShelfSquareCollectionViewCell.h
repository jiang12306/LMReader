//
//  LMBookShelfSquareCollectionViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMBookShelfModel.h"

NS_ASSUME_NONNULL_BEGIN

@class LMBookShelfSquareCollectionViewCell;

@protocol LMBookShelfSquareCollectionViewCellDelegate <NSObject>

@optional
-(void)LMBookShelfSquareCollectionViewCellDidLongPress:(LMBookShelfSquareCollectionViewCell* )pressedCell;

@end

@interface LMBookShelfSquareCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<LMBookShelfSquareCollectionViewCellDelegate> delegate;

@property (nonatomic, assign) BOOL isEditting;//编辑模式
@property (nonatomic, assign) BOOL isClicked;//是否已选中
@property (nonatomic, strong) UIImageView* selectIV;//选中状态

@property (nonatomic, strong) UIImageView* coverIV;//封面
@property (nonatomic, strong) UIImageView* markIV;//标签 图片
@property (nonatomic, strong) UILabel* redDotLab;//更新 红点
@property (nonatomic, strong) UILabel* nameLab;//书名
@property (nonatomic, strong) UILabel* progressLab;//阅读进度

-(void)setupSquareCellWithModel:(LMBookShelfModel* )model ivWidth:(CGFloat )ivWidth ivHeight:(CGFloat )ivHeight itemWidth:(CGFloat )itemWidth itemHeight:(CGFloat )itemHeight;

@end

NS_ASSUME_NONNULL_END
