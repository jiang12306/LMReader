//
//  LMProfileBookCommentTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/27.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileBookCommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"
#import "LMBookCommentTableViewCell.h"

@implementation LMProfileBookCommentTableViewCell

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
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, screenWidth - 10 - 5, 20)];
        self.nameLab.font = [UIFont boldSystemFontOfSize:CommentNameFontSize];
        self.nameLab.numberOfLines = 0;
        self.nameLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.nameLab];
    }
    if (!self.starView) {
        self.starView = [[LMCommentStarView alloc]initWithFrame:CGRectMake(10, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + 10, 120, CommentStarViewHeight)];
        self.starView.cancelStar = YES;
        [self.contentView addSubview:self.starView];
    }
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(self.starView.frame.origin.x + self.starView.frame.size.width + 10, self.starView.frame.origin.y, screenWidth - self.starView.frame.origin.x - self.starView.frame.size.width - 10 * 2, CommentNameLabHeight)];
        self.timeLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        self.timeLab.font = [UIFont systemFontOfSize:12];
        self.timeLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.timeLab];
    }
    if (!self.contentLab) {
        self.contentLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.starView.frame.origin.y + self.starView.frame.size.height + 10, screenWidth - 10 * 2, 20)];
        self.contentLab.font = [UIFont systemFontOfSize:CommentContentFontSize];
        self.contentLab.textColor = [UIColor colorWithRed:100.f/255 green:100.f/255 blue:100.f/255 alpha:1];
        self.contentLab.numberOfLines = 0;
        self.contentLab.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.contentLab];
    }
    if (!self.deleteBtn) {
        self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, self.contentLab.frame.origin.y + self.contentLab.frame.size.height + 10, 40, CommentLikeBtnHeight + 5)];
        self.deleteBtn.layer.cornerRadius = 3;
        self.deleteBtn.layer.masksToBounds = YES;
        self.deleteBtn.layer.borderColor = THEMEORANGECOLOR.CGColor;
        self.deleteBtn.layer.borderWidth = 0.5;
        self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.deleteBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deleteBtn];
    }
    if (!self.likeBtn) {
        self.likeBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth - (CommentLikeBtnHeight + 10), self.deleteBtn.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight)];
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

-(void)clickedDeleteButton:(UIButton* )sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bookCommentTableViewCellDidClickedDelete:)]) {
        [self.delegate bookCommentTableViewCellDidClickedDelete:self];
    }
}

-(void)clickedLikeButton:(UIButton* )sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bookCommentTableViewCellDidClickedLike:)]) {
        [self.delegate bookCommentTableViewCellDidClickedLike:self];
    }
}

-(void)setupContentWith:(CommentBook *)commentBook {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    Comment* comment = commentBook.comment;
    Book* book = commentBook.book;
    
    NSString* nameStr = book.name;
    if (nameStr) {
        self.nameLab.text = [NSString stringWithFormat:@"《%@》", nameStr];
    }
    
    NSInteger starCount = comment.starC;
    [self.starView setupStarWithCount:starCount];
    
    NSString* timeStr = comment.cT;
    if (timeStr != nameStr && timeStr.length > 0) {
        self.timeLab.text = [LMTool convertTimeStringToTime:timeStr];
    }
    
    CGRect commentRect = self.contentLab.frame;
    NSString* commentStr = comment.text;
    if (commentStr != nil && commentStr.length > 0) {
        self.contentLab.text = commentStr;
        CGSize labSize = [self.contentLab sizeThatFits:CGSizeMake(screenWidth - 10 * 2, 9999)];
        commentRect.size.height = labSize.height;
        commentRect.origin.y = self.starView.frame.origin.y + self.starView.frame.size.height + 10;
    }else {
        self.contentLab.text = @"";
        commentRect.origin.y = self.starView.frame.origin.y + self.starView.frame.size.height;
        commentRect.size.height = 0;
    }
    self.contentLab.frame = commentRect;
    
    CGRect deleteRect = self.deleteBtn.frame;
    deleteRect.origin.y = self.contentLab.frame.origin.y + self.contentLab.frame.size.height + 10;
    self.deleteBtn.frame = deleteRect;
    
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
        self.likeBtn.frame = CGRectMake(screenWidth - 10 - CommentLikeBtnHeight - self.likeLab.frame.size.width - 5, self.deleteBtn.frame.origin.y, CommentLikeBtnHeight + self.likeLab.frame.size.width + 5, CommentLikeBtnHeight);
    }else {
        self.likeLab.text = @"";
        self.likeLab.frame = CGRectMake(0, 0, 0, CommentLikeBtnHeight);
        self.likeIV.frame = CGRectMake(self.likeLab.frame.origin.x + self.likeLab.frame.size.width, self.likeLab.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight);
        self.likeBtn.frame = CGRectMake(screenWidth - 10 - CommentLikeBtnHeight, self.deleteBtn.frame.origin.y, CommentLikeBtnHeight, CommentLikeBtnHeight);
    }
    
    if (comment.isUp) {
        self.likeIV.image = [UIImage imageNamed:@"commentLike_Selected"];
    }else {
        self.likeIV.image = [UIImage imageNamed:@"commentLike"];
    }
}

@end
