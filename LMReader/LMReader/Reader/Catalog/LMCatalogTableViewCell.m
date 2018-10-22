//
//  LMCatalogTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/9.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMCatalogTableViewCell.h"

@implementation LMCatalogTableViewCell

static CGFloat cellHeight = 44;
static CGFloat spaceX = 10;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupContentViews];
    }
    return self;
}

-(void)setupContentViews {
    if (!self.numberLab) {
        self.numberLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, 0, 100, cellHeight)];
        self.numberLab.font = [UIFont systemFontOfSize:20];
        self.numberLab.textColor = [UIColor blackColor];
        [self.contentView insertSubview:self.numberLab belowSubview:self.lineView];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.numberLab.frame.origin.x + self.numberLab.frame.size.width + spaceX, 0, 200, cellHeight)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.nameLab.textColor = [UIColor grayColor];
        [self.contentView insertSubview:self.nameLab belowSubview:self.lineView];
    }
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + spaceX, 0, 150, 20)];
        self.timeLab.font = [UIFont systemFontOfSize:16];
        self.timeLab.textColor = [UIColor grayColor];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        [self.contentView insertSubview:self.timeLab belowSubview:self.lineView];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)setContentWithNumberStr:(NSString *)numberStr nameStr:(NSString *)nameStr timeStr:(NSString *)timeStr isClicked:(BOOL )isClicked {
    if (isClicked) {
        self.numberLab.textColor = UIColorFromRGB(0xcd9321);
        self.nameLab.textColor = UIColorFromRGB(0xcd9321);
        self.timeLab.textColor = UIColorFromRGB(0xcd9321);
    }else {
        self.numberLab.textColor = [UIColor blackColor];
        self.nameLab.textColor = [UIColor grayColor];
        self.timeLab.textColor = [UIColor grayColor];
    }
    if (numberStr != nil && numberStr.length > 0) {
        self.numberLab.text = numberStr;
        CGRect numberFrame = self.numberLab.frame;
        CGSize numberSize = [self.numberLab sizeThatFits:CGSizeMake(9999, numberFrame.size.height)];
        self.numberLab.frame = CGRectMake(spaceX, 0, numberSize.width, cellHeight);
    }else {
        self.numberLab.text = @"";
        self.numberLab.frame = CGRectMake(spaceX, 0, 0, cellHeight);
    }
    if (timeStr != nil && timeStr.length > 0) {
        self.timeLab.text = timeStr;
        CGRect timeFrame = self.timeLab.frame;
        CGSize timeSize = [self.timeLab sizeThatFits:CGSizeMake(9999, timeFrame.size.height)];
        self.timeLab.frame = CGRectMake(self.arrowIV.frame.origin.x - timeSize.width - spaceX, 0, timeSize.width, cellHeight);
    }else {
        self.timeLab.text = @"";
        self.timeLab.frame = CGRectMake(self.arrowIV.frame.origin.x - spaceX, 0, 0, cellHeight);
    }
    if (nameStr != nil && nameStr.length > 0) {
        self.nameLab.text = nameStr;
        self.nameLab.frame = CGRectMake(self.numberLab.frame.origin.x + self.numberLab.frame.size.width + spaceX, 0, self.arrowIV.frame.origin.x - self.timeLab.frame.size.width - self.numberLab.frame.origin.x - self.numberLab.frame.size.width - spaceX*4, cellHeight);
    }else {
        self.nameLab.text = @"";
        self.nameLab.frame = CGRectMake(self.numberLab.frame.origin.x + self.numberLab.frame.size.width + spaceX, 0, 0, cellHeight);
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
