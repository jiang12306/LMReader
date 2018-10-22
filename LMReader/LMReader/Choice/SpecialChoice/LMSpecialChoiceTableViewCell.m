//
//  LMSpecialChoiceTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/3.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSpecialChoiceTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMSpecialChoiceTableViewCell

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
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 10 * 2, 20)];
        self.titleLab.font = [UIFont boldSystemFontOfSize:16];
        self.titleLab.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView insertSubview:self.titleLab belowSubview:self.lineView];
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, self.titleLab.frame.size.width, 40)];
        self.briefLab.font = [UIFont systemFontOfSize:16];
        self.briefLab.numberOfLines = 0;
        self.briefLab.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView insertSubview:self.briefLab belowSubview:self.lineView];
    }
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, self.titleLab.frame.size.width, (screenWidth - 20) * 0.618)];
        self.coverIV.contentMode = UIViewContentModeScaleAspectFill;
        self.coverIV.layer.cornerRadius = 10;
        self.coverIV.layer.masksToBounds = YES;
//        self.coverIV.clipsToBounds = YES;
        [self.contentView addSubview:self.coverIV];
    }
}

-(void)setupSpecialChoiceModel:(LMSpecialChoiceModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    TopicChart* chart = model.topicChart;
    NSString* titleStr = chart.name;
    if (titleStr != nil && titleStr.length > 0) {
        self.titleLab.text = titleStr;
        self.titleLab.frame = CGRectMake(10, 10, screenWidth - 10 * 2, model.titleHeight);
    }else {
        self.titleLab.text = @"";
        self.titleLab.frame = CGRectMake(10, 0, screenWidth - 10 * 2, 0);
    }
    NSString* briefStr = chart.abstract;
    if (briefStr != nil && briefStr.length > 0) {
        self.briefLab.text = briefStr;
        self.briefLab.frame = CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, self.titleLab.frame.size.width, model.briefHeight);
    }else {
        self.briefLab.text = briefStr;
        self.briefLab.frame = CGRectMake(10, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, self.titleLab.frame.size.width, 0);
    }
    NSString* urlStr = [chart.converUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self.coverIV sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"defaultChoice"] options:SDWebImageRefreshCached];
    self.coverIV.frame = CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, self.titleLab.frame.size.width, (screenWidth - 20) * 0.618);
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
