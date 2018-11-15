//
//  LMBookDetailTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/14.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookDetailTableViewCell.h"

@implementation LMBookDetailTableViewCell

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
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 50, 60)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nameLab.text = @"查看目录";
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
        CGSize nameLabSize = [self.nameLab sizeThatFits:CGSizeMake(9999, 60)];
        self.nameLab.frame = CGRectMake(20, 0, nameLabSize.width, 60);
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + 20, 0, screenWidth - self.nameLab.frame.origin.x - self.nameLab.frame.size.width - 20 * 3, 60)];
        self.contentLab.font = [UIFont systemFontOfSize:15];
        self.contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.contentLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        [self.contentView insertSubview:self.contentLab belowSubview:self.lineView];
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
