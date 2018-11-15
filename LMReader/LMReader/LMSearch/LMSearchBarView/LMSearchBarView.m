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

-(CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
        self.layer.cornerRadius = frame.size.height / 2.f;
        self.layer.masksToBounds = YES;
        
        self.searchTF = [[UITextField alloc]initWithFrame:CGRectMake(5, 0, frame.size.width - 5, frame.size.height)];
        self.searchTF.font = [UIFont systemFontOfSize:15];
        self.searchTF.placeholder = @"搜索小说和作者";
        self.searchTF.keyboardType = UIKeyboardTypeWebSearch;
        self.searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.searchTF.delegate = self;
        
        UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.height + 15, frame.size.height)];
        UIImageView* searchIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 3, leftView.frame.size.height - 3 * 2, leftView.frame.size.height - 3 * 2)];
        searchIV.tintColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
        UIImage* image = [UIImage imageNamed:@"rightItem_Search"];
        searchIV.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [leftView addSubview:searchIV];
        
        self.searchTF.leftViewMode = UITextFieldViewModeAlways;
        self.searchTF.leftView = leftView;
        [self addSubview:self.searchTF];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

-(void)becomeFirstResponse {
    [self.searchTF becomeFirstResponder];
}

-(void)resignFirstResponse {
    if ([self.searchTF isFirstResponder]) {
        [self.searchTF resignFirstResponder];
    }
}

-(void)startInputWithText:(NSString *)inputText shouldBecomeFirstResponse:(BOOL)response {
    if (response) {
        [self.searchTF becomeFirstResponder];
    }
    if (inputText != nil && ![inputText isKindOfClass:[NSNull class]] && inputText.length > 0) {
        self.searchTF.text = inputText;
    }
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarDidStartEditting:)]) {
        [self.delegate searchBarDidStartEditting:self.searchTF.text];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarDidStopEditting:)]) {
        [self.delegate searchBarDidStopEditting:self.searchTF.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarViewDidStartSearch:)]) {
            [self.delegate searchBarViewDidStartSearch:self.searchTF.text];
    }
    [self.searchTF resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange:(NSNotification* )notify {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarDidChangeText:)]) {
        [self.delegate searchBarDidChangeText:self.searchTF.text];
    }
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
