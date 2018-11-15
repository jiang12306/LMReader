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
#import "AppDelegate.h"

@interface LMReaderRelatedBookAlertView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UILabel* infoLab;
@property (nonatomic, strong) UIButton* collectBtn;
@property (nonatomic, strong) UILabel* lineLab;
@property (nonatomic, strong) UIButton* closeBtn;
@property (nonatomic, strong) LMBaseAlertView* contentView;
@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//

@end

@implementation LMReaderRelatedBookAlertView

static NSString* cellId = @"cellIdentifier";

-(instancetype)initWithFrame:(CGRect)frame {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        CGFloat contentWidth = screenRect.size.width - 20 * 2;
        
        self.bookCoverWidth = (contentWidth - 15 * 4) / 3;
        self.bookCoverHeight = 145.f / 105 * self.bookCoverWidth;
        self.bookNameFontSize = 15.f;
        self.bookBriefFontSize = 12.f;
        
        self.contentView = [[LMBaseAlertView alloc]initWithFrame:CGRectMake(0, 0, contentWidth, screenRect.size.width)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.masksToBounds = YES;
        [self addSubview:self.contentView];
        self.contentView.center = self.center;
        
        self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, self.contentView.frame.size.width - 20 * 2, 40)];
        self.infoLab.font = [UIFont systemFontOfSize:15];
        self.infoLab.textColor = [UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1];
        self.infoLab.numberOfLines = 0;
        self.infoLab.lineBreakMode = NSLineBreakByCharWrapping;
        self.infoLab.text = @"亲，您不喜欢这本书吗？以下是书友最喜欢的书，您可以看看是否喜欢哦";
        [self.contentView addSubview:self.infoLab];
        CGSize infoSize = [self.infoLab sizeThatFits:CGSizeMake(self.contentView.frame.size.width - 20 * 2, CGFLOAT_MAX)];
        self.infoLab.frame = CGRectMake(20, 20, self.contentView.frame.size.width - 20 * 2, infoSize.height);
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.infoLab.frame.origin.y + self.infoLab.frame.size.height + 20, self.contentView.frame.size.width, 100) collectionViewLayout:layout];
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
        
        self.closeBtn = [self createButtonWithFrame:CGRectMake(20, self.contentView.frame.size.height - 20 - 20, 77, 20) titleStr:@"关闭并返回" selector:@selector(clickedCloseButton:)];
        [self.closeBtn setTitleColor:[UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1] forState:UIControlStateNormal];
        [self.contentView addSubview:self.closeBtn];
        
        self.collectBtn = [self createButtonWithFrame:CGRectMake(self.contentView.frame.size.width - 20 - 77, self.collectBtn.frame.origin.y, 77, 20) titleStr:@"收藏这本书" selector:@selector(clickedCollectButton:)];
        [self.contentView addSubview:self.collectBtn];
        
        self.lineLab = [[UILabel alloc]initWithFrame:CGRectMake(self.closeBtn.frame.origin.x + self.closeBtn.frame.size.width + (self.collectBtn.frame.origin.x - self.closeBtn.frame.origin.x - self.closeBtn.frame.size.width) / 2, self.closeBtn.frame.origin.y, 1, 20)];
        self.lineLab.backgroundColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1];
        [self.contentView addSubview:self.lineLab];
    }
    return self;
}

-(UIButton* )createButtonWithFrame:(CGRect )frame titleStr:(NSString* )titleStr selector:(SEL )selector {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [btn setTitle:titleStr forState:UIControlStateNormal];
    [btn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
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
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate bringSystemNightShiftToFront];
}

-(void)startHide {
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    AppDelegate* appDelegate = (AppDelegate* )[UIApplication sharedApplication].delegate;
    [appDelegate sendSystemNightShiftToback];
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
    UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
    tempLab.numberOfLines = 0;
    tempLab.lineBreakMode = NSLineBreakByTruncatingTail;
    tempLab.font = [UIFont systemFontOfSize:self.bookNameFontSize];
    
    CGFloat itemHeight = 5 + self.bookCoverHeight + 10 + 10 + 20;
    
    for (NSInteger i = 0; i < booksArr.count; i ++) {
        if (i % 3 == 0) {
            CGFloat maxLabHeight = 25;
            Book* subBook0 = [booksArr objectAtIndex:i];
            tempLab.text = subBook0.name;
            CGSize tempLabSize0 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
            if (tempLabSize0.height > tempLab.font.lineHeight * 2) {
                tempLabSize0.height = tempLab.font.lineHeight * 2;
            }
            
            if (i + 1 < booksArr.count) {
                Book* subBook1 = [booksArr objectAtIndex:i + 1];
                tempLab.text = subBook1.name;
                CGSize tempLabSize1 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                if (tempLabSize1.height > tempLab.font.lineHeight * 2) {
                    tempLabSize1.height = tempLab.font.lineHeight * 2;
                }
                maxLabHeight = MAX(tempLabSize0.height, tempLabSize1.height);
            }
            
            if (i + 2 < booksArr.count) {
                Book* subBook2 = [booksArr objectAtIndex:i + 2];
                tempLab.text = subBook2.name;
                CGSize tempLabSize2 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                if (tempLabSize2.height > tempLab.font.lineHeight * 2) {
                    tempLabSize2.height = tempLab.font.lineHeight * 2;
                }
                maxLabHeight = MAX(maxLabHeight, tempLabSize2.height);
            }
            itemHeight += maxLabHeight;
        }
    }
    
    self.collectionView.frame = CGRectMake(0, self.infoLab.frame.origin.y + self.infoLab.frame.size.height + 20, self.contentView.frame.size.width, itemHeight);
    CGRect originFrame = self.contentView.frame;
    self.contentView.frame = CGRectMake(0, 0, originFrame.size.width, self.collectionView.frame.origin.y + self.collectionView.frame.size.height + self.closeBtn.frame.size.height + 20 * 2);
    self.contentView.center = self.center;
    if (isCollected) {
        self.collectBtn.hidden = YES;
        self.lineLab.hidden = YES;
        self.closeBtn.frame = CGRectMake(20, self.contentView.frame.size.height - 20 - 20, self.contentView.frame.size.width - 20 * 2, 20);
    }else {
        self.collectBtn.hidden = NO;
        self.lineLab.hidden = NO;
        CGRect closeBtnRect = self.closeBtn.frame;
        CGRect collectBtnRect = self.collectBtn.frame;
        CGFloat tempSpaceX = (self.contentView.frame.size.width - closeBtnRect.size.width - collectBtnRect.size.width) / 4;
        self.closeBtn.frame = CGRectMake(tempSpaceX, self.contentView.frame.size.height - 20 - 20, closeBtnRect.size.width, closeBtnRect.size.height);
        self.collectBtn.frame = CGRectMake(self.contentView.frame.size.width - collectBtnRect.size.width - tempSpaceX, self.closeBtn.frame.origin.y, collectBtnRect.size.width, self.closeBtn.frame.size.height);
        self.lineLab.frame = CGRectMake(self.closeBtn.frame.origin.x + self.closeBtn.frame.size.width + (self.collectBtn.frame.origin.x - self.closeBtn.frame.origin.x - self.closeBtn.frame.size.width) / 2, self.closeBtn.frame.origin.y, 1, 20);
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
    [cell setupWithBook:tempBook ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.bookCoverWidth + 5 * 2 itemHeight:self.collectionView.frame.size.height nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
    
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
    CGFloat cellWidth = self.bookCoverWidth + 10;
    CGFloat cellHeight = self.collectionView.frame.size.height;
    return CGSizeMake(cellWidth, cellHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.f;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
