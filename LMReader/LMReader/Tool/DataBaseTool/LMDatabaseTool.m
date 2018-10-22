//
//  LMDatabaseTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/8.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMDatabaseTool.h"
#import "FMDB.h"
#import "LMTool.h"
#import "LMBookShelfModel.h"

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

//首次启动时创建数据表
-(void)createAllFirstLaunchTable {
    [self createBookShelfTable];
    [self createSourceTable];
    [self createLastChapterTable];
    
    //新增更新章节列表
    [self createBookNewestChapterTable];
    
    //阅读记录
    [self createReadRecordTable];
}

//删除首次启动时创建的数据表
-(void)deleteAllFirstLaunchTable {
    [self deleteLastChapterTable];
    [self deleteSourceTable];
    [self deleteBookShelfTable];
    
    //
    [self deleteBookNewestChapterTable];
    
    //阅读记录
    [self deleteReadRecordTable];
}

//获取当前时间date
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

//获取xx天前时间date
-(NSDate* )getDateOverDays:(NSInteger )dayInt {
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:(0 - dayInt)];
    NSDate *date30DaysAgo = [calendar dateByAddingComponents:dateComps toDate:currentDate options:0];
    return date30DaysAgo;
}


//获取数据库文件路径
-(NSString *)getDatabasePath {
    NSString* userFilePath = [LMTool getUserFilePath];//用户文件夹目录
    NSString *dbPath = [userFilePath stringByAppendingPathComponent:databaseName];
    return dbPath;
}

#define DatabaseId @"dbid"




//章节有更新列表
#define Book_newest_table @"bookNewestTable"
#define Book_newest_id @"bookNewestId"
#define Book_newest_title @"bookNewestTitle"
#define Book_newest_source @"bookNewestSource"
#define Book_newest_state @"bookNewestState"
#define Book_newest_time @"bookNewestTime"

//创建
-(BOOL )createBookNewestChapterTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer not null unique, %@ text, %@ text, %@ integer, %@ datetime)", Book_newest_table, DatabaseId, Book_newest_id, Book_newest_title, Book_newest_source, Book_newest_state, Book_newest_time];
        NSLog(@"%s, sql = %@", __FUNCTION__, sql);
        res = [db executeUpdate:sql];
    }
    
    [db close];
    
    return res;
}

//删除
-(BOOL )deleteBookNewestChapterTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"drop table %@", Book_newest_table];
        res = [db executeUpdate:sql];
    }
    [db close];
    return res;
}

//保存更新章节
-(BOOL )saveBookNewestChapter:(NewestChapter* )newestChapter bookId:(UInt32 )bookId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* newestSourceState = @1;
        NSString* newestChapterTitle = newestChapter.newestChapterTitle;//最新章节 title
        NSString* newestChapterSource = @"";//最新章节 sourceId用逗号链接拼成数组
        NSArray* newestSourceArr = newestChapter.sources;
        if (newestSourceArr != nil && newestSourceArr.count > 0) {
            for (NSInteger j = 0; j < newestSourceArr.count; j ++) {
                Source* newestSource = [newestSourceArr objectAtIndex:j];
                
                if (j == 0) {
                    newestChapterSource = [NSString stringWithFormat:@"%d", newestSource.id];
                }
                newestChapterSource = [newestChapterSource stringByAppendingString:[NSString stringWithFormat:@",%d", newestSource.id]];
            }
        }
        
        NSDate* currentDate = [self getCurrentDate];
        NSNumber* bookIdNumber = [NSNumber numberWithUnsignedInt:bookId];
        NSString* bookSql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@) values (?, ?, ?, ?, ?);", Book_newest_table, Book_newest_id, Book_newest_title, Book_newest_source, Book_newest_state, Book_newest_time];
        res = [db executeUpdate:bookSql, bookIdNumber, newestChapterTitle, newestChapterSource, newestSourceState, currentDate];
    }
    return res;
}

//取更新章节
-(LMBookNewestChapterModel* )queryBookNewestChapter:(UInt32 )bookId {
    LMBookNewestChapterModel* newestModel = [[LMBookNewestChapterModel alloc]init];
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookIdNumber = [NSNumber numberWithUnsignedInt:bookId];
        NSString* bookShelfSql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", Book_newest_table, Book_newest_id];
        FMResultSet* rs = [db executeQuery:bookShelfSql, bookIdNumber];
        while ([rs next]) {
            NSString* newestChapterTitle = [rs stringForColumn:Book_newest_title];
            NSString* newestChapterSource = [rs stringForColumn:Book_newest_source];
            int newestSourceState = [rs intForColumn:Book_newest_state];
            NSMutableArray<Source* >* newestChapterSourceArr = [NSMutableArray array];
            if (newestChapterSource != nil && ![newestChapterSource isKindOfClass:[NSNull class]] && newestChapterSource.length > 0) {
                NSArray* newestSourceIdArr = [newestChapterSource componentsSeparatedByString:@","];
                for (NSInteger j = 0; j < newestSourceIdArr.count; j ++) {
                    NSInteger newestSourceId = [[newestSourceIdArr objectAtIndex:j] integerValue];
                    //newestChapter sourceArr
                    
                    SourceBuilder* sourceBuilder = [Source builder];
                    [sourceBuilder setId:(UInt32 )newestSourceId];
                    Source* source = [sourceBuilder build];
                    
                    [newestChapterSourceArr addObject:source];
                }
            }
            
            NewestChapterBuilder* newestChapterBuilder = [NewestChapter builder];
            [newestChapterBuilder setNewestChapterTitle:newestChapterTitle];
            [newestChapterBuilder setSourcesArray:newestChapterSourceArr];
            NewestChapter* newestChapter = [newestChapterBuilder build];
            
            newestModel.newestChapter = newestChapter;
            newestModel.readState = newestSourceState;
            
            break;
        }
    }
    return newestModel;
}

//设置最新章节更新为已读
-(BOOL )clearNewestMarkWithBookId:(NSInteger )bookId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookIdNumber = [NSNumber numberWithInteger:bookId];
        NSString* sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?", Book_newest_table, Book_newest_state, Book_newest_id];
        res = [db executeUpdate:sql, @0, bookIdNumber];
    }
    [db close];
    return res;
}

//删除更新章节
-(BOOL )deleteBookNewestChapterWithBookId:(UInt32 )bookId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookIdNumber = [NSNumber numberWithInt:bookId];
        
        NSString* newestChapterSql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", Book_newest_table, Book_newest_id];
        res = [db executeUpdate:newestChapterSql, bookIdNumber];
    }
    [db close];
    return res;
}

//取书本是否有未读更新章节
-(NSInteger )queryNewestMarkWithBookId:(NSInteger )bookId {
    NSInteger queryResult = 0;
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookIdNumber = [NSNumber numberWithInteger:bookId];
        NSString* bookShelfSql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", Book_newest_table, Book_newest_id];
        FMResultSet* rs = [db executeQuery:bookShelfSql, bookIdNumber];
        while ([rs next]) {
            queryResult = [rs intForColumn:Book_newest_state];
            break;
        }
    }
    [db close];
    return queryResult;
}

//取书本未读更新章节
-(NewestChapter* )queryNewestChapterWithBookId:(NSInteger )bookId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookIdNumber = [NSNumber numberWithInteger:bookId];
        NSString* bookShelfSql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", Book_newest_table, Book_newest_id];
        FMResultSet* rs = [db executeQuery:bookShelfSql, bookIdNumber];
        while ([rs next]) {
            NSString* newestChapterTitle = [rs stringForColumn:Book_newest_title];
            NSString* newestChapterSource = [rs stringForColumn:Book_newest_source];
            NSMutableArray<Source* >* newestChapterSourceArr = [NSMutableArray array];
            if (newestChapterSource != nil && ![newestChapterSource isKindOfClass:[NSNull class]] && newestChapterSource.length > 0) {
                NSArray* newestSourceIdArr = [newestChapterSource componentsSeparatedByString:@","];
                for (NSInteger j = 0; j < newestSourceIdArr.count; j ++) {
                    NSInteger newestSourceId = [[newestSourceIdArr objectAtIndex:j] integerValue];
                    //newestChapter sourceArr
                    
                    SourceBuilder* sourceBuilder = [Source builder];
                    [sourceBuilder setId:(UInt32 )newestSourceId];
                    Source* source = [sourceBuilder build];
                    
                    [newestChapterSourceArr addObject:source];
                }
            }
            
            NewestChapterBuilder* newestChapterBuilder = [NewestChapter builder];
            [newestChapterBuilder setNewestChapterTitle:newestChapterTitle];
            [newestChapterBuilder setSourcesArray:newestChapterSourceArr];
            NewestChapter* newestChapter = [newestChapterBuilder build];
            
            [db close];
            
            return newestChapter;
        }
    }
    [db close];
    return nil;
}





//阅读记录 表
#define Read_table_name @"ReadRecord"
#define Read_book_id @"ReadBookId"
#define Read_book_name @"ReadBookName"
#define Read_chapter_id @"ReadChapterId"
#define Read_chapter_no @"ReadChapterNo"
#define Read_chapter_title @"ReadChapterTitle"
#define Read_source_id @"ReadSourceId"
#define Read_currentOffset @"ReadOffset"
#define Read_time @"ReadTime"

//创建
-(BOOL )createReadRecordTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer not null unique, %@ text, %@ integer, %@ integer, %@ text, %@ integer, %@ integer, %@ datetime)", Read_table_name, DatabaseId, Read_book_id, Read_book_name, Read_chapter_id, Read_chapter_no, Read_chapter_title, Read_source_id, Read_currentOffset, Read_time];
        NSLog(@"%s, sql = %@", __FUNCTION__, sql);
        res = [db executeUpdate:sql];
    }
    
    [db close];
    
    return res;
}

//删除
-(BOOL )deleteReadRecordTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"drop table %@", Read_table_name];
        res = [db executeUpdate:sql];
    }
    [db close];
    return res;
}

//保存一条阅读记录
-(BOOL)saveBookReadRecordWithBookId:(UInt32 )bookId bookName:(NSString* )bookName chapterId:(UInt32 )chapterId chapterNo:(UInt32 )chapterNo chapterTitle:(NSString* )chapterTitle sourceId:(UInt32 )sourceId offset:(NSInteger )offset {
    NSDate* currentDate = [self getCurrentDate];
    
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookNumber = [NSNumber numberWithUnsignedInt:bookId];
        NSNumber* chapterIdNumber = [NSNumber numberWithUnsignedInt:chapterId];
        NSNumber* chapterNoNumber = [NSNumber numberWithUnsignedInt:chapterNo];
        NSNumber* sourceIdNumber = [NSNumber numberWithUnsignedInt:sourceId];
        NSNumber* offsetNumber = [NSNumber numberWithInteger:offset];
        
        NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?, ?, ?);", Read_table_name, Read_book_id, Read_book_name, Read_chapter_id, Read_chapter_no, Read_chapter_title, Read_source_id, Read_currentOffset, Read_time];
        
        res = [db executeUpdate:sql, bookNumber, bookName, chapterIdNumber, chapterNoNumber, chapterTitle, sourceIdNumber, offsetNumber, currentDate];
    }
    [db close];
    return res;
}

//删除一条阅读记录
-(BOOL)deleteBookReadRecordWithBookId:(UInt32 )bookId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookNumber = [NSNumber numberWithUnsignedInt:bookId];
        
        NSString* sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?;", Read_table_name, Read_book_id];
        
        return [db executeUpdate:sql, bookNumber];
    }
    [db close];
    return res;
}

//删除过时的阅读记录
-(BOOL )deleteBookReadRecordOver30Days {
    NSDate* daysOver30 = [self getDateOverDays:30];
    
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"delete from %@ where %@ < ?;", Read_table_name, Read_time];
        
        return [db executeUpdate:sql, daysOver30];
    }
    [db close];
    return res;
}

//取过时的阅读记录
-(NSArray* )queryBookReadRecordOver30Days {
    NSDate* daysOver30 = [self getDateOverDays:30];
    
    NSMutableArray* arr = [NSMutableArray array];
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"select * from %@ where %@ < ? order by %@ desc;", Read_table_name, Read_time, Read_time];
        FMResultSet* rs = [db executeQuery:sql, daysOver30];
        while ([rs next]) {
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            
            UInt32 bookId = [rs intForColumn:Read_book_id];
            NSNumber* bookIdNum = [NSNumber numberWithInt:bookId];
            [dic setObject:bookIdNum forKey:@"bookId"];
            
            NSString* name = [rs stringForColumn:Read_book_name];
            if (name == nil || [name isKindOfClass:[NSNull class]]) {
                name = @"";
            }
            [dic setObject:name forKey:@"name"];
            
            UInt32 chapterId = [rs intForColumn:Read_chapter_id];
            NSNumber* chapterIdNum = [NSNumber numberWithInt:chapterId];
            [dic setObject:chapterIdNum forKey:@"chapterId"];
            
            UInt32 chapterNo = [rs intForColumn:Read_chapter_no];
            NSNumber* chapterNoNum = [NSNumber numberWithInt:chapterNo];
            [dic setObject:chapterNoNum forKey:@"chapterNo"];
            
            NSString* chapterTitle = [rs stringForColumn:Read_chapter_title];
            if (chapterTitle == nil || [chapterTitle isKindOfClass:[NSNull class]]) {
                chapterTitle = @"";
            }
            [dic setObject:chapterTitle forKey:@"chapterTitle"];
            
            UInt32 sourceId = [rs intForColumn:Read_source_id];
            NSNumber* sourceIdNum = [NSNumber numberWithInt:sourceId];
            [dic setObject:sourceIdNum forKey:@"sourceId"];
            
            UInt32 offset = [rs intForColumn:Read_currentOffset];
            NSNumber* offsetNum = [NSNumber numberWithInt:offset];
            [dic setObject:offsetNum forKey:@"offset"];
            
            NSDate* date = [rs dateForColumn:Read_time];
            [dic setObject:date forKey:@"date"];
            
            [arr addObject:dic];
        }
    }
    [db close];
    
    return arr;
}

//根据bookId取阅读记录
-(void)queryBookReadRecordWithBookId:(UInt32 )bookId recordBlock:(void (^) (BOOL hasRecord, UInt32 chapterId, UInt32 sourceId, NSInteger offset))block {
    UInt32 chapterId = 0;
    UInt32 sourceId = 0;
    NSInteger offset = 0;
    BOOL hasRecord = NO;
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookNumber = [NSNumber numberWithUnsignedInt:bookId];
        
        NSString* sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc;", Read_table_name, Read_book_id, Read_time];
        FMResultSet* rs = [db executeQuery:sql, bookNumber];
        while ([rs next]) {
            hasRecord = YES;
            chapterId = [rs intForColumn:Read_chapter_id];
            sourceId = [rs intForColumn:Read_source_id];
            offset = [rs longLongIntForColumn:Read_currentOffset];
            break;
        }
    }
    [db close];
    
    block(hasRecord, chapterId, sourceId, offset);
}

//根据bookId取阅读进度 标题
-(NSString* )queryBookReadRecordProgressWithBookId:(UInt32 )bookId {
    BOOL hasRecord = NO;
    NSString* resultStr = nil;
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookNumber = [NSNumber numberWithUnsignedInt:bookId];
        
        NSString* sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc;", Read_table_name, Read_book_id, Read_time];
        FMResultSet* rs = [db executeQuery:sql, bookNumber];
        while ([rs next]) {
            hasRecord = YES;
            resultStr = [rs stringForColumn:Read_chapter_title];
            break;
        }
    }
    [db close];
    
    if (hasRecord) {
        return resultStr;
    }else {
        return nil;
    }
}

//按照page、size取阅读记录
-(NSArray* )queryBookReadRecordWithPage:(NSInteger )page size:(NSInteger )size {
    NSDate* dayOver30 = [self getDateOverDays:30];
    
    NSInteger overInt = page * size;
    NSMutableArray* arr = [NSMutableArray array];
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"select * from %@ where %@ > ? order by %@ desc limit %ld,%ld;", Read_table_name, Read_time, Read_time, overInt, size];
        FMResultSet* rs = [db executeQuery:sql, dayOver30];
        while ([rs next]) {
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            
            UInt32 bookId = [rs intForColumn:Read_book_id];
            NSNumber* bookIdNum = [NSNumber numberWithInt:bookId];
            [dic setObject:bookIdNum forKey:@"bookId"];
            
            NSString* name = [rs stringForColumn:Read_book_name];
            if (name == nil || [name isKindOfClass:[NSNull class]]) {
                name = @"";
            }
            [dic setObject:name forKey:@"name"];
            
            UInt32 chapterId = [rs intForColumn:Read_chapter_id];
            NSNumber* chapterIdNum = [NSNumber numberWithInt:chapterId];
            [dic setObject:chapterIdNum forKey:@"chapterId"];
            
            UInt32 chapterNo = [rs intForColumn:Read_chapter_no];
            NSNumber* chapterNoNum = [NSNumber numberWithInt:chapterNo];
            [dic setObject:chapterNoNum forKey:@"chapterNo"];
            
            NSString* chapterTitle = [rs stringForColumn:Read_chapter_title];
            if (chapterTitle == nil || [chapterTitle isKindOfClass:[NSNull class]]) {
                chapterTitle = @"";
            }
            [dic setObject:chapterTitle forKey:@"chapterTitle"];
            
            UInt32 sourceId = [rs intForColumn:Read_source_id];
            NSNumber* sourceIdNum = [NSNumber numberWithInt:sourceId];
            [dic setObject:sourceIdNum forKey:@"sourceId"];
            
            UInt32 offset = [rs intForColumn:Read_currentOffset];
            NSNumber* offsetNum = [NSNumber numberWithInt:offset];
            [dic setObject:offsetNum forKey:@"offset"];
            
            NSDate* date = [rs dateForColumn:Read_time];
            [dic setObject:date forKey:@"date"];
            
            [arr addObject:dic];
        }
    }
    [db close];
    
    return arr;
}

//取出所有阅读记录
-(NSArray* )queryAllBookReadRecord {
    NSMutableArray* arr = [NSMutableArray array];
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"select * from %@ order by %@ desc;", Read_table_name, Read_time];
        FMResultSet* rs = [db executeQuery:sql];
        while ([rs next]) {
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            
            UInt32 bookId = [rs intForColumn:Read_book_id];
            NSNumber* bookIdNum = [NSNumber numberWithInt:bookId];
            [dic setObject:bookIdNum forKey:@"bookId"];
            
            NSString* name = [rs stringForColumn:Read_book_name];
            if (name == nil || [name isKindOfClass:[NSNull class]]) {
                name = @"";
            }
            [dic setObject:name forKey:@"name"];
            
            UInt32 chapterId = [rs intForColumn:Read_chapter_id];
            NSNumber* chapterIdNum = [NSNumber numberWithInt:chapterId];
            [dic setObject:chapterIdNum forKey:@"chapterId"];
            
            UInt32 chapterNo = [rs intForColumn:Read_chapter_no];
            NSNumber* chapterNoNum = [NSNumber numberWithInt:chapterNo];
            [dic setObject:chapterNoNum forKey:@"chapterNo"];
            
            NSString* chapterTitle = [rs stringForColumn:Read_chapter_title];
            if (chapterTitle == nil || [chapterTitle isKindOfClass:[NSNull class]]) {
                chapterTitle = @"";
            }
            [dic setObject:chapterTitle forKey:@"chapterTitle"];
            
            UInt32 sourceId = [rs intForColumn:Read_source_id];
            NSNumber* sourceIdNum = [NSNumber numberWithInt:sourceId];
            [dic setObject:sourceIdNum forKey:@"sourceId"];
            
            UInt32 offset = [rs intForColumn:Read_currentOffset];
            NSNumber* offsetNum = [NSNumber numberWithInt:offset];
            [dic setObject:offsetNum forKey:@"offset"];
            
            NSDate* date = [rs dateForColumn:Read_time];
            [dic setObject:date forKey:@"date"];
            
            [arr addObject:dic];
        }
    }
    [db close];
    
    return arr;
}








//书架 表
#define Book_table_name @"bookShelf"
#define Book_book_time @"bookShelfTime"

//创建
-(BOOL )createBookShelfTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer not null unique, %@ text, %@ text, %@ integer, %@ text, %@ text, %@ text, %@ integer, %@ text, %@ integer, %@ integer, %@ datetime)", Book_table_name, DatabaseId, Book_book_id, Book_name, Book_book_type, Book_book_length, Book_author, Book_key_word, Book_abstract, Book_clicked, Book_pic, Book_book_state, UserBook_is_top, Book_book_time];
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






//卷 表
#define Source_table_name @"source"
#define Source_time @"sourceTime"

//创建
-(BOOL )createSourceTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer, %@ text, %@ text, %@ integer, %@ integer, %@ datetime)", Source_table_name, DatabaseId, Source_id, Source_name, Source_url, Source_source_state, Source_copyright_state, Source_time];
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
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?);", Source_table_name, Source_id, Source_name, Source_url, Source_source_state, Source_copyright_state, Source_time];
    
    return [db executeUpdate:sql, idNumber, source.name, source.url, sourceStateNumber, copyrightNumber, date];
}




//最新章节 表
#define Chapter_table_name @"bookLastChapter"
#define Chapter_foreign_BookId @"lastChapterForeignBookId"
#define Chapter_bookNo_no @"lastChapterBookNono"
#define Chapter_bookNo_name @"lastChapterBookNoname"
#define Chapter_foreign_SourceId @"lastChapterForeignSourceId"
#define Chapter_time @"lastChapterTime"
#define Chapter_chapter_id @"lastChapterId"

//创建
-(BOOL )createLastChapterTable {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* sql = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer not null primary key autoincrement, %@ integer references %@(%@), %@ integer, %@ text, %@ integer, %@ text, %@ text, %@ integer references %@(%@), %@ integer, %@ integer, %@ datetime)", Chapter_table_name, DatabaseId, Chapter_foreign_BookId, Book_table_name, Book_book_id, Chapter_bookNo_no, Chapter_bookNo_name, Chapter_chapter_no, Chapter_chapter_title, Chapter_chapter_content, Chapter_foreign_SourceId, Source_table_name, Source_id, Chapter_updated_at, Chapter_chapter_id, Chapter_time];
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
-(BOOL )insertLastChapterData:(Chapter* )chapter bookIdNumber:(NSNumber* )bookIdNumber sourceIdNumber:(NSNumber* )sourceIdNumber db:(FMDatabase* )db date:(NSDate* )date {
//    NSNumber* bookIdNumber = [NSNumber numberWithUnsignedInt:chapter.book.bookId];
    NSNumber* bookNoNoNumber = [NSNumber numberWithUnsignedInt:chapter.bookNo.no];
//    NSNumber* sourceIdNumber = [NSNumber numberWithUnsignedInt:chapter.source.id];
    NSNumber* chapterNoNumber = [NSNumber numberWithInt:chapter.chapterNo];
    NSNumber* chapterUpdateAtNumber = [NSNumber numberWithLongLong:chapter.updatedAt];
    NSNumber* chapterIdNumber = [NSNumber numberWithInt:chapter.id];
    
    NSString* chapterSql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", Chapter_table_name, Chapter_foreign_BookId, Chapter_bookNo_no, Chapter_bookNo_name, Chapter_chapter_no, Chapter_chapter_title, Chapter_chapter_content, Chapter_foreign_SourceId, Chapter_updated_at, Chapter_chapter_id, Chapter_time];
    return [db executeUpdate:chapterSql, bookIdNumber, bookNoNoNumber, chapter.bookNo.name, chapterNoNumber, chapter.chapterTitle, chapter.chapterContent, sourceIdNumber, chapterUpdateAtNumber, chapterIdNumber, date];
}









//保存书
-(BOOL)saveUserBooksWithArray:(NSArray *)booksArr {
    NSDate* currentDate = [self getCurrentDate];
    
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSInteger currentIndex = 0;
        for (NSInteger i = 0; i < booksArr.count; i ++) {
            UserBook* userBook = [booksArr objectAtIndex:i];
            Book* book = userBook.book;
            
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
            NSNumber* topNumber = [NSNumber numberWithInt:userBook.isTop];
            
            NSString* bookSql = [NSString stringWithFormat:@"insert or replace into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", Book_table_name, Book_book_id, Book_name, Book_book_type, Book_book_length, Book_author, Book_key_word, Book_abstract, Book_clicked, Book_pic, Book_book_state, UserBook_is_top, Book_book_time];
            res = [db executeUpdate:bookSql, bookIdNumber, book.name, typeStr, lengthNumber, book.author, keyWordStr, book.abstract, clickedNumber, book.pic, stateNumber, topNumber, currentDate];
            
            NSNumber* sourceIdNumber = [NSNumber numberWithUnsignedInt:source.id];
            BOOL lastChapterResult = [self insertLastChapterData:lastChapter bookIdNumber:bookIdNumber sourceIdNumber:sourceIdNumber db:db date:currentDate];
            
            if ([userBook hasNewestChapter]) {
                [self saveBookNewestChapter:userBook.newestChapter bookId:book.bookId];
            }
            
            if (sourceResult && res && lastChapterResult) {
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

//判断 书架页面 某本书是否已存在
-(BOOL )checkUserBooksIsExistWithBookId:(UInt32 )bookId {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        res = NO;
        NSNumber* bookIdNum = [NSNumber numberWithInt:bookId];
        NSString* bookShelfSql = [NSString stringWithFormat:@"select * from %@ where %@ = ?", Book_table_name, Book_book_id];
        FMResultSet* rs = [db executeQuery:bookShelfSql, bookIdNum];
        while ([rs next]) {
            res = YES;
            break;
        }
    }
    [db close];
    return res;
}

//删除 书架页面 书
-(BOOL )deleteUserBookWithBook:(Book* )book {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        Chapter* lastChapter = book.lastChapter;
        Source* source = lastChapter.source;
        
        NSNumber* bookIdNumber = [NSNumber numberWithInt:book.bookId];
        NSNumber* sourceIdNumber = [NSNumber numberWithInt:source.id];
        
        NSString* sourceSql = [NSString stringWithFormat:@"delete from %@ where %@ = ? and %@ = ? and %@ = ?", Source_table_name, Source_id, Source_name, Source_url];
        BOOL sourceResult = [db executeUpdate:sourceSql, sourceIdNumber, source.name, source.url];
        
        NSString* chapterSql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", Chapter_table_name, Chapter_foreign_BookId];
        BOOL chapterResult = [db executeUpdate:chapterSql, bookIdNumber];
        
        NSString* sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", Book_table_name, Book_book_id];
        res = [db executeUpdate:sql, bookIdNumber];
        
        NSString* newestChapterSql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", Book_newest_table, Book_newest_id];
        res = [db executeUpdate:newestChapterSql, bookIdNumber];
        
        if (sourceResult && chapterResult && res) {
            res = YES;
        }
    }
    [db close];
    return res;
}

//删除本地有，服务端无的书籍
-(BOOL)deleteLocalSurplusBooksWithArray:(NSArray *)booksArr {
    if (booksArr == nil || booksArr.count == 0) {
        return YES;
    }
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* bookIdStr = @"";
        for (NSInteger i = 0; i < booksArr.count; i ++) {
            UserBook* userBook = [booksArr objectAtIndex:i];
            Book* book = userBook.book;
            NSNumber* bookIdNumber = [NSNumber numberWithUnsignedInt:book.bookId];
            if (i == 0) {
                bookIdStr = [NSString stringWithFormat:@"%@", bookIdNumber];
            }else {
                bookIdStr = [NSString stringWithFormat:@"%@,%@", bookIdStr, bookIdNumber];
            }
        }
        bookIdStr = [NSString stringWithFormat:@"(%@)", bookIdStr];
        NSString* bookSql = [NSString stringWithFormat:@"select * from %@ where %@ not in %@;", Book_table_name, Book_book_id, bookIdStr];
        FMResultSet* rs = [db executeQuery:bookSql];
        while ([rs next]) {
            int bookId = [rs intForColumn:Book_book_id];
            NSNumber* bookIdNumber = [NSNumber numberWithUnsignedInt:bookId];
            NSString* sql = [NSString stringWithFormat:@"delete from %@ where %@ = ?", Book_table_name, Book_book_id];
            res = [db executeUpdate:sql, bookIdNumber];
        }
    }
    [db close];
    return NO;
}

//取所有 书
-(NSMutableArray* )queryAllUserBooks {
    NSMutableArray * arr = [NSMutableArray array];
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSString* bookShelfSql = [NSString stringWithFormat:@"select * from %@ order by %@ desc, %@ desc", Book_table_name, UserBook_is_top, Book_book_time];
        FMResultSet* rs = [db executeQuery:bookShelfSql];
        while ([rs next]) {
            BookBuilder* bookBuilder = [Book builder];
            int bookId = [rs intForColumn:Book_book_id];
            [bookBuilder setBookId:bookId];
            [bookBuilder setName:[rs stringForColumn:Book_name]];
            NSString* typeStr = [rs stringForColumn:Book_book_type];
            NSArray* typeArr = nil;
            if (typeStr != nil && ![typeStr isKindOfClass:[NSNull class]] && typeStr.length > 0) {
                typeArr = [typeStr componentsSeparatedByString:@","];
            }
            [bookBuilder setBookTypeArray:typeArr];
            [bookBuilder setBookLength:[rs intForColumn:Book_book_length]];
            [bookBuilder setAuthor:[rs stringForColumn:Book_author]];
            NSString* keyWordStr = [rs stringForColumn:Book_key_word];
            NSArray* keyWordArr = nil;
            if (keyWordStr != nil && ![keyWordStr isKindOfClass:[NSNull class]] && keyWordStr.length > 0) {
                keyWordArr = [keyWordStr componentsSeparatedByString:@","];
            }
            [bookBuilder setKeyWordArray:keyWordArr];
            [bookBuilder setAbstract:[rs stringForColumn:Book_abstract]];
            [bookBuilder setClicked:[rs intForColumn:Book_clicked]];
            BookState bookState = BookStateStateUnknown;
            int bookStateInt = [rs intForColumn:Book_book_state];
            if (bookStateInt == 1) {
                bookState = BookStateStateWriting;
            }else if (bookStateInt == 2) {
                bookState = BookStateStateFinished;
            }else if (bookStateInt == 3) {
                bookState = BookStateStatePause;
            }
            [bookBuilder setBookState:bookState];
            
            //lastChapter
            ChapterBuilder* chapterBuilder = [Chapter builder];
            NSString* chapterSql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc", Chapter_table_name, Chapter_foreign_BookId, Chapter_time];
            FMResultSet* chapterRS = [db executeQuery:chapterSql, [NSNumber numberWithInt:bookId]];
            while ([chapterRS next]) {
                int sourceId = [chapterRS intForColumn:Chapter_foreign_SourceId];
                
                int bookNono = [chapterRS intForColumn:Chapter_bookNo_no];
                NSString* bookNoname = [chapterRS stringForColumn:Chapter_bookNo_name];
                BookNoBuilder* bookNoBuilder = [BookNo builder];
                [bookNoBuilder setNo:bookNono];
                [bookNoBuilder setName:bookNoname];
                BookNo* bookNo = [bookNoBuilder build];
                
                [chapterBuilder setBookNo:bookNo];
                [chapterBuilder setChapterNo:[chapterRS intForColumn:Chapter_chapter_no]];
                [chapterBuilder setChapterTitle:[chapterRS stringForColumn:Chapter_chapter_title]];
                [chapterBuilder setChapterContent:[chapterRS stringForColumn:Chapter_chapter_content]];
                [chapterBuilder setUpdatedAt:[chapterRS unsignedLongLongIntForColumn:Chapter_updated_at]];
                [chapterBuilder setId:[chapterRS intForColumn:Chapter_chapter_id]];
                
                //source
                NSString* sourceSql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc", Source_table_name, Source_id, Source_time];
                FMResultSet* sourceRS = [db executeQuery:sourceSql, [NSNumber numberWithInt:sourceId]];
                while ([sourceRS next]) {
                    SourceBuilder* sourceBuilder = [Source builder];
                    [sourceBuilder setId:[sourceRS intForColumn:Source_id]];
                    [sourceBuilder setName:[sourceRS stringForColumn:Source_name]];
                    [sourceBuilder setUrl:[sourceRS stringForColumn:Source_url]];
                    SourceState sourceState = SourceStateSourcestateUnknown;
                    int sourceStateInt = [sourceRS intForColumn:Source_source_state];
                    if (sourceStateInt == 1) {
                        sourceState = SourceStateSourcestateWorking;
                    }else if (sourceStateInt == 2) {
                        sourceState = SourceStateSourcestateStop;
                    }else if (sourceStateInt == 2) {
                        sourceState = SourceStateSourcestatePause;
                    }
                    [sourceBuilder setSourceState:sourceState];
                    CopyrightState copyrightState = CopyrightStateCopyrightstateHave;
                    int copyrightInt = [sourceRS intForColumn:Source_copyright_state];
                    if (copyrightInt == 1) {
                        copyrightState = CopyrightStateCopyrightstateNo;
                    }
                    [sourceBuilder setCopyrightState:copyrightState];
                    Source* source = [sourceBuilder build];
                    
                    [chapterBuilder setSource:source];
                    break;
                }
                
                Chapter* lastChapter = [chapterBuilder build];
                [bookBuilder setLastChapter:lastChapter];//最新章节
                
                break;
            }
            
            Book* book = [bookBuilder build];
            
            UserBookBuilder* userBookBuilder = [UserBook builder];
            [userBookBuilder setIsTop:[rs intForColumn:UserBook_is_top]];
            [userBookBuilder setBook:book];
            UserBook* userBook = [userBookBuilder build];
            
            [arr addObject:userBook];
        }
    }
    [db close];
    return arr;
}

//取出所有 书架页面 书 page默认0，size默认20
-(NSMutableArray* )queryBookShelfUserBooksWithPage:(NSInteger )page size:(NSInteger )size {
    NSMutableArray * arr = [NSMutableArray array];
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSInteger querySize = size;
        if (size == 0) {
            querySize = 20;
        }
        NSInteger startInteger = page * querySize;
        NSNumber* startNumber = [NSNumber numberWithInteger:startInteger];
        NSNumber* totalNumber = [NSNumber numberWithInteger:size];
        NSString* bookShelfSql = [NSString stringWithFormat:@"select * from %@ order by %@ desc, %@ desc limit ? offset ?", Book_table_name, UserBook_is_top, Book_book_time];
        FMResultSet* rs;
        if (page == 0 && size == 0) {//取所有
            bookShelfSql = [NSString stringWithFormat:@"select * from %@ order by %@ desc, %@ desc", Book_table_name, UserBook_is_top, Book_book_time];
            rs = [db executeQuery:bookShelfSql];
        }else {
            rs = [db executeQuery:bookShelfSql, totalNumber, startNumber];
        }
        while ([rs next]) {
            BookBuilder* bookBuilder = [Book builder];
            int bookId = [rs intForColumn:Book_book_id];
            [bookBuilder setBookId:bookId];
            [bookBuilder setName:[rs stringForColumn:Book_name]];
            NSString* typeStr = [rs stringForColumn:Book_book_type];
            NSArray* typeArr = nil;
            if (typeStr != nil && ![typeStr isKindOfClass:[NSNull class]] && typeStr.length > 0) {
                typeArr = [typeStr componentsSeparatedByString:@","];
            }
            [bookBuilder setBookTypeArray:typeArr];
            [bookBuilder setBookLength:[rs intForColumn:Book_book_length]];
            [bookBuilder setAuthor:[rs stringForColumn:Book_author]];
            NSString* keyWordStr = [rs stringForColumn:Book_key_word];
            NSArray* keyWordArr = nil;
            if (keyWordStr != nil && ![keyWordStr isKindOfClass:[NSNull class]] && keyWordStr.length > 0) {
                keyWordArr = [keyWordStr componentsSeparatedByString:@","];
            }
            [bookBuilder setKeyWordArray:keyWordArr];
            [bookBuilder setAbstract:[rs stringForColumn:Book_abstract]];
            [bookBuilder setClicked:[rs intForColumn:Book_clicked]];
            [bookBuilder setPic:[rs stringForColumn:Book_pic]];
            BookState bookState = BookStateStateUnknown;
            int bookStateInt = [rs intForColumn:Book_book_state];
            if (bookStateInt == 1) {
                bookState = BookStateStateWriting;
            }else if (bookStateInt == 2) {
                bookState = BookStateStateFinished;
            }else if (bookStateInt == 3) {
                bookState = BookStateStatePause;
            }
            [bookBuilder setBookState:bookState];
            
            //lastChapter
            ChapterBuilder* chapterBuilder = [Chapter builder];
            NSString* chapterSql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc", Chapter_table_name, Chapter_foreign_BookId, Chapter_time];
            FMResultSet* chapterRS = [db executeQuery:chapterSql, [NSNumber numberWithInt:bookId]];
            while ([chapterRS next]) {
                int sourceId = [chapterRS intForColumn:Chapter_foreign_SourceId];
                
                int bookNono = [chapterRS intForColumn:Chapter_bookNo_no];
                NSString* bookNoname = [chapterRS stringForColumn:Chapter_bookNo_name];
                BookNoBuilder* bookNoBuilder = [BookNo builder];
                [bookNoBuilder setNo:bookNono];
                [bookNoBuilder setName:bookNoname];
                BookNo* bookNo = [bookNoBuilder build];
                
                [chapterBuilder setBookNo:bookNo];
                [chapterBuilder setChapterNo:[chapterRS intForColumn:Chapter_chapter_no]];
                [chapterBuilder setChapterTitle:[chapterRS stringForColumn:Chapter_chapter_title]];
                [chapterBuilder setChapterContent:[chapterRS stringForColumn:Chapter_chapter_content]];
                [chapterBuilder setUpdatedAt:[chapterRS unsignedLongLongIntForColumn:Chapter_updated_at]];
                [chapterBuilder setId:[chapterRS intForColumn:Chapter_chapter_id]];
                
                //source
                NSString* sourceSql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc", Source_table_name, Source_id, Source_time];
                FMResultSet* sourceRS = [db executeQuery:sourceSql, [NSNumber numberWithInt:sourceId]];
                while ([sourceRS next]) {
                    SourceBuilder* sourceBuilder = [Source builder];
                    [sourceBuilder setId:[sourceRS intForColumn:Source_id]];
                    [sourceBuilder setName:[sourceRS stringForColumn:Source_name]];
                    [sourceBuilder setUrl:[sourceRS stringForColumn:Source_url]];
                    SourceState sourceState = SourceStateSourcestateUnknown;
                    int sourceStateInt = [sourceRS intForColumn:Source_source_state];
                    if (sourceStateInt == 1) {
                        sourceState = SourceStateSourcestateWorking;
                    }else if (sourceStateInt == 2) {
                        sourceState = SourceStateSourcestateStop;
                    }else if (sourceStateInt == 2) {
                        sourceState = SourceStateSourcestatePause;
                    }
                    [sourceBuilder setSourceState:sourceState];
                    CopyrightState copyrightState = CopyrightStateCopyrightstateHave;
                    int copyrightInt = [sourceRS intForColumn:Source_copyright_state];
                    if (copyrightInt == 1) {
                        copyrightState = CopyrightStateCopyrightstateNo;
                    }
                    [sourceBuilder setCopyrightState:copyrightState];
                    Source* source = [sourceBuilder build];
                    
                    [chapterBuilder setSource:source];
                    break;
                }
                
                Chapter* lastChapter = [chapterBuilder build];
                [bookBuilder setLastChapter:lastChapter];//最新章节
                
                break;
            }
            
            LMBookNewestChapterModel* chapterModel = [self queryBookNewestChapter:bookId];
            
            Book* book = [bookBuilder build];
            
            UserBookBuilder* userBookBuilder = [UserBook builder];
            [userBookBuilder setIsTop:[rs intForColumn:UserBook_is_top]];
            [userBookBuilder setBook:book];
            if (chapterModel.newestChapter != nil) {
                [userBookBuilder setNewestChapter:chapterModel.newestChapter];
            }
            UserBook* userBook = [userBookBuilder build];
            
            LMBookShelfModel* model = [[LMBookShelfModel alloc]init];
            model.userBook = userBook;
            model.markState = chapterModel.readState;
            
            [arr addObject:model];
        }
    }
    [db close];
    return arr;
}

//置顶/取消置顶 书架页面 书
-(BOOL )setUpside:(BOOL )upside book:(Book* )book {
    NSString* dbPath = [self getDatabasePath];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    BOOL res = [db open];
    if (res == YES) {
        NSNumber* bookIdNumber = [NSNumber numberWithInt:book.bookId];
        if (upside) {//置顶
            NSString* sql = [NSString stringWithFormat:@"update %@ set %@ = %@ + 1 where %@ = ?", Book_table_name, UserBook_is_top, UserBook_is_top, Book_book_id];
            res = [db executeUpdate:sql, bookIdNumber];
        }else {//取消置顶
            NSString* sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?", Book_table_name, UserBook_is_top, Book_book_id];
            res = [db executeUpdate:sql, @0, bookIdNumber];
        }
    }
    [db close];
    return res;
}





@end


@implementation LMBookNewestChapterModel

@end
