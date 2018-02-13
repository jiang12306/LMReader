//
//  LMDatabaseTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/8.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMDatabaseTool : NSObject

+(instancetype )sharedDatabaseTool;

//书架 book 表

//创建
-(BOOL )createBookShelfTable;
//删除
-(BOOL )deleteBookShelfTable;
//保存书
-(BOOL )saveBooksWithArray:(NSArray* )booksArr;




//最新章节 lastChapter 表

//创建
-(BOOL )createLastChapterTable;
//删除
-(BOOL )deleteLastChapterTable;




//来源 source 表

//创建
-(BOOL )createSourceTable;
//删除
-(BOOL )deleteSourceTable;


@end
