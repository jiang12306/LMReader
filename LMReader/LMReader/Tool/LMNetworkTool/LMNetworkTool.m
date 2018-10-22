//
//  LMNetworkTool.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMNetworkTool.h"
#import "AFNetworking.h"
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

//修改用户信息用，需传入user信息
-(void)postWithCmd:(UInt32 )cmd regUser:(LoginedRegUser* )regUser ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock {
    
    GpsBuilder* gpsBuilder = [Gps builder];
    [gpsBuilder setCoordinateType:GpsCoordinateTypeWgs84];
    [gpsBuilder setLatitude:0];
    [gpsBuilder setLongitude:0];
    [gpsBuilder setTimestamp:[LMTool get10NumbersTimeStamp]];
    Gps* gps = [gpsBuilder build];
    
    FtBookApiReqBuilder* apiBuilder = [FtBookApiReq builder];
    [apiBuilder setCmd:cmd];
    [apiBuilder setDevice:[LMTool protobufDevice]];
    if (reqData != nil) {
        [apiBuilder setBody:reqData];
    }
    //GPS
    [apiBuilder setGps:gps];
    //LoginedRegUser
    if (regUser != nil) {
        [apiBuilder setLoginedUser:regUser];
    }else {
        LoginedRegUser* tempLogUser = [LMTool getLoginedRegUser];
        if (tempLogUser != nil && tempLogUser.token.length > 0) {
            [apiBuilder setLoginedUser:tempLogUser];
        }
    }
    [apiBuilder setVerName:[LMTool applicationCurrentVersion]];
    
    FtBookApiReq* apiReq = [apiBuilder build];
    NSData* bodyData = [apiReq data];
    
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@?cmd=%d", urlHost, cmd]];
    NSString *urlEnCode = [mutableUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *nsurl = [NSURL URLWithString:urlEnCode];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;//[postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        BOOL isError = NO;
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (error) {
            failureBlock(error);
        } else {
            NSError* tempErr = nil;
            if (responseStatusCode != 200) {
                isError = YES;
                NSDictionary *userInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"未知错误", NSLocalizedDescriptionKey, @"protobuf协议出错", NSLocalizedFailureReasonErrorKey,nil];
                tempErr = [[NSError alloc]initWithDomain:NSCocoaErrorDomain code:responseStatusCode userInfo:userInfoDic];
            }
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:data];
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                }
                
            } @catch (NSException *exception) {
                isError = YES;
                failureBlock(tempErr);
            } @finally {
                if (isError) {
                    failureBlock(tempErr);
                }else {
                    successBlock(data);
                }
            }
            
        }
    }];
    [dataTask resume];
}


-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock {
    
    GpsBuilder* gpsBuilder = [Gps builder];
    [gpsBuilder setCoordinateType:GpsCoordinateTypeWgs84];
    [gpsBuilder setLatitude:0];
    [gpsBuilder setLongitude:0];
    [gpsBuilder setTimestamp:[LMTool get10NumbersTimeStamp]];
    Gps* gps = [gpsBuilder build];
    
    FtBookApiReqBuilder* apiBuilder = [FtBookApiReq builder];
    [apiBuilder setCmd:cmd];
    [apiBuilder setDevice:[LMTool protobufDevice]];
    if (reqData != nil) {
        [apiBuilder setBody:reqData];
    }
    //GPS
    [apiBuilder setGps:gps];
    //LoginedRegUser
    LoginedRegUser* tempLogUser = [LMTool getLoginedRegUser];
    if (tempLogUser != nil && tempLogUser.token.length > 0) {
        [apiBuilder setLoginedUser:tempLogUser];
    }
    [apiBuilder setVerName:[LMTool applicationCurrentVersion]];
    
    FtBookApiReq* apiReq = [apiBuilder build];
    NSData* bodyData = [apiReq data];
    
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@?cmd=%d", urlHost, cmd]];
    NSString *urlEnCode = [mutableUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *nsurl = [NSURL URLWithString:urlEnCode];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;//[postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 15;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        BOOL isError = NO;
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (error) {
            failureBlock(error);
        } else {
            NSError* tempErr = nil;
            if (responseStatusCode != 200) {
                isError = YES;
                NSDictionary *userInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"未知错误", NSLocalizedDescriptionKey, @"protobuf协议出错", NSLocalizedFailureReasonErrorKey,nil];
                tempErr = [[NSError alloc]initWithDomain:NSCocoaErrorDomain code:responseStatusCode userInfo:userInfoDic];
            }
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:data];
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                }
                
            } @catch (NSException *exception) {
                isError = YES;
                failureBlock(tempErr);
            } @finally {
                if (isError) {
                    failureBlock(tempErr);
                }else {
                    successBlock(data);
                }
            }
            
        }
    }];
    [dataTask resume];
}

-(NSData* )postSyncWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData {
    GpsBuilder* gpsBuilder = [Gps builder];
    [gpsBuilder setCoordinateType:GpsCoordinateTypeWgs84];
    [gpsBuilder setLatitude:0];
    [gpsBuilder setLongitude:0];
    [gpsBuilder setTimestamp:[LMTool get10NumbersTimeStamp]];
    Gps* gps = [gpsBuilder build];
    
    FtBookApiReqBuilder* apiBuilder = [FtBookApiReq builder];
    [apiBuilder setCmd:cmd];
    [apiBuilder setDevice:[LMTool protobufDevice]];
    if (reqData != nil) {
        [apiBuilder setBody:reqData];
    }
    //GPS
    [apiBuilder setGps:gps];
    //LoginedRegUser
    LoginedRegUser* tempLogUser = [LMTool getLoginedRegUser];
    if (tempLogUser != nil && tempLogUser.token.length > 0) {
        [apiBuilder setLoginedUser:tempLogUser];
    }
    [apiBuilder setVerName:[LMTool applicationCurrentVersion]];
    
    FtBookApiReq* apiReq = [apiBuilder build];
    NSData* bodyData = [apiReq data];
    
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:urlHost];
    NSString *urlEnCode = [mutableUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *nsurl = [NSURL URLWithString:urlEnCode];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;//[postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        return nil;
    }else {
        return data;
    }
}


//网络异步请求，加时间限制
-(void)postWithCmd:(UInt32 )cmd ReqData:(NSData* )reqData limitTime:(NSTimeInterval )limitTime successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock)failureBlock {
    
    GpsBuilder* gpsBuilder = [Gps builder];
    [gpsBuilder setCoordinateType:GpsCoordinateTypeWgs84];
    [gpsBuilder setLatitude:0];
    [gpsBuilder setLongitude:0];
    [gpsBuilder setTimestamp:[LMTool get10NumbersTimeStamp]];
    Gps* gps = [gpsBuilder build];
    
    FtBookApiReqBuilder* apiBuilder = [FtBookApiReq builder];
    [apiBuilder setCmd:cmd];
    [apiBuilder setDevice:[LMTool protobufDevice]];
    if (reqData != nil) {
        [apiBuilder setBody:reqData];
    }
    //GPS
    [apiBuilder setGps:gps];
    //LoginedRegUser
    LoginedRegUser* tempLogUser = [LMTool getLoginedRegUser];
    if (tempLogUser != nil && tempLogUser.token.length > 0) {
        [apiBuilder setLoginedUser:tempLogUser];
    }
    [apiBuilder setVerName:[LMTool applicationCurrentVersion]];
    
    FtBookApiReq* apiReq = [apiBuilder build];
    NSData* bodyData = [apiReq data];
    
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@?cmd=%d", urlHost, cmd]];
    NSString *urlEnCode = [mutableUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *nsurl = [NSURL URLWithString:urlEnCode];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = bodyData;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (limitTime) {
        config.timeoutIntervalForRequest = limitTime;
    }else {
        config.timeoutIntervalForRequest = 15;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        BOOL isError = NO;
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (error) {
            failureBlock(error);
        } else {
            NSError* tempErr = nil;
            if (responseStatusCode != 200) {
                isError = YES;
                NSDictionary *userInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"未知错误", NSLocalizedDescriptionKey, @"protobuf协议出错", NSLocalizedFailureReasonErrorKey,nil];
                tempErr = [[NSError alloc]initWithDomain:NSCocoaErrorDomain code:responseStatusCode userInfo:userInfoDic];
            }
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:data];
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                }
                
            } @catch (NSException *exception) {
                isError = YES;
                failureBlock(tempErr);
            } @finally {
                if (isError) {
                    failureBlock(tempErr);
                }else {
                    successBlock(data);
                }
            }
            
        }
    }];
    [dataTask resume];
}



//AFNetworking
-(void)AFNetworkPostWithURLString:(NSString* )urlStr successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock )failureBlock {
    NSString* encodedStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:encodedStr]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil && data.length > 0) {
                successBlock(data);
            }else {
                failureBlock(nil);
            }
        });
    });
}

//AFNetworking postSync 放子线程用
-(void)AFNetworkPostSyncWithURLString:(NSString* )urlStr successBlock:(LMNetworkToolSuccessBlock)successBlock failureBlock:(LMNetworkToolFailueBlock )failureBlock {
    NSString *encodedStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:encodedStr]];
    if (data != nil && data.length > 0) {
        successBlock(data);
    }else {
        failureBlock(nil);
    }
}



@end
