//
//  LMCatalogTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/9.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMCatalogTableViewCell.h"

@implementation LMCatalogTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupContentViews];
    }
    return self;
}

-(void)setupContentViews {
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 200, 60)];
        self.nameLab.font = [UIFont systemFontOfSize:15];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.nameLab.textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
}

-(void)setContentWithNameStr:(NSString *)nameStr isClicked:(BOOL )isClicked {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (isClicked) {
        self.nameLab.textColor = UIColorFromRGB(0xcd9321);
    }else {
        self.nameLab.textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
    }
    if (nameStr != nil && nameStr.length > 0) {
        self.nameLab.text = nameStr;
    }else {
        self.nameLab.text = @"暂无该章节名称";
    }
    CGSize tempLabSize = [self.nameLab sizeThatFits:CGSizeMake(screenRect.size.width - 20 * 2, 9999)];
    if (tempLabSize.height < 20) {
        tempLabSize.height = 20;
    }
    self.nameLab.frame = CGRectMake(20, 0, screenRect.size.width - 20 * 2, tempLabSize.height + 20 * 2);
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
