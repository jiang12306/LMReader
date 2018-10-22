//
//  LMSearchAuthorTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/16.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@interface LMSearchAuthorTableViewCell : LMBaseTableViewCell

@property (nonatomic, strong) UILabel* textLab;
@property (nonatomic, strong) UIImageView* coverIV;
@property (nonatomic, strong) UILabel* markLab;//“作者”标签label

-(void)setupWithAuthorString:(NSString* )authorStr;

@end
