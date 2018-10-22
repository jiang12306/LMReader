//
//  LMShareMessage.m
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/6.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMShareMessage.h"

@implementation LMShareMessage

-(void)qqHandleOpenURL:(NSURL *)url delegate:(id<QQApiInterfaceDelegate>)delegate {
    [QQApiInterface handleOpenURL:url delegate:self];
}

#pragma mark -QQApiInterfaceDelegate
-(void)onResp:(QQBaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp* qqResp = (SendMessageToQQResp* )resp;
        if ([qqResp.result isEqualToString:@"0"]) {
            NSDictionary* infoDic = @{weChatShareKey : [NSNumber numberWithBool:YES]};
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatShareNotifyName object:nil userInfo:infoDic];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:weChatShareNotifyName object:nil userInfo:nil];
        }
    }
}


+(void)shareToWeChatWithTitle:(NSString* )titleStr description:(NSString* )descriptionStr urlStr:(NSString* )urlStr isMoment:(BOOL )isMoment img:(UIImage* )img {
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    if (isMoment) {
        req.scene = WXSceneTimeline;
    }else {
        req.scene = WXSceneSession;
    }
    WXMediaMessage* urlMessage = [WXMediaMessage message];
    urlMessage.title = titleStr;
    urlMessage.description = descriptionStr;
    [urlMessage setThumbImage:img];
    //创建多媒体对象
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = urlStr;//分享链接
    
    //完成发送对象实例
    urlMessage.mediaObject = webObj;
    req.message = urlMessage;
    
    //发送分享信息
    [WXApi sendReq:req];
}

+(void)shareToQQWithTitle:(NSString* )titleStr description:(NSString* )descriptionStr urlStr:(NSString* )urlStr isZone:(BOOL )isZone imgStr:(NSString* )imgStr {
    TencentOAuth* auth = [[TencentOAuth alloc]initWithAppId:qqAppId andDelegate:[LMShareMessage new]];
    NSLog(@"auth = %@", auth);
    
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:urlStr]
                                title:titleStr
                                description:descriptionStr
                                previewImageURL:[NSURL URLWithString:imgStr]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    if (!isZone) {//将内容分享到qq
        [QQApiInterface sendReq:req];
    }else {//将内容分享到qzone
        [QQApiInterface SendReqToQZone:req];
    }
}

@end
