//
//  LMProfileBookCommentModel.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/6.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMProfileBookCommentModel : NSObject

@property (nonatomic, strong) CommentBook* commentBook;
@property (nonatomic, assign) NSInteger dayInteger;

@end

NS_ASSUME_NONNULL_END
