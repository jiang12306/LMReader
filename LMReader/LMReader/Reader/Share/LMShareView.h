//
//  LMShareView.h
//  LMNews
//
//  Created by Jiang Kuan on 2018/6/5.
//  Copyright © 2018年 rongyao100. All rights reserved.
//

#import "LMBaseAlertView.h"

typedef enum {
    LMShareViewTypeWeChat = 1,//微信好友
    LMShareViewTypeWeChatMoment = 2,//微信朋友圈
    LMShareViewTypeQQ = 3,//QQ
    LMShareViewTypeQQZone = 4,//QQ空间
    LMShareViewTypeCopyLink = 5,//拷贝链接
}LMShareViewType;

typedef void (^LMShareViewClickBlock) (LMShareViewType shareType);

@interface LMShareView : LMBaseAlertView

@property (nonatomic, copy) LMShareViewClickBlock shareBlock;

-(void)startShow;

@end
