//
//  LMSystemSettingTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSystemSettingTableViewCell.h"

@implementation LMSystemSettingTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 200, 60)];
        self.nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width - 20 - 100, 0, 100, 60)];
        self.contentLab.font = [UIFont systemFontOfSize:15];
        self.contentLab.textAlignment = NSTextAlignmentRight;
        self.contentLab.textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
        [self.contentView insertSubview:self.contentLab belowSubview:self.lineView];
    }
    if (!self.contentSwitch) {
        self.contentSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(screenRect.size.width - 20 - 50, 15, 50, 30)];
        self.contentSwitch.onTintColor = THEMEORANGECOLOR;
        [self.contentSwitch addTarget:self action:@selector(clickedSwitch:) forControlEvents:UIControlEventValueChanged];
        [self.contentView insertSubview:self.contentSwitch belowSubview:self.lineView];
    }
}

-(void)clickedSwitch:(UISwitch* )sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickSwitch:systemSettingCell:)]) {
        [self.delegate didClickSwitch:sender.isOn systemSettingCell:self];
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
