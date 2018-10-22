//
//  LMSearchRelatedModel.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/15.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LMSearchRelatedModelAuthor = 1,//作者类型
    LMSearchRelatedModelBook = 2,//书籍类型
}LMSearchRelatedModelType;

@interface LMSearchRelatedModel : NSObject

@property (nonatomic, assign) LMSearchRelatedModelType type;/**<匹配搜索结果类型，优先作者，然后书籍*/
@property (nonatomic, assign) UInt32 bookId;
@property (nonatomic, copy) NSString* bookName;
@property (nonatomic, copy) NSString* bookAuthor;

//将作者数组转换成model数组
+(NSArray *)convertToElementArrayWithAuthorArray:(NSArray *)authorArray;/**<将元素为NSString的作者数组转换成元素为LMSearchRelatedModel的数组*/

//将book数组转换成model数组
+(NSArray* )convertToElementArrayWithBookArray:(NSArray* )bookArray;/**<将元素为book的数组转换成元素为LMSearchRelatedModel的数组*/

@end
