//
//  LMBookShelfBottomOperationTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfBottomOperationTableViewCell.h"

@implementation LMBookShelfBottomOperationTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.iconIV) {
        self.iconIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, (self.frame.size.height - 22) / 2, 22, 22)];
        [self.contentView addSubview:self.iconIV];
    }
    if (!self.titleLab) {
        self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(self.iconIV.frame.origin.x + self.iconIV.frame.size.width + 10, 0, 250, self.frame.size.height)];
        self.titleLab.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:self.titleLab];
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconIV.frame = CGRectMake(20, (self.frame.size.height - 22) / 2, 22, 22);
    self.titleLab.frame = CGRectMake(self.iconIV.frame.origin.x + self.iconIV.frame.size.width + 10, 0, 250, self.frame.size.height);
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
