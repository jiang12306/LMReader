//
//  LMCatalogTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/9.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@interface LMCatalogTableViewCell : LMBaseArrowTableViewCell

@property (nonatomic, strong) UILabel* nameLab;//更新章节 label

-(void)setContentWithNameStr:(NSString* )nameStr isClicked:(BOOL )isClicked;

@end
