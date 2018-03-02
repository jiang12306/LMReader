//
//  LMDatabaseTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/8.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ftbook.pb.h"

@interface LMDatabaseTool : NSObject

+(instancetype )sharedDatabaseTool;

//首次启动时创建数据表
-(void)createAllFirstLaunchTable;
//删除首次启动时创建的数据表
-(void)deleteAllFirstLaunchTable;





//阅读记录 表

//创建
-(BOOL )createReadRecordTable;
//删除
-(BOOL )deleteReadRecordTable;
//保存一条阅读记录
-(BOOL)saveBookReadRecordWithBookId:(UInt32 )bookId bookName:(NSString* )bookName chapterId:(UInt32 )chapterId offset:(NSInteger )offset;
//删除一条阅读记录
-(BOOL)deleteBookReadRecordWithBookId:(UInt32 )bookId;
//根据bookId取阅读记录
-(void)queryBookReadRecordWithBookId:(UInt32 )bookId recordBlock:(void (^) (BOOL hasRecord, UInt32 chapterId, NSInteger offset))block;





//书架 book 表

//创建
-(BOOL )createBookShelfTable;
//删除
-(BOOL )deleteBookShelfTable;




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





//保存 书架页面 书
-(BOOL )saveUserBooksWithArray:(NSArray* )booksArr;
//删除 书架页面 书
-(BOOL )deleteUserBookWithBook:(Book* )book;
//取出所有 书架页面 书
-(NSMutableArray<UserBook*>* )queryAllUserBooks;
//置顶/取消置顶 书架页面 书
-(BOOL )setUpside:(BOOL )upside book:(Book* )book;





@end
