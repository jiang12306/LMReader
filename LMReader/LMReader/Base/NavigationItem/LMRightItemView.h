//
//  LMRightItemView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/15.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMRightItemViewBlock) (BOOL clicked);

@interface LMRightItemView : UIView

@property (nonatomic, copy) LMRightItemViewBlock callBlock;

@end
