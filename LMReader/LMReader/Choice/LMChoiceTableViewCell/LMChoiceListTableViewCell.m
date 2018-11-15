//
//  LMChoiceListTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/25.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMChoiceListTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMChoiceListTableViewCell


CGFloat aligmentSpace = 20;

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
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(aligmentSpace, aligmentSpace, 70, 70 * 1.25)];
        [self.contentView addSubview:self.coverIV];
    }
    if (!self.markIV) {
        self.markIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width - 50 + 4, self.coverIV.frame.origin.y - 4, 50, 50)];
        [self.contentView addSubview:self.markIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + aligmentSpace, self.coverIV.frame.origin.y, screenRect.size.width - self.coverIV.frame.size.width - aligmentSpace * 3, 20)];
        self.nameLab.font = [UIFont systemFontOfSize:15];
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + 20, self.nameLab.frame.size.width, 20)];
        self.briefLab.font = [UIFont systemFontOfSize:12];
        self.briefLab.numberOfLines = 0;
        self.briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.briefLab.textColor = [UIColor colorWithRed:165.f/255 green:165.f/255 blue:165.f/255 alpha:1];
        [self.contentView addSubview:self.briefLab];
    }
    if (!self.authorIV) {
        self.authorIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 20, 20, 20)];
        self.authorIV.image = [UIImage imageNamed:@"bookAuthor"];
        [self.contentView addSubview:self.authorIV];
    }
    if (!self.authorLab) {
        self.authorLab = [[UILabel alloc]initWithFrame:CGRectMake(self.authorIV.frame.origin.x + self.authorIV.frame.size.width, self.authorIV.frame.origin.y, 100, self.authorIV.frame.size.height)];
        self.authorLab.font = [UIFont systemFontOfSize:12];
        self.authorLab.numberOfLines = 0;
        self.authorLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.authorLab.textColor = [UIColor colorWithRed:165.f/255 green:165.f/255 blue:165.f/255 alpha:1];
        [self.contentView addSubview:self.authorLab];
    }
    if (!self.typeLab) {
        self.typeLab = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width - 50 - aligmentSpace, self.frame.size.height - 25 - aligmentSpace, 50, 25)];
        self.typeLab.backgroundColor = [UIColor colorWithRed:232.f/255 green:232.f/255 blue:232.f/255 alpha:1];
        self.typeLab.textAlignment = NSTextAlignmentCenter;
        self.typeLab.layer.cornerRadius = 2;
        self.typeLab.layer.masksToBounds = YES;
        self.typeLab.font = [UIFont systemFontOfSize:12];
        self.typeLab.textColor = THEMEORANGECOLOR;
        [self.contentView addSubview:self.typeLab];
    }
    if (!self.stateLab) {
        self.stateLab = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width - self.typeLab.frame.size.width - 10, self.typeLab.frame.origin.y, 50, self.typeLab.frame.size.height)];
        self.stateLab.backgroundColor = [UIColor colorWithRed:232.f/255 green:232.f/255 blue:232.f/255 alpha:1];
        self.stateLab.textAlignment = NSTextAlignmentCenter;
        self.stateLab.layer.cornerRadius = 2;
        self.stateLab.layer.masksToBounds = YES;
        self.stateLab.font = [UIFont systemFontOfSize:12];
        self.stateLab.textColor = THEMEORANGECOLOR;
        [self.contentView addSubview:self.stateLab];
    }
}

-(void)setupContentBook:(Book *)book cellHeight:(CGFloat)cellHeight ivWidth:(CGFloat )ivWidth nameFontSize:(CGFloat )nameFontSize briefFontSize:(CGFloat )briefFontSize {
    
    if (nameFontSize) {
        self.nameLab.font = [UIFont systemFontOfSize:nameFontSize];
    }
    if (briefFontSize) {
        self.briefLab.font = [UIFont systemFontOfSize:briefFontSize];
        self.authorLab.font = [UIFont systemFontOfSize:briefFontSize];
        self.typeLab.font = [UIFont systemFontOfSize:briefFontSize];
        self.stateLab.font = [UIFont systemFontOfSize:briefFontSize];
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    NSString* coverUrlStr = [book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.coverIV.frame = CGRectMake(aligmentSpace, aligmentSpace, ivWidth, cellHeight - aligmentSpace * 2);
    [self.coverIV sd_setImageWithURL:[NSURL URLWithString:coverUrlStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage"]];
    
    if ([book hasMarkUrl]) {
        self.markIV.hidden = NO;
        
        NSString* markUrlStr = [book.markUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        CGFloat markIVWidth = 50;
        CGFloat markTopSpace = 4;
        if ([UIScreen mainScreen].bounds.size.width <= 320) {
            markIVWidth = 40;
            markTopSpace = 3;
        }
        self.markIV.frame = CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width - markIVWidth + markTopSpace, self.coverIV.frame.origin.y - markTopSpace, markIVWidth, markIVWidth);
        
        UIImage* markImg = [[SDImageCache sharedImageCache] imageFromCacheForKey:markUrlStr];
        if (markImg != nil) {
            self.markIV.image = markImg;
        }else {
            [self.markIV sd_setImageWithURL:[NSURL URLWithString:markUrlStr] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error == nil && image != nil) {
                    
                }
            }];
        }
    }else {
        self.markIV.hidden = YES;
    }
    
    NSString* briefStr = @"暂无简介";
    if (book.abstract != nil && book.abstract.length > 0) {
        briefStr = book.abstract;
        briefStr = [briefStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    self.briefLab.text = briefStr;
    CGSize briefLabSize = [self.briefLab sizeThatFits:CGSizeMake(screenRect.size.width - ivWidth - aligmentSpace * 3, 9999)];
    if (briefLabSize.height > self.briefLab.font.lineHeight * 3) {
        briefLabSize.height = self.briefLab.font.lineHeight * 3;
    }
    self.briefLab.frame = CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + aligmentSpace, self.coverIV.frame.origin.y + (self.coverIV.frame.size.height - briefLabSize.height) / 2, briefLabSize.width, briefLabSize.height);
    
    self.nameLab.text = book.name;
    CGRect nameLabRect = CGRectMake(self.briefLab.frame.origin.x, self.coverIV.frame.origin.y, screenRect.size.width - ivWidth - aligmentSpace * 3, 25);
    if (self.briefLab.frame.origin.y - nameLabRect.size.height > nameLabRect.origin.y) {
        nameLabRect.origin.y = self.coverIV.frame.origin.y + (self.briefLab.frame.origin.y - nameLabRect.size.height - self.coverIV.frame.origin.y) / 2;
    }
    self.nameLab.frame = nameLabRect;
    
    NSArray* typeArr = book.bookType;
    self.typeLab.text = [typeArr objectAtIndex:0];
    CGSize typeLabSize = [self.typeLab sizeThatFits:CGSizeMake(9999, 25)];
    self.typeLab.frame = CGRectMake(screenRect.size.width - aligmentSpace - typeLabSize.width - 5, self.coverIV.frame.origin.y + self.coverIV.frame.size.height - 25, typeLabSize.width + 5, 25);
    
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
    CGSize stateSize = [self.stateLab sizeThatFits:CGSizeMake(9999, self.typeLab.frame.size.height)];
    self.stateLab.frame = CGRectMake(self.typeLab.frame.origin.x - 10 - stateSize.width - 5, self.typeLab.frame.origin.y, stateSize.width + 5, self.typeLab.frame.size.height);
    
    self.authorIV.frame = CGRectMake(self.briefLab.frame.origin.x, self.coverIV.frame.origin.y + self.coverIV.frame.size.height - 25 + 2.5, 15, 15);
    
    self.authorLab.text = book.author;
    self.authorLab.frame = CGRectMake(self.authorIV.frame.origin.x + self.authorIV.frame.size.width + 5, self.authorIV.frame.origin.y - 2.5, self.stateLab.frame.origin.x - self.authorIV.frame.origin.x - self.authorIV.frame.size.width - 5 - 10, 20);
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
