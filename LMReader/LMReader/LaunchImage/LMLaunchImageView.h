//
//  LMLaunchImageView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/4/4.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMLaunchImageBlock) (BOOL isOver, NSString* openUrlStr);

@interface LMLaunchImageView : UIView

@property (nonatomic, copy) LMLaunchImageBlock callBlock;

@end
