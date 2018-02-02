//
//  LMBookShelfTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfTableViewCell.h"

@interface LMBookShelfTableViewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* cellView;//内容视图
@property (nonatomic, strong) UIButton* deleteBtn;//删除 按钮
@property (nonatomic, strong) UIButton* upsideBtn;//置顶 按钮

@property (nonatomic, strong) UIImageView* coverIV;//小说封面
@property (nonatomic, strong) UILabel* nameLab;//书名 label
@property (nonatomic, strong) UILabel* timeLab;//更新时间 label
@property (nonatomic, strong) UILabel* chapterLab;//章节 label
@property (nonatomic, strong) UILabel* updateLab;//更新标识 label

@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanX;

@end

@implementation LMBookShelfTableViewCell

static CGFloat deleteWidth = 50;
static CGFloat upsideWidth = 50;
static CGFloat slideSpace = 50;//滑动距离 显示/隐藏 置顶 删除 按钮
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
    if (!self.upsideBtn) {
        self.upsideBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, upsideWidth, self.frame.size.height)];
        self.upsideBtn.backgroundColor = [UIColor grayColor];
        [self.upsideBtn addTarget:self action:@selector(clickedUpsiceButton:) forControlEvents:UIControlEventTouchUpInside];
        self.upsideBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.upsideBtn setTitle:@"置顶" forState:UIControlStateNormal];
        [self.contentView insertSubview:self.upsideBtn belowSubview:self.cellView];
    }
    if (!self.deleteBtn) {
        self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height)];
        self.deleteBtn.backgroundColor = [UIColor colorWithRed:1 green:51/255.f blue:42/255.f alpha:1];
        [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.contentView insertSubview:self.deleteBtn belowSubview:self.upsideBtn];
    }
    if (!self.coverIV) {
        self.coverIV = [[UIImageView alloc]initWithFrame:CGRectMake(spaceX, spaceX, 50, 40)];
        self.coverIV.image = [UIImage imageNamed:@"navigationItem_Back"];
        self.coverIV.layer.borderWidth = 1;
        self.coverIV.layer.borderColor = [UIColor grayColor].CGColor;
        [self.cellView addSubview:self.coverIV];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:deleteButton:)]) {
        [self.delegate didClickCell:self deleteButton:self.deleteBtn];
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
        upsideBtnFrame = CGRectMake(screenRect.size.width - upsideWidth, 0, upsideWidth, self.frame.size.height);
        deleteBtnFrame = CGRectMake(screenRect.size.width - (upsideWidth + deleteWidth), 0, deleteWidth, self.frame.size.height);
    }
    
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
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.startPanX = [panGR locationInView:self.cellView].x;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartScrollCell:)]) {
            [self.delegate didStartScrollCell:self];
        }
    }else if (panGR.state == UIGestureRecognizerStateChanged) {
        CGRect startFrame = self.cellView.frame;
        startFrame.origin.x = startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) < - (upsideWidth + deleteWidth) ? - (upsideWidth + deleteWidth) : (startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) > 0 ? 0 : startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX));
        self.cellView.frame = startFrame;
        self.deleteBtn.frame = CGRectMake(self.cellView.frame.origin.x + self.cellView.frame.size.width, 0, deleteWidth, self.frame.size.height);
        self.upsideBtn.frame = CGRectMake(self.deleteBtn.frame.origin.x - startFrame.origin.x / 2, 0, upsideWidth, self.deleteBtn.frame.size.height);
    }else if (panGR.state == UIGestureRecognizerStateEnded || panGR.state == UIGestureRecognizerStateCancelled) {
        CGFloat endFrameX = self.cellView.frame.origin.x;
        if (endFrameX > - slideSpace) {
            [self showUpsideAndDelete:NO animation:YES];
        }else {
            [self showUpsideAndDelete:YES animation:YES];
        }
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
