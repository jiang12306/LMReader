//
//  LMTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMTool.h"
#import "sys/utsname.h"
#import "LMNetworkTool.h"
#import "LMDatabaseTool.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonCrypto.h>
#import "TFHpple.h"
#import <AdSupport/AdSupport.h>

@implementation LMTool

static NSString* launchCount = @"launchCount";
static NSString* currentUserId = @"currentUserId";
static NSString* bookRecord = @"bookRecord";//阅读器 缓存、下载 文件夹

//是否第一次launch
+(BOOL)isFirstLaunch {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:keyStr];
    if (count == nil) {
        return YES;
    }
    if ([count isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (count.integerValue == 0) {
        return YES;
    }
    return NO;
}

//删除启动次数
+(void)clearLaunchCount {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:keyStr];
    [defaults synchronize];
}

//启动次数+1
+(void)incrementLaunchCount {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* keyStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, launchCount];
    NSInteger countInteger = 0;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* count = [defaults objectForKey:keyStr];
    if (count != nil && [count isKindOfClass:[NSNull class]]) {
        countInteger = [count integerValue];
    }
    countInteger ++;
    
    [defaults setObject:[NSNumber numberWithInteger:countInteger] forKey:keyStr];
    [defaults synchronize];
}

//获取用户文件夹目录
+(NSString* )getUserFilePath {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* userFilePath = [documentPath stringByAppendingPathComponent:appDelegate.userId];
    BOOL isDir;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userFilePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:userFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* bookRecordPath = [documentPath stringByAppendingPathComponent:bookRecord];//书本记录 文件夹
    BOOL isBookDir;
    if (![fileManager fileExistsAtPath:bookRecordPath isDirectory:&isBookDir]) {//不存在文件夹 创建
        [fileManager createDirectoryAtPath:bookRecordPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return userFilePath;
}

//获取用户图书目录
+(NSString* )getBookRecordPath {
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString* bookRecordPath = [documentPath stringByAppendingPathComponent:bookRecord];//书本记录 文件夹
    BOOL isBookDir;
    if (![fileManager fileExistsAtPath:bookRecordPath isDirectory:&isBookDir]) {//不存在文件夹 创建
        [fileManager createDirectoryAtPath:bookRecordPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return bookRecordPath;
}

//初始化第一次启动用户数据
+(void)initFirstLaunchData {
    //创建用户文件夹
    [LMTool getUserFilePath];
    
    //创建图书文件夹
    [LMTool getBookRecordPath];
    
    //配置 初始化
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* modelDayStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerModelDay"];
    NSString* fontStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerFont"];
    NSNumber* fontNum = [userDefaults objectForKey:fontStr];
    if (fontNum != nil && ![fontNum isKindOfClass:[NSNull class]] && fontNum.integerValue > 0) {
        [userDefaults removeObjectForKey:modelDayStr];//阅读界面第二版：删除夜间模式，改成不同背景颜色选择
        [userDefaults synchronize];
    }else {
        //阅读界面 默认设置
        [userDefaults setObject:@16 forKey:fontStr];
        
        //系统设置 默认设置
        NSString* alertStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"updateAlert"];
        NSString* downloadStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"autoDownload"];
        NSString* loadNextStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"autoLoadNext"];
        [userDefaults setObject:@0 forKey:alertStr];
        [userDefaults setObject:@0 forKey:downloadStr];
        [userDefaults setObject:@0 forKey:loadNextStr];
        
        [userDefaults synchronize];
    }
    //阅读界面第二版新增设置
    NSString* brightStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerBright"];
    NSString* readBgStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerBackground"];
    NSString* lineSpaceStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerLineSpace"];
    NSNumber* readBgNum = [userDefaults objectForKey:readBgStr];
    if (readBgNum != nil && ![readBgNum isKindOfClass:[NSNull class]] && readBgNum.integerValue > 0) {
        
    }else {
        CGFloat brightFloat = [UIScreen mainScreen].brightness;
        NSNumber* brightNum = [NSNumber numberWithFloat:brightFloat];
        [userDefaults setObject:brightNum forKey:brightStr];
        [userDefaults setObject:@1 forKey:readBgStr];
        [userDefaults setObject:@1 forKey:lineSpaceStr];
        [userDefaults synchronize];
    }
    
    
    
    
    
    
    //创建 表
    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
    [tool createAllFirstLaunchTable];
    
    
    
    [LMNetworkTool sharedNetworkTool];
}

//获取 阅读界面 配置
+(void)getReaderConfig:(void (^) (CGFloat brightness, CGFloat fontSize, NSInteger bgInteger, CGFloat lineSpace, NSInteger lpIndex))block {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* brightStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerBright"];
    NSString* fontStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerFont"];
    NSString* bgStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerBackground"];
    NSString* lineSpaceStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerLineSpace"];
    NSNumber* brightNum = [userDefaults objectForKey:brightStr];
    NSNumber* fontNum = [userDefaults objectForKey:fontStr];
    NSNumber* bgNum = [userDefaults objectForKey:bgStr];
    NSNumber* lineSpaceNum = [userDefaults objectForKey:lineSpaceStr];
    
    CGFloat brightFloat = brightNum.floatValue;
    CGFloat fontSize = fontNum.floatValue;
    NSInteger bgInt = bgNum.integerValue;
    //适配新版行间距
    CGFloat linsSpaceFloat = lineSpaceNum.floatValue;
    UIFont* font = [UIFont systemFontOfSize:fontSize];
    NSInteger lineSpaceInt = lineSpaceNum.integerValue;
    if (lineSpaceInt == 1) {
        linsSpaceFloat = font.lineHeight / 2;
    }else if (lineSpaceInt == 2) {
        linsSpaceFloat = font.lineHeight * 2 / 3;
    }else if (lineSpaceInt == 3) {
        linsSpaceFloat = font.lineHeight * 6 / 7;
    }else {
        linsSpaceFloat = font.lineHeight / 2;
        lineSpaceInt = 1;
    }
    block(brightFloat, fontSize, bgInt, linsSpaceFloat, lineSpaceInt);
}

//修改阅读器 配置 亮度
+(void)changeReaderConfigWithBrightness:(CGFloat )brightness {
    NSNumber* brightNum = [NSNumber numberWithFloat:brightness];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* brightStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerBright"];
    [userDefaults setObject:brightNum forKey:brightStr];
    [userDefaults synchronize];
}

//修改阅读器 配置 字号
+(void)changeReaderConfigWithFontSize:(CGFloat )fontSize {
    NSNumber* fontNum = @16;
    if (fontSize >= ReaderMinFontSize && fontSize <= ReaderMaxFontSize) {//最小字号
        fontNum = [NSNumber numberWithFloat:fontSize];
    }
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fontStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerFont"];
    [userDefaults setObject:fontNum forKey:fontStr];
    [userDefaults synchronize];
}

//修改阅读器 配置 背景
+(void)changeReaderConfigWithBackgroundInteger:(CGFloat )bgInteger {
    NSNumber* bgNum = [NSNumber numberWithInteger:bgInteger];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* bgStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerBackground"];
    [userDefaults setObject:bgNum forKey:bgStr];
    [userDefaults synchronize];
}

//修改阅读器 配置 行间距
+(void)changeReaderConfigWithLineSpace:(CGFloat )lineSpace lineSpaceIndex:(NSInteger)lpIndex {
    NSNumber* lineSpaceNum = [NSNumber numberWithFloat:lineSpace];
    if (lpIndex) {
        lineSpaceNum = [NSNumber numberWithInteger:lpIndex];
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* lineSpaceStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"readerLineSpace"];
    [userDefaults setObject:lineSpaceNum forKey:lineSpaceStr];
    [userDefaults synchronize];
}

//获取 系统设置 配置 自动加载下一章节
+(BOOL )getSystemAutoLoadNextChapterConfig {
    BOOL loadNextBool = NO;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* loadNextStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"autoLoadNext"];
    NSInteger loadNextInt = [[userDefaults objectForKey:loadNextStr] integerValue];
    if (loadNextInt > 0) {
        loadNextBool = YES;
    }
    return loadNextBool;
}

//获取 系统设置 配置
+(void)getSystemSettingConfig:(void (^) (BOOL alert, BOOL download, BOOL loadNext))block {
    BOOL alertBool = NO;
    BOOL downloadBool = NO;
    BOOL loadNextBool = NO;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* alertStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"updateAlert"];
    NSString* downloadStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"autoDownload"];
    NSString* loadNextStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"autoLoadNext"];
    
    NSInteger alertInt = [[userDefaults objectForKey:alertStr] integerValue];
    if (alertInt > 0) {
        alertBool = YES;
    }
    NSInteger downloadInt = [[userDefaults objectForKey:downloadStr] integerValue];
    if (downloadInt > 0) {
        downloadBool = YES;
    }
    NSInteger loadNextInt = [[userDefaults objectForKey:loadNextStr] integerValue];
    if (loadNextInt > 0) {
        loadNextBool = YES;
    }
    block(alertBool, downloadBool, loadNextBool);
}

//更改 系统设置 配置
+(void)changeSystemSettingWithAlert:(BOOL )alert download:(BOOL )download loadNext:(BOOL )loadNext {
    NSNumber* alertNum = @0;
    if (alert) {
        alertNum = @1;
    }
    NSNumber* downloadNum = @0;
    if (download) {
        downloadNum = @1;
    }
    NSNumber* loadNextNum = @0;
    if (loadNext) {
        loadNextNum = @1;
    }
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    
    NSString* alertStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"updateAlert"];
    NSString* downloadStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"autoDownload"];
    NSString* loadNextStr = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"autoLoadNext"];
    
    [userDefaults setObject:alertNum forKey:alertStr];
    [userDefaults setObject:downloadNum forKey:downloadStr];
    [userDefaults setObject:loadNextNum forKey:loadNextStr];
    [userDefaults synchronize];
}

//设置是否允许推送
+(void)setupUserNotificatioinState:(BOOL )isAllowed {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* notifyKey = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"notificationState"];
    [userDefaults setBool:isAllowed forKey:notifyKey];
    [userDefaults synchronize];
}

//获取是否允许推送
+(BOOL )getUserNotificatioinState {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* notifyKey = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"notificationState"];
    return [userDefaults boolForKey:notifyKey];
}

//获取系统设置中 夜间模式
+(BOOL )getSystemNightShift {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* nightKey = [NSString stringWithFormat:@"%@%@", appDelegate.userId, AppSystemNightShift];
    return [userDefaults boolForKey:nightKey];
}

//更改系统设置中 夜间模式
+(void )changeSystemNightShift:(BOOL )nightShift {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* nightKey = [NSString stringWithFormat:@"%@%@", appDelegate.userId, AppSystemNightShift];
    if (nightShift) {
        [userDefaults setBool:YES forKey:nightKey];
    }else {
        [userDefaults removeObjectForKey:nightKey];
    }
    [userDefaults synchronize];
}

//保存txt
+(BOOL )saveBookTextWithBookId:(UInt32 )bookId chapterId:(NSString* )chapterId bookText:(NSString* )text {
    BOOL result = NO;
    NSString* path = [LMTool getBookRecordPath];
    NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
    NSString* bookPath = [path stringByAppendingPathComponent:bookIdStr];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:bookPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* textPath = [bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", chapterId]];
    
    if ([fileManager fileExistsAtPath:textPath]) {
        [fileManager removeItemAtPath:textPath error:nil];
    }
    result = [text writeToFile:textPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return result;
}

//删除txt
+(BOOL )deleteBookTextWithBookId:(UInt32 )bookId chapterId:(NSString* )chapterId {
    BOOL result = NO;
    NSString* path = [LMTool getBookRecordPath];
    NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
    NSString* bookPath = [path stringByAppendingPathComponent:bookIdStr];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
        return result;
    }
    NSString* textPath = [bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", chapterId]];
    
    if ([fileManager fileExistsAtPath:textPath]) {
        result = [fileManager removeItemAtPath:textPath error:nil];
    }
    
    return result;
}

//删除book
+(BOOL )deleteBookWithBookId:(UInt32 )bookId {
    BOOL result = NO;
    NSString* path = [LMTool getBookRecordPath];
    NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
    NSString* bookPath = [path stringByAppendingPathComponent:bookIdStr];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
        return result;
    }else {
        result = [fileManager removeItemAtPath:bookPath error:nil];
    }
    
    return result;
}

//book目录下的所有书本
+(NSArray* )queryAllBookDirectory {
    NSString* path = [LMTool getBookRecordPath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* allBookPath = [fileManager contentsOfDirectoryAtPath:path error:nil];
    return allBookPath;
}

//是否存在某本书的文件
+(BOOL )isExistBookDirectoryWithBookId:(UInt32 )bookId {
    BOOL result = NO;
    NSString* path = [LMTool getBookRecordPath];
    NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
    NSString* bookPath = [path stringByAppendingPathComponent:bookIdStr];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
        if (isDir) {
            return YES;
        }
    }
    return result;
}

//获取书本所占内存大小 单位：MB
+(float )getBookFileSizeWithBookId:(UInt32 )bookId {
    NSString* path = [LMTool getBookRecordPath];
    NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
    NSString* bookPath = [path stringByAppendingPathComponent:bookIdStr];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
        if (isDir) {
            NSDictionary* dic = [fileManager attributesOfItemAtPath:bookPath error:nil];
            NSNumber *freeFileSystemSizeInBytes = [dic objectForKey:NSFileSystemFreeSize];
            long long bookSize = [freeFileSystemSizeInBytes unsignedIntegerValue];
            
//            long long bookSize = [[fileManager attributesOfItemAtPath:bookPath error:nil] fileSize];
            float changeSize = (float )(bookSize / (1024.0 * 1024.0));
            return changeSize;
        }
    }
    return 0;
}

//是否存在txt
+(BOOL )isExistBookTextWithBookId:(UInt32 )bookId chapterId:(NSString* )chapterId {
    BOOL result = NO;
    NSString* path = [LMTool getBookRecordPath];
    NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
    NSString* bookPath = [path stringByAppendingPathComponent:bookIdStr];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
        return result;
    }
    NSString* textPath = [bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", chapterId]];
    
    if ([fileManager fileExistsAtPath:textPath]) {
        result = YES;
    }
    
    return result;
}

//取txt
+(NSString* )queryBookTextWithBookId:(UInt32 )bookId chapterId:(NSString* )chapterId {
    NSString* path = [LMTool getBookRecordPath];
    NSString* bookIdStr = [NSString stringWithFormat:@"%d", bookId];
    NSString* bookPath = [path stringByAppendingPathComponent:bookIdStr];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:bookPath isDirectory:&isDir]) {
        return nil;
    }
    NSString* textPath = [bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", chapterId]];
    if (![fileManager fileExistsAtPath:textPath]) {
        return nil;
    }
    NSString* str = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
    
    return str;
}

//新解析方式下 保存章节列表  拼上catalogList，用以区别旧解析方式下保存的NSData数据
+(BOOL )archiveNewParseBookCatalogListWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList {
    BOOL result = NO;
    if (catalogList != nil && ![catalogList isKindOfClass:[NSNull class]] && catalogList.count > 0) {
        
    }else {
        return result;
    }
    NSMutableArray* arr = [NSMutableArray array];
    for (NSInteger i = 0; i < catalogList.count; i ++) {
        LMReaderBookChapter* chapter = [catalogList objectAtIndex:i];
        NSString* urlStr = chapter.url;
        NSString* title = chapter.title;
        NSString* chapterIdStr = chapter.chapterId;
        NSDictionary* dic = [[NSDictionary alloc]initWithObjects:@[urlStr, title, chapterIdStr] forKeys:@[@"url", @"title", @"chapterId"]];
        [arr addObject:dic];
    }
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d_catalogList", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    result = [arr writeToFile:filePath atomically:YES];
    return result;
}

//新解析方式下 取章节列表
+(NSArray<LMReaderBookChapter* >* )unarchiveNewParseBookCatalogListWithBookId:(UInt32 )bookId {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d_catalogList", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    NSMutableArray* arr = [NSMutableArray array];
    NSArray* catalogList = [[NSArray alloc]initWithContentsOfFile:filePath];
    for (NSInteger i = 0; i < catalogList.count; i ++) {
        NSDictionary* dic = [catalogList objectAtIndex:i];
        LMReaderBookChapter* chapter = [[LMReaderBookChapter alloc]init];
        chapter.url = [dic objectForKey:@"url"];
        chapter.title = [dic objectForKey:@"title"];
        id chapterId = [dic objectForKey:@"chapterId"];
        chapter.chapterId = [NSString stringWithFormat:@"%@", chapterId];
        [arr addObject:chapter];
    }
    return arr;
}

//删除 图书目录
+(BOOL )deleteArchiveBookNewParseCatalogListWithBookId:(UInt32 )bookId {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d_catalogList", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    BOOL result = NO;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        result = [fileManager removeItemAtPath:filePath error:nil];
    }
    return result;
}

//归档 保存图书目录
+(BOOL )archiveBookCatalogListWithBookId:(UInt32 )bookId catalogList:(NSData* )catalogList {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    BOOL result = [catalogList writeToFile:filePath atomically:YES];
    return result;
}

//反归档 取图书目录
+(NSData* )unArchiveBookCatalogListWithBookId:(UInt32 )bookId {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    NSData* data = [[NSData alloc]initWithContentsOfFile:filePath];
    return data;
}

//删除 图书目录
+(BOOL )deleteArchiveBookCatalogListWithBookId:(UInt32 )bookId {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    BOOL result = NO;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        result = [fileManager removeItemAtPath:filePath error:nil];
    }
    return result;
}

//json解析获取章节目录列表，元素为 LMReaderBookChapter 类型
+(NSArray* )jsonParseChapterListWithParse:(UrlReadParse* )parse originalDic:(NSDictionary* )originalDic {
    if (originalDic == nil || [originalDic isKindOfClass:[NSNull class]] || originalDic.count == 0) {
        return nil;
    }
    NSMutableArray* listArr = [NSMutableArray array];
    
    KanapiJiaston* jsonApi = parse.api;
    
    NSString* originalUrlStr = jsonApi.curlStr;
    NSString* titleKeyStr = jsonApi.ctitleKey;
    NSString* idKeyStr = jsonApi.cidKey;
    
    NSArray* listParseArr = jsonApi.listParse;
    id tempResultId = originalDic;
    NSMutableArray* dicArray = [NSMutableArray array];
    for (NSInteger i = 0; i < listParseArr.count; i ++) {
        JsonParse* jsonParse = [listParseArr objectAtIndex:i];
        NSString* keyStr = jsonParse.jsonKey;
        if (jsonParse.jsonType == 1) {//array类型
            if ([tempResultId isKindOfClass:[NSArray class]]) {
                for (id subIdType in tempResultId) {
                    NSArray* finalArr = [subIdType objectForKey:keyStr];
                    
                    for (id finalElement in finalArr) {
                        if (i == listParseArr.count - 1) {
                            [dicArray addObject:finalElement];
                        }else {
                            
                        }
                    }
                }
            }else if ([tempResultId isKindOfClass:[NSDictionary class]]) {
                if (i == listParseArr.count - 1) {
                    [dicArray addObject:tempResultId];
                }else {
                    
                }
            }
        }else if (jsonParse.jsonType == 0) {//dictionary类型
            if ([tempResultId isKindOfClass:[NSDictionary class]]) {
                tempResultId = [tempResultId objectForKey:keyStr];
                if (i == listParseArr.count - 1) {
                    if ([tempResultId isKindOfClass:[NSArray class]]) {
                        for (id finalSub in tempResultId) {
                            [dicArray addObject:finalSub];
                        }
                    }else if ([tempResultId isKindOfClass:[NSDictionary class]]) {
                        [dicArray addObject:tempResultId];
                    }
                }
            }
        }
    }
    
    for (id subElement in dicArray) {
        if ([subElement isKindOfClass:[NSDictionary class]]) {
            LMReaderBookChapter* bookChapter = [[LMReaderBookChapter alloc]init];
            id subIdType = [subElement objectForKey:idKeyStr];
            bookChapter.url = [originalUrlStr stringByReplacingOccurrencesOfString:@"[cid]" withString:[NSString stringWithFormat:@"%@", subIdType]];
            bookChapter.title = [subElement objectForKey:titleKeyStr];
            bookChapter.chapterId = [NSString stringWithFormat:@"%@", subIdType];
            [listArr addObject:bookChapter];
        }
    }
    
    if (listArr.count > 0) {
        return listArr;
    }
    return nil;
}

//json解析获取章节内容，为 NSString 类型
+(NSString* )jsonParseChapterContentWithParse:(UrlReadParse* )parse originalDic:(NSDictionary* )originalDic {
    if (originalDic == nil || [originalDic isKindOfClass:[NSNull class]] || originalDic.count == 0) {
        return nil;
    }
    
    KanapiJiaston* jsonApi = parse.api;
    
    NSString* contentKeyStr = jsonApi.contentKey;
    
    NSArray* listParseArr = jsonApi.contentParse;
    id tempResultId = originalDic;
    NSDictionary* resultDic;
    for (NSInteger i = 0; i < listParseArr.count; i ++) {
        JsonParse* jsonParse = [listParseArr objectAtIndex:i];
        NSString* keyStr = jsonParse.jsonKey;
        if (jsonParse.jsonType == 1) {//array类型
            if ([tempResultId isKindOfClass:[NSArray class]]) {
                for (id subIdType in tempResultId) {
                    NSArray* finalArr = [subIdType objectForKey:keyStr];
                    
                    for (id finalElement in finalArr) {
                        if (i == listParseArr.count - 1) {
                            resultDic = finalElement;
                        }else {
                            
                        }
                    }
                }
            }else if ([tempResultId isKindOfClass:[NSDictionary class]]) {
                if (i == listParseArr.count - 1) {
                    resultDic = tempResultId;
                }else {
                    
                }
            }
        }else if (jsonParse.jsonType == 0) {//dictionary类型
            if ([tempResultId isKindOfClass:[NSDictionary class]]) {
                tempResultId = [tempResultId objectForKey:keyStr];
                if (i == listParseArr.count - 1) {
                    resultDic = tempResultId;
                }
            }
        }
    }
    
    
    if ([resultDic isKindOfClass:[NSDictionary class]]) {
        NSString* resultStr = [resultDic objectForKey:contentKeyStr];
        if (resultStr != nil && [resultStr isKindOfClass:[NSString class]]) {
            return resultStr;
        }
    }
    
    return nil;
}

//归档 保存图书源列表最新章节
+(BOOL )archiveBookSourceWithBookId:(UInt32 )bookId sourceDic:(NSDictionary* )sourceDic {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d_sourceDic", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    BOOL result = [sourceDic writeToFile:filePath atomically:YES];
    return result;
}

//反归档 取图书源列表最新章节
+(NSDictionary* )unArchiveBookSourceDicWithBookId:(UInt32 )bookId {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d_sourceDic", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    NSDictionary* dic = [[NSDictionary alloc]initWithContentsOfFile:filePath];
    return dic;
}

//删除 图书源列表最新章节
+(BOOL )deleteArchiveBookSourceDicWithBookId:(UInt32 )bookId {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%d_sourceDic", appDelegate.userId, bookId];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    BOOL result = NO;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        result = [fileManager removeItemAtPath:filePath error:nil];
    }
    return result;
}

//归档 精选首页
+(BOOL )archiveChoiceData:(NSData* )choiceData {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"choiceData"];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    BOOL result = [choiceData writeToFile:filePath atomically:YES];
    return result;
}

//反归档 精选首页
+(NSData* )unArchiveChoiceData {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"choiceData"];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    NSData* data = [[NSData alloc]initWithContentsOfFile:filePath];
    return data;
}

//删除 精选首页
+(BOOL )deleteChoiceData {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"choiceData"];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    BOOL result = NO;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        result = [fileManager removeItemAtPath:filePath error:nil];
    }
    return result;
}

//判断设备是否绑定
+(BOOL )deviceIsBinding {
    NSString* uuidStr = [LMTool uuid];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userId = [defaults objectForKey:uuidStr];
    if (userId != nil && ![userId isKindOfClass:[NSNull class]] && userId.length > 0) {
        return YES;
    }
    return NO;
}

//获取当前userId
+(NSString* )getAppUserId {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([LMTool deviceIsBinding]) {
        NSString* userId = [defaults objectForKey:currentUserId];
        return userId;
    }else {
        NSString* uuidStr = [LMTool uuid];
        uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        return uuidStr;
    }
}

//首次进入app选择性别之后 保存性别
+(void)saveFirstLaunchGenderType:(GenderType )genderType {
    NSNumber* typeNum = @1;
    if (genderType == GenderTypeGenderFemale) {
        typeNum = @2;
    }
    NSString* keyStr = [NSString stringWithFormat:@"%@_%@", [self getAppUserId], @"GenderType"];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:typeNum forKey:keyStr];
    [userDefaults synchronize];
}

//删除首次进入app时选择的性别
+(void)deleteFirstLaunchGenderType {
    NSString* keyStr = [NSString stringWithFormat:@"%@_%@", [self getAppUserId], @"GenderType"];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:keyStr];
    [userDefaults synchronize];
}

//获取首次进入app时选择的性别
+(GenderType )getFirstLaunchGenderType {
    NSString* keyStr = [NSString stringWithFormat:@"%@_%@", [self getAppUserId], @"GenderType"];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* typeNum = [userDefaults objectForKey:keyStr];
    if (typeNum != nil && ![NSNumber isKindOfClass:[NSNull class]] && typeNum.integerValue == 2) {
        return GenderTypeGenderFemale;
    }
    return GenderTypeGenderMale;
}

//将设备号与用户绑定
+(void)bindDeviceToUser:(LoginedRegUser* )loginUser {
    NSString* userId = loginUser.user.uid;
    NSString* uuidStr = [LMTool uuid];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([LMTool deviceIsBinding]) {//设备已经被绑定过
        NSString* bindUserId = [LMTool getAppUserId];
        if ([bindUserId isEqualToString:uuidStr]) {//设备绑定的是当前账号
            return;
        }
        
        //根据用户id来创建用户目录文件夹、设置APPDelegate.userId、创建数据表
        
        [defaults setObject:userId forKey:currentUserId];
        [defaults synchronize];
        
        //初始化用户数据
        [LMTool initFirstLaunchData];
        
        //To Do...
        
    }else {
        [defaults setObject:userId forKey:uuidStr];
        [defaults setObject:uuidStr forKey:currentUserId];
        [defaults synchronize];
    }
    
}

//保存用户信息
+(void)saveLoginedRegUser:(LoginedRegUser* )loginedUser {
    NSString* token = loginedUser.token;
    RegUser* regUser = loginedUser.user;
    NSString* uidStr = regUser.uid;
    NSString* phoneNumStr = regUser.phoneNum;
    NSString* emailStr = regUser.email;
    GenderType genderType = regUser.gender;
    NSNumber* genderNum = @0;
    if (genderType == GenderTypeGenderMale) {
        genderNum = @1;
    }else if (genderType == GenderTypeGenderFemale) {
        genderNum = @2;
    }else if (genderType == GenderTypeGenderOther) {
        genderNum = @3;
    }
    NSString* birthdayStr = regUser.birthday;
    NSString* localAreaStr = regUser.localArea;
    UInt32 registerTimeInt = regUser.registerTime;
    NSNumber* registerTimeNum = [NSNumber numberWithInt:registerTimeInt];
    NSString* iconStr = regUser.icon;
    NSString* wxStr = regUser.wx;
    NSString* qqStr = regUser.qq;
    RegUserSetPw setpw = regUser.setpw;
    NSNumber* setpwNum = @0;
    if (setpw == RegUserSetPwYes) {
        setpwNum = @1;
    }
    NSData* avatorData = regUser.iconB;
    NSString* nickNameStr = regUser.nickname;
    NSString* wxNickNameStr = regUser.wxNickname;
    NSString* qqNickNameStr = regUser.qqNickname;
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:token forKey:@"token"];
    [dic setObject:uidStr forKey:@"uid"];
    [dic setObject:phoneNumStr forKey:@"phoneNum"];
    [dic setObject:emailStr forKey:@"email"];
    [dic setObject:genderNum forKey:@"gender"];
    [dic setObject:birthdayStr forKey:@"birthday"];
    [dic setObject:localAreaStr forKey:@"localArea"];
    [dic setObject:registerTimeNum forKey:@"registerTime"];
    [dic setObject:iconStr forKey:@"icon"];
    [dic setObject:wxStr forKey:@"wx"];
    [dic setObject:qqStr forKey:@"qq"];
    [dic setObject:setpwNum forKey:@"setpw"];
    [dic setObject:nickNameStr forKey:@"nickName"];
    [dic setObject:wxNickNameStr forKey:@"wxNickName"];
    [dic setObject:qqNickNameStr forKey:@"qqNickName"];
    [dic setObject:avatorData forKey:@"avator"];
    
    //
    [dic writeToFile:plistPath atomically:YES];
}

//删除用户信息
+(BOOL )deleteLoginedRegUser {
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;
    if ([fileManager fileExistsAtPath:plistPath]) {
        [fileManager removeItemAtPath:plistPath error:&error];
    }
    if (error) {
        return NO;
    }
    return YES;
}

//获取用户信息
+(LoginedRegUser* )getLoginedRegUser {
    LoginedRegUserBuilder* builder = [LoginedRegUser builder];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* plistPath = [documentPath stringByAppendingPathComponent:@"loginedRegUser.plist"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:plistPath]) {
        return nil;
    }
    
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString* tokenStr = [dic objectForKey:@"token"];
    NSString* uidStr = [dic objectForKey:@"uid"];
    NSString* phoneNumStr = [dic objectForKey:@"phoneNum"];
    NSString* emailStr = [dic objectForKey:@"email"];
    NSNumber* genderNum = [dic objectForKey:@"gender"];
    NSInteger genderInt = [genderNum integerValue];
    GenderType type = GenderTypeGenderUnknown;
    if (genderInt == 1) {
        type = GenderTypeGenderMale;
    }else if (genderInt == 2) {
        type = GenderTypeGenderFemale;
    }else if (genderInt == 3) {
        type = GenderTypeGenderOther;
    }
    NSString* birthdayStr = [dic objectForKey:@"birthday"];
    NSString* localAreaStr = [dic objectForKey:@"localArea"];
    NSNumber* registerTimeNum = [dic objectForKey:@"registerTime"];
    NSString* iconStr = [dic objectForKey:@"icon"];
    NSString* wxStr = [dic objectForKey:@"wx"];
    NSString* qqStr = [dic objectForKey:@"qq"];
    NSNumber* setpwNum = [dic objectForKey:@"setpw"];
    RegUserSetPw setPw = RegUserSetPwNo;
    if (setpwNum.integerValue == 1) {
        setPw = RegUserSetPwYes;
    }
    NSData* avatorData = [dic objectForKey:@"avator"];
    NSString* nickNameStr = [dic objectForKey:@"nickName"];
    NSString* wxNickNameStr = [dic objectForKey:@"wxNickName"];
    NSString* qqNickNameStr = [dic objectForKey:@"qqNickName"];
    
    RegUserBuilder* userBuilder = [RegUser builder];
    [userBuilder setUid:uidStr];
    [userBuilder setPhoneNum:phoneNumStr];
    [userBuilder setEmail:emailStr];
    [userBuilder setGender:type];
    [userBuilder setBirthday:birthdayStr];
    [userBuilder setLocalArea:localAreaStr];
    [userBuilder setRegisterTime:(UInt32)[registerTimeNum intValue]];
    [userBuilder setIcon:iconStr];
    [userBuilder setWx:wxStr];
    [userBuilder setQq:qqStr];
    [userBuilder setSetpw:setPw];
    [userBuilder setNickname:nickNameStr];
    [userBuilder setWxNickname:wxNickNameStr];
    [userBuilder setQqNickname:qqNickNameStr];
    [userBuilder setIconB:avatorData];
    RegUser* regUser = [userBuilder build];
    
    [builder setToken:tokenStr];
    [builder setUser:regUser];
    
    LoginedRegUser* user = [builder build];
    return user;
}

//存储 启动页 数据
+(BOOL )saveLaunchImageData:(NSData* )launchData {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* launchPath = [documentPath stringByAppendingPathComponent:@"launchData"];
    if ([fileManager fileExistsAtPath:launchPath]) {
        [fileManager removeItemAtPath:launchPath error:nil];
    }
    BOOL result = [launchData writeToFile:launchPath atomically:YES];
    return result;
}
//删 启动页 数据
+(BOOL )deleteLaunchImageData {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* launchPath = [documentPath stringByAppendingPathComponent:@"launchData"];
    if ([fileManager fileExistsAtPath:launchPath]) {
        return [fileManager removeItemAtPath:launchPath error:nil];
    }
    return NO;
}
//取 启动页 数据
+(NSData* )queryLaunchImageData {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray *pathsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [pathsArr objectAtIndex:0];
    NSString* launchPath = [documentPath stringByAppendingPathComponent:@"launchData"];
    if ([fileManager fileExistsAtPath:launchPath]) {
        NSData* data = [[NSData alloc]initWithContentsOfFile:launchPath];
        return data;
    }else {
        return nil;
    }
}
//存 启动页 上次角标
+(void )saveLastLaunchImageIndex:(NSInteger )index {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInteger:index] forKey:@"launchDataIndex"];
    [userDefaults synchronize];
}
//取 启动页 上次角标
+(NSInteger )queryLastLaunchImageIndex {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* num = [userDefaults objectForKey:@"launchDataIndex"];
    if (num != nil && ![num isKindOfClass:[NSNull class]]) {
        return num.integerValue;
    }else {
        return 0;
    }
}
//删 启动页 上次角标
+(void )deleteLastLaunchImageIndex {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"launchDataIndex"];
    [userDefaults synchronize];
}

//刘海屏 适配navigationBar和tabBar
+(BOOL )isBangsScreen {
    CGRect rectX = CGRectMake(0, 0, 375, 812);//iPhone X 分辨率1125*2436
    CGRect rectXs = CGRectMake(0, 0, 375, 812);//iPhone Xs 分辨率1125*2436
    CGRect rectXsMax = CGRectMake(0, 0, 414, 896);//iPhone Xs Max 分辨率1242*2688
    CGRect rectXr = CGRectMake(0, 0, 414, 896);//iPhone Xr 分辨率828*1792
    CGRect deviceRect = [UIScreen mainScreen].bounds;
    BOOL result = NO;
    if (CGRectEqualToRect(deviceRect, rectX)) {
        result = YES;
    }else if (CGRectEqualToRect(deviceRect, rectXs)) {
        result = YES;
    }else if (CGRectEqualToRect(deviceRect, rectXsMax)) {
        result = YES;
    }else if (CGRectEqualToRect(deviceRect, rectXr)) {
        result = YES;
    }
    return result;
}

//uuid
+(NSString* )uuid {
    NSString* uuidStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return uuidStr;
}

//idfa
+(NSString* )idfa {
    ASIdentifierManager* adManager = [ASIdentifierManager sharedManager];
    if (adManager.advertisingTrackingEnabled) {
        NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return advertisingId;
    }
    return nil;
}

//当前APP版本号（2.0.1）
+(NSString* )applicationCurrentVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appCurVersion;
}

//系统版本
+(NSString* )systemVersion {
    NSString* systemStr = [[UIDevice currentDevice] systemVersion];
    return systemStr;
}

//系统版本
+(float )systemVersionFloat {
    NSString* systemStr = [[UIDevice currentDevice] systemVersion];
    return systemStr.floatValue;
}

//设备型号
+(NSString* )deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

//机型 4、4s,5、5c、5s,6、7、8,6p、7p、8p,x
+(NSString *)deviceType {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight == 480) {
        return @"4";
    }else if (screenHeight == 568) {
        return @"5";
    }else if (screenHeight == 667) {
        return @"6";
    }else if (screenHeight == 736) {
        return @"6p";
    }else if (screenHeight == 812) {
        return @"x";
    }
    return @"unknow";
}

+(DeviceUdId* )protobufDeviceUuId {
    DeviceUdIdBuilder* builder = [DeviceUdId builder];
    [builder setUuid:[LMTool uuid]];
    [builder setIdfa:[LMTool idfa]];
    return [builder build];
}

+(DeviceSize* )protobufDeviceSize {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    DeviceSizeBuilder* builder = [DeviceSize builder];
    [builder setWidth: (UInt32)screenRect.size.width];
    [builder setHeight:(UInt32)screenRect.size.height];
    return [builder build];
}

+(Device* )protobufDevice {
    DeviceDeviceType type = DeviceDeviceTypeDevicePhone;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        type = DeviceDeviceTypeDevicePhone;
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        type = DeviceDeviceTypeDeviceTablet;
    }else {
        type = DeviceDeviceTypeDeviceUnknown;
    }
    DeviceBuilder* devideBuild = [Device builder];
    [devideBuild setDeviceType:type];
    [devideBuild setOsType:DeviceOsTypeIos];
    [devideBuild setOsVersion:[LMTool systemVersion]];
    [devideBuild setVendor:[@"Apple" dataUsingEncoding:NSUTF8StringEncoding]];
    [devideBuild setModel:[[LMTool deviceModel] dataUsingEncoding:NSUTF8StringEncoding]];
    [devideBuild setUdid:[LMTool protobufDeviceUuId]];
    [devideBuild setScreenSize:[LMTool protobufDeviceSize]];
    
    return [devideBuild build];
}


//将时间戳转换成字符串
+(NSString* )convertTimeStampToTime:(UInt64 )timeStamp {
    if (timeStamp) {
        
    }else {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //获取此时时间戳长度
    NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970];
    int timeInt = nowTimeinterval - timeStamp; //时间差
    
    int year = timeInt / (3600 * 24 * 30 *12);
    int month = timeInt / (3600 * 24 * 30);
    int day = timeInt / (3600 * 24);
    int hour = timeInt / 3600;
    int minute = timeInt / 60;
    if (year > 0) {
        return [NSString stringWithFormat:@"%d年前",year];
    }else if (month > 0) {
        return [NSString stringWithFormat:@"%d个月前",month];
    }else if (day > 0) {
        if (day == 1) {
            return @"昨天";
        }
        return [NSString stringWithFormat:@"%d天前",day];
    }else if (hour > 0) {
        return [NSString stringWithFormat:@"%d小时前",hour];
    }else if (minute > 0) {
        return [NSString stringWithFormat:@"%d分钟前",minute];
    }else {
        return [NSString stringWithFormat:@"刚刚"];
    }
}

//将时间换成字符串
+(NSString* )convertTimeStringToTime:(NSString* )timeStr {
    if (timeStr != nil && ![timeStr isKindOfClass:[NSNull class]] && timeStr.length > 0) {
        
    }else {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //获取此时时间戳长度
    NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970];
    NSDate* date = [dateFormatter dateFromString:timeStr];
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    int timeInt = nowTimeinterval - timeStamp; //时间差
    
    int year = timeInt / (3600 * 24 * 30 *12);
    int month = timeInt / (3600 * 24 * 30);
    int day = timeInt / (3600 * 24);
    int hour = timeInt / 3600;
    int minute = timeInt / 60;
    if (year > 0) {
        return [NSString stringWithFormat:@"%d年前",year];
    }else if (month > 0) {
        return [NSString stringWithFormat:@"%d个月前",month];
    }else if (day > 0) {
        if (day == 1) {
            return @"昨天";
        }
        return [NSString stringWithFormat:@"%d天前",day];
    }else if (hour > 0) {
        return [NSString stringWithFormat:@"%d小时前",hour];
    }else if (minute > 0) {
        return [NSString stringWithFormat:@"%d分钟前",minute];
    }else {
        return [NSString stringWithFormat:@"刚刚"];
    }
}

//将时间转换成时间字符串
+(NSString* )convertDateToTime:(NSDate* )date {
    long dateStamp = [date timeIntervalSince1970];
    return [LMTool convertTimeStampToTime:dateStamp];
}

//将日期转换成小时
+(NSInteger )convertDateToHourTime:(NSDate* )date {
    long dateStamp = [date timeIntervalSince1970];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //获取此时时间戳长度
    NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970];
    int timeInt = nowTimeinterval - dateStamp; //时间差
    
    NSInteger hour = timeInt / 3600;
    return hour;
}

//将日期转换成天
+(NSInteger )convertTimeStampToDayTime:(NSInteger )timeStamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //获取此时时间戳长度
    NSTimeInterval nowTimeinterval = [[NSDate date] timeIntervalSince1970];
    int timeInt = nowTimeinterval - timeStamp; //时间差
    
    NSInteger day = timeInt / (3600 * 24);
    return day;
}

//MD5加密, 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str {
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

//10位时间戳，到秒
+(UInt32 )get10NumbersTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    return (UInt32 )[timeString integerValue];
}

//url编码
+(NSString* )encodeURLString:(NSString* )urlStr {
    NSString *encodedString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return encodedString;
}

//HTML解析，将后台返回的解析数组转成node字符串
+(NSString* )convertToHTMLStringWithListArray:(NSArray* )listArray {
    NSString* searchStr = @"";
    for (NSString* subList in listArray) {
        NSString* tempSubList = [subList stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray* tempStrArr1 = [tempSubList componentsSeparatedByString:@" "];
        for (NSString* tempSubStr1 in tempStrArr1) {
            NSRange dotRange = [tempSubStr1 rangeOfString:@"."];
            if (dotRange.location != NSNotFound) {
                NSArray* dotStrArr = [tempSubStr1 componentsSeparatedByString:@"."];
                if (dotStrArr.count >= 2) {//多个属性值时
                    NSString* firstStr = [dotStrArr objectAtIndex:0];
                    NSString* otherStr = [dotStrArr objectAtIndex:1];
                    for (NSInteger i = 2; i < dotStrArr.count; i ++) {
                        NSString* subDotStr = [dotStrArr objectAtIndex:i];
                        otherStr = [otherStr stringByAppendingString:[NSString stringWithFormat:@" %@", subDotStr]];
                    }
                    searchStr = [searchStr stringByAppendingString:[NSString stringWithFormat:@"//%@[@class='%@']", firstStr, otherStr]];
                }else {
                    NSString* dotBeforeStr = [tempSubStr1 substringToIndex:dotRange.location];
                    NSString* dotAfterStr = [tempSubStr1 substringFromIndex:dotRange.location + dotRange.length];
                    searchStr = [searchStr stringByAppendingString:[NSString stringWithFormat:@"//%@[@class='%@']", dotBeforeStr, dotAfterStr]];
                }
            }else {
                NSRange sharpRange = [tempSubStr1 rangeOfString:@"#"];
                if (sharpRange.location != NSNotFound) {
                    NSString* sharpBeforeStr = [tempSubStr1 substringToIndex:sharpRange.location];
                    NSString* sharpAfterStr = [tempSubStr1 substringFromIndex:sharpRange.location + sharpRange.length];
                    if (sharpBeforeStr == nil || sharpBeforeStr.length == 0) {
                        sharpBeforeStr = @"div";
                    }
                    searchStr = [searchStr stringByAppendingString:[NSString stringWithFormat:@"//%@[@id='%@']", sharpBeforeStr, sharpAfterStr]];
                }else {
                    searchStr = [searchStr stringByAppendingString:[NSString stringWithFormat:@"//%@", tempSubStr1]];
                }
            }
        }
    }
    return searchStr;
}

//将br段落符天换成换行符\n
+(NSString* )replaceBrCharacterWithReturnCharacter:(NSString* )originalStr {
    if (originalStr == nil || [originalStr isKindOfClass:[NSNull class]]) {
        return @"";
    }
//    NSString* resultStr = [originalStr stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//    resultStr = [originalStr stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    
    //替换<p>标签
    NSString* regexStr2 = @"<p>";
    NSString* replaceStr2 = @"   ";
    NSRegularExpression* expression2 = [NSRegularExpression regularExpressionWithPattern:regexStr2 options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
    NSString* resultStr = [expression2 stringByReplacingMatchesInString:originalStr options:NSMatchingReportProgress range:NSMakeRange(0, originalStr.length) withTemplate:replaceStr2];
    
    //替换</p>标签
    NSString* regexStr3 = @"</p>";
    NSString* replaceStr3 = @"\n";
    NSRegularExpression* expression3 = [NSRegularExpression regularExpressionWithPattern:regexStr3 options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
    resultStr = [expression3 stringByReplacingMatchesInString:resultStr options:NSMatchingReportProgress range:NSMakeRange(0, resultStr.length) withTemplate:replaceStr3];
    
    //替换<P>标签
    NSString* regexStr4 = @"<P>";
    NSString* replaceStr4 = @"\n";
    NSRegularExpression* expression4 = [NSRegularExpression regularExpressionWithPattern:regexStr4 options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
    resultStr = [expression4 stringByReplacingMatchesInString:resultStr options:NSMatchingReportProgress range:NSMakeRange(0, resultStr.length) withTemplate:replaceStr4];
    
    //替换</P>标签
    NSString* regexStr5 = @"</P>";
    NSString* replaceStr5 = @"\n";
    NSRegularExpression* expression5 = [NSRegularExpression regularExpressionWithPattern:regexStr5 options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
    resultStr = [expression5 stringByReplacingMatchesInString:resultStr options:NSMatchingReportProgress range:NSMakeRange(0, resultStr.length) withTemplate:replaceStr5];
    
    //去掉<br><br/><br /><br >等标签
    NSString* regexStr1 = @"<br[ ]?[/]?>";
    NSString* replaceStr1 = @"\n";
    NSRegularExpression* expression1 = [NSRegularExpression regularExpressionWithPattern:regexStr1 options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
    resultStr = [expression1 stringByReplacingMatchesInString:resultStr options:NSMatchingReportProgress range:NSMakeRange(0, resultStr.length) withTemplate:replaceStr1];
    
    //去掉带<script>相关东西
    NSString* regexStr = @"<script[^>]*>[\\d\\D]*?</script>";
    NSString* replaceStr = @"";
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
    resultStr = [expression stringByReplacingMatchesInString:resultStr options:NSMatchingReportProgress range:NSMakeRange(0, resultStr.length) withTemplate:replaceStr];
    return resultStr;
}

//过滤掉无用文本
+(NSString* )filterUselessStringWithText:(NSString* )originalStr filterArr:(NSArray* )filterArr {
    if (originalStr == nil || [originalStr isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSString* resultStr = originalStr;
    for (NSInteger i = 0; i < filterArr.count; i ++) {
        id subElement = [filterArr objectAtIndex:i];
        if ([subElement isKindOfClass:[NSString class]]) {
            NSString* filterStr = subElement;
            if (filterStr.length > 0) {
                NSString* regexStr = filterStr;
                NSString* replaceStr = @"";
                NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
                resultStr = [expression stringByReplacingMatchesInString:resultStr options:NSMatchingReportProgress range:NSMakeRange(0, resultStr.length) withTemplate:replaceStr];
            }
        }
    }
    return resultStr;
}

//替换空格
+(NSString* )replaceSeveralNewLineWithOneNewLineWithText:(NSString* )originalStr {
    if (originalStr == nil || [originalStr isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    
    NSString* changedStr = [originalStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* regexStr1 = @"(\\r|\\n){1,}[ ]?";//将\r\n等换行符替换成\n
    NSString* replaceStr1 = @"\n";
    NSRegularExpression* expression1 = [NSRegularExpression regularExpressionWithPattern:regexStr1 options:NSRegularExpressionUseUnixLineSeparators error:nil];
    NSString* resultStr = [expression1 stringByReplacingMatchesInString:changedStr options:NSMatchingReportCompletion range:NSMakeRange(0, changedStr.length) withTemplate:replaceStr1];
    
    NSString* regexStr = @"\\n+\\s{1,}\\n+";//将多个\n替换成一个\n
    NSString* replaceStr = @"\n";
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnixLineSeparators error:nil];
    resultStr = [expression stringByReplacingMatchesInString:resultStr options:NSMatchingReportCompletion range:NSMakeRange(0, resultStr.length) withTemplate:replaceStr];
    resultStr = [NSString stringWithFormat:@"    %@", resultStr];
    return resultStr;
}

//去掉换行，开头不添加两字符空白对齐
+(NSString* )replaceSeveralNewLineNotAddSpaceWithText:(NSString* )originalStr {
    if (originalStr == nil || [originalStr isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSString* changedStr = [originalStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* regexStr = @"(\\r|\\n|\\t){1,}[ ]?";
    NSString* replaceStr = @"";
    NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnixLineSeparators error:nil];
    NSString* resultStr = [expression stringByReplacingMatchesInString:changedStr options:NSMatchingReportCompletion range:NSMakeRange(0, changedStr.length) withTemplate:replaceStr];
    return resultStr;
}

//根据转码（如gbk）转换成utf-8
+(NSStringEncoding )convertEncodingStringWithEncoding:(NSString* )encoding {
    if (encoding == nil || [encoding isKindOfClass:[NSNull class]]) {
        return NSUTF8StringEncoding;
    }else if ([encoding isEqualToString:@"utf-8"]) {
        return NSUTF8StringEncoding;
    }else if ([encoding isEqualToString:@"gbk"]) {
        return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }else if ([encoding isEqualToString:@"GB2312"]) {
        return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    return NSUTF8StringEncoding;
}

//根据书籍hostUrl以及章节briefStr组合得到章节的具体章节url
+(NSString* )getChapterUrlStrWithHostUrlStr:(NSString* )urlStr briefStr:(NSString* )briefStr {
    NSString* originBriefStr = [LMTool replaceSeveralNewLineNotAddSpaceWithText:briefStr];
    NSString* bookChapterUrlStr = nil;
    NSString *regex =@"[a-zA-z]+://[^\\s]*";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([urlTest evaluateWithObject:originBriefStr]) {
        bookChapterUrlStr = originBriefStr;
    }else {
        NSURL* bookUrl = [NSURL URLWithString:originBriefStr relativeToURL:[NSURL URLWithString:urlStr]];
        bookChapterUrlStr = bookUrl.absoluteString;
        if ([urlTest evaluateWithObject:bookChapterUrlStr]) {
            return bookChapterUrlStr;
        }
        if ([urlStr rangeOfString:@"/index.htm"].location != NSNotFound) {
            if ([urlStr rangeOfString:@"/index.html"].location != NSNotFound) {
                NSString* subUrlStr = [urlStr stringByReplacingOccurrencesOfString:@"/index.html" withString:@""];
                if ([originBriefStr hasPrefix:@"/"]) {
                    bookChapterUrlStr = [NSString stringWithFormat:@"%@%@", subUrlStr,originBriefStr];
                }else {
                    bookChapterUrlStr = [NSString stringWithFormat:@"%@/%@", subUrlStr, originBriefStr];
                }
            }else {
                NSString* subUrlStr = [urlStr stringByReplacingOccurrencesOfString:@"/index.htm" withString:@""];
                if ([originBriefStr hasPrefix:@"/"]) {
                    bookChapterUrlStr = [NSString stringWithFormat:@"%@%@", subUrlStr,originBriefStr];
                }else {
                    bookChapterUrlStr = [NSString stringWithFormat:@"%@/%@", subUrlStr, originBriefStr];
                }
            }
        }else {
            NSURL* bookUrl = [NSURL URLWithString:originBriefStr relativeToURL:[NSURL URLWithString:urlStr]];
            bookChapterUrlStr = bookUrl.absoluteString;
        }
    }
    return bookChapterUrlStr;
}

//保存 微信登录、分享是否打开
+(void)saveWeChatLoginOpen:(BOOL)open {
    NSString* keyStr = [NSString stringWithFormat:@"weChatLoginOpen%@", [LMTool applicationCurrentVersion]];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:open forKey:keyStr];
    [userDefaults synchronize];
}
//获取 微信登录、分享是否打开
+(BOOL )getWeChatLoginOpen {
    NSString* keyStr = [NSString stringWithFormat:@"weChatLoginOpen%@", [LMTool applicationCurrentVersion]];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:keyStr];
}

//归档 广告开关
+(BOOL )archiveAdvertisementSwitchData:(NSData* )adData {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"adSwitch"];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    BOOL result = [adData writeToFile:filePath atomically:YES];
    return result;
}

//反归档 广告开关
+(NSData* )unArchiveAdvertisementSwitchData {
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    NSString* fileName = [NSString stringWithFormat:@"%@%@", appDelegate.userId, @"adSwitch"];
    NSString* filePath = [LMTool getUserFilePath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    NSData* data = [[NSData alloc]initWithContentsOfFile:filePath];
    return data;
}




//是否显示所有的用户指引
+(BOOL )shouldShowAllUserInstructionsView {
    NSString* keyStr = @"allUserInstructionsView";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:keyStr];
}
//设置不显示所有的用户指引
+(void)updateSetShowAllUserInstructionsView {
    NSString* keyStr = @"allUserInstructionsView";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}

//是否显示书架页指引
+(BOOL )shouldShowBookShelfUserInstructionsView {
    if ([LMTool shouldShowAllUserInstructionsView]) {
        NSString* keyStr = @"bookShelfUserInstructionsView";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL didShow = [userDefaults boolForKey:keyStr];
        return !didShow;
    }
    return NO;
}
//已经显示过书架页指引
+(void)updateSetShowBookShelfUserInstructionsView {
    NSString* keyStr = @"bookShelfUserInstructionsView";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}

//是否显示书城页指引
+(BOOL )shouldShowBookStoreUserInstructionsView {
    if ([LMTool shouldShowAllUserInstructionsView]) {
        NSString* keyStr = @"bookStoreUserInstructionsView";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL didShow = [userDefaults boolForKey:keyStr];
        return !didShow;
    }
    return NO;
}
//已经显示过书城页指引
+(void)updateSetShowBookStoreUserInstructionsView {
    NSString* keyStr = @"bookStoreUserInstructionsView";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}

//是否显示搜索页指引
+(BOOL )shouldShowSearchUserInstructionsView {
    if ([LMTool shouldShowAllUserInstructionsView]) {
        NSString* keyStr = @"searchUserInstructionsView";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL didShow = [userDefaults boolForKey:keyStr];
        return !didShow;
    }
    return NO;
}
//已经显示过搜索页指引
+(void)updateSetShowSearchUserInstructionsView {
    NSString* keyStr = @"searchUserInstructionsView";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}

//是否显示阅读页指引
+(BOOL )shouldShowReaderUserInstructionsView {
    if ([LMTool shouldShowAllUserInstructionsView]) {
        NSString* keyStr = @"readerUserInstructionsView";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL didShow = [userDefaults boolForKey:keyStr];
        return !didShow;
    }
    return NO;
}
//已经显示过阅读页指引
+(void)updateSetShowReaderUserInstructionsView {
    NSString* keyStr = @"readerUserInstructionsView";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}
//是否显示阅读页指引1
+(BOOL )shouldShowReaderUserInstructionsView1 {
    if ([LMTool shouldShowReaderUserInstructionsView]) {
        NSString* keyStr = @"readerUserInstructionsView1";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL didShow = [userDefaults boolForKey:keyStr];
        return !didShow;
    }
    return NO;
}
//已经显示过阅读页指引1
+(void)updateSetShowReaderUserInstructionsView1 {
    NSString* keyStr = @"readerUserInstructionsView1";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}
//是否显示阅读页指引2
+(BOOL )shouldShowReaderUserInstructionsView2 {
    if ([LMTool shouldShowReaderUserInstructionsView]) {
        NSString* keyStr = @"readerUserInstructionsView2";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL didShow = [userDefaults boolForKey:keyStr];
        return !didShow;
    }
    return NO;
}
//已经显示过阅读页指引2
+(void)updateSetShowReaderUserInstructionsView2 {
    NSString* keyStr = @"readerUserInstructionsView2";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}
//是否显示阅读页指引3
+(BOOL )shouldShowReaderUserInstructionsView3 {
    if ([LMTool shouldShowReaderUserInstructionsView]) {
        NSString* keyStr = @"readerUserInstructionsView3";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL didShow = [userDefaults boolForKey:keyStr];
        return !didShow;
    }
    return NO;
}
//已经显示过阅读页指引3
+(void)updateSetShowReaderUserInstructionsView3 {
    NSString* keyStr = @"readerUserInstructionsView3";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:keyStr];
    [userDefaults synchronize];
}



@end
