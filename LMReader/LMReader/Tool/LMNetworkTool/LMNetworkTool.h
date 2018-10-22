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


static NSString* aboutUsHost = @"http://book.yeseshuguan.com/apk/about.htm";//关于我们 url
static NSString* copyrightHost = @"http://book.yeseshuguan.com/apk/cr.htm";//版权声明 url
static NSString* protocolHost = @"http://www.yeseshuguan.com/apk/sy.htm";//用户隐私协议 url


//static NSString* urlHost = @"http://book.tkmob.com/api/index";
static NSString* urlHost = @"http://book.yeseshuguan.com/api/index";

@interface LMNetworkTool : NSObject


+(instancetype )sharedNetworkTool;

//修改用户信息用，需传入user信息
-(void)postWithCmd:(UInt32 )cmd regUser:(LoginedRegUser* )regUser ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock;

-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock;

-(NSData* )postSyncWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData;

//网络异步请求，加时间限制
-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData limitTime:(NSTimeInterval )limitTime successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock;


//AFNetworking
-(void)AFNetworkPostWithURLString:(NSString* )urlStr successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock )failureBlock;

//AFNetworking postSync 放子线程用
-(void)AFNetworkPostSyncWithURLString:(NSString* )urlStr successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock )failureBlock;

@end
