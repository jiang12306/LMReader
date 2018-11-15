//
//  LMSourceTitleView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/23.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"
#import "LMContentViewController.h"

typedef void (^LMSourceTitleViewBlock) (BOOL didClick);

@interface LMSourceTitleView : LMBaseAlertView

@property (nonatomic, copy) LMSourceTitleViewBlock callBlock;
@property (nonatomic, copy) NSString* alertText;

-(void)startShow;
-(void)startHide;
-(void)reloadSourceTitleViewWithModel:(LMReadModel )currentModel;/**<更换字体颜色*/

@end
