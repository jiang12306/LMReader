//
//  LMSpecialChoiceModel.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/3.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceModel.h"

@implementation LMSpecialChoiceModel

+(CGFloat )caculateSpecialChoiceModelTextHeightWithText:(NSString* )text width:(CGFloat )width font:(UIFont* )font {
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    lab.lineBreakMode = NSLineBreakByCharWrapping;
    lab.numberOfLines = 0;
    if (font) {
        lab.font = font;
    }else {
        lab.font = [UIFont systemFontOfSize:18];
    }
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    return labSize.height;
}

@end
