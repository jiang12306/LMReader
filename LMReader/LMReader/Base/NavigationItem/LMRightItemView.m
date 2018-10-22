//
//  LMRightItemView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/15.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMRightItemView.h"

@implementation LMRightItemView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton* rightItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [rightItemBtn setImage:[UIImage imageNamed:@"rightItem_Search"] forState:UIControlStateNormal];
        [rightItemBtn setImageEdgeInsets:UIEdgeInsetsMake(9, 12, 10, 7)];
        [rightItemBtn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightItemBtn];
    }
    return self;
}

-(void)clickedButton:(UIButton* )sender {
    if (self.callBlock) {
        self.callBlock(YES);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
