//
//  LMReaderFeedBackAlertViewTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/6.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderFeedBackAlertViewTableViewCell.h"

@implementation LMReaderFeedBackAlertViewTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.selectIV) {
        self.selectIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 20, 20)];
        self.selectIV.image = [UIImage imageNamed:@"feedBackAlertView_Normal"];
        [self.contentView addSubview:self.selectIV];
    }
    if (!self.textLab) {
        self.textLab = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 150, 40)];
        self.textLab.font = [UIFont systemFontOfSize:15];
        self.textLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
        [self.contentView addSubview:self.textLab];
    }
}

-(void)setupClicked:(BOOL)isClicked {
    UIImage* normalImg = [UIImage imageNamed:@"feedBackAlertView_Normal"];
    UIImage* selectedImg = [UIImage imageNamed:@"feedBackAlertView_Selected"];
    if (isClicked) {
        self.selectIV.image = selectedImg;
    }else {
        self.selectIV.image = normalImg;
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
