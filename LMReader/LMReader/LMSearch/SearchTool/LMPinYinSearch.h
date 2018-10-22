//
//  LMPinYinSearch.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/7.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMPinYinSearch : NSObject

+(NSArray *)searchWithOriginalArray:(NSArray *)originalArray andSearchText:(NSString *)searchText;/**<直接匹配字符串，数组元素是字符串*/

+(NSArray *)searchWithOriginalArray:(NSArray *)originalArray andSearchText:(NSString *)searchText andSearchByPropertyName:(NSString *)propertyName;/**<数组元素是NSDictionary类型，搜索匹配某一key*/

@end
