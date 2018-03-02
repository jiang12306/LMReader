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
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 50)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 50)];
        self.contentLab.font = [UIFont systemFontOfSize:16];
        self.contentLab.textAlignment = NSTextAlignmentRight;
        self.contentLab.textColor = THEMECOLOR;
        [self.contentView insertSubview:self.contentLab belowSubview:self.lineView];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentLab.frame = CGRectMake(self.nameLab.frame.size.width + 10 * 2, 0, self.arrowIV.frame.origin.x - self.nameLab.frame.size.width - 10 * 3, 50);
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
