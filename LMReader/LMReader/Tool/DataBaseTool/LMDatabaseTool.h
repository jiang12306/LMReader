//
//  LMDatabaseTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/8.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMBookShelfModel.h"
#import "LMBookShelfLastestReadBook.h"

@interface LMDatabaseTool : NSObject

+(instancetype )sharedDatabaseTool;

//首次启动时创建数据表
-(void)createAllFirstLaunchTable;
//删除首次启动时创建的数据表
-(void)deleteAllFirstLaunchTable;



//章节有更新列表
//创建
-(BOOL )createBookNewestChapterTable;
//删除
-(BOOL )deleteBookNewestChapterTable;
//设置最新章节更新为已读
-(BOOL )clearNewestMarkWithBookId:(NSInteger )bookId;
//删除更新章节
-(BOOL )deleteBookNewestChapterWithBookId:(UInt32 )bookId;
//取书本是否有未读更新章节
-(NSInteger )queryNewestMarkWithBookId:(NSInteger )bookId;
//取书本未读更新章节
-(NewestChapter* )queryNewestChapterWithBookId:(NSInteger )bookId;



//阅读记录 表

//创建
-(BOOL )createReadRecordTable;
//删除
-(BOOL )deleteReadRecordTable;
//清空阅读记录
-(BOOL )deleteAllReadRecord;
//保存一条阅读记录
-(BOOL)saveBookReadRecordWithBookId:(UInt32 )bookId bookName:(NSString* )bookName chapterId:(NSString* )chapterId chapterNo:(UInt32 )chapterNo chapterTitle:(NSString* )chapterTitle sourceId:(UInt32 )sourceId offset:(NSInteger )offset progressStr:(NSString* )progressStr coverStr:(NSString* )coverStr;
//删除一条阅读记录
-(BOOL)deleteBookReadRecordWithBookId:(UInt32 )bookId;
//删除过时的阅读记录
-(BOOL )deleteBookReadRecordOver30Days;
//取过时的阅读记录
-(NSArray* )queryBookReadRecordOver30Days;
//根据bookId取阅读记录
-(void)queryBookReadRecordWithBookId:(UInt32 )bookId recordBlock:(void (^) (BOOL hasRecord, NSString* chapterId, UInt32 sourceId, NSInteger offset))block;
//根据bookId取阅读进度 标题
-(NSString* )queryBookReadRecordProgressWithBookId:(UInt32 )bookId;
//按照page、size取阅读记录
-(NSArray* )queryBookReadRecordWithPage:(NSInteger )page size:(NSInteger )size;
//删除本地有，服务端无的书籍
-(BOOL)deleteLocalSurplusBooksWithArray:(NSArray *)booksArr;
//取出所有阅读记录
-(NSArray* )queryAllBookReadRecord;
//取阅读记录中最近一本书 且书架不包含该书
-(LMBookShelfLastestReadBook* )queryLastestBookReadRecordWithBookShelfExistIdStr:(NSString* )existIdStr;





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
//判断 书架页面 某本书是否已存在
-(BOOL )checkUserBooksIsExistWithBookId:(UInt32 )bookId;
//删除 书架页面 书
-(BOOL )deleteUserBookWithBook:(Book* )book;
//取所有 书
-(NSMutableArray* )queryAllUserBooks;
//取出 书架页面 书
-(NSMutableArray* )queryAllBookShelfUserBooks;
//取一本 书架页面 书
-(LMBookShelfModel* )queryBookShelfUserBookWithBookId:(NSInteger )bookId;
//置顶/取消置顶 书架页面 书
-(BOOL )setUpside:(BOOL )upside book:(Book* )book;









@end


@interface LMBookNewestChapterModel : NSObject

@property (nonatomic, strong) NewestChapter* newestChapter;
@property (nonatomic, assign) NSInteger readState;

@end
