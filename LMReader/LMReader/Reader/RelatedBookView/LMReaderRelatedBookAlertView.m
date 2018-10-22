//
//  LMReaderRelatedBookAlertView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderRelatedBookAlertView.h"
#import "LMReaderRelatedBookCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface LMReaderRelatedBookAlertView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UILabel* infoLab;
@property (nonatomic, strong) UIButton* collectBtn;
@property (nonatomic, strong) UIButton* closeBtn;
@property (nonatomic, strong) LMBaseAlertView* contentView;
@property (nonatomic, strong) UICollectionView* collectionView;

@end

@implementation LMReaderRelatedBookAlertView

static NSString* cellId = @"cellIdentifier";

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        
        CGFloat contentWidth = screenRect.size.width - 100;
        if (screenRect.size.width <= 320) {
            contentWidth = screenRect.size.width - 40;
        }
        self.contentView = [[LMBaseAlertView alloc]initWithFrame:CGRectMake(0, 0, contentWidth, screenRect.size.width)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        self.contentView.center = self.center;
        
        self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.contentView.frame.size.width - 20, 40)];
        self.infoLab.font = [UIFont systemFontOfSize:16];
        self.infoLab.numberOfLines = 0;
        self.infoLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.infoLab.text = @"亲，不喜欢这本书吗？以下是书友最喜欢的书，您可以看看是否喜欢哦！";
        [self.contentView addSubview:self.infoLab];
        CGSize infoSize = [self.infoLab sizeThatFits:CGSizeMake(self.contentView.frame.size.width - 20, CGFLOAT_MAX)];
        self.infoLab.frame = CGRectMake(10, 10, self.contentView.frame.size.width - 20, infoSize.height);
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.infoLab.frame.origin.y + self.infoLab.frame.size.height + 10, self.contentView.frame.size.width, 100) collectionViewLayout:layout];
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[LMReaderRelatedBookCollectionViewCell class] forCellWithReuseIdentifier:cellId];
        [self.contentView addSubview:self.collectionView];
        
        self.collectBtn = [self createButtonWithFrame:CGRectMake(0, self.contentView.frame.size.height - 40, 100, 30) titleStr:@"喜欢，收藏本书" selector:@selector(clickedCollectButton:)];
        [self.contentView addSubview:self.collectBtn];
        
        self.closeBtn = [self createButtonWithFrame:CGRectMake(0, self.collectBtn.frame.origin.y, 100, 30) titleStr:@"关闭并返回" selector:@selector(clickedCloseButton:)];
        [self.contentView addSubview:self.closeBtn];
    }
    return self;
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
    btn.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    btn.layer.borderWidth = 1;
    return btn;
}

-(void)clickedCollectButton:(UIButton* )sender {
    if (self.collectBlock) {
        self.collectBlock(YES);
    }
    [self startHide];
}

-(void)clickedCloseButton:(UIButton* )sender {
    if (self.closeBlock) {
        self.closeBlock(YES);
    }
    [self startHide];
}

-(void)startShow {
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)startHide {
    [UIView animateWithDuration:0.1 animations:^{
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

-(void)setupAlertViewWithArray:(NSArray *)booksArr isCollected:(BOOL)isCollected {
    if (booksArr != nil && booksArr.count > 0) {
        self.dataArray = [NSMutableArray arrayWithArray:booksArr];
    }
    CGFloat cellWidth = (self.contentView.frame.size.width - 40) / 3;
    CGFloat cellHeight = cellWidth / 3 * 4 + 40;
    self.collectionView.frame = CGRectMake(0, self.infoLab.frame.origin.y + self.infoLab.frame.size.height + 10, self.contentView.frame.size.width, cellHeight + 10);
    CGRect originFrame = self.contentView.frame;
    self.contentView.frame = CGRectMake(0, 0, originFrame.size.width, self.collectionView.frame.origin.y + self.collectionView.frame.size.height + self.closeBtn.frame.size.height + 10 * 2);
    self.contentView.center = self.center;
    if (isCollected) {
        self.collectBtn.hidden = YES;
        self.closeBtn.frame = CGRectMake(10, self.contentView.frame.size.height - 30 - 10, self.contentView.frame.size.width - 20, 30);
    }else {
        self.collectBtn.hidden = NO;
        self.collectBtn.frame = CGRectMake(10, self.contentView.frame.size.height - 30 - 10, (self.contentView.frame.size.width - 30) / 2, 30);
        self.closeBtn.frame = CGRectMake(self.collectBtn.frame.origin.x + self.collectBtn.frame.size.width + 10, self.collectBtn.frame.origin.y, self.collectBtn.frame.size.width, self.collectBtn.frame.size.height);
    }
    
    [self.collectionView reloadData];
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMReaderRelatedBookCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    Book* tempBook = [self.dataArray objectAtIndex:indexPath.row];
    NSString* picStr = [tempBook.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.coverIV sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage"]];
    cell.nameLab.text = tempBook.name;
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    Book* tempBook = [self.dataArray objectAtIndex:indexPath.row];
    if (self.clickedBookBlock) {
        self.clickedBookBlock(tempBook);
    }
    [self startHide];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = (self.contentView.frame.size.width - 40) / 3;
    CGFloat cellHeight = cellWidth / 3 * 4 + 40;
    return CGSizeMake(cellWidth, cellHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
