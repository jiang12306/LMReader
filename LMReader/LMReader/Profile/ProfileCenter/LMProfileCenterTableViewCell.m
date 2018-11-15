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
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 65, 60)];
        self.nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + 20, 0, screenWidth - self.nameLab.frame.origin.x - self.nameLab.frame.size.width - 20 * 2, 60)];
        self.contentLab.font = [UIFont systemFontOfSize:15];
        self.contentLab.textColor = [UIColor colorWithRed:160.f/255 green:160.f/255 blue:160.f/255 alpha:1];
        [self.contentView insertSubview:self.contentLab belowSubview:self.lineView];
    }
}

-(void)setupShowContentLabel:(BOOL)show {
    if (show) {
        self.contentLab.hidden = NO;
    }else {
        self.contentLab.hidden = YES;
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
