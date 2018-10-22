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
    
    if (!self.contentIV) {
        self.contentIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
        self.contentIV.image = [UIImage imageNamed:@"bookDetail_Catalog"];
        [self.contentView insertSubview:self.contentIV belowSubview:self.lineView];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.contentIV.frame.origin.x + self.contentIV.frame.size.width + 5, 0, 40, 50)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        self.nameLab.text = @"目录";
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + 5, 0, screenWidth - 20 - 10 * 4 - self.nameLab.frame.size.width - self.contentIV.frame.size.width, 50)];
        self.contentLab.font = [UIFont systemFontOfSize:16];
        self.contentLab.lineBreakMode = NSLineBreakByTruncatingTail;
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
