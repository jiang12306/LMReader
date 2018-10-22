//
//  LMComboxViewTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMComboxViewTableViewCell.h"

@implementation LMComboxViewTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1].CGColor;
        
        [self setupContentLab];
    }
    return self;
}

-(void)setupContentLab {
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width, 30)];
        self.contentLab.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.contentLab];
    }
    self.backgroundColor = [UIColor whiteColor];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentLab.frame = CGRectMake(10, 0, self.frame.size.width, 30);
}

-(void)setClicked:(BOOL)clicked {
    if (clicked) {
        self.backgroundColor = [UIColor colorWithRed:140.f/255 green:140.f/255 blue:140.f/255 alpha:1];
    }else {
        self.backgroundColor = [UIColor whiteColor];
    }
    _clicked = clicked;
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
