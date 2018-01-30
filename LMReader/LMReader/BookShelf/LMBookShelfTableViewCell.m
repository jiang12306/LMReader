//
//  LMBookShelfTableViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/30.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookShelfTableViewCell.h"

@interface LMBookShelfTableViewCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* cellView;//内容视图
@property (nonatomic, strong) UIButton* deleteBtn;//删除 按钮
@property (nonatomic, strong) UIButton* upsideBtn;//置顶 按钮

@property (nonatomic, strong) UIImageView* coverIV;//小说封面
@property (nonatomic, strong) UILabel* nameLab;//书名 label
@property (nonatomic, strong) UILabel* timeLab;//更新时间 label
@property (nonatomic, strong) UILabel* chapterLab;//章节 label
@property (nonatomic, strong) UILabel* updateLab;//更新标识 label

@end

@implementation LMBookShelfTableViewCell

static CGFloat deleteWidth = 50;
static CGFloat upsideWidth = 50;
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
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.contentSize = CGSizeMake(screenRect.size.width + upsideWidth + deleteWidth, 0);
        self.scrollView.delegate = self;
        [self.contentView insertSubview:self.scrollView belowSubview:self.lineView];
        
        self.scrollView.backgroundColor = [UIColor clearColor];
    }
    if (!self.upsideBtn) {
        self.upsideBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, upsideWidth, self.frame.size.height)];
        self.upsideBtn.backgroundColor = [UIColor grayColor];
        [self.upsideBtn addTarget:self action:@selector(clickedUpsiceButton:) forControlEvents:UIControlEventTouchUpInside];
        self.upsideBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.upsideBtn setTitle:@"置顶" forState:UIControlStateNormal];
        [self.contentView addSubview:self.upsideBtn];
    }
    if (!self.deleteBtn) {
        self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height)];
        self.deleteBtn.backgroundColor = [UIColor colorWithRed:1 green:51/255.f blue:42/255.f alpha:1];
        [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.contentView insertSubview:self.deleteBtn belowSubview:self.upsideBtn];
    }
    if (!self.cellView) {
        self.cellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        self.cellView.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:self.cellView];
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

//不显示 删除 置顶 按钮
-(void)resetScrollViewAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL finished) {
            
        }];
        return;
    }
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

//显示 删除 置顶 按钮
-(void)editScrollViewAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.contentOffset = CGPointMake(upsideWidth + deleteWidth, 0);
        } completion:^(BOOL finished) {
            
        }];
        return;
    }
    self.scrollView.contentOffset = CGPointMake(upsideWidth + deleteWidth, 0);
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.cellView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.upsideBtn.frame = CGRectMake(screenRect.size.width, 0, upsideWidth, self.frame.size.height);
    self.deleteBtn.frame = CGRectMake(screenRect.size.width, 0, deleteWidth, self.frame.size.height);
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = self.scrollView.contentOffset.x;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.upsideBtn.frame = CGRectMake(screenRect.size.width - offsetX/2, 0, upsideWidth, self.frame.size.height);
    self.deleteBtn.frame = CGRectMake(screenRect.size.width - offsetX, 0, deleteWidth, self.frame.size.height);
    if (offsetX >= upsideWidth + deleteWidth) {
        self.upsideBtn.frame = CGRectMake(screenRect.size.width - upsideWidth, 0, upsideWidth, self.frame.size.height);
        self.deleteBtn.frame = CGRectMake(screenRect.size.width - upsideWidth - deleteWidth, 0, deleteWidth, self.frame.size.height);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX < 30) {
        [self resetScrollViewAnimation:YES];
    }else {
        [self editScrollViewAnimation:YES];
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
