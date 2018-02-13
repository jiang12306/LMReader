//
//  LMNetworkTool.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LMNetworkToolSuccessBlock) (NSData* successData);
typedef void (^LMNetworkToolFailueBlock) (NSError* failureError);

@interface LMNetworkTool : NSObject

+(instancetype )sharedNetworkTool;

-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock;

@end
