//
//  LMChangeSourceTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/24.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMChangeSourceTableViewCell.h"

@implementation LMChangeSourceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupContentViews];
    }
    return self;
}

-(void)setupContentViews {
    if (!self.stateLab) {
        self.stateLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 5, 50)];
        self.stateLab.backgroundColor = [UIColor colorWithRed:250/255.f green:52/255.f blue:111/255.f alpha:1];
        [self.contentView addSubview:self.stateLab];
        self.stateLab.hidden = YES;
    }
    if (!self.coverLab) {
        self.coverLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        self.coverLab.backgroundColor = [UIColor colorWithRed:250/255.f green:52/255.f blue:111/255.f alpha:1];
        self.coverLab.layer.cornerRadius = 5;
        self.coverLab.layer.masksToBounds = YES;
        self.coverLab.textAlignment = NSTextAlignmentCenter;
        self.coverLab.numberOfLines = 2;
        self.coverLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.coverLab.font = [UIFont systemFontOfSize:20];
        self.coverLab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.coverLab];
    }
    if (!self.sourceLab) {
        self.sourceLab = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, 50, 30)];
        self.sourceLab.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:self.sourceLab];
    }
    if (!self.updateTimeLab) {
        self.updateTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, 50, 30)];
        self.updateTimeLab.font = [UIFont systemFontOfSize:14];
        self.updateTimeLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.updateTimeLab];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(70, 40, 150, 20)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        self.nameLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.nameLab];
    }
}

-(void)setupSourceWithSource:(Source *)source nameStr:(NSString *)nameStr timeStr:(NSString *)timeStr isClicked:(BOOL)isClicked {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.stateLab.hidden = YES;
    if (isClicked) {
        self.stateLab.hidden = NO;
    }
    self.coverLab.text = source.name;
    self.sourceLab.text = source.name;
    CGRect sourceFrame = self.sourceLab.frame;
    CGSize sourceSize = [self.sourceLab sizeThatFits:CGSizeMake(9999, sourceFrame.size.height)];
    if (sourceSize.width > screenRect.size.width - self.coverLab.frame.size.width - 10 * 3 - 20) {
        sourceSize.width = screenRect.size.width - self.coverLab.frame.size.width - 10 * 3 - 20;
    }
    self.sourceLab.frame = CGRectMake(70, 10, sourceSize.width, sourceFrame.size.height);
    
    self.updateTimeLab.hidden = NO;
    if (timeStr != nil && timeStr.length > 0) {
        self.updateTimeLab.text = timeStr;
        CGRect timeFrame = self.updateTimeLab.frame;
        CGSize timeSize = [self.updateTimeLab sizeThatFits:CGSizeMake(9999, timeFrame.size.height)];
        if (timeSize.width > screenRect.size.width - self.coverLab.frame.size.width - self.sourceLab.frame.size.width - 10 * 3 - 20) {
            timeSize.width = screenRect.size.width - self.coverLab.frame.size.width - self.sourceLab.frame.size.width - 10 * 3 - 20;
        }
        self.updateTimeLab.frame = CGRectMake(self.sourceLab.frame.origin.x + self.sourceLab.frame.size.width + 10, 10, timeSize.width, timeFrame.size.height);
        if (self.updateTimeLab.frame.origin.x > screenRect.size.width - 20 - 10) {
            self.updateTimeLab.hidden = YES;
        }
    }else {
        self.updateTimeLab.text = @"";
    }
    if (nameStr != nil && ![nameStr isKindOfClass:[NSNull class]] && nameStr.length > 0) {
        self.nameLab.text = nameStr;
        self.nameLab.frame = CGRectMake(70, 40, screenRect.size.width - 70 - 40, 20);
    }else {
        self.nameLab.text = @"";
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
