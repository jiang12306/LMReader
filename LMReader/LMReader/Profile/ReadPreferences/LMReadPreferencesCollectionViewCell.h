//
//  LMReadPreferencesCollectionViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/20.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMReadPreferencesCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel* nameLab;

-(void)setClicked:(BOOL )isClicked genderType:(GenderType )genderType;

@end
