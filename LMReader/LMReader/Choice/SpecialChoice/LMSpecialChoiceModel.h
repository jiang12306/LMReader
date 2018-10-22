//
//  LMSpecialChoiceModel.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/3.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMSpecialChoiceModel : NSObject

@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat briefHeight;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) TopicChart* topicChart;

+(CGFloat )caculateSpecialChoiceModelTextHeightWithText:(NSString* )text width:(CGFloat )width font:(UIFont* )font;

@end
