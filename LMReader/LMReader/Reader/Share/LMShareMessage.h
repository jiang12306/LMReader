//
//  LMShareMessage.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/6.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

@interface LMShareMessage : NSObject <QQApiInterfaceDelegate, TencentSessionDelegate>

//
-(void)qqHandleOpenURL:(NSURL* )url delegate:(id<QQApiInterfaceDelegate> ) delegate;

+(void)shareToWeChatWithTitle:(NSString* )titleStr description:(NSString* )descriptionStr urlStr:(NSString* )urlStr isMoment:(BOOL )isMoment img:(UIImage* )img;

+(void)shareToQQWithTitle:(NSString* )titleStr description:(NSString* )descriptionStr urlStr:(NSString* )urlStr isZone:(BOOL )isZone imgStr:(NSString* )imgStr;

@end
