//
//  LMSearchTitleView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/24.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMSearchTitleView.h"

@implementation LMSearchTitleView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
        self.layer.cornerRadius = frame.size.height / 2.f;
        self.layer.masksToBounds = YES;
        
        UIImageView* searchIV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 3, frame.size.height - 3 * 2, frame.size.height - 3 * 2)];
        searchIV.tintColor = [UIColor colorWithRed:164.f/255 green:164.f/255 blue:164.f/255 alpha:1];
        UIImage* image = [UIImage imageNamed:@"rightItem_Search"];
        searchIV.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self addSubview:searchIV];
        
        UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(searchIV.frame.origin.x + searchIV.frame.size.width + 7, 0, 120, frame.size.height)];
        lab.font = [UIFont systemFontOfSize:18];
        lab.textColor = [UIColor colorWithRed:164.f/255 green:164.f/255 blue:164.f/255 alpha:1];
        lab.text = @"搜小说";
        [self addSubview:lab];
        
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

-(void)clickedButton:(UIButton* )sender {
    if (self.clickBlock) {
        self.clickBlock(YES);
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
