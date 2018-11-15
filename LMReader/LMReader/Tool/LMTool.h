//
//  LMTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMReaderBook.h"

@interface LMTool : NSObject

//获取用户图书目录
+(NSString* )getBookRecordPath;

//是否第一次launch
+(BOOL )isFirstLaunch;

//删除启动次数
+(void)clearLaunchCount;

//启动次数+1
+(void)incrementLaunchCount;

//获取用户文件夹目录
+(NSString* )getUserFilePath;

//初始化第一次启动用户数据
+(void)initFirstLaunchData;

//获取 阅读界面 配置
+(void)getReaderConfig:(void (^) (CGFloat brightness, CGFloat fontSize, NSInteger bgInteger, CGFloat lineSpace, NSInteger lpIndex))block;
//修改阅读器 配置 亮度
+(void)changeReaderConfigWithBrightness:(CGFloat )brightness;
//修改阅读器 配置 字号
+(void)changeReaderConfigWithFontSize:(CGFloat )fontSize;
//修改阅读器 配置 背景
+(void)changeReaderConfigWithBackgroundInteger:(CGFloat )bgInteger;
//修改阅读器 配置 行间距
+(void)changeReaderConfigWithLineSpace:(CGFloat )lineSpace lineSpaceIndex:(NSInteger )lpIndex;

//设置是否允许推送
+(void)setupUserNotificatioinState:(BOOL )isAllowed;
//获取是否允许推送
+(BOOL )getUserNotificatioinState;

//获取系统设置中 夜间模式
+(BOOL )getSystemNightShift;
//更改系统设置中 夜间模式
+(void )changeSystemNightShift:(BOOL )nightShift;

//获取 系统设置 配置 自动加载下一章节
+(BOOL )getSystemAutoLoadNextChapterConfig;
//获取 系统设置 配置
+(void)getSystemSettingConfig:(void (^) (BOOL alert, BOOL download, BOOL loadNext))block;
//更改 系统设置 配置
+(void)changeSystemSettingWithAlert:(BOOL )alert download:(BOOL )download loadNext:(BOOL )loadNext;

//保存txt
+(BOOL )saveBookTextWithBookId:(UInt32 )bookId chapterId:(UInt32 )chapterId bookText:(NSString* )text;

//删除txt
+(BOOL )deleteBookTextWithBookId:(UInt32 )bookId chapterId:(UInt32 )chapterId;

//删除book
+(BOOL )deleteBookWithBookId:(UInt32 )bookId;
//book目录下的所有书本
+(NSArray* )queryAllBookDirectory;
//是否存在某本书的文件
+(BOOL )isExistBookDirectoryWithBookId:(UInt32 )bookId;
//获取书本所占内存大小 单位：MB
+(float )getBookFileSizeWithBookId:(UInt32 )bookId;
//是否存在txt
+(BOOL )isExistBookTextWithBookId:(UInt32 )bookId chapterId:(UInt32 )chapterId;
//取txt
+(NSString* )queryBookTextWithBookId:(UInt32 )bookId chapterId:(UInt32 )chapterId;

//新解析方式下 保存章节列表  拼上catalogList，用以区别旧解析方式下保存的NSData数据
+(BOOL )archiveNewParseBookCatalogListWithBookId:(UInt32 )bookId catalogList:(NSArray* )catalogList;
//新解析方式下 取章节列表
+(NSArray<LMReaderBookChapter* >* )unarchiveNewParseBookCatalogListWithBookId:(UInt32 )bookId;
//删除 图书目录
+(BOOL )deleteArchiveBookNewParseCatalogListWithBookId:(UInt32 )bookId;
//归档 保存图书目录
+(BOOL )archiveBookCatalogListWithBookId:(UInt32 )bookId catalogList:(NSData* )catalogList;
//反归档 取图书目录
+(NSData* )unArchiveBookCatalogListWithBookId:(UInt32 )bookId;
//删除 图书目录
+(BOOL )deleteArchiveBookCatalogListWithBookId:(UInt32 )bookId;

//归档 保存图书源列表最新章节
+(BOOL )archiveBookSourceWithBookId:(UInt32 )bookId sourceDic:(NSDictionary* )sourceDic;
//反归档 取图书源列表最新章节
+(NSDictionary* )unArchiveBookSourceDicWithBookId:(UInt32 )bookId;
//删除 图书源列表最新章节
+(BOOL )deleteArchiveBookSourceDicWithBookId:(UInt32 )bookId;

//归档 精选首页
+(BOOL )archiveChoiceData:(NSData* )choiceData;
//反归档 精选首页
+(NSData* )unArchiveChoiceData;
//删除 精选首页
+(BOOL )deleteChoiceData;

//存储 启动页 数据
+(BOOL )saveLaunchImageData:(NSData* )launchData;
//删 启动页 数据
+(BOOL )deleteLaunchImageData;
//取 启动页 数据
+(NSData* )queryLaunchImageData;
//存 启动页 上次角标
+(void )saveLastLaunchImageIndex:(NSInteger )index;
//取 启动页 上次角标
+(NSInteger )queryLastLaunchImageIndex;
//删 启动页 上次角标
+(void )deleteLastLaunchImageIndex;

//获取当前userId
+(NSString* )getAppUserId;

//首次进入app选择性别之后 保存性别
+(void)saveFirstLaunchGenderType:(GenderType )genderType;
//删除首次进入app时选择的性别
+(void)deleteFirstLaunchGenderType;
//获取首次进入app时选择的性别
+(GenderType )getFirstLaunchGenderType;

//将设备号与用户绑定
+(void)bindDeviceToUser:(LoginedRegUser* )loginUser;

//保存用户信息
+(void)saveLoginedRegUser:(LoginedRegUser* )loginedUser;

//删除用户信息
+(BOOL )deleteLoginedRegUser;

//获取用户信息
+(LoginedRegUser* )getLoginedRegUser;

//刘海屏 适配navigationBar和tabBar
+(BOOL )isBangsScreen;

//uuid
+(NSString* )uuid;

//当前APP版本号（1.0.1）
+(NSString* )applicationCurrentVersion;

//系统版本
+(float )systemVersionFloat;

//设备机型 4、4s,5、5c、5s,6、7、8,6p、7p、8p,x
+(NSString* )deviceType;

//protobuf device 设备信息
+(Device* )protobufDevice;

//将时间戳转换成时间
+(NSString* )convertTimeStampToTime:(UInt64 )timeStamp;

//将时间换成字符串
+(NSString* )convertTimeStringToTime:(NSString* )timeStr;

//将时间转换成时间字符串
+(NSString* )convertDateToTime:(NSDate* )date;

//将日期转换成小时
+(NSInteger )convertDateToHourTime:(NSDate* )date;

//将日期转换成天
+(NSInteger )convertTimeStampToDayTime:(NSInteger )timeStamp;

//MD5加密, 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str;

//10位时间戳，到秒
+(UInt32 )get10NumbersTimeStamp;

//url编码
+(NSString* )encodeURLString:(NSString* )urlStr;

//HTML解析，将后台返回的解析数组转成node字符串
+(NSString* )convertToHTMLStringWithListArray:(NSArray* )listArray;

//将br段落符天换成换行符\n
+(NSString* )replaceBrCharacterWithReturnCharacter:(NSString* )originalStr;

//过滤掉无用文本
+(NSString* )filterUselessStringWithText:(NSString* )originalStr filterArr:(NSArray* )filterArr;

//将多个换行替换成一个换行
+(NSString* )replaceSeveralNewLineWithOneNewLineWithText:(NSString* )originalStr;

//根据转码（如gbk）转换成utf-8
+(NSStringEncoding )convertEncodingStringWithEncoding:(NSString* )encoding;

//根据书籍hostUrl以及章节briefStr组合得到章节的具体章节url
+(NSString* )getChapterUrlStrWithHostUrlStr:(NSString* )urlStr briefStr:(NSString* )briefStr;

//保存 微信登录、分享是否打开
+(void)saveWeChatLoginOpen:(BOOL)open;
//获取 微信登录、分享是否打开
+(BOOL )getWeChatLoginOpen;

//归档 广告开关
+(BOOL )archiveAdvertisementSwitchData:(NSData* )adData;

//反归档 广告开关
+(NSData* )unArchiveAdvertisementSwitchData;

@end
