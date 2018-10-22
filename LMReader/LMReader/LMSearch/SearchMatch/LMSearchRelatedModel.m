//
//  LMSearchRelatedModel.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/15.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchRelatedModel.h"

@implementation LMSearchRelatedModel

+(NSArray *)convertToElementArrayWithAuthorArray:(NSArray *)authorArray {
    NSMutableArray* resultArr = [NSMutableArray array];
    @try {
        for (NSString* str in authorArray) {
            LMSearchRelatedModel* model = [[LMSearchRelatedModel alloc]init];
            model.type = LMSearchRelatedModelAuthor;
            model.bookAuthor = str;
            //
            [resultArr addObject:model];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        return resultArr;
    }
}

+(NSArray *)convertToElementArrayWithBookArray:(NSArray *)bookArray {
    NSMutableArray* resultArr = [NSMutableArray array];
    @try {
        for (Book* book in bookArray) {
            UInt32 bookId = book.bookId;
            NSString* bookName = book.name;
            NSString* bookAuthor = book.author;
            
            LMSearchRelatedModel* model = [[LMSearchRelatedModel alloc]init];
            model.type = LMSearchRelatedModelBook;
            model.bookId = bookId;
            model.bookAuthor = bookAuthor;
            model.bookName = bookName;
            //
            [resultArr addObject:model];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        return resultArr;
    }
}

@end
