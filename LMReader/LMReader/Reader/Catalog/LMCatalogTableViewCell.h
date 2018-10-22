//
//  LMCatalogTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/9.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@interface LMCatalogTableViewCell : LMBaseArrowTableViewCell

@property (nonatomic, strong) UILabel* numberLab;//章节 第1章 label
@property (nonatomic, strong) UILabel* nameLab;//更新章节 label
@property (nonatomic, strong) UILabel* timeLab;//更新时间 label

-(void)setContentWithNumberStr:(NSString* )numberStr nameStr:(NSString* )nameStr timeStr:(NSString* )timeStr isClicked:(BOOL )isClicked;

@end
