//
//  LMReaderConfig.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/13.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMReaderConfig : NSObject

@property (nonatomic, assign) CGFloat brightness;/**<屏幕亮度*/
@property (nonatomic, assign) CGFloat fontSize;/**<字号*/
@property (nonatomic, assign) NSInteger bgIndex;/**<背景 角标*/
@property (nonatomic, assign) CGFloat lineSpace;/**<行间距*/

@end
