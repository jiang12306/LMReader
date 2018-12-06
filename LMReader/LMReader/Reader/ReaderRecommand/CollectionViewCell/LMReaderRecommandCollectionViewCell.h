//
//  LMReaderRecommandCollectionViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/12/3.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMReaderRecommandCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView* coverIV;//封面
@property (nonatomic, strong) UIImageView* markIV;//标签 图片
@property (nonatomic, strong) UILabel* nameLab;//书名
@property (nonatomic, strong) UIImageView* authorIV;//作者 图片
@property (nonatomic, strong) UILabel* authorLab;//作者

-(void)setupWithBook:(Book* )book ivWidth:(CGFloat )ivWidth ivHeight:(CGFloat )ivHeight itemWidth:(CGFloat )itemWidth itemHeight:(CGFloat )itemHeight nameFontSize:(CGFloat )nameFontSize briefFontSize:(CGFloat )briefFontSize;

@end

NS_ASSUME_NONNULL_END
