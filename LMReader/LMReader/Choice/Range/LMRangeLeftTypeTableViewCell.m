//
//  LMRangeLeftTypeTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/2.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMRangeLeftTypeTableViewCell.h"

@implementation LMRangeLeftTypeTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.titleLab) {
            self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 55, 20)];
            self.titleLab.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:self.titleLab];
        }
    }
    return self;
}

-(void)setupClicked:(BOOL)clicked {
    if (clicked) {
        self.titleLab.textColor = THEMEORANGECOLOR;
        self.backgroundColor = [UIColor whiteColor];
    }else {
        self.titleLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.backgroundColor = [UIColor clearColor];
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
