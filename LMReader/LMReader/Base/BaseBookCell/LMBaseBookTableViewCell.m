//
//  LMBaseBookTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/2.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseBookTableViewCell.h"
#import "UIImageView+WebCache.h"

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
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceMax, spaceMax, 55, 95 - spaceMax * 2)];
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
    }
    if (!self.type1Lab) {
        self.type1Lab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + spaceMin, 45, 20)];
        self.type1Lab.backgroundColor = [UIColor colorWithRed:31/255.f green:192/255.f blue:210/255.f alpha:1];
        self.type1Lab.textAlignment = NSTextAlignmentCenter;
        self.type1Lab.layer.cornerRadius = 3;
        self.type1Lab.layer.masksToBounds = YES;
        self.type1Lab.font = [UIFont systemFontOfSize:16];
        self.type1Lab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.type1Lab];
    }
    if (!self.type2Lab) {
        self.type2Lab = [[UILabel alloc]initWithFrame:CGRectMake(self.type1Lab.frame.origin.x + self.type1Lab.frame.size.width + spaceMin, self.type1Lab.frame.origin.y, self.type1Lab.frame.size.width, self.type1Lab.frame.size.height)];
        self.type2Lab.backgroundColor = [UIColor colorWithRed:184/255.f green:110/255.f blue:250/255.f alpha:1];
        self.type2Lab.textAlignment = NSTextAlignmentCenter;
        self.type2Lab.layer.cornerRadius = 3;
        self.type2Lab.layer.masksToBounds = YES;
        self.type2Lab.font = [UIFont systemFontOfSize:16];
        self.type2Lab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.type2Lab];
    }
    if (!self.type3Lab) {
        self.type3Lab = [[UILabel alloc]initWithFrame:CGRectMake(self.type2Lab.frame.origin.x + self.type2Lab.frame.size.width + spaceMin, self.type2Lab.frame.origin.y, self.type2Lab.frame.size.width, self.type2Lab.frame.size.height)];
        self.type3Lab.backgroundColor = [UIColor blueColor];
        self.type3Lab.textAlignment = NSTextAlignmentCenter;
        self.type3Lab.layer.cornerRadius = 3;
        self.type3Lab.layer.masksToBounds = YES;
        self.type3Lab.font = [UIFont systemFontOfSize:16];
        self.type3Lab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.type3Lab];
    }
    if (!self.readersLab) {
        self.readersLab = [[UILabel alloc]initWithFrame:CGRectMake(self.type3Lab.frame.origin.x + self.type3Lab.frame.size.width + spaceMin, self.type3Lab.frame.origin.y, 120, 20)];
        self.readersLab.backgroundColor = [UIColor whiteColor];
        self.readersLab.textAlignment = NSTextAlignmentCenter;
        self.readersLab.layer.cornerRadius = 3;
        self.readersLab.layer.masksToBounds = YES;
        self.readersLab.layer.borderColor = [UIColor redColor].CGColor;
        self.readersLab.layer.borderWidth = 1;
        self.readersLab.font = [UIFont systemFontOfSize:16];
        self.readersLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.readersLab];
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.readersLab.frame.origin.y + self.readersLab.frame.size.height + spaceMin, screenRect.size.width - self.coverIV.frame.size.width - spaceMax - spaceMin * 2, 20)];
        self.briefLab.font = [UIFont systemFontOfSize:16];
        self.briefLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.briefLab];
    }
}

-(void)setupContentBook:(Book* )book {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    NSURL* picUrl = [NSURL URLWithString:book.pic];
    [self.coverIV sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"firstLaunch1"] options:SDWebImageRefreshCached];
    
    self.nameLab.text = book.name;
    CGRect nameFrame = self.nameLab.frame;
    CGSize nameSize = [self.nameLab sizeThatFits:CGSizeMake(9999, nameFrame.size.height)];
    self.nameLab.frame = CGRectMake(nameFrame.origin.x, nameFrame.origin.y, nameSize.width, nameFrame.size.height);
    
    self.authorLab.text = [NSString stringWithFormat:@"作者：%@", book.author];
    CGRect authorFrame = self.authorLab.frame;
    CGSize authorSize = [self.authorLab sizeThatFits:CGSizeMake(9999, authorFrame.size.height)];
    self.authorLab.frame = CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + spaceMin, self.nameLab.frame.origin.y, authorSize.width, authorFrame.size.height);
    
    CGRect type1Frame = self.type1Lab.frame;
    CGRect type2Frame = self.type2Lab.frame;
    CGRect type3Frame = self.type3Lab.frame;
    CGRect readersFrame = self.readersLab.frame;
    
    NSArray* typeArr = book.bookType;
    
    if (typeArr.count == 1) {
        self.type1Lab.text = [typeArr objectAtIndex:0];
        CGSize type1Size = [self.type1Lab sizeThatFits:CGSizeMake(9999, type1Frame.size.height)];
        self.type1Lab.frame = CGRectMake(self.nameLab.frame.origin.x, type1Frame.origin.y, type1Size.width, type1Frame.size.height);
        
        self.type2Lab.frame = CGRectMake(self.type1Lab.frame.origin.x + self.type1Lab.frame.size.width, type2Frame.origin.y, 0, type2Frame.size.height);
        self.type3Lab.frame = CGRectMake(self.type2Lab.frame.origin.x + self.type2Lab.frame.size.width, type3Frame.origin.y, 0, type3Frame.size.height);
        
        readersFrame.origin.x = self.type1Lab.frame.origin.x + self.type1Lab.frame.size.width + spaceMin;
    }else if (typeArr.count == 2) {
        self.type1Lab.text = [typeArr objectAtIndex:0];
        CGSize type1Size = [self.type1Lab sizeThatFits:CGSizeMake(9999, type1Frame.size.height)];
        self.type1Lab.frame = CGRectMake(self.nameLab.frame.origin.x, type1Frame.origin.y, type1Size.width, type1Frame.size.height);
        
        self.type2Lab.text = [typeArr objectAtIndex:1];
        CGSize type2Size = [self.type2Lab sizeThatFits:CGSizeMake(9999, type2Frame.size.height)];
        self.type2Lab.frame = CGRectMake(self.type1Lab.frame.origin.x + self.type1Lab.frame.size.width + spaceMin, type2Frame.origin.y, type2Size.width, type2Frame.size.height);
        
        self.type3Lab.frame = CGRectMake(self.type2Lab.frame.origin.x + self.type2Lab.frame.size.width, type3Frame.origin.y, 0, type3Frame.size.height);
        
        readersFrame.origin.x = self.type2Lab.frame.origin.x + self.type2Lab.frame.size.width + spaceMin;
    }else if (typeArr.count >= 3) {
        self.type1Lab.text = [typeArr objectAtIndex:0];
        CGSize type1Size = [self.type1Lab sizeThatFits:CGSizeMake(9999, type1Frame.size.height)];
        self.type1Lab.frame = CGRectMake(self.nameLab.frame.origin.x, type1Frame.origin.y, type1Size.width, type1Frame.size.height);
        
        self.type2Lab.text = [typeArr objectAtIndex:1];
        CGSize type2Size = [self.type2Lab sizeThatFits:CGSizeMake(9999, type2Frame.size.height)];
        self.type2Lab.frame = CGRectMake(self.type1Lab.frame.origin.x + self.type1Lab.frame.size.width + spaceMin, type2Frame.origin.y, type2Size.width, type2Frame.size.height);
        
        self.type3Lab.text = [typeArr objectAtIndex:2];
        CGSize type3Size = [self.type3Lab sizeThatFits:CGSizeMake(9999, type3Frame.size.height)];
        self.type3Lab.frame = CGRectMake(self.type2Lab.frame.origin.x + self.type2Lab.frame.size.width + spaceMin, type3Frame.origin.y, type3Size.width, type3Frame.size.height);
        
        readersFrame.origin.x = self.type3Lab.frame.origin.x + self.type3Lab.frame.size.width + spaceMin;
    }else {
        self.type1Lab.frame = CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width, type1Frame.origin.y, 0, type1Frame.size.height);
        self.type2Lab.frame = CGRectMake(self.type1Lab.frame.origin.x, type2Frame.origin.y, 0, type2Frame.size.height);
        self.type3Lab.frame = CGRectMake(self.type2Lab.frame.origin.x, type3Frame.origin.y, 0, type3Frame.size.height);
        
        readersFrame.origin.x = self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceMin;
    }
    
    self.readersLab.text = [NSString stringWithFormat:@"%u人阅读", book.clicked];
    CGSize readersSize = [self.readersLab sizeThatFits:CGSizeMake(999, readersFrame.size.height)];
    self.readersLab.frame = CGRectMake(readersFrame.origin.x, readersFrame.origin.y, readersSize.width, readersSize.height);
    if (self.readersLab.frame.origin.x + self.readersLab.frame.size.width > screenRect.size.width) {
        self.readersLab.hidden = YES;
    }else {
        self.readersLab.hidden = NO;
    }
    
    self.briefLab.text = book.abstract;
    
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
