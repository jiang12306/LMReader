//
//  LMSearchBarView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/13.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchBarView.h"

@interface LMSearchBarView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField* searchTF;

@end

@implementation LMSearchBarView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.searchTF = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.searchTF.placeholder = @"搜索小说";
        self.searchTF.layer.borderColor = [UIColor whiteColor].CGColor;
        self.searchTF.layer.borderWidth = 1;
        self.searchTF.layer.cornerRadius = 5;
        self.searchTF.layer.masksToBounds = YES;
        self.searchTF.keyboardType = UIKeyboardTypeWebSearch;
        self.searchTF.delegate = self;
        [self addSubview:self.searchTF];
    }
    return self;
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString* str = [self.searchTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (str.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarViewDidStartSearch:)]) {
            [self.delegate searchBarViewDidStartSearch:str];
        }
    }
    self.searchTF.text = nil;
    [self.searchTF resignFirstResponder];
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
