//
//  LMReaderBook.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/12.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMReaderBookPage : NSObject

@property (nonatomic, copy) NSString* text;
@property (nonatomic, assign) NSInteger startLocation;/**<开始偏移位置*/
@property (nonatomic, assign) NSInteger endLocation;/**<结束偏移位置*/

@property (nonatomic, assign) BOOL showAd;//是否展示广告
@property (nonatomic, assign) NSInteger adType;//广告类型：1.章节末内嵌类型；2.章节w末单独一个广告
@property (nonatomic, assign) NSInteger adFromWhich;//广告来源：0.腾讯广告；1.自家广告；2.百度广告

@end


@interface LMReaderBookChapter : NSObject

//从Chapter转换过来的属性
@property (nonatomic, copy) NSArray<SourceLastChapter* >* sourcesArr;/**<旧解析方式中 章节源数组*/
@property (nonatomic, assign) UInt64 updateTime;
@property (nonatomic, assign) NSInteger chapterNo;
@property (nonatomic, assign) NSInteger chapterId;
@property (nonatomic, assign) NSInteger sourceId;/**<*/
@property (nonatomic, copy) NSString* title;/**<章节标题*/

@property (nonatomic, copy) NSString* content;/**<章节内容*/
@property (nonatomic, copy) NSArray<LMReaderBookPage* >* pagesArr;/**<章节页数*/
@property (nonatomic, assign) NSInteger currentPage;/**<当前页数，从0开始*/
@property (nonatomic, assign) NSInteger pageChange;/**<翻页过程，当临时变量使用，从0开始*/
@property (nonatomic, assign) NSInteger offset;/**<阅读偏移量*/

@property (nonatomic, copy) NSString* url;/**<*/

/** 将Chapter转LMReaderBookChapter类型
 */
+(LMReaderBookChapter* )convertReaderBookChapterWithChapter:(Chapter* )chapter;

@end


@interface LMReaderBook : NSObject

@property (nonatomic, assign) NSInteger bookId;
@property (nonatomic, copy) NSString* bookName;
@property (nonatomic, copy) NSArray<LMReaderBookChapter* >* chaptersArr;/**<*/
@property (nonatomic, strong) LMReaderBookChapter* currentChapter;/**<*/
//@property (nonatomic, assign) CGFloat progress;/**<*/
@property (nonatomic, assign) BOOL isNew;/**<*/
@property (nonatomic, copy) NSArray<UrlReadParse* >* parseArr;/**<书本源及解析方法，用于换源*/
@property (nonatomic, assign) NSInteger currentParseIndex;/**<当前书本源 角标*/

@end
