//
//  LMProfileCenterTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileCenterTableViewCell.h"

@implementation LMProfileCenterTableViewCell

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
    
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 50)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 10 * 2 - self.arrowIV.frame.size.width - 180, 0, 180, 50)];
        self.contentLab.font = [UIFont systemFontOfSize:16];
        self.contentLab.textAlignment = NSTextAlignmentRight;
        self.contentLab.textColor = [UIColor grayColor];
        [self.contentView insertSubview:self.contentLab belowSubview:self.lineView];
    }
    if (!self.contentIV) {
        self.contentIV = [[UIImageView alloc]initWithFrame:CGRectMake(screenWidth - 10 * 2 - 40 - self.arrowIV.frame.size.width, 5, 40, 40)];
        self.contentIV.layer.cornerRadius = 20;
        self.contentIV.layer.masksToBounds = YES;
        [self.contentView insertSubview:self.contentIV belowSubview:self.lineView];
    }
}

-(void)setupShowContentLabel:(BOOL)show {
    if (show) {
        self.contentLab.hidden = NO;
    }else {
        self.contentLab.hidden = YES;
    }
}

-(void)setupShowContentImageView:(BOOL)show {
    if (show) {
        self.contentIV.hidden = NO;
    }else {
        self.contentIV.hidden = YES;
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
