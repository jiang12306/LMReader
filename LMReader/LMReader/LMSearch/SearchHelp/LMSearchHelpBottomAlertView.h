//
//  LMSearchHelpBottomAlertView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/23.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LMSearchHelpBottomAlertViewClickBlock) (BOOL didClick);

@interface LMSearchHelpBottomAlertView : LMBaseAlertView

@property (nonatomic, copy) LMSearchHelpBottomAlertViewClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
