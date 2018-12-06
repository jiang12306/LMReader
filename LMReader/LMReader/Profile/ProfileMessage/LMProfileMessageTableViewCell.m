//
//  LMProfileMessageTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/26.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMProfileMessageTableViewCell.h"

@implementation LMProfileMessageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupProfileMessageSubviews];
    }
    return self;
}

-(void)setupProfileMessageSubviews {
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.frame.size.width - 20 * 2, 20)];
        self.titleLab.font = [UIFont systemFontOfSize:15];
        self.titleLab.numberOfLines = 0;
        self.titleLab.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.titleLab];
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(20, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, self.frame.size.width - 20 * 2, 20)];
        self.briefLab.font = [UIFont systemFontOfSize:12];
        self.briefLab.numberOfLines = 0;
        self.briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.briefLab];
    }
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(20, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, self.frame.size.width - 20 * 2, 20)];
        self.timeLab.font = [UIFont systemFontOfSize:12];
        self.timeLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.timeLab];
    }
}

-(void)setupProfileMessageWithModel:(LMProfileMessageModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIColor* textColor = [UIColor blackColor];
    UIFont* textFont = [UIFont boldSystemFontOfSize:15];
    if (model.hasRead) {
        textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
        textFont = [UIFont systemFontOfSize:15];
    }
    self.titleLab.font = textFont;
    self.titleLab.textColor = textColor;
    self.briefLab.textColor = textColor;
    self.timeLab.textColor = textColor;
    
    self.titleLab.text = model.titleStr;
    self.titleLab.frame = CGRectMake(20, 20, screenWidth - 20 * 2, model.titleHeight);
    
    if (model.briefStr != nil && model.briefStr.length > 0) {
        self.briefLab.text = model.briefStr;
        self.briefLab.frame = CGRectMake(20, self.titleLab.frame.origin.y + self.titleLab.frame.size.height + 10, screenWidth - 20 * 2, model.briefHeight);
    }else {
        self.briefLab.text = @"";
        self.briefLab.frame = CGRectMake(20, self.titleLab.frame.origin.y + self.titleLab.frame.size.height, screenWidth - 20 * 2, 0);
    }
    
    self.timeLab.text = model.timeStr;
    self.timeLab.frame = CGRectMake(20, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, screenWidth - 20 * 2, 20);
}

@end
