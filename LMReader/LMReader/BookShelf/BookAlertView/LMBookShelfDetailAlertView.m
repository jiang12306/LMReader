//
//  LMBookShelfDetailAlertView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/4.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfDetailAlertView.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"

@interface LMBookShelfDetailAlertView ()

@property (nonatomic, strong) UIView* contentView;

@property (nonatomic, strong) UIImageView* bookCover;
@property (nonatomic, strong) UILabel* nameLab;
@property (nonatomic, strong) UILabel* authorLab;
@property (nonatomic, strong) UILabel* chapterLab;
@property (nonatomic, strong) UILabel* briefLab;

@property (nonatomic, strong) UIButton* downloadBtn;
@property (nonatomic, strong) UIButton* readBtn;
@property (nonatomic, strong) UIButton* detailBtn;

@end

@implementation LMBookShelfDetailAlertView

static CGFloat spaceY = 7;

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        
        self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.width)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.contentView];
        
        self.bookCover = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 55, 75)];
        [self.contentView addSubview:self.bookCover];
        
        self.nameLab = [self createLabelWithFrame:CGRectMake(self.bookCover.frame.origin.x + self.bookCover.frame.size.width + 10, self.bookCover.frame.origin.y, self.contentView.frame.size.width - self.bookCover.frame.size.width - 30, 20) font:[UIFont boldSystemFontOfSize:18] textColor:[UIColor blackColor]];
        self.nameLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.nameLab];
        
        self.authorLab = [self createLabelWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + spaceY, self.nameLab.frame.size.width, 20) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor]];
        [self.contentView addSubview:self.authorLab];
        
        self.chapterLab = [self createLabelWithFrame:CGRectMake(self.nameLab.frame.origin.x, self.authorLab.frame.origin.y + self.authorLab.frame.size.height + spaceY, self.nameLab.frame.size.width, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor]];
        self.chapterLab.textColor = [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1];
        [self.contentView addSubview:self.chapterLab];
        
        self.briefLab = [self createLabelWithFrame:CGRectMake(10, self.bookCover.frame.origin.y + self.bookCover.frame.size.height + spaceY, self.contentView.frame.size.width - 20, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor blackColor]];
        [self.contentView addSubview:self.briefLab];
        
        self.downloadBtn = [self createButtonWithFrame:CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + spaceY, (self.contentView.frame.size.width - 30) / 2, 30) titleStr:@"开始下载" selector:@selector(clickedDownloadButton:)];
        self.downloadBtn.layer.borderColor = THEMEORANGECOLOR.CGColor;
        self.downloadBtn.backgroundColor = [UIColor whiteColor];
        [self.downloadBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
        [self.contentView addSubview:self.downloadBtn];
        
        self.readBtn = [self createButtonWithFrame:CGRectMake(self.downloadBtn.frame.origin.x + self.downloadBtn.frame.size.width + 10, self.downloadBtn.frame.origin.y, self.downloadBtn.frame.size.width, 30) titleStr:@"开始阅读" selector:@selector(clickedReadButton:)];
        self.readBtn.layer.borderColor = THEMEORANGECOLOR.CGColor;
        self.readBtn.backgroundColor = THEMEORANGECOLOR;
        [self.readBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.readBtn];
        
        self.detailBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width - 30, self.bookCover.frame.origin.y, 30, self.bookCover.frame.size.height)];
        self.detailBtn.backgroundColor = [UIColor clearColor];
        self.detailBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.detailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.detailBtn setTitle:@">" forState:UIControlStateNormal];
        [self.detailBtn addTarget:self action:@selector(clickedDetailButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.detailBtn];
    }
    return self;
}

-(UILabel* )createLabelWithFrame:(CGRect )frame font:(UIFont* )font textColor:(UIColor* )textColor {
    UILabel* lab = [[UILabel alloc] initWithFrame:frame];
    lab.font = font;
    lab.textColor = textColor;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    lab.numberOfLines = 0;
    return lab;
}

-(UIButton* )createButtonWithFrame:(CGRect )frame titleStr:(NSString* )titleStr selector:(SEL )selector {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.layer.cornerRadius = 3;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 1;
    return btn;
}

-(void)clickedDownloadButton:(UIButton* )sender {
    if (self.downloadBlock) {
        self.downloadBlock(YES);
    }
    [self startHide];
}

-(void)clickedReadButton:(UIButton* )sender {
    if (self.readBlock) {
        self.readBlock(YES);
    }
    [self startHide];
}

-(void)clickedDetailButton:(UIButton* )sender {
    if (self.detailBlock) {
        self.detailBlock(YES);
    }
    [self startHide];
}

-(CGSize )caculateLabelSizeWithText:(NSString* )text width:(CGFloat )width font:(UIFont* )font lines:(NSInteger )lines {
    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectZero];
    lab.font = font;
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    lab.text = text;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    if (lines > 0) {
        CGFloat finalHeight = lab.font.lineHeight * lines;
        if (labSize.height > finalHeight) {
            return CGSizeMake(labSize.width, finalHeight);
        }
    }
    return labSize;
}

-(void)startShow {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)startHide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    bool isContain = CGRectContainsPoint(self.contentView.frame, point);
    if (!isContain) {
        [self startHide];
    }
}

-(void)setupContentsWithBook:(UserBook *)userBook {
    Book* book = userBook.book;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat maxLabWidth = self.contentView.frame.size.width - self.bookCover.frame.size.width - self.detailBtn.frame.size.width - 40;
    
    NSString* picStr = [book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* picUrl = [NSURL URLWithString:picStr];
    [self.bookCover sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"defaultBookImage"] options:SDWebImageRefreshCached];
    
    self.nameLab.text = book.name;
    CGSize nameSize = [self caculateLabelSizeWithText:book.name width:maxLabWidth font:[UIFont boldSystemFontOfSize:18] lines:0];
    self.nameLab.frame = CGRectMake(self.bookCover.frame.origin.x + self.bookCover.frame.size.width + 10, self.bookCover.frame.origin.y, nameSize.width, nameSize.height);
    
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
    NSString* typeStr = [book.bookType firstObject];
    self.authorLab.text = [NSString stringWithFormat:@"%@ | %@ | %@", book.author, stateStr, typeStr];
    CGSize authorSize = [self caculateLabelSizeWithText:self.authorLab.text width:maxLabWidth font:[UIFont systemFontOfSize:14] lines:0];
    self.authorLab.frame = CGRectMake(self.nameLab.frame.origin.x, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + spaceY, authorSize.width, authorSize.height);
    
    NSString* chapterStr = userBook.newestChapter.newestChapterTitle;
    if (chapterStr == nil || [chapterStr isKindOfClass:[NSNull class]] || chapterStr.length == 0) {
        chapterStr = book.lastChapter.chapterTitle;
    }
    if (chapterStr == nil || [chapterStr isKindOfClass:[NSNull class]] || chapterStr.length == 0) {
        chapterStr = @"暂无最新章节信息";
    }
    self.chapterLab.text = chapterStr;
    CGSize chapterSize = [self caculateLabelSizeWithText:chapterStr width:maxLabWidth font:[UIFont systemFontOfSize:13] lines:0];
    self.chapterLab.frame = CGRectMake(self.nameLab.frame.origin.x, self.authorLab.frame.origin.y + self.authorLab.frame.size.height + spaceY, chapterSize.width, chapterSize.height);
    
    CGFloat briefY = self.bookCover.frame.origin.y + self.bookCover.frame.size.height + spaceY;
    if (self.chapterLab.frame.origin.y + self.chapterLab.frame.size.height + spaceY > briefY) {
        briefY = self.chapterLab.frame.origin.y + self.chapterLab.frame.size.height + spaceY;
    }
    self.briefLab.text = book.abstract;
    CGSize briefSize = [self caculateLabelSizeWithText:book.abstract width:self.contentView.frame.size.width - 20 font:[UIFont systemFontOfSize:13] lines:4];
    self.briefLab.frame = CGRectMake(10, briefY, briefSize.width, briefSize.height);
    
    CGRect originFrame = self.contentView.frame;
    CGFloat contentHeight = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + self.downloadBtn.frame.size.height + 10 * 2;
    if ([LMTool isBangsScreen]) {
        contentHeight += 40;
    }
    self.contentView.frame = CGRectMake(0, screenRect.size.height - contentHeight, originFrame.size.width,contentHeight);
    
    self.downloadBtn.frame = CGRectMake(10, self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10, (self.contentView.frame.size.width - 30) / 2, 30);
    self.readBtn.frame = CGRectMake(self.downloadBtn.frame.origin.x + self.downloadBtn.frame.size.width + 10, self.downloadBtn.frame.origin.y, self.downloadBtn.frame.size.width, 30);
    self.detailBtn.frame = CGRectMake(self.contentView.frame.size.width - 30, self.bookCover.frame.origin.y, 30, self.bookCover.frame.size.height);
}

-(void)setupDownloadTitleWithString:(NSString *)titleStr {
    [self.downloadBtn setTitle:titleStr forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
