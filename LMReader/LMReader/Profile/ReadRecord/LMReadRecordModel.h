//
//  LMReadRecordModel.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/11.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMReadRecordModel : NSObject

@property (nonatomic, assign) UInt32 bookId;/**<*/
@property (nonatomic, copy) NSString* name;/**<*/
@property (nonatomic, assign) UInt32 chapterId;/**<*/
@property (nonatomic, assign) UInt32 chapterNo;/**<*/
@property (nonatomic, copy) NSString* chapterTitle;/**<*/
@property (nonatomic, assign) UInt32 sourceId;/**<*/
@property (nonatomic, assign) UInt32 offset;/**<阅读进度 偏移量*/
@property (nonatomic, strong) NSString* dateStr;/**<日期*/
@property (nonatomic, assign) BOOL isCollected;/**<是否已收藏*/

@property (nonatomic, assign) NSInteger dayInteger;/**<距离今天天数：0.今天；1.昨天；x天前*/

@end
