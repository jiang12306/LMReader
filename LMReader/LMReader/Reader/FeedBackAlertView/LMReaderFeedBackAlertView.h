//
//  LMReaderFeedBackAlertView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

@interface LMReaderFeedBackAlertViewModel : NSObject

@property (nonatomic, copy) NSString* alertString;
@property (nonatomic, assign) BOOL isSelected;

@end




typedef void (^LMReaderFeedBackAlertViewBlock) (BOOL submit, NSString* text);

@interface LMReaderFeedBackAlertView : LMBaseAlertView

-(void)startShow;

-(void)startHide;

@property (nonatomic, copy) LMReaderFeedBackAlertViewBlock submitBlock;


@end
