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
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12.5, 25, 25)];
        self.coverIV.contentMode = UIViewContentModeScaleAspectFill;
        self.coverIV.clipsToBounds = YES;
        [self.contentView insertSubview:self.coverIV belowSubview:self.lineView];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 10, 0, 200, 50)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
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
