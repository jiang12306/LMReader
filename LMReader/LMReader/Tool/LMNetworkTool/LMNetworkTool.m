//
//  LMNetworkTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMNetworkTool.h"
#import "AFNetworking.h"
#import "Ftbook.pb.h"
#import "LMTool.h"

@implementation LMNetworkTool

static LMNetworkTool *_sharedNetworkTool;
static dispatch_once_t onceToken;

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        if (_sharedNetworkTool == nil) {
            _sharedNetworkTool = [super allocWithZone:zone];
            
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        }
    });
    return _sharedNetworkTool;
}

-(id)copyWithZone:(NSZone *)zone {
    return _sharedNetworkTool;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedNetworkTool;
}

+(instancetype)sharedNetworkTool {
    return [[self alloc]init];
}



-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock {
    
    /*
    FtBookApiReqBuilder* apiBuilder = [FtBookApiReq builder];
    [apiBuilder setCmd:cmd];
    [apiBuilder setDevice:[LMTool protobufDevice]];
    [apiBuilder setBody:reqData];
    FtBookApiReq* apiReq = [apiBuilder build];
    NSData* bodyData = [apiReq data];
    
    NSString* urlString = @"http://book.tkmob.com/api/index";
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.f;
    [manager POST:urlString parameters:bodyData constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
    */
    
    
    
    
    
    
    FtBookApiReqBuilder* apiBuilder = [FtBookApiReq builder];
    [apiBuilder setCmd:cmd];
    [apiBuilder setDevice:[LMTool protobufDevice]];
    [apiBuilder setBody:reqData];
    FtBookApiReq* apiReq = [apiBuilder build];
    NSData* bodyData = [apiReq data];
    
    NSString* urlString = @"http://book.tkmob.com/api/index";
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:urlString];
    NSString *urlEnCode = [mutableUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *nsurl = [NSURL URLWithString:urlEnCode];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;//[postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failureBlock(error);
        } else {
//            NSLog(@"--------------data = %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            successBlock(data);
        }
    }];
    [dataTask resume];
    
}












@end
