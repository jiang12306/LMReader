//
//  LMRangeTitleCollectionViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMRangeTitleCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* lineLab;

-(void)setupClciked:(BOOL )isClicked;

@end
