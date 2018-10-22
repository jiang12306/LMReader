//
//  LMBookShelfTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"
#import "LMBaseBookTableViewCell.h"

@interface LMBookShelfTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* cellView;//内容视图
@property (nonatomic, strong) UIButton* deleteBtn;//删除 按钮
@property (nonatomic, strong) UIButton* upsideBtn;//置顶 按钮

@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanX;

@end

@implementation LMBookShelfTableViewCell

static CGFloat deleteWidth = 70;
static CGFloat upsideWidth = 70;
static CGFloat slideSpace = 70;//滑动距离 显示/隐藏 置顶 删除 按钮
static CGFloat spaceX = 10;

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
    if (!self.cellView) {
        self.cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, self.frame.size.height)];
        self.cellView.backgroundColor = [UIColor whiteColor];
        [self.contentView insertSubview:self.cellView belowSubview:self.lineView];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didMoveCellView:)];
        self.panGestureRecognizer.delegate = self;
        [self.cellView addGestureRecognizer:self.panGestureRecognizer];
    }
    if (!self.deleteBtn) {
        self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height)];
        self.deleteBtn.backgroundColor = [UIColor colorWithRed:1 green:51/255.f blue:42/255.f alpha:1];
        [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        self.deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.deleteBtn setTitle:@"确定删除" forState:UIControlStateSelected];
        self.deleteBtn.selected = NO;
        [self.contentView insertSubview:self.deleteBtn belowSubview:self.cellView];
    }
    if (!self.upsideBtn) {
        self.upsideBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, upsideWidth, self.frame.size.height)];
        self.upsideBtn.backgroundColor = [UIColor grayColor];
        [self.upsideBtn addTarget:self action:@selector(clickedUpsiceButton:) forControlEvents:UIControlEventTouchUpInside];
        self.upsideBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.upsideBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView insertSubview:self.upsideBtn belowSubview:self.deleteBtn];
    }
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceX, 12.5, 70, baseBookCellHeight - 12.5 * 2)];
        self.coverIV.layer.borderColor = [UIColor colorWithRed:200.f / 255 green:200.f / 255 blue:200.f / 255 alpha:1].CGColor;
        self.coverIV.layer.borderWidth = 0.5;
        self.coverIV.layer.shadowColor = [UIColor grayColor].CGColor;
        self.coverIV.layer.shadowOffset = CGSizeMake(-5, 5);
        self.coverIV.layer.shadowOpacity = 0.4;
        self.coverIV.image = [UIImage imageNamed:@"navigationItem_Back"];
        [self.cellView addSubview:self.coverIV];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceX, self.coverIV.frame.origin.y + 3, 100, 20)];
        self.nameLab.font = [UIFont systemFontOfSize:18];
        [self.cellView addSubview:self.nameLab];
    }
    if (!self.markLab) {
        self.markLab = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + 5, self.nameLab.frame.origin.y + 7.5, 5, 5)];
        self.markLab.layer.cornerRadius = 2.5;
        self.markLab.layer.masksToBounds = YES;
        self.markLab.backgroundColor = [UIColor redColor];
        [self.cellView addSubview:self.markLab];
        self.markLab.hidden = YES;
    }
    if (!self.briefBtn) {
        self.briefBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width - spaceX - 40, self.coverIV.frame.origin.y + self.coverIV.frame.size.height - 20, 40, 20)];
        [self.briefBtn setImage:[UIImage imageNamed:@"bookShelf_Brief"] forState:UIControlStateNormal];
        [self.briefBtn setImageEdgeInsets:UIEdgeInsetsMake(2.5, 10, 2.5, 0)];
        [self.briefBtn addTarget:self action:@selector(clickedBookBriefButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellView addSubview:self.briefBtn];
    }
    if (!self.lastChapterLab) {
        self.lastChapterLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceX, self.nameLab.frame.origin.y + self.nameLab.frame.size.height + 5, screenRect.size.width - self.coverIV.frame.size.width - spaceX * 3, self.coverIV.frame.size.height - self.nameLab.frame.size.height - 20 - 10)];
        self.lastChapterLab.font = [UIFont systemFontOfSize:15];
        self.lastChapterLab.textAlignment = NSTextAlignmentLeft;
        self.lastChapterLab.numberOfLines = 2;
        self.lastChapterLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lastChapterLab.textColor = [UIColor colorWithRed:178/255.f green:178/255.f blue:178/255.f alpha:1];
        [self.cellView addSubview:self.lastChapterLab];
    }
    if (!self.statusLab) {
        self.statusLab = [[UILabel alloc]initWithFrame:CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceX, self.coverIV.frame.origin.y + self.coverIV.frame.size.height - 20 - 3, screenRect.size.width - self.coverIV.frame.size.width - 70 - spaceX * 4, 20)];
        self.statusLab.font = [UIFont systemFontOfSize:15];
        self.statusLab.textColor = [UIColor grayColor];
        [self.cellView addSubview:self.statusLab];
    }
}

//点击 置顶/取消置顶 按钮
-(void)clickedUpsiceButton:(UIButton* )sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:upsideButton:)]) {
        [self.delegate didClickCell:self upsideButton:self.upsideBtn];
    }
}

//点击 删除 按钮
-(void)clickedDeleteButton:(UIButton* )sender {
    if (self.deleteBtn.selected == NO) {
        self.deleteBtn.selected = YES;
        
        CGRect deleteBtnFrame = CGRectMake(self.cellView.frame.origin.x + self.cellView.frame.size.width, 0, deleteWidth + upsideWidth, self.frame.size.height);
        [UIView animateWithDuration:0.2 animations:^{
            self.deleteBtn.frame = deleteBtnFrame;
        } completion:^(BOOL finished) {
            
        }];
        
    }else if (self.deleteBtn.selected == YES) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:deleteButton:)]) {
            [self.delegate didClickCell:self deleteButton:self.deleteBtn];
        }
        
//        self.deleteBtn.selected = NO;
    }
}

//点击 书籍详情 按钮
-(void)clickedBookBriefButton:(UIButton* )sener {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:briefButton:)]) {
        [self.delegate didClickCell:self briefButton:self.briefBtn];
    }
}

//显示/不显示 删除 置顶 按钮
-(void)showUpsideAndDelete:(BOOL )isShow animation:(BOOL)animation {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect cellViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect upsideBtnFrame = CGRectMake(screenRect.size.width, 0, upsideWidth, self.frame.size.height);
    CGRect deleteBtnFrame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
    if (isShow) {
        cellViewFrame = CGRectMake(- (upsideWidth + deleteWidth), 0, self.frame.size.width, self.frame.size.height);
        upsideBtnFrame = CGRectMake(screenRect.size.width - (upsideWidth + deleteWidth), 0, upsideWidth, self.frame.size.height);
        deleteBtnFrame = CGRectMake(screenRect.size.width - deleteWidth, 0, deleteWidth, self.frame.size.height);
    }
    
    self.deleteBtn.selected = NO;
    
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.cellView.frame = cellViewFrame;
            self.upsideBtn.frame = upsideBtnFrame;
            self.deleteBtn.frame = deleteBtnFrame;
        } completion:^(BOOL finished) {

        }];
        return;
    }else {
        self.cellView.frame = cellViewFrame;
        self.upsideBtn.frame = upsideBtnFrame;
        self.deleteBtn.frame = deleteBtnFrame;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.cellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.upsideBtn.frame = CGRectMake(screenRect.size.width, 0, upsideWidth, self.frame.size.height);
    self.deleteBtn.frame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
}

-(BOOL )gestureRecognizerShouldBegin:(UIGestureRecognizer* )gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint point = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:gestureRecognizer.view];
        return fabs(point.y) <= fabs(point.x);
    }else {
        return YES;
    }
}

-(void)didMoveCellView:(UIPanGestureRecognizer* )panGR {
    
    self.deleteBtn.selected = NO;
    
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.startPanX = [panGR locationInView:self.cellView].x;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartScrollCell:)]) {
            [self.delegate didStartScrollCell:self];
        }
    }else if (panGR.state == UIGestureRecognizerStateChanged) {
        CGRect startFrame = self.cellView.frame;
        startFrame.origin.x = startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) < - (upsideWidth + deleteWidth) ? - (upsideWidth + deleteWidth) : (startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) > 0 ? 0 : startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX));
        self.cellView.frame = startFrame;
        self.upsideBtn.frame = CGRectMake(self.cellView.frame.origin.x + self.cellView.frame.size.width, 0, upsideWidth, self.frame.size.height);//CGRectMake(self.deleteBtn.frame.origin.x - startFrame.origin.x / 2, 0, upsideWidth, self.deleteBtn.frame.size.height);
        self.deleteBtn.frame = CGRectMake(self.upsideBtn.frame.origin.x - startFrame.origin.x / 2, 0, deleteWidth, self.deleteBtn.frame.size.height);//CGRectMake(self.cellView.frame.origin.x + self.cellView.frame.size.width, 0, deleteWidth, self.frame.size.height);
    }else if (panGR.state == UIGestureRecognizerStateEnded || panGR.state == UIGestureRecognizerStateCancelled) {
        CGFloat endFrameX = self.cellView.frame.origin.x;
        if (endFrameX > - slideSpace) {
            [self showUpsideAndDelete:NO animation:YES];
        }else {
            [self showUpsideAndDelete:YES animation:YES];
        }
    }
}

-(void)setupBookShelfModel:(LMBookShelfModel* )model {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    UserBook* userBook = model.userBook;
    Book* book = userBook.book;
    UInt32 isTop = userBook.isTop;
    if (isTop) {
        [self.upsideBtn setTitle:@"取消置顶" forState:UIControlStateNormal];
    }else {
        [self.upsideBtn setTitle:@"置顶" forState:UIControlStateNormal];
    }
    NSString* picStr = [book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* picUrl = [NSURL URLWithString:picStr];
    [self.coverIV sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"defaultBookImage"] options:SDWebImageRefreshCached];
    
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
    self.statusLab.text = stateStr;
    
    self.nameLab.text = book.name;
    CGRect nameFrame = self.nameLab.frame;
    CGSize nameSize = [self.nameLab sizeThatFits:CGSizeMake(9999, nameFrame.size.height)];
    CGFloat maxNameWidth = screenRect.size.width - 10 * 3 - self.coverIV.frame.size.width;
    if (nameSize.width > maxNameWidth) {
        nameSize.width = maxNameWidth;
    }
    self.nameLab.frame = CGRectMake(self.coverIV.frame.origin.x + self.coverIV.frame.size.width + spaceX, self.coverIV.frame.origin.y + 3, nameSize.width, nameFrame.size.height);
    
    if (model.markState > 0) {
        self.markLab.frame = CGRectMake(self.nameLab.frame.origin.x + self.nameLab.frame.size.width + 5, self.nameLab.frame.origin.y + 7.5, 5, 5);
        self.markLab.hidden = NO;
    }else {
        self.markLab.hidden = YES;
    }
    
    
    NSString* chapterStr = userBook.newestChapter.newestChapterTitle;
    if (chapterStr == nil || [chapterStr isKindOfClass:[NSNull class]] || chapterStr.length == 0) {
        chapterStr = book.lastChapter.chapterTitle;
    }
    if (chapterStr != nil && chapterStr.length > 0) {
        self.lastChapterLab.text = [NSString stringWithFormat:@"最新章节：%@", chapterStr];
    }else {
        self.lastChapterLab.text = @"暂无最新章节信息";
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
