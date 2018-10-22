//
//  LMPinYinSearch.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/7.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMPinYinSearch.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "objc/runtime.h"

@implementation LMPinYinSearch

+(NSArray *)searchWithOriginalArray:(NSArray *)originalArray andSearchText:(NSString *)searchText {
    NSMutableArray * dataSourceArray = [[NSMutableArray alloc]init];
    if (originalArray.count <= 0) {
        return nil;
    }
    if (searchText.length > 0 && ![ChineseInclude isIncludeChineseInString:searchText]) {//搜索文字不包含中文
        for (int i = 0; i < originalArray.count; i++) {
            NSString * tempString = originalArray[i];
            
            if ([ChineseInclude isIncludeChineseInString:tempString]) {
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:tempString];
                
                NSRange titleResult = [tempPinYinStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:tempString];
                
                NSRange titleHeadResult = [tempPinYinHeadStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
            }else {
                NSRange titleResult = [tempString rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length > 0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
            }
        }
    } else if (searchText.length > 0 && [ChineseInclude isIncludeChineseInString:searchText]) {//搜索文字包含中文
        for (id object in originalArray) {
            NSString * tempString = object;
            
            NSRange titleResult = [tempString rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (titleResult.length > 0) {
                [dataSourceArray addObject:object];
            }
        }
    }
    return dataSourceArray;
}


+(NSArray *)searchWithOriginalArray:(NSArray *)originalArray andSearchText:(NSString *)searchText andSearchByPropertyName:(NSString *)propertyName {
    NSMutableArray* dataSourceArray = [[NSMutableArray alloc]init];
    if (originalArray.count <= 0) {
        return dataSourceArray;
    }else{
        id object = originalArray[0];
        
        NSMutableArray *props = [NSMutableArray array];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([object class], &outCount);
        for (i = 0; i<outCount; i++) {
            objc_property_t property = properties[i];
            const char* char_f = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            [props addObject:propertyName];
        }
        
        free(properties);
        BOOL isExit = NO;
        for (NSString * property in props) {
            if([property isEqualToString:propertyName]){
                isExit = YES;
                break;
            }
        }
        if (!isExit) {
            return originalArray;
        }
    }
    if (searchText.length > 0 && ![ChineseInclude isIncludeChineseInString:searchText]) {//搜索文字不包含中文
        for (int i = 0; i < originalArray.count; i++) {
            NSString* tempString = [originalArray[i] valueForKey:propertyName];
            
            if ([ChineseInclude isIncludeChineseInString:tempString]) {
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:tempString];
                
                NSRange titleResult = [tempPinYinStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length > 0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:tempString];
                
                NSRange titleHeadResult = [tempPinYinHeadStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length > 0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
            }else {
                NSRange titleResult = [tempString rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length > 0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
            }
        }
    }else if (searchText.length > 0 && [ChineseInclude isIncludeChineseInString:searchText]) {//搜索文字包含中文
        for (id object in originalArray) {
            NSString* tempString = [object valueForKey:propertyName];
            
            NSRange titleResult = [tempString rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (titleResult.length > 0) {
                [dataSourceArray addObject:object];
            }
        }
    }
    return dataSourceArray;
}

@end
