//
//  LMBaseTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ftbook.pb.h"

@interface LMBaseTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView* lineView;

-(void)showLineView:(BOOL )isShow;

@end
