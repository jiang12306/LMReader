//
//  LMReaderRecommandCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/12/3.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMReaderRecommandCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMReaderRecommandCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width - 5 * 2, self.frame.size.height - 5 - 10 * 2 - 50 - 20)];
        self.coverIV.contentMode = UIViewContentModeScaleAspectFill;
        self.coverIV.clipsToBounds = YES;
        [self.contentView addSubview:self.coverIV];
    }
    if (!self.markIV) {
        self.markIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width - 50 + 4, self.coverIV.frame.origin.y - 4, 50, 50)];
        [self.contentView addSubview:self.markIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(5, self.coverIV.frame.origin.y + self.coverIV.frame.size.height + 10, self.frame.size.width - 5 * 2, 50)];
        self.nameLab.font = [UIFont systemFontOfSize:15];
        self.nameLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.authorIV) {
        self.authorIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + 10, 20, 20)];
        self.authorIV.image = [UIImage imageNamed:@"bookAuthor"];
        [self.contentView addSubview:self.authorIV];
    }
    if (!self.authorLab) {
        self.authorLab = [[UILabel alloc]initWithFrame:CGRectMake(self.authorIV.frame.origin.x + self.authorIV.frame.size.width + 5, self.authorIV.frame.origin.y, 100, self.authorIV.frame.size.height)];
        self.authorLab.font = [UIFont systemFontOfSize:12];
        self.authorLab.numberOfLines = 0;
        self.authorLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.authorLab.textColor = [UIColor colorWithRed:165.f/255 green:165.f/255 blue:165.f/255 alpha:1];
        [self.contentView addSubview:self.authorLab];
    }
}

-(void)setupWithBook:(Book *)book ivWidth:(CGFloat)ivWidth ivHeight:(CGFloat)ivHeight itemWidth:(CGFloat)itemWidth itemHeight:(CGFloat)itemHeight nameFontSize:(CGFloat )nameFontSize briefFontSize:(CGFloat )briefFontSize {
    
    if (nameFontSize) {
        self.nameLab.font = [UIFont systemFontOfSize:nameFontSize];
    }
    if (briefFontSize) {
        self.authorLab.font = [UIFont systemFontOfSize:briefFontSize];
    }
    
    NSString* coverUrlStr = [book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    CGFloat tempSpace = (itemWidth - ivWidth) / 2;
    self.coverIV.frame = CGRectMake(tempSpace, tempSpace, ivWidth, ivHeight);
    [self.coverIV sd_setImageWithURL:[NSURL URLWithString:coverUrlStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage_Gray"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image && error == nil) {
            
        }else {
            self.coverIV.image = [UIImage imageNamed:@"defaultBookImage"];
        }
    }];
    
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
    
    self.authorIV.frame = CGRectMake(5, itemHeight - 20, 15, 15);
    
    self.authorLab.text = book.author;
    self.authorLab.frame = CGRectMake(self.authorIV.frame.origin.x + self.authorIV.frame.size.width + 5, self.authorIV.frame.origin.y, itemWidth - self.authorIV.frame.origin.x - self.authorIV.frame.size.width - 5, self.authorIV.frame.size.height);
    
    self.nameLab.text = book.name;
    self.nameLab.frame = CGRectMake(5, self.coverIV.frame.origin.y + self.coverIV.frame.size.height + 10, itemWidth - 5 * 2, self.authorLab.frame.origin.y - self.coverIV.frame.origin.y - self.coverIV.frame.size.height - 10 * 2);
}

@end
