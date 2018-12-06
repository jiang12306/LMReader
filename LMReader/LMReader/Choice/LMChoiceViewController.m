//
//  LMChoiceViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMChoiceViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMRangeViewController.h"
#import "LMSpecialChoiceViewController.h"
#import "LMInterestOrEndViewController.h"
#import "LMBookDetailViewController.h"
#import "LMSearchViewController.h"
#import "LMSearchTitleView.h"
#import "LMTool.h"
#import "UIImageView+WebCache.h"
#import "LMLaunchDetailViewController.h"
#import "SCAdView.h"
#import "LMChoiceListTableViewCell.h"
#import "LMChoiceCollectionTableViewCell.h"
#import "LMChoiceMoreViewController.h"

@interface LMChoiceViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, SCAdViewDelegate, LMChoiceCollectionTableViewCellDelegate>

@property (nonatomic, strong) SCAdView* scAdView;
@property (nonatomic, strong) NSMutableArray* topArr;//顶部广告、书籍部分

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;//编辑推荐
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL firstLoad;//首次加载

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//
@property (nonatomic, assign) CGFloat sectionHeaderFontSize;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//

@end

@implementation LMChoiceViewController

static NSString* listCellIdentifier = @"listCellIdentifier";
static NSString* collectionCellIdentifier = @"collectionCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bookCoverWidth = 105.f;
    self.bookCoverHeight = 145.f;
    self.sectionHeaderFontSize = 18.f;
    self.bookNameFontSize = 15.f;
    self.bookBriefFontSize = 12.f;
    
    CGFloat maxBookWidth = (self.view.frame.size.width - 20 * 4 - 10 * 3) / 3.f;
    self.bookFontScale = (self.view.frame.size.width / 414.f);
    if (self.bookFontScale > 1) {
        self.bookFontScale = 1;
    }
    if (self.bookCoverWidth * self.bookFontScale > maxBookWidth) {
        self.bookFontScale = maxBookWidth / self.bookCoverWidth;
    }
    self.bookCoverWidth *= self.bookFontScale;
    self.bookCoverHeight *= self.bookFontScale;
    
    __weak LMChoiceViewController* weakSelf = self;
    LMSearchTitleView* searchView = [[LMSearchTitleView alloc]initWithFrame:CGRectMake(20, 7, self.view.frame.size.width - 20 * 2, 30)];
    searchView.clickBlock = ^(BOOL didClick) {
        if (didClick) {
            LMSearchViewController* searchVC = [[LMSearchViewController alloc]init];
            [weakSelf.navigationController pushViewController:searchVC animated:YES];
        }
    };
    self.navigationItem.titleView = searchView;
    
    CGFloat naviHeight = 20 + 44;
    CGFloat tabBarHeight = 49;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
        tabBarHeight = 83;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight - tabBarHeight) style:UITableViewStyleGrouped];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMChoiceListTableViewCell class] forCellReuseIdentifier:listCellIdentifier];
    [self.tableView registerClass:[LMChoiceCollectionTableViewCell class] forCellReuseIdentifier:collectionCellIdentifier];
    [self.tableView setupNoMoreData];
    [self.view addSubview:self.tableView];
    
    self.topArr = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    
    self.firstLoad = YES;
    
    [self loadChoiceData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //防止iOS11 刘海屏tabBar下移34
    UITabBarController* tabBarController = self.tabBarController;
    if (tabBarController) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGFloat tabBarHeight = 49;
        if ([LMTool isBangsScreen]) {
            tabBarHeight = 83;
        }
        tabBarController.tabBar.frame = CGRectMake(0, screenRect.size.height - tabBarHeight, screenRect.size.width, tabBarHeight);
    }
}

-(void)setupTableHeaderView {
    CGFloat topHeaderHeight = 0;
    CGFloat spaceHeight = 20 * 2;
    CGFloat btnHeight = 75;
    CGFloat btnWidth = 50;
    CGFloat btnCenterY = topHeaderHeight + btnHeight / 2 + spaceHeight / 2;
    CGFloat totalHeaderHeight = btnHeight + spaceHeight;
    CGFloat adHeight = 0;
    if (self.topArr != nil && self.topArr.count > 0) {
        topHeaderHeight = 20;
        adHeight = self.view.frame.size.width * 27 / 64;
        btnCenterY = topHeaderHeight + adHeight + btnHeight / 2 + spaceHeight / 2;
        totalHeaderHeight = topHeaderHeight + adHeight + btnHeight + spaceHeight;
    }
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, totalHeaderHeight)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    if (self.topArr != nil && self.topArr.count > 0) {
        if (self.scAdView) {
            [self.scAdView pause];
            self.scAdView.delegate = nil;
            [self.scAdView removeFromSuperview];
            self.scAdView = nil;
        }
        __weak LMChoiceViewController* weakSelf = self;
        self.scAdView = [[SCAdView alloc] initWithBuilder:^(SCAdViewBuilder *builder) {
            CGFloat adWidth = weakSelf.view.bounds.size.width - 13 * 2;
            CGFloat scale = 1.1;
            builder.adArray = [NSArray arrayWithArray:weakSelf.topArr];
            builder.viewFrame = CGRectMake(0, topHeaderHeight, weakSelf.view.bounds.size.width, adHeight);
            builder.adItemSize = CGSizeMake(adWidth / scale, adHeight / scale);
            builder.allowedInfinite = YES;
            builder.minimumLineSpacing = 0;
            builder.secondaryItemMinAlpha = 0.8;
            builder.threeDimensionalScale = scale;
            builder.itemCellClassName = @"LMChoiceAdCollectionViewCell";
        }];
        self.scAdView.backgroundColor = [UIColor whiteColor];
        self.scAdView.delegate = self;
        [self.headerView addSubview:self.scAdView];
        [self.scAdView play];
    }else {
        if (self.scAdView) {
            [self.scAdView pause];
            self.scAdView.delegate = nil;
            [self.scAdView removeFromSuperview];
            self.scAdView = nil;
        }
    }
    
    UIButton* rangeBtn = [self createTitleButtonWithFrame:CGRectMake(0, 0, btnWidth, btnHeight) title:@"排行榜" imageStr:@"choice_Range" selector:@selector(clickedRangeButton:)];
    rangeBtn.center = CGPointMake(self.headerView.frame.size.width / 8, btnCenterY);
    [self.headerView addSubview:rangeBtn];
    
    UIButton* specialBtn = [self createTitleButtonWithFrame:CGRectMake(0, 0, rangeBtn.frame.size.width, rangeBtn.frame.size.height) title:@"精选专题" imageStr:@"choice_Special" selector:@selector(clickedSpecialChoiceButton:)];
    specialBtn.center = CGPointMake(self.headerView.frame.size.width * 3/8, rangeBtn.center.y);
    [self.headerView addSubview:specialBtn];
    
    UIButton* recommandBtn = [self createTitleButtonWithFrame:CGRectMake(0, 0, rangeBtn.frame.size.width, rangeBtn.frame.size.height) title:@"编辑推荐" imageStr:@"choice_Recommand" selector:@selector(clickedRecommandChoiceButton:)];
    recommandBtn.center = CGPointMake(self.headerView.frame.size.width * 5/8, rangeBtn.center.y);
    [self.headerView addSubview:recommandBtn];
    
    UIButton* overBtn = [self createTitleButtonWithFrame:CGRectMake(0, 0, rangeBtn.frame.size.width, rangeBtn.frame.size.height) title:@"经典完结" imageStr:@"choice_Over" selector:@selector(clickedOverChoiceButton:)];
    overBtn.center = CGPointMake(self.headerView.frame.size.width * 7/8, rangeBtn.center.y);
    [self.headerView addSubview:overBtn];
    
    self.tableView.tableHeaderView = self.headerView;
}

-(UIButton* )createTitleButtonWithFrame:(CGRect )frame title:(NSString* )titleStr imageStr:(NSString* )imageStr selector:(SEL )selector {
    UIButton* btn = [[UIButton alloc]initWithFrame:frame];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* overIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, frame.size.width - 10, 40)];
    overIV.image = [UIImage imageNamed:imageStr];
    [btn addSubview:overIV];
    
    UILabel* overLab = [[UILabel alloc]initWithFrame:CGRectMake(-10, btn.frame.size.height - 25, btn.frame.size.width + 20, 25)];
    overLab.text = titleStr;
    overLab.textAlignment = NSTextAlignmentCenter;
    overLab.font = [UIFont systemFontOfSize:self.bookNameFontSize];
    [btn addSubview:overLab];
    
    return btn;
}

//排行榜
-(void)clickedRangeButton:(UIButton* )sender {
    LMRangeViewController* rangeVC = [[LMRangeViewController alloc]init];
    [self.navigationController pushViewController:rangeVC animated:YES];
}

//精选专题
-(void)clickedSpecialChoiceButton:(UIButton* )sender {
    LMSpecialChoiceViewController* specialChoiceVC = [[LMSpecialChoiceViewController alloc]init];
    [self.navigationController pushViewController:specialChoiceVC animated:YES];
}

//编辑推荐
-(void)clickedRecommandChoiceButton:(UIButton* )sender {
    LMInterestOrEndViewController* interestOrEndVC = [[LMInterestOrEndViewController alloc]init];
    interestOrEndVC.type = LMEditorRecommandType;
    [self.navigationController pushViewController:interestOrEndVC animated:YES];
}

//经典完结
-(void)clickedOverChoiceButton:(UIButton* )sender {
    LMInterestOrEndViewController* interestOrEndVC = [[LMInterestOrEndViewController alloc]init];
    interestOrEndVC.type = LMEndType;
    [self.navigationController pushViewController:interestOrEndVC animated:YES];
}

//查看更多
-(void)clcikedSectionFooterButton:(UIButton* )sender {
    NSInteger section = sender.tag;
    SelfDefinedTopic* topic = [self.dataArray objectAtIndex:section];
    LMChoiceMoreViewController* choiceMoreVC = [[LMChoiceMoreViewController alloc]init];
    choiceMoreVC.moreId = topic.id;
    choiceMoreVC.moreName = topic.name;
    [self.navigationController pushViewController:choiceMoreVC animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.dataArray.count == 0) {
        UIView* tempVi = [[UIView alloc]initWithFrame:CGRectZero];
        return tempVi;
    }
    CGFloat headerGraySpace = 10;
    SelfDefinedTopic* topic = [self.dataArray objectAtIndex:section];
    NSString* titleStr = topic.name;
    
    UIView* tempHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10 + 60)];
    tempHeaderView.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, headerGraySpace, self.view.frame.size.width, tempHeaderView.frame.size.height - headerGraySpace)];
    vi.backgroundColor = [UIColor whiteColor];
    [tempHeaderView addSubview:vi];
    
    UILabel* lab0 = [[UILabel alloc]initWithFrame:CGRectMake(20, vi.frame.size.height - 25 - 10, 3, 25)];
    lab0.backgroundColor = THEMEORANGECOLOR;
    lab0.layer.cornerRadius = 1.5;
    lab0.layer.masksToBounds = YES;
    [vi addSubview:lab0];
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(lab0.frame.origin.x + lab0.frame.size.width + 7, lab0.frame.origin.y, 250, 25)];
    lab.textColor = [UIColor blackColor];
    lab.font = [UIFont systemFontOfSize:self.sectionHeaderFontSize];
    lab.text = titleStr;
    [vi addSubview:lab];
    
    return tempHeaderView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.dataArray.count == 0) {
        UIView* tempVi = [[UIView alloc]initWithFrame:CGRectZero];
        return tempVi;
    }
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, 40)];
    btn.titleLabel.font = [UIFont systemFontOfSize:self.bookNameFontSize];
    [btn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
    [btn setTitle:@"查看更多" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clcikedSectionFooterButton:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = section;
    [vi addSubview:btn];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SelfDefinedTopic* topic = [self.dataArray objectAtIndex:section];
    NSArray* booksArr = topic.books;
    NSInteger styleInteger = topic.style;
    if (styleInteger == 2) {//九宫格样式
        return 1;
    }else if (styleInteger == 3) {//一图+九宫格样式
        return 2;
    }else {//列表样式
        return booksArr.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10 + 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    SelfDefinedTopic* topic = [self.dataArray objectAtIndex:section];
    NSArray* booksArr = topic.books;
    NSInteger styleInteger = topic.style;
    if (styleInteger == 2) {//九宫格样式
        UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
        tempLab.numberOfLines = 0;
        tempLab.lineBreakMode = NSLineBreakByTruncatingTail;
        tempLab.font = [UIFont systemFontOfSize:self.bookNameFontSize];
        
        CGFloat totalCollectionHeight = 0;
        for (NSInteger i = 0; i < booksArr.count; i ++) {
            if (i % 3 == 0) {
                CGFloat itemHeight = 10 + self.bookCoverHeight + 10 + 10 + 20;
                
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
                totalCollectionHeight+= itemHeight;
            }
        }
        
        NSInteger booksCount = booksArr.count;
        NSInteger lineCount = booksCount / 3;
        if (booksCount % 3 != 0) {
            lineCount ++;
        }
        return totalCollectionHeight + 20 * (lineCount + 1);
    }else if (styleInteger == 3) {//一图+九宫格样式
        if (row == 0) {
            return self.bookCoverHeight + 20 * 2;
        }else {
            NSArray* subBooksArr = [booksArr subarrayWithRange:NSMakeRange(1, booksArr.count - 1)];
            NSInteger booksCount = subBooksArr.count;
            NSInteger lineCount = booksCount / 3;
            if (booksCount % 3 != 0) {
                lineCount ++;
            }
            
            UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
            tempLab.numberOfLines = 0;
            tempLab.lineBreakMode = NSLineBreakByTruncatingTail;
            tempLab.font = [UIFont systemFontOfSize:self.bookNameFontSize];
            
            CGFloat totalCollectionHeight = 0;
            for (NSInteger i = 0; i < subBooksArr.count; i ++) {
                if (i % 3 == 0) {
                    CGFloat itemHeight = 10 + self.bookCoverHeight + 10 + 10 + 20;
                    
                    CGFloat maxLabHeight = 25;
                    Book* subBook0 = [subBooksArr objectAtIndex:i];
                    tempLab.text = subBook0.name;
                    CGSize tempLabSize0 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                    if (tempLabSize0.height > tempLab.font.lineHeight * 2) {
                        tempLabSize0.height = tempLab.font.lineHeight * 2;
                    }
                    
                    if (i + 1 < subBooksArr.count) {
                        Book* subBook1 = [subBooksArr objectAtIndex:i + 1];
                        tempLab.text = subBook1.name;
                        CGSize tempLabSize1 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                        if (tempLabSize1.height > tempLab.font.lineHeight * 2) {
                            tempLabSize1.height = tempLab.font.lineHeight * 2;
                        }
                        maxLabHeight = MAX(tempLabSize0.height, tempLabSize1.height);
                    }
                    
                    if (i + 2 < subBooksArr.count) {
                        Book* subBook2 = [subBooksArr objectAtIndex:i + 2];
                        tempLab.text = subBook2.name;
                        CGSize tempLabSize2 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                        if (tempLabSize2.height > tempLab.font.lineHeight * 2) {
                            tempLabSize2.height = tempLab.font.lineHeight * 2;
                        }
                        maxLabHeight = MAX(maxLabHeight, tempLabSize2.height);
                    }
                    itemHeight += maxLabHeight;
                    totalCollectionHeight+= itemHeight;
                }
            }
            return totalCollectionHeight + 20 * (lineCount + 1);
        }
    }else {//列表样式
        return self.bookCoverHeight + 20 * 2;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    SelfDefinedTopic* topic = [self.dataArray objectAtIndex:section];
    NSArray* booksArr = topic.books;
    NSInteger styleInteger = topic.style;
    if (styleInteger == 2) {//九宫格样式
        LMChoiceCollectionTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:collectionCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMChoiceCollectionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collectionCellIdentifier];
        }
        cell.delegate = self;
        
        UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
        tempLab.numberOfLines = 0;
        tempLab.lineBreakMode = NSLineBreakByTruncatingTail;
        tempLab.font = [UIFont systemFontOfSize:self.bookNameFontSize];
        
        CGFloat totalCollectionHeight = 0;
        NSMutableArray* tempHeightArr = [NSMutableArray array];
        for (NSInteger i = 0; i < booksArr.count; i ++) {
            if (i % 3 == 0) {
                CGFloat itemHeight = 10 + self.bookCoverHeight + 10 + 10 + 20;
                
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
                totalCollectionHeight+= itemHeight;
                [tempHeightArr addObject:[NSNumber numberWithFloat:itemHeight]];
            }
        }
        
        NSInteger booksCount = booksArr.count;
        NSInteger lineCount = booksCount / 3;
        if (booksCount % 3 != 0) {
            lineCount ++;
        }
        CGFloat cellHeight = totalCollectionHeight + 20 * (lineCount + 1);
        [cell setupContentBookArray:booksArr cellHeight:cellHeight ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.bookCoverWidth + 5 * 2 itemHeightArr:tempHeightArr nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
        
        return cell;
    }else if (styleInteger == 3) {//一图+九宫格样式
        if (row == 0) {
            LMChoiceListTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:listCellIdentifier forIndexPath:indexPath];
            if (!cell) {
                cell = [[LMChoiceListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listCellIdentifier];
            }
            Book* book = [booksArr objectAtIndex:row];
            [cell setupContentBook:book cellHeight:self.bookCoverHeight + 20 * 2 ivWidth:self.bookCoverWidth nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
            
            return cell;
        }else {
            LMChoiceCollectionTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:collectionCellIdentifier forIndexPath:indexPath];
            if (!cell) {
                cell = [[LMChoiceCollectionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collectionCellIdentifier];
            }
            cell.delegate = self;
            
            NSArray* subBooksArr = [booksArr subarrayWithRange:NSMakeRange(1, booksArr.count - 1)];
            
            UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
            tempLab.numberOfLines = 0;
            tempLab.lineBreakMode = NSLineBreakByTruncatingTail;
            tempLab.font = [UIFont systemFontOfSize:self.bookNameFontSize];
            
            CGFloat totalCollectionHeight = 0;
            NSMutableArray* tempHeightArr = [NSMutableArray array];
            for (NSInteger i = 0; i < subBooksArr.count; i ++) {
                if (i % 3 == 0) {
                    CGFloat itemHeight = 10 + self.bookCoverHeight + 10 + 10 + 20;
                    
                    Book* subBook0 = [subBooksArr objectAtIndex:i];
                    tempLab.text = subBook0.name;
                    CGSize tempLabSize0 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                    if (tempLabSize0.height > tempLab.font.lineHeight * 2) {
                        tempLabSize0.height = tempLab.font.lineHeight * 2;
                    }
                    CGFloat maxLabHeight = tempLabSize0.height;
                    
                    if (i + 1 < subBooksArr.count) {
                        Book* subBook1 = [subBooksArr objectAtIndex:i + 1];
                        tempLab.text = subBook1.name;
                        CGSize tempLabSize1 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                        if (tempLabSize1.height > tempLab.font.lineHeight * 2) {
                            tempLabSize1.height = tempLab.font.lineHeight * 2;
                        }
                        maxLabHeight = MAX(tempLabSize0.height, tempLabSize1.height);
                    }
                    
                    if (i + 2 < subBooksArr.count) {
                        Book* subBook2 = [subBooksArr objectAtIndex:i + 2];
                        tempLab.text = subBook2.name;
                        CGSize tempLabSize2 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                        if (tempLabSize2.height > tempLab.font.lineHeight * 2) {
                            tempLabSize2.height = tempLab.font.lineHeight * 2;
                        }
                        maxLabHeight = MAX(maxLabHeight, tempLabSize2.height);
                    }
                    itemHeight += maxLabHeight;
                    totalCollectionHeight += itemHeight;
                    [tempHeightArr addObject:[NSNumber numberWithFloat:itemHeight]];
                }
            }
            
            NSInteger booksCount = subBooksArr.count;
            NSInteger lineCount = booksCount / 3;
            if (booksCount % 3 != 0) {
                lineCount ++;
            }
            CGFloat cellHeight = totalCollectionHeight + 20 * (lineCount + 1);
            [cell setupContentBookArray:subBooksArr cellHeight:cellHeight ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.bookCoverWidth + 5 * 2 itemHeightArr:tempHeightArr nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
            
            return cell;
        }
    }else {//列表样式
        LMChoiceListTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:listCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMChoiceListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:listCellIdentifier];
        }
        Book* book = [booksArr objectAtIndex:row];
        [cell setupContentBook:book cellHeight:self.bookCoverHeight + 20 * 2 ivWidth:self.bookCoverWidth nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Book* book;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    SelfDefinedTopic* topic = [self.dataArray objectAtIndex:section];
    NSArray* booksArr = topic.books;
    NSInteger styleInteger = topic.style;
    if (styleInteger == 2) {//九宫格样式
        
    }else if (styleInteger == 3) {//一图+九宫格样式
        if (row == 0) {
            book = [booksArr objectAtIndex:row];
        }else {
            
        }
    }else {//列表样式
        book = [booksArr objectAtIndex:row];
    }
    
    if (book != nil) {
        LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
        detailVC.bookId = book.bookId;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

-(void)loadChoiceData {
    self.isRefreshing = YES;
    
    SelfDefinedHomeReqBuilder* builder = [SelfDefinedHomeReq builder];
    [builder setPage:0];
    SelfDefinedHomeReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMChoiceViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:43 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 43) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    SelfDefinedHomeRes* res = [SelfDefinedHomeRes parseFromData:apiRes.body];
                    
                    NSArray* arr0 = res.ads;
                    if (arr0 != nil && arr0.count > 0) {
                        [weakSelf.topArr removeAllObjects];
                        [weakSelf.topArr addObjectsFromArray:arr0];
                    }
                    
                    NSArray* arr1 = res.selfDefinedTopics;
                    if (arr1.count > 0) {
                        self.firstLoad = NO;
                        
                        [weakSelf.dataArray removeAllObjects];
                        [weakSelf.dataArray addObjectsFromArray:arr1];
                    }
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        if (weakSelf.dataArray.count == 0) {
            [weakSelf showReloadButton];
        }else {
            [weakSelf hideReloadButton];
        }
        weakSelf.isRefreshing = NO;
        [weakSelf.tableView stopRefresh];
        [weakSelf hideNetworkLoadingView];
        
        [weakSelf setupTableHeaderView];
        [weakSelf.tableView reloadData];
        
    } failureBlock:^(NSError *failureError) {
        weakSelf.isRefreshing = NO;
        [weakSelf.tableView stopRefresh];
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        if (weakSelf.dataArray.count == 0) {
            [weakSelf showReloadButton];
        }else {
            [weakSelf setupTableHeaderView];
            [weakSelf.tableView reloadData];
        }
    }];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self loadChoiceData];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    if (self.isRefreshing) {
        return;
    }
    [self loadChoiceData];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    
}

#pragma mark -SCAdViewRenderDelegate
-(void)sc_didClickAd:(id)adModel {
    if ([adModel isKindOfClass:[TopicAd class]]) {
        TopicAd* topAd = (TopicAd* )adModel;
        if ([topAd.book hasBook]) {
            Book* book = topAd.book.book;
            LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
            detailVC.bookId = book.bookId;
            [self.navigationController pushViewController:detailVC animated:YES];
        }else {
            NSString* targetUrlStr = [topAd.ad.to stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            LMLaunchDetailViewController* launchDetailVC = [[LMLaunchDetailViewController alloc]init];
            launchDetailVC.urlString = targetUrlStr;
            [self.navigationController pushViewController:launchDetailVC animated:YES];
        }
    }
}

#pragma mark -LMChoiceCollectionTableViewCellDelegate
-(void)didClickedChoiceTableViewCellCollectionViewCellOfBook:(id)bookModel {
    if ([bookModel isKindOfClass:[Book class]]) {
        Book* book = (Book* )bookModel;
        if (book != nil) {
            LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
            detailVC.bookId = book.bookId;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
