//
//  LMReadRecordTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/3/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReadRecordTableViewCell.h"

@interface LMReadRecordTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* cellView;//内容视图
@property (nonatomic, strong) UIButton* deleteBtn;//删除 按钮
@property (nonatomic, strong) UIButton* collectBtn;//置顶 按钮
@property (nonatomic, strong) UIImageView* arrowIV;

@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanX;

@end

@implementation LMReadRecordTableViewCell

static CGFloat deleteWidth = 70;
static CGFloat collectWidth = 70;
static CGFloat slideSpace = 70;//滑动距离 显示/隐藏 置顶 删除 按钮

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
    if (!self.collectBtn) {
        self.collectBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, collectWidth, self.frame.size.height)];
        self.collectBtn.backgroundColor = [UIColor grayColor];
        [self.collectBtn addTarget:self action:@selector(clickedUpsiceButton:) forControlEvents:UIControlEventTouchUpInside];
        self.collectBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.collectBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.collectBtn setTitle:@"收藏" forState:UIControlStateNormal];
        [self.contentView insertSubview:self.collectBtn belowSubview:self.cellView];
    }
    if (!self.deleteBtn) {
        self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height)];
        self.deleteBtn.backgroundColor = [UIColor colorWithRed:1 green:51/255.f blue:42/255.f alpha:1];
        [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        self.deleteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.contentView insertSubview:self.deleteBtn belowSubview:self.collectBtn];
    }
    if (!self.arrowIV) {
        self.arrowIV = [[UIImageView alloc]initWithFrame:CGRectMake(screenRect.size.width - 10 - 10, 15, 10, 20)];
        UIImage* image = [UIImage imageNamed:@"cell_Arrow"];
        UIImage* tintImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.arrowIV setTintColor:[UIColor grayColor]];
        self.arrowIV.image = tintImage;
        [self.cellView addSubview:self.arrowIV];
    }
    if (!self.timeLab) {
        self.timeLab = [[UILabel alloc]initWithFrame:CGRectMake(screenRect.size.width - 30 - 80, 0, 80, 50)];
        self.timeLab.font = [UIFont systemFontOfSize:14];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        self.timeLab.textColor = [UIColor colorWithRed:190/255.f green:190/255.f blue:190/255.f alpha:1];
        [self.cellView addSubview:self.timeLab];
    }
    if (!self.nameLab) {
        self.nameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.timeLab.frame.origin.x - 10 * 2, 50)];
        self.nameLab.font = [UIFont systemFontOfSize:16];
        [self.cellView addSubview:self.nameLab];
    }
}

//点击 置顶/取消置顶 按钮
-(void)clickedUpsiceButton:(UIButton* )sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:collectButton:)]) {
        [self.delegate didClickCell:self collectButton:self.collectBtn];
    }
}

//点击 删除 按钮
-(void)clickedDeleteButton:(UIButton* )sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:deleteButton:)]) {
        [self.delegate didClickCell:self deleteButton:self.deleteBtn];
    }
}

//显示/不显示 删除 置顶 按钮
-(void)showCollectAndDelete:(BOOL )isShow animation:(BOOL)animation {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect cellViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect collectBtnFrame = CGRectMake(screenRect.size.width, 0, collectWidth, self.frame.size.height);
    CGRect deleteBtnFrame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
    if (isShow) {
        cellViewFrame = CGRectMake(- (collectWidth + deleteWidth), 0, self.frame.size.width, self.frame.size.height);
        collectBtnFrame = CGRectMake(screenRect.size.width - collectWidth, 0, collectWidth, self.frame.size.height);
        deleteBtnFrame = CGRectMake(screenRect.size.width - (collectWidth + deleteWidth), 0, deleteWidth, self.frame.size.height);
    }
    
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.cellView.frame = cellViewFrame;
            self.collectBtn.frame = collectBtnFrame;
            self.deleteBtn.frame = deleteBtnFrame;
        } completion:^(BOOL finished) {
            
        }];
        return;
    }else {
        self.cellView.frame = cellViewFrame;
        self.collectBtn.frame = collectBtnFrame;
        self.deleteBtn.frame = deleteBtnFrame;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.cellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.collectBtn.frame = CGRectMake(screenRect.size.width, 0, collectWidth, self.frame.size.height);
    self.deleteBtn.frame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
}

-(BOOL )gestureRecognizerShouldBegin:(UIGestureRecognizer* )gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint startPoint = [gestureRecognizer locationInView:self.cellView];
        if (startPoint.x < slideSpace) {
            return NO;
        }
        
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
        startFrame.origin.x = startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) < - (collectWidth + deleteWidth) ? - (collectWidth + deleteWidth) : (startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX) > 0 ? 0 : startFrame.origin.x + ([panGR locationInView:self.cellView].x - self.startPanX));
        self.cellView.frame = startFrame;
        self.deleteBtn.frame = CGRectMake(self.cellView.frame.origin.x + self.cellView.frame.size.width, 0, deleteWidth, self.frame.size.height);
        self.collectBtn.frame = CGRectMake(self.deleteBtn.frame.origin.x - startFrame.origin.x / 2, 0, collectWidth, self.deleteBtn.frame.size.height);
    }else if (panGR.state == UIGestureRecognizerStateEnded || panGR.state == UIGestureRecognizerStateCancelled) {
        CGFloat endFrameX = self.cellView.frame.origin.x;
        if (endFrameX > - slideSpace) {
            [self showCollectAndDelete:NO animation:YES];
        }else {
            [self showCollectAndDelete:YES animation:YES];
        }
    }
}

-(void)setupReadRecordWithModel:(LMReadRecordModel *)model {
    self.nameLab.text = model.name;
    self.timeLab.text = model.dateStr;
    if (model.isCollected) {
        [self.collectBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
    }else {
        [self.collectBtn setTitle:@"收藏" forState:UIControlStateNormal];
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
