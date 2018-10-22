//
//  LMWindowLoadingView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

@interface LMWindowLoadingView : LMBaseAlertView

+(instancetype )sharedWindowLoadingView;

-(void)showWithAnimated:(BOOL )animated;
-(void)hideWithAnimated:(BOOL )animated;

@end
