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
CGFloat spaceTop = 12.5;
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
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceMax, spaceTop, 70, baseBookCellHeight - spaceTop * 2)];
        self.coverIV.layer.borderColor = [UIColor colorWithRed:200.f / 255 green:200.f / 255 blue:200.f / 255 alpha:1].CGColor;
        self.coverIV.layer.borderWidth = 0.5;
        self.coverIV.layer.shadowColor = [UIColor grayColor].CGColor;
        self.coverIV.layer.shadowOffset = CGSizeMake(-5, 5);
        self.coverIV.layer.shadowOpacity = 0.4;
        [self.contentView insertSubview:self.coverIV belowSubview:self.lineView];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceMax, self.coverIV.frame.origin.y, screenRect.size.width - self.coverIV.frame.size.width - spaceMax * 3, 20)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.authorLab) {
        self.authorLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + spaceMin, self.nameLab.frame.size.width, 20)];
        self.authorLab.font = [UIFont systemFontOfSize:14];
        self.authorLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.authorLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.authorLab];
    }
    if (!self.typeLab) {
        self.typeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.authorLab.frame.origin.y + self.authorLab.frame.size.height + spaceMin, 45, 20)];
        self.typeLab.textAlignment = NSTextAlignmentCenter;
        self.typeLab.layer.cornerRadius = 3;
        self.typeLab.layer.masksToBounds = YES;
        self.typeLab.layer.borderColor = [UIColor colorWithRed:199.f/255 green:143.f/255 blue:37.f/255 alpha:1].CGColor;
        self.typeLab.layer.borderWidth = 1;
        self.typeLab.font = [UIFont systemFontOfSize:13];
        self.typeLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.typeLab];
    }
    if (!self.stateLab) {
        self.stateLab = [[UILabel alloc]initWithFrame:CGRectMake(self.typeLab.frame.origin.x + self.typeLab.frame.size.width + spaceMin, self.typeLab.frame.origin.y, self.typeLab.frame.size.width, self.typeLab.frame.size.height)];
        self.stateLab.textAlignment = NSTextAlignmentCenter;
        self.stateLab.layer.cornerRadius = 3;
        self.stateLab.layer.masksToBounds = YES;
        self.stateLab.layer.borderColor = [UIColor colorWithRed:199.f/255 green:143.f/255 blue:37.f/255 alpha:1].CGColor;
        self.stateLab.layer.borderWidth = 1;
        self.stateLab.font = [UIFont systemFontOfSize:13];
        self.stateLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.stateLab];
    }
    if (!self.readersLab) {
        self.readersLab = [[UILabel alloc]initWithFrame:CGRectMake(self.stateLab.frame.origin.x + self.stateLab.frame.size.width + spaceMin, self.stateLab.frame.origin.y, 120, 20)];
        self.readersLab.backgroundColor = [UIColor whiteColor];
        self.readersLab.textAlignment = NSTextAlignmentCenter;
        self.readersLab.layer.cornerRadius = 3;
        self.readersLab.layer.masksToBounds = YES;
        self.readersLab.layer.borderColor = [UIColor colorWithRed:195.f/255 green:26.f/255 blue:46.f/255 alpha:1].CGColor;
        self.readersLab.layer.borderWidth = 1;
        self.readersLab.font = [UIFont systemFontOfSize:13];
        self.readersLab.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.readersLab];
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.coverIV.frame.origin.y + self.coverIV.frame.size.height - 20, screenRect.size.width - self.coverIV.frame.size.width - spaceMax - spaceMin * 2, 20)];
        self.briefLab.font = [UIFont systemFontOfSize:13];
        self.briefLab.textColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
        [self.contentView addSubview:self.briefLab];
    }
}

-(void)setupContentBook:(Book* )book {
    NSString* picStr = [book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* picUrl = [NSURL URLWithString:picStr];
    [self.coverIV sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"defaultBookImage"] options:SDWebImageRefreshCached];
    
    self.nameLab.text = book.name;
    
    self.authorLab.text = [NSString stringWithFormat:@"作者：%@", book.author];
    
    CGRect typeFrame = self.typeLab.frame;
    
    NSArray* typeArr = book.bookType;
    self.typeLab.text = [typeArr objectAtIndex:0];
    CGSize typeSize = [self.typeLab sizeThatFits:CGSizeMake(9999, typeFrame.size.height)];
    self.typeLab.frame = CGRectMake(self.nameLab.frame.origin.x, typeFrame.origin.y, typeSize.width + spaceMin, typeFrame.size.height);
    
    NSString* stateStr = @"未知";
    BookState state = book.bookState;
    if (state == BookStateStateFinished) {
        stateStr = @"完结";
    }else if (state == BookStateStateUnknown) {
        stateStr = @"未知";
    }else if (state == BookStateStateWriting) {
        stateStr = @"连载中";
    }else if (state == BookStateStatePause) {
        stateStr = @"暂停";
    }
    self.stateLab.text = stateStr;
    CGRect stateFrame = self.stateLab.frame;
    CGSize stateSize = [self.stateLab sizeThatFits:CGSizeMake(9999, typeFrame.size.height)];
    self.stateLab.frame = CGRectMake(self.typeLab.frame.origin.x + self.typeLab.frame.size.width + spaceMin, stateFrame.origin.y, stateSize.width + spaceMin, stateFrame.size.height);
    
    NSString* readerStr = @"";
    if (book.clicked / 10000 > 0) {
        readerStr = [NSString stringWithFormat:@"%d万人阅读", book.clicked/10000];
    }else if (book.clicked / 1000 > 0) {
        readerStr = [NSString stringWithFormat:@"%d千人阅读", book.clicked/1000];
    }else {
        readerStr = [NSString stringWithFormat:@"%u人阅读", book.clicked];
    }
    self.readersLab.text = readerStr;
    CGRect readersFrame = self.readersLab.frame;
    readersFrame.origin.x = self.stateLab.frame.origin.x + self.stateLab.frame.size.width + spaceMin;
    CGSize readersSize = [self.readersLab sizeThatFits:CGSizeMake(999, readersFrame.size.height)];
    self.readersLab.frame = CGRectMake(readersFrame.origin.x, readersFrame.origin.y, readersSize.width + spaceMin, readersFrame.size.height);
    
    NSString* briefStr = @"暂无简介";
    if (book.abstract != nil && book.abstract.length > 0) {
        briefStr = book.abstract;
        briefStr = [briefStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    self.briefLab.text = briefStr;
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
