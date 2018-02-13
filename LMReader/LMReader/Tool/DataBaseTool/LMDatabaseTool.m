//
//  LMDatabaseTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/8.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMDatabaseTool.h"
#import "FMDB.h"
#import "Ftbook.pb.h"

@implementation LMDatabaseTool

static LMDatabaseTool *_sharedDatabaseTool;
static dispatch_once_t onceToken;
static NSString* databaseName = @"book.db";

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        if (_sharedDatabaseTool == nil) {
            _sharedDatabaseTool = [super allocWithZone:zone];
        }
    });
    return _sharedDatabaseTool;
}

-(id)copyWithZone:(NSZone *)zone {
    return _sharedDatabaseTool;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedDatabaseTool;
}

+(instancetype)sharedDatabaseTool {
    return [[self alloc]init];
}

-(NSDate* )getCurrentDate {
    //获取系统时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //获取系统时区 **此时不设置时区是默认为系统时区
    formatter.timeZone = [NSTimeZone systemTimeZone];
    //指定时间显示样式: HH表示24小时制 hh表示12小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //只显示时间
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
    //只显示日期
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSDate* date = [formatter dateFromString:dateStr];
    
    return date;
}


//获取数据库文件路径
-(NSString *)getDatabasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [paths objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:databaseName];
    return dbPath;
}

#define DatabaseId @"dbid"


//书架 表
#define Book_table_name @"bookShelf"
#define Book_book_time @"bookShelfTime"

//创建
-(BOOL )createBookShelfTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer, %@ text, %@ text, %@ integer, %@ text, %@ text, %@ text, %@ integer, %@ text, %@ integer, %@ integer, %@ datetime)", Book_table_name, DatabaseId, Book_book_id, Book_name, Book_book_type, Book_book_length, Book_author, Book_key_word, Book_abstract, Book_clicked, Book_pic, Book_book_state, UserBook_is_top, Book_book_time];
        NSLog(@"%s, sql = %@", __FUNCTION__, sql);
        res = [db executeUpdate:sql];
    }
    
    [db close];
    
    return res;
}

//删除
-(BOOL )deleteBookShelfTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"drop table %@", Book_table_name];
        res = [db executeUpdate:sql];
    }
    [db close];
    return res;
}

//保存书
-(BOOL)saveBooksWithArray:(NSArray *)booksArr {
    NSDate* currentDate = [self getCurrentDate];
    
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSInteger currentIndex = 0;
        for (NSInteger i = 0; i < booksArr.count; i ++) {
            Book* book = [booksArr objectAtIndex:i];
            
            Chapter* lastChapter = book.lastChapter;
            
            Source* source = lastChapter.source;
            BOOL sourceResult = [self insertSourceData:source db:db date:currentDate];
            
            NSArray* typeArr = book.bookType;
            NSString* typeStr = [typeArr componentsJoinedByString:@","];
            
            NSArray* keyWordArr = book.keyWord;
            NSString* keyWordStr = [keyWordArr componentsJoinedByString:@","];
            
            NSNumber* bookIdNumber = [NSNumber numberWithUnsignedInt:book.bookId];
            NSNumber* lengthNumber = [NSNumber numberWithUnsignedInt:book.bookLength];
            NSNumber* clickedNumber = [NSNumber numberWithUnsignedInt:book.clicked];
            NSNumber* stateNumber = [NSNumber numberWithInt:book.bookState];
            
            NSString* bookSql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", Book_table_name, Book_book_id, Book_name, Book_book_type, Book_book_length, Book_author, Book_key_word, Book_abstract, Book_clicked, Book_pic, Book_book_state, UserBook_is_top, Book_book_time];
            res = [db executeUpdate:bookSql, bookIdNumber, book.name, typeStr, lengthNumber, book.author, keyWordStr, book.abstract, clickedNumber, book.pic, stateNumber, @0, currentDate];
            
            BOOL lastChapterResult = [self insertLastChapterData:lastChapter db:db date:currentDate];
            
            if (res == YES) {
                currentIndex ++;
            }
        }
        if (currentIndex == booksArr.count) {
            res = YES;
        }else {
            res = NO;
        }
    }
    [db close];
    return NO;
}





//卷 表
#define Source_table_name @"source"
#define Source_time @"sourceTime"

//创建
-(BOOL )createSourceTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer, %@ text, %@ text, %@ integer, %@ integer, %@ datetime)", Source_table_name, DatabaseId, Source_id, Source_table_name, Source_url, Source_source_state, Source_copyright_state, Source_time];
        NSLog(@"%s, sql = %@", __FUNCTION__, sql);
        res = [db executeUpdate:sql];
    }
    
    [db close];
    
    return res;
}

//删除
-(BOOL )deleteSourceTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"drop table %@", Source_table_name];
        res = [db executeUpdate:sql];
    }
    [db close];
    return res;
}

//添加数据
-(BOOL )insertSourceData:(Source* )source db:(FMDatabase* )db date:(NSDate* )date {
    NSNumber* idNumber = [NSNumber numberWithUnsignedInt:source.id];
    NSNumber* sourceStateNumber = [NSNumber numberWithInt:source.sourceState];
    NSNumber* copyrightNumber = [NSNumber numberWithInt:source.copyrightState];
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?);", Source_table_name, Source_id, Source_table_name, Source_url, Source_source_state, Source_copyright_state, Source_time];
    
    return [db executeUpdate:sql, idNumber, source.name, source.url, sourceStateNumber, copyrightNumber, date];
}




//最新章节 表
#define Chapter_table_name @"bookLastChapter"
#define Chapter_foreign_BookId @"lastChapterForeignBookId"
#define Chapter_bookNo_no @"lastChapterBookNono"
#define Chapter_bookNo_name @"lastChapterBookNoname"
#define Chapter_foreign_SourceId @"lastChapterForeignSourceId"
#define Chapter_time @"lastChapterTime"

//创建
-(BOOL )createLastChapterTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer references %@(%@), %@ integer, %@ text, %@ text, %@ text, %@ text, %@ integer references %@(%@), %@ integer, %@ datetime)", Chapter_table_name, DatabaseId, Chapter_foreign_BookId, Book_table_name, Book_book_id, Chapter_bookNo_no, Chapter_bookNo_name, Chapter_chapter_no, Chapter_chapter_title, Chapter_chapter_content, Chapter_foreign_SourceId, Source_table_name, Source_id, Chapter_updated_at, Chapter_time];
        NSLog(@"%s, sql = %@", __FUNCTION__, sql);
        res = [db executeUpdate:sql];
    }
    
    [db close];
    
    return res;
}

//删除
-(BOOL )deleteLastChapterTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"drop table %@", Chapter_table_name];
        res = [db executeUpdate:sql];
    }
    [db close];
    return res;
}

//添加数据
-(BOOL )insertLastChapterData:(Chapter* )chapter db:(FMDatabase* )db date:(NSDate* )date {
    NSNumber* bookIdNumber = [NSNumber numberWithUnsignedInt:chapter.book.bookId];
    NSNumber* bookNoNoNumber = [NSNumber numberWithUnsignedInt:chapter.bookNo.no];
    NSNumber* sourceIdNumber = [NSNumber numberWithUnsignedInt:chapter.source.id];
    
    NSString* sourceSql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?, ?, ?, ?);", Chapter_table_name, Chapter_foreign_BookId, Chapter_bookNo_no, Chapter_bookNo_name, Chapter_chapter_no, Chapter_chapter_title, Chapter_chapter_content, Chapter_foreign_SourceId, Chapter_updated_at, Chapter_time];
    return [db executeUpdate:sourceSql, bookIdNumber, bookNoNoNumber, chapter.bookNo.name, chapter.chapterNo, chapter.chapterTitle, chapter.chapterContent, sourceIdNumber, chapter.updatedAt, date];
}


@end
