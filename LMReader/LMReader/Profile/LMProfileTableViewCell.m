//
//  LMProfileTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileTableViewCell.h"

@interface LMProfileTableViewCell ()

@property (nonatomic, strong) UIImageView* arrowIV;//箭头

@end

@implementation LMProfileTableViewCell

static CGFloat spaceX = 10;

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
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(spaceX, spaceX, 200, 30)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.arrowIV) {
        self.arrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(screenRect.size.width - 10 - 15, spaceX, 15, 20)];
        self.arrowIV.image = [UIImage imageNamed:@"navigationItem_Back"];
        self.arrowIV.layer.borderWidth = 1;
        self.arrowIV.layer.borderColor = [UIColor grayColor].CGColor;
        [self.contentView addSubview:self.arrowIV];
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
