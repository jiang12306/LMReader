//
//  LMSearchAuthorTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/8/16.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchAuthorTableViewCell.h"

@implementation LMSearchAuthorTableViewCell

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
        self.coverIV.image = [[UIImage imageNamed:@"search_Author"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.coverIV.tintColor = THEMEORANGECOLOR;
        [self.contentView addSubview:self.coverIV];
    }
    if (!self.textLab) {
        self.textLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 10, 0, screenWidth - 10 * 2 - 20 * 3 - 35, 60)];
        self.textLab.font = [UIFont systemFontOfSize:15];
        self.textLab.numberOfLines = 1;
        self.textLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.textLab];
    }
    if (!self.markLab) {
        self.markLab = [[UILabel alloc]initWithFrame:CGRectMake(self.textLab.frame.origin.x + self.textLab.frame.size.width + 10, 20, 35, 20)];
        self.markLab.layer.cornerRadius = 1;
        self.markLab.layer.masksToBounds = YES;
        self.markLab.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
        self.markLab.font = [UIFont systemFontOfSize:12];
        self.markLab.textColor = THEMEORANGECOLOR;
        self.markLab.textAlignment = NSTextAlignmentCenter;
        self.markLab.text = @"作者";
        [self.contentView addSubview:self.markLab];
    }
}

-(void)setupWithAuthorString:(NSString* )authorStr {
    if (authorStr != nil && authorStr.length > 0) {
        self.markLab.hidden = NO;
        
        self.textLab.text = authorStr;
        CGRect originalTextFrame = self.textLab.frame;
        CGSize textSize = [self.textLab sizeThatFits:CGSizeMake(CGFLOAT_MAX, originalTextFrame.size.height)];
        self.textLab.frame = CGRectMake(originalTextFrame.origin.x, originalTextFrame.origin.y, textSize.width, originalTextFrame.size.height);
        CGRect originalMarkFrame = self.markLab.frame;
        self.markLab.frame = CGRectMake(self.textLab.frame.origin.x + self.textLab.frame.size.width + 10, originalMarkFrame.origin.y, originalMarkFrame.size.width, originalMarkFrame.size.height);
    }else {
        self.textLab.text = @"";
        self.markLab.hidden = YES;
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
