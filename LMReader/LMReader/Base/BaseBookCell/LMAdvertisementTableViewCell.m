//
//  LMAdvertisementTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMAdvertisementTableViewCell.h"

@interface LMAdvertisementTableViewCell ()

@property (nonatomic, strong) UILabel* adLab;//

@end

@implementation LMAdvertisementTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupAdvertisement];
    }
    return self;
}

-(void)setupAdvertisement {
    if (!self.adLab) {
        self.adLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 50)];
        self.adLab.font = [UIFont systemFontOfSize:20];
        [self.contentView addSubview:self.adLab];
        self.adLab.text = @"广告";
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
