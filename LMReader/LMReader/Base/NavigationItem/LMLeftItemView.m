//
//  LMLeftItemView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/15.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMLeftItemView.h"

@implementation LMLeftItemView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton* leftItemButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        leftItemButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [leftItemButton setTitle:APPNAME forState:UIControlStateNormal];
        [leftItemButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:leftItemButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
