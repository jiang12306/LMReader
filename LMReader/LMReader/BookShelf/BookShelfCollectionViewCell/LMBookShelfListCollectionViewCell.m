//
//  LMBookShelfListCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/28.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfListCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMBookShelfListCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 100, self.frame.size.height - 20 * 2)];
        self.coverIV.contentMode = UIViewContentModeScaleAspectFill;
        self.coverIV.clipsToBounds = YES;
        [self.contentView addSubview:self.coverIV];
    }
    if (!self.markIV) {
        self.markIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width - 50 + 4, self.coverIV.frame.origin.y - 4, 50, 50)];
        [self.contentView addSubview:self.markIV];
    }
    if (!self.redDotLab) {
        self.redDotLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 20 + 1, self.coverIV.frame.origin.y + 5, 8, 8)];
        self.redDotLab.backgroundColor = [UIColor colorWithRed:210.f/255 green:33.f/255 blue:43.f/255 alpha:1];
        self.redDotLab.layer.cornerRadius = 5;
        self.redDotLab.layer.masksToBounds = YES;
        [self.contentView addSubview:self.redDotLab];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.redDotLab.frame.origin.x + self.redDotLab.frame.size.width + 5, self.coverIV.frame.origin.y, 100, 20)];
        self.nameLab.font = [UIFont systemFontOfSize:15];
        self.nameLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.progressLab) {
        self.progressLab = [[UILabel alloc]initWithFrame:CGRectMake(self.redDotLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + 10, self.frame.size.width - 5 * 2, 15)];
        self.progressLab.font = [UIFont systemFontOfSize:12];
        self.progressLab.textColor = THEMEORANGECOLOR;
        self.progressLab.numberOfLines = 0;
        self.progressLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.progressLab];
    }
    if (!self.briefLab) {
        self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(self.redDotLab.frame.origin.x, self.progressLab.frame.origin.y + self.progressLab.frame.size.height + 10, self.frame.size.width - 5 * 2, 15)];
        self.briefLab.font = [UIFont systemFontOfSize:12];
        self.briefLab.textColor = [UIColor colorWithRed:165.f/255 green:165.f/255 blue:165.f/255 alpha:1];
        self.briefLab.numberOfLines = 0;
        self.briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.briefLab];
    }
    if (!self.stateLab) {
        self.stateLab = [[UILabel alloc]initWithFrame:CGRectMake(self.redDotLab.frame.origin.x, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, self.frame.size.width - 5 * 2, 15)];
        self.stateLab.font = [UIFont systemFontOfSize:12];
        self.stateLab.textColor = [UIColor colorWithRed:165.f/255 green:165.f/255 blue:165.f/255 alpha:1];
        self.stateLab.numberOfLines = 0;
        self.stateLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.stateLab];
        
        
        UILongPressGestureRecognizer* pressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
        [self addGestureRecognizer:pressGR];
    }
    if (!self.selectIV) {
        self.selectIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 20 - 20, self.coverIV.frame.origin.y + (self.coverIV.frame.size.height - 20) / 2, 20, 20)];
        self.selectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
        [self.contentView addSubview:self.selectIV];
        self.selectIV.hidden = YES;
    }
}

-(void)longPressed:(UILongPressGestureRecognizer* )pressGR {
    UIGestureRecognizerState grState = pressGR.state;
    if (grState == UIGestureRecognizerStateBegan) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(LMBookShelfListCollectionViewCellDidLongPress:)]) {
            [self.delegate LMBookShelfListCollectionViewCellDidLongPress:self];
        }
    }
}

-(void)setupSquareCellWithModel:(LMBookShelfModel *)model ivWidth:(CGFloat)ivWidth ivHeight:(CGFloat)ivHeight itemWidth:(CGFloat)itemWidth {
    UserBook* userBook = model.userBook;
    Book* book = userBook.book;
    
    CGFloat cellWidth = itemWidth;
    if (self.isEditting) {
        cellWidth = itemWidth - 20 - 20;
        self.selectIV.hidden = NO;
        self.selectIV.frame = CGRectMake(itemWidth - 20 - 20, self.coverIV.frame.origin.y + (self.coverIV.frame.size.height - 20) / 2, 20, 20);
        if (self.isClicked) {
            self.selectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Selected"];
        }else {
            self.selectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
        }
    }else {
        self.selectIV.hidden = YES;
    }
    
    NSString* coverUrlStr = [book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.coverIV.frame = CGRectMake(20, 20, ivWidth, ivHeight);
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
    
    CGFloat tempSpaceY = (ivHeight - self.nameLab.frame.size.height - self.progressLab.frame.size.height - self.briefLab.frame.size.height - self.stateLab.frame.size.height) / 5;
    
    self.nameLab.text = book.name;
    CGRect nameRect = CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 20, self.coverIV.frame.origin.y + tempSpaceY, cellWidth - self.coverIV.frame.origin.x - self.coverIV.frame.size.width - 20 * 2, 20);
    if (model.markState > 0) {
        self.redDotLab.hidden = NO;
        self.redDotLab.frame = CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 20, self.coverIV.frame.origin.y + tempSpaceY + 5 + 1, 8, 8);
        nameRect.origin.x = self.redDotLab.frame.origin.x + self.redDotLab.frame.size.width + 5;
        nameRect.origin.y = self.redDotLab.frame.origin.y - 5;
        nameRect.size.width = cellWidth - self.redDotLab.frame.origin.x - self.redDotLab.frame.size.width - 5 - 20;
    }else {
        self.redDotLab.hidden = YES;
        self.redDotLab.frame = CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + 20, self.coverIV.frame.origin.y + tempSpaceY + 5 + 1, 0, 0);
    }
    self.nameLab.frame = nameRect;
    
    NSString* readProgressStr = @"未读";
    if (model.progressStr != nil && model.progressStr.length > 0) {
        readProgressStr = [NSString stringWithFormat:@"已读%@%%", model.progressStr];
    }
    if (model.isLastestRecord) {
        self.progressLab.textColor = THEMEORANGECOLOR;
    }else {
        self.progressLab.textColor = [UIColor colorWithRed:165.f/255 green:165.f/255 blue:165.f/255 alpha:1];
    }
    self.progressLab.text = readProgressStr;
    self.progressLab.frame = CGRectMake(self.redDotLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + tempSpaceY, cellWidth - self.redDotLab.frame.origin.x - 20, 15);
    
    NSString* chapterStr = userBook.newestChapter.newestChapterTitle;
    if (chapterStr == nil || [chapterStr isKindOfClass:[NSNull class]] || chapterStr.length == 0) {
        chapterStr = book.lastChapter.chapterTitle;
    }
    if (chapterStr != nil && chapterStr.length > 0) {
        self.briefLab.text = [NSString stringWithFormat:@"最新章节：%@", chapterStr];
    }else {
        self.briefLab.text = @"暂无最新章节信息";
    }
    self.briefLab.frame = CGRectMake(self.progressLab.frame.origin.x, self.progressLab.frame.origin.y + self.progressLab.frame.size.height + tempSpaceY, self.progressLab.frame.size.width, 15);
    
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
    self.stateLab.frame = CGRectMake(self.briefLab.frame.origin.x, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + tempSpaceY, self.briefLab.frame.size.width, 15);
}

@end
