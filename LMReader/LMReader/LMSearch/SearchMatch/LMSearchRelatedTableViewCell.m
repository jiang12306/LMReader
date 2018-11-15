//
//  LMSearchRelatedTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchRelatedTableViewCell.h"

@implementation LMSearchRelatedTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTextLabel];
    }
    return self;
}

-(void)setupTextLabel {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 20, 20)];
        [self.contentView addSubview:self.coverIV];
    }
    if (!self.textLab) {
        self.textLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 10, 0, screenWidth - 20 * 3 - 10, 60)];
        self.textLab.font = [UIFont systemFontOfSize:18];
        self.textLab.numberOfLines = 1;
        self.textLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textLab.textColor = [UIColor colorWithRed:100 / 255.f green:100 / 255.f blue:100 / 255.f alpha:1];
        [self.contentView addSubview:self.textLab];
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
