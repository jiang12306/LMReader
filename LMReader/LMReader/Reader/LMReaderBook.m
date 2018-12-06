//
//  LMReaderBook.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/12.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderBook.h"


@implementation LMReaderBookPage

@end


@implementation LMReaderBookChapter

+(LMReaderBookChapter *)convertReaderBookChapterWithChapter:(Chapter *)chapter {
    LMReaderBookChapter* bookChapter = [[LMReaderBookChapter alloc]init];
    bookChapter.updateTime = chapter.updatedAt;
    bookChapter.chapterNo = chapter.chapterNo;
    bookChapter.chapterId = [NSString stringWithFormat:@"%d", chapter.id];
    bookChapter.title = chapter.chapterTitle;
    bookChapter.sourceId = chapter.source.id;
    return bookChapter;
}

@end



@implementation LMReaderBook

-(instancetype)init {
    self = [super init];
    if (self) {
        self.chaptersArr = [NSArray array];
    }
    return self;
}

@end
