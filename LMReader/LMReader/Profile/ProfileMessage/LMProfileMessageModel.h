//
//  LMProfileMessageModel.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/26.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMProfileMessageModel : NSObject

@property (nonatomic, assign) UInt32 msgId;
@property (nonatomic, copy) NSString* titleStr;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, copy) NSString* briefStr;
@property (nonatomic, assign) CGFloat briefHeight;
@property (nonatomic, copy) NSString* timeStr;

@property (nonatomic, assign) BOOL hasRead;
@property (nonatomic, assign) CGFloat cellHeight;

@end

NS_ASSUME_NONNULL_END
