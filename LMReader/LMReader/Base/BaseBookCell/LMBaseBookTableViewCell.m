//
//  LMBaseBookTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseBookTableViewCell.h"

@implementation LMBaseBookTableViewCell

CGFloat spaceMax = 10;
CGFloat spaceMin = 5;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceMax, spaceMin, 50, 100 - spaceMin * 2)];
        self.coverIV.image = [UIImage imageNamed:@"firstLaunch1"];
        [self.contentView insertSubview:self.coverIV belowSubview:self.lineView];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceMin, self.coverIV.frame.origin.y, 100, 20)];
        self.nameLab.font = [UIFont systemFontOfSize:20];
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.authorLab) {
        self.authorLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + spaceMin, self.nameLab.frame.origin.y, 140, 20)];
        self.authorLab.font = [UIFont systemFontOfSize:14];
        self.authorLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.authorLab];
        self.authorLab.text = @"作者：兰陵笑笑生";
    }
    if (!self.type1Lab) {
        self.type1Lab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + spaceMin, 45, 20)];
        self.type1Lab.backgroundColor = [UIColor greenColor];
        self.type1Lab.textAlignment = NSTextAlignmentCenter;
        self.type1Lab.layer.cornerRadius = 3;
        self.type1Lab.layer.masksToBounds = YES;
        self.type1Lab.font = [UIFont systemFontOfSize:18];
        self.type1Lab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.type1Lab];
        self.type1Lab.text = @"爱情";
    }
    if (!self.type2Lab) {
        self.type2Lab = [[UILabel alloc]initWithFrame:CGRectMake(self.type1Lab.frame.origin.x + self.type1Lab.frame.size.width + spaceMin, self.type1Lab.frame.origin.y, self.type1Lab.frame.size.width, self.type1Lab.frame.size.height)];
        self.type2Lab.backgroundColor = [UIColor yellowColor];
        self.type2Lab.textAlignment = NSTextAlignmentCenter;
        self.type2Lab.layer.cornerRadius = 3;
        self.type2Lab.layer.masksToBounds = YES;
        self.type2Lab.font = [UIFont systemFontOfSize:18];
        self.type2Lab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.type2Lab];
        self.type2Lab.text = @"玄幻";
    }
    if (!self.readersLab) {
        self.readersLab = [[UILabel alloc]initWithFrame:CGRectMake(self.type2Lab.frame.origin.x + self.type2Lab.frame.size.width + spaceMin, self.type2Lab.frame.origin.y, 120, 20)];
        self.readersLab.backgroundColor = [UIColor whiteColor];
        self.readersLab.textAlignment = NSTextAlignmentCenter;
        self.readersLab.layer.cornerRadius = 3;
        self.readersLab.layer.masksToBounds = YES;
        self.readersLab.layer.borderColor = [UIColor redColor].CGColor;
        self.readersLab.layer.borderWidth = 1;
        self.readersLab.font = [UIFont systemFontOfSize:18];
        self.readersLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.readersLab];
        self.readersLab.text = @"500万人阅读";
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.readersLab.frame.origin.y + self.readersLab.frame.size.height + spaceMin, screenRect.size.width - self.coverIV.frame.size.width - spaceMax - spaceMin * 2, 20)];
        self.briefLab.font = [UIFont systemFontOfSize:16];
        self.briefLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.briefLab];
        self.briefLab.text = @"什么鬼，乱七八糟的东西";
    }
}

-(void)setContentMode:(NSDictionary* )dic {
    
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
