//
//  LMBaseTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseTableViewCell.h"

@implementation LMBaseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLineView];
    }
    return self;
}

-(void)setupLineView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.lineView) {
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, CGRectGetWidth(screenRect) - 10, 1)];
        self.lineView.backgroundColor = [UIColor colorWithRed:224/255.f green:224/255.f blue:224/255.f alpha:1];
        [self.contentView addSubview:self.lineView];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.lineView.frame = CGRectMake(10, self.frame.size.height - 1, CGRectGetWidth(screenRect) - 10, 1);
    [self bringSubviewToFront:self.lineView];
}

-(void)showLineView:(BOOL)isShow {
    if (isShow) {
        self.lineView.hidden = NO;
    }else {
        self.lineView.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
