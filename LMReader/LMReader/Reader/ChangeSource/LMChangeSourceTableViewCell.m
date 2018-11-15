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
        self.stateLab = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 20 - 50, 25, 50, 20)];
        self.stateLab.textColor = THEMEORANGECOLOR;
        self.stateLab.font = [UIFont systemFontOfSize:12];
        self.stateLab.textAlignment = NSTextAlignmentRight;
        self.stateLab.text = @"当前选择";
        [self.contentView addSubview:self.stateLab];
        self.stateLab.hidden = YES;
    }
    if (!self.coverLab) {
        self.coverLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 40, 40)];
        self.coverLab.backgroundColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:1];
        self.coverLab.layer.cornerRadius = 20;
        self.coverLab.layer.masksToBounds = YES;
        self.coverLab.textAlignment = NSTextAlignmentCenter;
        self.coverLab.font = [UIFont systemFontOfSize:18];
        self.coverLab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.coverLab];
    }
    if (!self.sourceLab) {
        self.sourceLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverLab.frame.origin.x + self.coverLab.frame.size.width + 20, 10, 50, 25)];
        self.sourceLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.sourceLab];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.sourceLab.frame.origin.x, self.sourceLab.frame.origin.y + self.sourceLab.frame.size.height, 50, 25)];
        self.nameLab.font = [UIFont systemFontOfSize:15];
        self.nameLab.textColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1];
        [self.contentView addSubview:self.nameLab];
    }
}

-(void)setupSourceWithSource:(Source *)source nameStr:(NSString *)nameStr isClicked:(BOOL)isClicked {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.stateLab.hidden = YES;
    self.stateLab.frame = CGRectMake(screenRect.size.width - 20 - 50, 25, 50, 20);
    self.coverLab.backgroundColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:1];
    CGFloat maxNameLabWidth = screenRect.size.width - self.coverLab.frame.origin.x - self.coverLab.frame.size.width - 20 * 2;
    if (isClicked) {
        self.stateLab.hidden = NO;
        self.coverLab.backgroundColor = THEMEORANGECOLOR;
        maxNameLabWidth = self.stateLab.frame.origin.x - self.coverLab.frame.origin.x - self.coverLab.frame.size.width - 20 * 2;
    }
    if (source.name != nil && source.name.length > 0) {
        self.coverLab.text = [NSString stringWithFormat:@"%@", [source.name substringToIndex:1]];
    }else {
        self.coverLab.text = @"源";
    }
    self.sourceLab.text = source.name;
    self.sourceLab.frame = CGRectMake(self.coverLab.frame.origin.x + self.coverLab.frame.size.width + 20, 10, maxNameLabWidth, 25);
    
    if (nameStr != nil && ![nameStr isKindOfClass:[NSNull class]] && nameStr.length > 0) {
        self.nameLab.text = nameStr;
        self.nameLab.frame = CGRectMake(self.sourceLab.frame.origin.x, self.sourceLab.frame.origin.y + self.sourceLab.frame.size.height, self.sourceLab.frame.size.width, 25);
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
