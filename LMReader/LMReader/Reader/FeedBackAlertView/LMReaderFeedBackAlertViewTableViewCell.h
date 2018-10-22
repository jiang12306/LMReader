//
//  LMReaderFeedBackAlertViewTableViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMReaderFeedBackAlertViewTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView* selectIV;
@property (nonatomic, strong) UILabel* textLab;

-(void)setupClicked:(BOOL )isClicked;

@end
