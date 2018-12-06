//
//  LMBookShelfLastestReadBook.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMBookShelfLastestReadBook : NSObject

@property (nonatomic, assign) UInt32 bookId;
@property (nonatomic, copy) NSString* coverUrlStr;
@property (nonatomic, copy) NSString* bookName;
@property (nonatomic, copy) NSString* readProgress;

@end

NS_ASSUME_NONNULL_END
