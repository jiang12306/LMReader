//
//  LMProfileTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileTableViewCell.h"

@interface LMProfileTableViewCell ()

@end

@implementation LMProfileTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, (60 - 28) / 2, 28, 28)];
        self.coverIV.contentMode = UIViewContentModeScaleAspectFill;
        self.coverIV.clipsToBounds = YES;
        [self.contentView insertSubview:self.coverIV belowSubview:self.lineView];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 20, 0, 200, 60)];
        self.nameLab.font = [UIFont systemFontOfSize:15.f];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
    if (!self.markLab) {
        self.markLab = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 20 - 35, 0, 35, 60)];
        self.markLab.font = [UIFont systemFontOfSize:15];
        self.markLab.textColor = [UIColor colorWithRed:60.f/255 green:60.f/255 blue:60.f/255 alpha:1];
        self.markLab.textAlignment = NSTextAlignmentRight;
        self.markLab.text = @"夜间";
        [self.contentView addSubview:self.markLab];
        self.markLab.hidden = YES;
    }
    if (!self.markIV) {
        self.markIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.markLab.frame.origin.x - 20, 22.5, 15, 15)];
        self.markIV.image = [UIImage imageNamed:@"systemSetting_Night"];
        [self.contentView addSubview:self.markIV];
        self.markIV.hidden = YES;
    }
}

-(void)setupShowArrowIV:(BOOL)showArrow showMarkLabel:(BOOL)showMarkLab showMarkIV:(BOOL)showMarkIV {
    if (showArrow) {
        self.arrowIV.hidden = NO;
    }else {
        self.arrowIV.hidden = YES;
    }
    if (showMarkLab) {
        self.markLab.hidden = NO;
    }else {
        self.markLab.hidden = YES;
    }
    if (showMarkIV) {
        self.markIV.hidden = NO;
    }else {
        self.markIV.hidden = YES;
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
