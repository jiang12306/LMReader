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

-(void)searchBarViewDidStartSearch:(NSString* )inputText;

@end;

@interface LMSearchBarView : UIView

@property (nonatomic, weak) id<LMSearchBarViewDelegate> delegate;

@end
