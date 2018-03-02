//
//  LMComboxView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LMComboxViewBlock) (NSInteger selectedIndex);

@interface LMComboxView : UIView

-(instancetype )initWithFrame:(CGRect )frame titleArr:(NSArray* )titleArr cellHeight:(CGFloat )cellHeight;

-(void)didSelectedIndex:(LMComboxViewBlock )callBlock;

@end
