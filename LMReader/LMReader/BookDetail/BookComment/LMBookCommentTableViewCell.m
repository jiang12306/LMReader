//
//  LMBookCommentTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookCommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@implementation LMBookCommentTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (!self.avatorIV) {
        self.avatorIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, CommentAvatorIVWidth, CommentAvatorIVWidth)];
        self.avatorIV.layer.cornerRadius = CommentAvatorIVWidth / 2;
        self.avatorIV.layer.masksToBounds = YES;
        self.avatorIV.layer.borderColor = [UIColor grayColor].CGColor;
        self.avatorIV.layer.borderWidth = 1.f;
        [self.contentView addSubview:self.avatorIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.avatorIV.frame.origin.x + self.avatorIV.frame.size.width + 10, 10, screenWidth - self.avatorIV.frame.origin.x - self.avatorIV.frame.size.width - 10 * 2, CommentNameLabHeight)];
        self.nameLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.nameLab.textAlignment = NSTextAlignmentLeft;
        self.nameLab.font = [UIFont systemFontOfSize:CommentNameFontSize];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height, self.nameLab.frame.size.width, CommentNameLabHeight)];
        self.timeLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.timeLab.textAlignment = NSTextAlignmentLeft;
        self.timeLab.font = [UIFont systemFontOfSize:12];
        self.timeLab.numberOfLines = 0;
        self.timeLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.timeLab];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height + 10, screenWidth - 10 * 2, 20)];
        self.contentLab.font = [UIFont systemFontOfSize:CommentContentFontSize];
        self.contentLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.contentLab.numberOfLines = 0;
        self.contentLab.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.contentLab];
    }
    if (!self.starView) {
        self.starView = [[LMCommentStarView alloc]initWithFrame:CGRectMake(10, self.contentLab.frame.origin.y + self.contentLab.frame.size.height + 10, 120, CommentStarViewHeight)];
        self.starView.cancelStar = YES;
        [self.contentView addSubview:self.starView];
    }
    if (!self.likeBtn) {
        self.likeBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - (CommentLikeBtnHeight + 10), self.starView.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight)];
        [self.likeBtn addTarget:self action:@selector(clickedLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.likeBtn];
        
        self.likeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, CommentLikeBtnHeight)];
        self.likeLab.numberOfLines = 0;
        self.likeLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.likeLab.font = [UIFont systemFontOfSize:16];
        self.likeLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.likeLab.textAlignment = NSTextAlignmentCenter;
        [self.likeBtn addSubview:self.likeLab];
        
        self.likeIV = [[UIImageView alloc]initWithFrame:CGRectMake(self.likeLab.frame.origin.x + self.likeLab.frame.size.width, self.likeLab.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight)];
        self.likeIV.image = [UIImage imageNamed:@"commentLike"];
        [self.likeBtn addSubview:self.likeIV];
    }
}

-(void)clickedLikeButton:(UIButton* )sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bookCommentTableViewCellDidClickedLikeButton:)]) {
        [self.delegate bookCommentTableViewCellDidClickedLikeButton:self];
    }
}

-(void)setupContentWithComment:(Comment *)comment {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    RegUser* user = comment.user;
    NSString* imgStr = user.icon;
    NSString* encodeStr = [imgStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.avatorIV sd_setImageWithURL:[NSURL URLWithString:encodeStr] placeholderImage:[UIImage imageNamed:@"comment_Avator"]];
    
    NSString* nickStr = user.nickname;
    if (nickStr) {
//        if () {
//            nickStr = @"我";
//        }
        self.nameLab.text = nickStr;
    }else {
        self.nameLab.text = @"";
    }
    
    NSString* timeStr = comment.cT;
    if (timeStr != nickStr && timeStr.length > 0) {
        self.timeLab.text = [LMTool convertTimeStringToTime:timeStr];
    }
    
    CGRect commentRect = self.contentLab.frame;
    NSString* commentStr = comment.text;
    if (commentStr != nil && commentStr.length > 0) {
        self.contentLab.text = commentStr;
        CGSize labSize = [self.contentLab sizeThatFits:CGSizeMake(screenWidth - 10 * 2, 9999)];
        commentRect.size.height = labSize.height;
        commentRect.origin.y = self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height + 10;
    }else {
        self.contentLab.text = @"";
        commentRect.origin.y = self.avatorIV.frame.origin.y + self.avatorIV.frame.size.height;
        commentRect.size.height = 0;
    }
    self.contentLab.frame = commentRect;
    
    CGRect starViewRect = self.starView.frame;
    starViewRect.origin.y = self.contentLab.frame.origin.y + self.contentLab.frame.size.height + 10;
    self.starView.frame = starViewRect;
    NSInteger starCount = comment.starC;
    [self.starView setupStarWithCount:starCount];
    
    NSInteger upCount = comment.upCount;
    if (upCount != 0) {
        NSString* likeStr = [NSString stringWithFormat:@"%ld", upCount];
        if (upCount >= 1000) {
            likeStr = [NSString stringWithFormat:@"%ld千", upCount / 1000];
        }
        self.likeLab.text = likeStr;
        CGSize likeSize = [self.likeLab sizeThatFits:CGSizeMake(9999, CommentLikeBtnHeight)];
        self.likeLab.frame = CGRectMake(0, 0, likeSize.width, CommentLikeBtnHeight);
        self.likeIV.frame = CGRectMake(self.likeLab.frame.origin.x + self.likeLab.frame.size.width + 5, self.likeLab.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight);
        self.likeBtn.frame = CGRectMake(screenWidth - 10 - CommentLikeBtnHeight - self.likeLab.frame.size.width - 5, self.starView.frame.origin.y, CommentLikeBtnHeight + self.likeLab.frame.size.width + 5, CommentLikeBtnHeight);
    }else {
        self.likeLab.text = @"";
        self.likeLab.frame = CGRectMake(0, 0, 0, CommentLikeBtnHeight);
        self.likeIV.frame = CGRectMake(self.likeLab.frame.origin.x + self.likeLab.frame.size.width, self.likeLab.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight);
        self.likeBtn.frame = CGRectMake(screenWidth - 10 - CommentLikeBtnHeight, self.starView.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight);
    }
    
    if (comment.isUp) {
        self.likeIV.image = [UIImage imageNamed:@"commentLike_Selected"];
    }else {
        self.likeIV.image = [UIImage imageNamed:@"commentLike"];
    }
}

//计算label高度
+(CGFloat)caculateLabelHeightWithWidth:(CGFloat)width text:(NSString* )text font:(UIFont* )font maxLines:(NSInteger)maxLines {
    
    UILabel* sizeLab = [[UILabel alloc]initWithFrame:CGRectZero];
    sizeLab.numberOfLines = 0;
    sizeLab.lineBreakMode = NSLineBreakByCharWrapping;
    if (font) {
        sizeLab.font = font;
    }else {
        sizeLab.font = [UIFont systemFontOfSize:16];
    }
    sizeLab.text = text;
    CGSize labSize = [sizeLab sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGFloat lines = labSize.height / sizeLab.font.lineHeight;
    if (maxLines > 0 && maxLines < lines) {
        return maxLines * sizeLab.font.lineHeight;
    }
    return labSize.height;
}

@end