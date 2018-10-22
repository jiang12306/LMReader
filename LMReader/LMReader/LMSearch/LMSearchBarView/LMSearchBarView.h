//
//  LMSearchBarView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/13.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMSearchBarView;

@protocol LMSearchBarViewDelegate <NSObject>

@optional
//作为输入框时
-(void)searchBarViewDidStartSearch:(NSString* )inputText;/**<点击“搜索”*/
-(void)searchBarDidStartEditting:(NSString* )inputText;/**<开始编辑*/
-(void)searchBarDidStopEditting:(NSString* )inputText;/**<停止编辑*/
-(void)searchBarDidChangeText:(NSString* )inputText;/**<输入框内容改变*/

@end;


@interface LMSearchBarView : UIView

@property (nonatomic, weak) id<LMSearchBarViewDelegate> delegate;

-(void)becomeFirstResponse;
-(void)resignFirstResponse;
-(void)startInputWithText:(NSString* )inputText shouldBecomeFirstResponse:(BOOL )response;

@end
