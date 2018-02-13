//
//  LMBaseArrowTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseArrowTableViewCell.h"

@implementation LMBaseArrowTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupArrowView];
    }
    return self;
}

-(void)setupArrowView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.arrowIV) {
        self.arrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(screenRect.size.width - 10 - 10, (self.frame.size.height - 20)/2, 10, 20)];
        UIImage* image = [UIImage imageNamed:@"cell_Arrow"];
        UIImage* tintImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.arrowIV setTintColor:[UIColor grayColor]];
        self.arrowIV.image = tintImage;
        [self.contentView addSubview:self.arrowIV];
    }
}

-(void)showArrowImageView:(BOOL)isShow {
    if (isShow) {
        self.arrowIV.hidden = NO;
    }else {
        self.arrowIV.hidden = YES;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.arrowIV.frame = CGRectMake(screenRect.size.width - 10 - 10, (self.frame.size.height - 20)/2, 10, 20);
    [self bringSubviewToFront:self.arrowIV];
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
