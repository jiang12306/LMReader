//
//  LMSearchTitleView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/24.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMSearchTitleViewClickBlock) (BOOL didClick);

@interface LMSearchTitleView : UIView

@property (nonatomic, copy) LMSearchTitleViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
