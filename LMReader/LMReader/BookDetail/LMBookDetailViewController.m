//
//  LMBookDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/11.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMBookDetailTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMTool.h"
#import "LMBaseNavigationController.h"
#import "LMDatabaseTool.h"
#import "LMDownloadBookView.h"
#import "LMReaderBookViewController.h"
#import "LMAuthorBookViewController.h"
#import "PopoverView.h"
#import "LMRootViewController.h"
#import "LMShareView.h"
#import "LMShareMessage.h"
#import "LMRecommandMoreViewController.h"
#import "LMBookCatalogViewController.h"
#import "LMBookCommentTableViewCell.h"
#import "LMBookEditCommentViewController.h"
#import "LMBookCommentDetailViewController.h"
#import "LMLoginAlertView.h"
#import "LMProfileProtocolViewController.h"
#import "LMChoiceTableViewCellCollectionViewCell.h"
#import "LMCommentStarView.h"

@interface LMBookDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMBookCommentTableViewCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* relatedArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UILabel* briefLab;//小说简介
@property (nonatomic, strong) UIButton* showMoreBtn;//展开按钮
@property (nonatomic, strong) UIView* toolBarView;//toolBar
@property (nonatomic, strong) UIButton* addBtn;//加入书架 按钮
@property (nonatomic, strong) UIButton* downloadBtn;//下载 按钮
@property (nonatomic, strong) UIButton* readBtn;//开始阅读 按钮
@property (nonatomic, strong) Book* book;
@property (nonatomic, strong) NSMutableArray* commentArray;//评论

@property (nonatomic, strong) LMDownloadBookView* downloadView;//下载 视图

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//

@end

@implementation LMBookDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* commentCellIdentifier = @"commentCellIdentifier";
static NSString* cvCellIdentifier = @"cvCellIdentifier";

static CGFloat cellHeight = 60;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bookCoverWidth = 105.f;
    self.bookCoverHeight = 145.f;
    
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
    
    self.title = @"书籍详情";
    
    UIView* moreItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIButton* moreItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, moreItemView.frame.size.width, moreItemView.frame.size.height)];
    [moreItemBtn setImage:[[UIImage imageNamed:@"readerBook_More"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [moreItemBtn setTintColor:UIColorFromRGB(0x656565)];
    [moreItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 13)];
    [moreItemBtn addTarget:self action:@selector(clickedMoreItemButton:) forControlEvents:UIControlEventTouchUpInside];
    [moreItemView addSubview:moreItemBtn];
    UIBarButtonItem* moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreItemView];
    
    UIView* shareItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIButton* shareItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, shareItemView.frame.size.width, shareItemView.frame.size.height)];
    [shareItemBtn setImage:[[UIImage imageNamed:@"rightBarButtonItem_Share"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareItemBtn setTintColor:UIColorFromRGB(0x656565)];
    [shareItemBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 11, 9, 5)];
    [shareItemBtn addTarget:self action:@selector(clickedShareButton:) forControlEvents:UIControlEventTouchUpInside];
    [shareItemView addSubview:shareItemBtn];
    UIBarButtonItem* shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareItemView];
    
    self.navigationItem.rightBarButtonItems = @[moreItem, shareItem];
    
    //微信分享通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shareNewsSucceed:) name:weChatShareNotifyName object:nil];
    
    //评论刷新 通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshComment:) name:@"refreshComment" object:nil];
    
    self.commentArray = [NSMutableArray array];
    self.relatedArray = [NSMutableArray array];
    
    //加载数据
    [self loadBookDetailData];
}

//
-(void)refreshComment:(NSNotification* )notify {
    NSDictionary* infoDic = notify.userInfo;
    if (infoDic != nil && ![infoDic isKindOfClass:[NSNull class]] && infoDic.count > 0) {
        NSNumber* bookNum = [infoDic objectForKey:@"bookId"];
        if (bookNum != nil && ![bookNum isKindOfClass:[NSNull class]]) {
            UInt32 bookInt = bookNum.intValue;
            if (bookInt == self.bookId) {
                [self.tableView cancelNoRefreshData];
                
                [self loadBookDetailData];
            }
        }
    }
}

-(void)setupTableView {
    CGFloat naviHeight = 20 + 44;
    CGFloat toolBarHeight = 50;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
        toolBarHeight = 50 + 30;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - toolBarHeight) style:UITableViewStyleGrouped];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    [self.tableView setupNoRefreshData];
    [self.tableView setupNoMoreData];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBookDetailTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.tableView registerClass:[LMBookCommentTableViewCell class] forCellReuseIdentifier:commentCellIdentifier];
    [self.view addSubview:self.tableView];
}

-(void)setupFooterView {
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    footerView.backgroundColor = [UIColor colorWithRed:233.f/255 green:233.f/255 blue:233.f/255 alpha:1];
    if (self.relatedArray.count == 0) {
        self.tableView.tableFooterView = footerView;
        return;
    }
    
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 10, footerView.frame.size.width, 0)];
    vi.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:vi];
    
    UILabel* sectionLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, vi.frame.size.width, 20)];
    sectionLab.font = [UIFont systemFontOfSize:18];
    sectionLab.text = @"喜欢这本书的人还喜欢";
    [vi addSubview:sectionLab];
    
    UILabel* tempLab = [[UILabel alloc]initWithFrame:CGRectZero];
    tempLab.numberOfLines = 0;
    tempLab.lineBreakMode = NSLineBreakByTruncatingTail;
    tempLab.font = [UIFont systemFontOfSize:15];
    
    CGFloat itemStartY = sectionLab.frame.origin.y + sectionLab.frame.size.height;
    CGFloat itemHeight = 10 + self.bookCoverHeight + 10 + 10 + 20;
    CGFloat maxLabHeight = 25;
    for (NSInteger i = 0; i < self.relatedArray.count; i ++) {
        if (i == 0) {
            Book* subBook0 = [self.relatedArray objectAtIndex:i];
            tempLab.text = subBook0.name;
            CGSize tempLabSize0 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
            if (tempLabSize0.height > tempLab.font.lineHeight * 2) {
                tempLabSize0.height = tempLab.font.lineHeight * 2;
            }
            
            if (i + 1 < self.relatedArray.count) {
                Book* subBook1 = [self.relatedArray objectAtIndex:i + 1];
                tempLab.text = subBook1.name;
                CGSize tempLabSize1 = [tempLab sizeThatFits:CGSizeMake(self.bookCoverWidth, 9999)];
                if (tempLabSize1.height > tempLab.font.lineHeight * 2) {
                    tempLabSize1.height = tempLab.font.lineHeight * 2;
                }
                maxLabHeight = MAX(tempLabSize0.height, tempLabSize1.height);
            }
            
            if (i + 2 < self.relatedArray.count) {
                Book* subBook2 = [self.relatedArray objectAtIndex:i + 2];
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
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, itemStartY, self.view.frame.size.width, itemHeight + 20 * 2) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollEnabled = NO;
    [collectionView registerClass:[LMChoiceTableViewCellCollectionViewCell class] forCellWithReuseIdentifier:cvCellIdentifier];
    [vi addSubview:collectionView];
    
    UIButton* moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, collectionView.frame.origin.y + collectionView.frame.size.height, vi.frame.size.width, 40)];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [moreBtn setTitle:@"查看更多" forState:UIControlStateNormal];
    [moreBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(clickedSectionMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:moreBtn];
    
    vi.frame = CGRectMake(0, 10, footerView.frame.size.width, moreBtn.frame.origin.y + moreBtn.frame.size.height + 10);
    footerView.frame = CGRectMake(0, 0, self.view.frame.size.width, vi.frame.origin.y + vi.frame.size.height);
    
    self.tableView.tableFooterView = footerView;
}

//
-(void)clickedShareButton:(UIButton* )sender {
    __weak LMBookDetailViewController* weakSelf = self;
    
    LMShareView* shareView = [[LMShareView alloc]init];
    shareView.shareBlock = ^(LMShareViewType shareType) {
        NSString* shareUrl = [NSString stringWithFormat:@"http://m.yeseshuguan.com/book/%d/?shared=1", weakSelf.book.bookId];
        NSString* bookCoverUrl = @"";
        NSString* shareTitleStr = [NSString stringWithFormat:@"我正在【%@】APP看小说，小说全部都免费，太爽了", APPNAME];
        if (weakSelf.book != nil) {
            bookCoverUrl = weakSelf.book.pic;
            shareTitleStr = [NSString stringWithFormat:@"我正在【%@】APP看《%@》，值得一看", APPNAME, weakSelf.book.name];
        }
        NSString* shareBriefStr = @"";
        if (shareUrl != nil && shareUrl.length > 0) {
            UIImage* tempImg = [[SDImageCache sharedImageCache]imageFromCacheForKey:bookCoverUrl];
            if (tempImg == nil) {
                tempImg = [UIImage imageNamed:@"share_AppIcon"];
            }
            NSString* tempImgStr = bookCoverUrl;
            if (tempImg != nil && (shareType == LMShareViewTypeWeChat || shareType == LMShareViewTypeWeChatMoment)) {
                NSData* imgData = UIImageJPEGRepresentation(tempImg, 0.5);
                tempImg = [UIImage imageWithData:imgData];
                if (imgData.length / 1024 > 32) {//图片大于32KB，给默认图
                    tempImg = [UIImage imageNamed:@"share_AppIcon"];
                }
            }
            if (tempImg == nil) {
                tempImg = [UIImage imageNamed:@"share_AppIcon"];
            }
            
            if (shareType == LMShareViewTypeWeChat) {
                [LMShareMessage shareToWeChatWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isMoment:NO img:tempImg];
            }else if (shareType == LMShareViewTypeWeChatMoment) {
                [LMShareMessage shareToWeChatWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isMoment:YES img:tempImg];
            }else if (shareType == LMShareViewTypeQQ) {
                [LMShareMessage shareToQQWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isZone:NO imgStr:tempImgStr];
            }else if (shareType == LMShareViewTypeQQZone) {
                [LMShareMessage shareToQQWithTitle:shareTitleStr description:shareBriefStr urlStr:shareUrl isZone:YES imgStr:tempImgStr];
            }else if (shareType == LMShareViewTypeCopyLink) {
                [[UIPasteboard generalPasteboard]setString:shareUrl];
                
                [weakSelf showMBProgressHUDWithText:@"复制成功"];
            }
        }
    };
    [shareView startShow];
}

//微信分享通知
-(void)shareNewsSucceed:(NSNotification* )notify {
    NSDictionary* dic = notify.userInfo;
    if (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
        [self showMBProgressHUDWithText:@"分享失败"];
        return;
    }
    [self showMBProgressHUDWithText:@"分享成功"];
}

//
-(void)clickedMoreItemButton:(UIButton* )sender {
    NSMutableArray* actionArray = [NSMutableArray array];
    PopoverAction* shelfAction = [PopoverAction actionWithTitle:@"书架" handler:^(PopoverAction *action) {
        LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
        [rootVC backToTabBarControllerWithViewControllerIndex:0];
    }];
    [actionArray addObject:shelfAction];
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.style = PopoverViewStyleDefault;
    popoverView.hideAfterTouchOutside = YES;
    [popoverView showToView:sender withActions:actionArray];
}

-(void)loadBookDetailData {
    BookRelateReqBuilder* builder = [BookRelateReq builder];
    [builder setBookId:self.bookId];
    BookRelateReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:9 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 9) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookRelateRes* res = [BookRelateRes parseFromData:apiRes.body];
                    UInt32 isAdd = res.haveAdd;
                    self.book = res.book;
                    
                    [weakSelf setupTableView];
                    
                    [weakSelf setupHeaderViewWithState:isAdd];
                    
                    NSArray* arr = res.relateBooks;
                    if (arr.count > 0) {
                        if (arr.count > 3) {
                            [weakSelf.relatedArray addObjectsFromArray:[arr subarrayWithRange:NSMakeRange(0, 3)]];
                        }else {
                            weakSelf.relatedArray = [NSMutableArray arrayWithArray:arr];
                        }
                    }
                    
                    [weakSelf setupFooterView];
                    
                    //
                    [weakSelf setupToolBarView];
                    
                    if (isAdd == 1) {//已加入到书架
                        weakSelf.addBtn.selected = YES;
                    }else {//未加入到书架
                        weakSelf.addBtn.selected = NO;
                    }
                    NSArray* commentArr = res.book.comments;
                    if (commentArr.count > 0) {
                        weakSelf.commentArray = [NSMutableArray arrayWithArray:commentArr];
                    }
                    
                    [weakSelf.tableView reloadData];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            [weakSelf showReloadButton];
        } @finally {
            
        }
        
        [weakSelf hideNetworkLoadingView];
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

//刷新
-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self loadBookDetailData];
}

//头视图
-(void)setupHeaderViewWithState:(BOOL )isAdd {
    if (!self.headerView) {
        self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        self.headerView.backgroundColor = [UIColor whiteColor];
    }
    for (UIView* subvi in self.headerView.subviews) {
        [subvi removeFromSuperview];
    }
    NSString* picStr = [self.book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.bookCoverWidth, self.bookCoverHeight)];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    [iv sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage_Gray"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image && error == nil) {
            
        }else {
            iv.image = [UIImage imageNamed:@"defaultBookImage"];
        }
    }];
    [self.headerView addSubview:iv];
    
    if ([self.book hasMarkUrl]) {
        NSString* markUrlStr = [self.book.markUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        CGFloat markIVWidth = 50;
        CGFloat markTopSpace = 4;
        if (self.view.frame.size.width <= 320) {
            markIVWidth = 40;
            markTopSpace = 3;
        }
        UIImageView* markIV = [[UIImageView alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width - markIVWidth + markTopSpace, iv.frame.origin.y - markTopSpace, markIVWidth, markIVWidth)];
        [self.headerView addSubview:markIV];
        
        UIImage* markImg = [[SDImageCache sharedImageCache] imageFromCacheForKey:markUrlStr];
        if (markImg != nil) {
            markIV.image = markImg;
        }else {
            [markIV sd_setImageWithURL:[NSURL URLWithString:markUrlStr] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error == nil && image != nil) {
                    
                }
            }];
        }
    }
    
    UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width + 20, iv.frame.origin.y, self.headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, 20)];
    nameLab.numberOfLines = 0;
    nameLab.lineBreakMode = NSLineBreakByCharWrapping;
    nameLab.font = [UIFont systemFontOfSize:18];
    nameLab.text = self.book.name;
    [self.headerView addSubview:nameLab];
    CGSize nameSize = [nameLab sizeThatFits:CGSizeMake(self.headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, 9999)];
    
    CGFloat tempSpaceY = (self.bookCoverHeight - nameSize.height - 20 - 15 - 15) / 5;
    if (tempSpaceY < 0) {
        tempSpaceY = 0;
    }
    
    nameLab.frame = CGRectMake(iv.frame.origin.x + iv.frame.size.width + 20, iv.frame.origin.y + tempSpaceY, self.headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, nameSize.height);
    
    UILabel* typeLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height + tempSpaceY, 45, 20)];
    typeLab.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
    typeLab.textAlignment = NSTextAlignmentCenter;
    typeLab.font = [UIFont systemFontOfSize:12];
    typeLab.textColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
    NSArray* typeArr = self.book.bookType;
    typeLab.text = [typeArr objectAtIndex:0];
    [self.headerView addSubview:typeLab];
    CGRect typeFrame = typeLab.frame;
    CGSize typeSize = [typeLab sizeThatFits:CGSizeMake(9999, typeFrame.size.height)];
    typeLab.frame = CGRectMake(typeFrame.origin.x, typeFrame.origin.y, typeSize.width + 5, typeFrame.size.height);
    
    UILabel* stateLab = [[UILabel alloc]initWithFrame:CGRectMake(typeLab.frame.origin.x + typeLab.frame.size.width + 5, typeLab.frame.origin.y, 50, 20)];
    stateLab.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
    stateLab.textAlignment = NSTextAlignmentCenter;
    stateLab.textColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
    stateLab.font = [UIFont systemFontOfSize:12];
    [self.headerView addSubview:stateLab];
    NSString* stateStr = @"未知";
    BookState state = self.book.bookState;
    if (state == BookStateStateFinished) {
        stateStr = @"完结";
    }else if (state == BookStateStateUnknown) {
        stateStr = @"未知";
    }else if (state == BookStateStateWriting) {
        stateStr = @"连载中";
    }else if (state == BookStateStatePause) {
        stateStr = @"暂停";
    }
    stateLab.text = stateStr;
    CGRect stateFrame = stateLab.frame;
    CGSize stateSize = [stateLab sizeThatFits:CGSizeMake(9999, stateFrame.size.height)];
    stateLab.frame = CGRectMake(stateFrame.origin.x, stateFrame.origin.y, stateSize.width + 5, stateFrame.size.height);
    
    UILabel* readersLab = [[UILabel alloc]initWithFrame:CGRectMake(stateLab.frame.origin.x + stateLab.frame.size.width + 5, stateLab.frame.origin.y, 50, 20)];
    readersLab.backgroundColor = [UIColor colorWithRed:237.f/255 green:237.f/255 blue:237.f/255 alpha:1];
    readersLab.textAlignment = NSTextAlignmentCenter;
    readersLab.font = [UIFont systemFontOfSize:12];
    readersLab.textColor = [UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1];
    [self.headerView addSubview:readersLab];
    NSString* readerStr = @"";
    if (self.book.clicked / 10000 > 0) {
        readerStr = [NSString stringWithFormat:@"%d万人阅读", self.book.clicked/10000];
    }else if (self.book.clicked / 1000 > 0) {
        readerStr = [NSString stringWithFormat:@"%d千人阅读", self.book.clicked/1000];
    }else {
        readerStr = [NSString stringWithFormat:@"%u人阅读", self.book.clicked];
    }
    readersLab.text = readerStr;
    CGRect readersFrame = readersLab.frame;
    CGSize readersSize = [readersLab sizeThatFits:CGSizeMake(999, readersFrame.size.height)];
    readersLab.frame = CGRectMake(readersFrame.origin.x, readersFrame.origin.y, readersSize.width + 5, readersFrame.size.height);
    if (readersLab.frame.origin.x + readersLab.frame.size.width > self.view.frame.size.width) {
        readersLab.hidden = YES;
    }
    
    LMCommentStarView* starView = [[LMCommentStarView alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, typeLab.frame.origin.y + typeLab.frame.size.height + tempSpaceY, 80, 15)];
    starView.cancelStar = YES;
    [starView setupStarWithFloatCount:self.book.avgScore];
    [self.headerView addSubview:starView];
    
    UILabel* startLab = [[UILabel alloc]initWithFrame:CGRectMake(starView.frame.origin.x + starView.frame.size.width + 5, starView.frame.origin.y, 100, starView.frame.size.height)];
    startLab.font = [UIFont systemFontOfSize:12];
    startLab.textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
    startLab.text = [NSString stringWithFormat:@"%.1f", self.book.avgScore];
    [self.headerView addSubview:startLab];
    
    UIImageView* authorIV = [[UIImageView alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, starView.frame.origin.y + starView.frame.size.height + tempSpaceY, 15, 15)];
    authorIV.image = [UIImage imageNamed:@"bookAuthor"];
    [self.headerView addSubview:authorIV];
    
    UILabel* authorLab = [[UILabel alloc]initWithFrame:CGRectMake(authorIV.frame.origin.x + authorIV.frame.size.width + 5, authorIV.frame.origin.y, 100, 15)];
    authorLab.font = [UIFont systemFontOfSize:12];
    authorLab.textColor = THEMEORANGECOLOR;
    authorLab.text = self.book.author;
    [self.headerView addSubview:authorLab];
    CGRect authorFrame = authorLab.frame;
    CGSize authorSize = [authorLab sizeThatFits:CGSizeMake(9999, authorFrame.size.height)];
    authorLab.frame = CGRectMake(authorFrame.origin.x, authorFrame.origin.y, authorSize.width, authorFrame.size.height);
    
    authorLab.userInteractionEnabled = YES;
    UITapGestureRecognizer* authorTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedAuthorButton)];
    [authorLab addGestureRecognizer:authorTap];
    
    self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(20, iv.frame.origin.y + iv.frame.size.height + 20, self.headerView.frame.size.width - 20 * 2, 50)];
    self.briefLab.font = [UIFont systemFontOfSize:15];
    self.briefLab.numberOfLines = 0;
    self.briefLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.briefLab.text = [self.book.abstract stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.briefLab.textColor = [UIColor grayColor];
    [self.headerView addSubview:self.briefLab];
    
    CGRect briefFrame = self.briefLab.frame;
    CGSize briefSize = [self.briefLab sizeThatFits:CGSizeMake(briefFrame.size.width, CGFLOAT_MAX)];
    CGRect headerViewFrame = self.headerView.frame;
    if (briefSize.height > self.briefLab.font.lineHeight * 2) {
        self.briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, self.briefLab.font.lineHeight * 2);
        self.showMoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.headerView.frame.size.width - 20 * 2, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, 20, 20)];
        self.showMoreBtn.selected = NO;
        [self.showMoreBtn setImage:[UIImage imageNamed:@"bookDetail_Show_Normal"] forState:UIControlStateNormal];
        [self.showMoreBtn setImage:[UIImage imageNamed:@"bookDetail_Show_Selected"] forState:UIControlStateSelected];
        [self.showMoreBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 0)];
        [self.showMoreBtn addTarget:self action:@selector(clickedShowMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.showMoreBtn];
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 10 + 20;
    }else {
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefSize.height);
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + 20;
    }
    
    self.headerView.frame = headerViewFrame;
    self.tableView.tableHeaderView = self.headerView;
}

//
-(void)setupToolBarView {
    CGFloat toolBarHeight = 50;
    CGFloat toolBarStartY = self.view.frame.size.height - toolBarHeight;
    if ([LMTool isBangsScreen]) {
        toolBarHeight = 50 + 30;
        toolBarStartY = self.view.frame.size.height - toolBarHeight;
    }
    if (self.toolBarView) {
        [self.view bringSubviewToFront:self.toolBarView];
        return;
    }else {
        self.toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, toolBarStartY, self.view.frame.size.width, toolBarHeight)];
        self.toolBarView.backgroundColor = [UIColor whiteColor];
        [self.view insertSubview:self.toolBarView aboveSubview:self.tableView];
    }
    UIColor* orangeCo = [UIColor colorWithRed:248/255.f green:72/255.f blue:25/255.f alpha:1];
    self.addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 3, 50)];
    self.addBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.addBtn setTitle:@"加入书架" forState:UIControlStateNormal];
    [self.addBtn setTitle:@"已加入书架" forState:UIControlStateSelected];
    [self.addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(clickedAddButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.addBtn];
    
    self.readBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.addBtn.frame.origin.x + self.addBtn.frame.size.width, self.addBtn.frame.origin.y, self.addBtn.frame.size.width, self.addBtn.frame.size.height)];
    self.readBtn.backgroundColor = orangeCo;
    self.readBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.readBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.readBtn setTitle:@"开始阅读" forState:UIControlStateNormal];
    [self.readBtn addTarget:self action:@selector(clickedReadButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.readBtn];
    
    self.downloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.readBtn.frame.origin.x + self.readBtn.frame.size.width, self.addBtn.frame.origin.y, self.addBtn.frame.size.width, self.addBtn.frame.size.height)];
    self.downloadBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.downloadBtn.titleLabel.numberOfLines = 0;
    self.downloadBtn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.downloadBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"全书缓存" forState:UIControlStateNormal];
    [self.downloadBtn addTarget:self action:@selector(clickedDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.downloadBtn];
}

//点击作者名称
-(void)clickedAuthorButton {
    LMAuthorBookViewController* authorBookVC = [[LMAuthorBookViewController alloc]init];
    authorBookVC.author = self.book.author;
    [self.navigationController pushViewController:authorBookVC animated:YES];
}

//点击 加入书架 按钮
-(void)clickedAddButton:(UIButton* )sender {
    if (self.addBtn.selected == YES) {
        return;
    }
    UserBookStoreOperateType type = UserBookStoreOperateTypeOperateAdd;
    
    UserBookStoreOperateReqBuilder* builder = [UserBookStoreOperateReq builder];
    [builder setBookId:self.book.bookId];
    [builder setType:type];
    UserBookStoreOperateReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:4 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 4) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {//成功
                    UserBookBuilder* bookBuilder = [UserBook builder];
                    [bookBuilder setBook:weakSelf.book];
                    [bookBuilder setIsTop:0];
                    UserBook* userBook = [bookBuilder build];
                    
                    LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                    [tool saveUserBooksWithArray:@[userBook]];
                    
                    [weakSelf.addBtn setTitle:@"已加入书架" forState:UIControlStateNormal];
                    weakSelf.addBtn.selected = YES;
                    
                    //通知书架界面刷新
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBookShelfViewController" object:nil];
                    
                }else {
                    [weakSelf showMBProgressHUDWithText:@"添加失败"];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

//点击 下载 按钮
-(void)clickedDownloadButton:(UIButton* )sender {
//    加入书架
    [self clickedAddButton:self.addBtn];
    
    
    if (self.downloadView.isDownload == NO) {
//        [self showNetworkLoadingView];
        
        __weak LMBookDetailViewController* weakSelf = self;
        //先加载章节列表，根据章节列表来判断解析方式
        LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
        [tool queryBookReadRecordWithBookId:self.bookId recordBlock:^(BOOL hasRecord, NSString* chapterId, UInt32 sourceId, NSInteger offset) {
            NSInteger currentSourceId = 0;
            if (hasRecord) {
                currentSourceId = sourceId;
            }
            
            BookChapterReqBuilder* builder = [BookChapterReq builder];
            [builder setBookId:self.bookId];
            BookChapterReq* req = [builder build];
            NSData* reqData = [req data];
            LMNetworkTool* networkTool = [LMNetworkTool sharedNetworkTool];
            [networkTool postWithCmd:7 ReqData:reqData successBlock:^(NSData *successData) {
                @try {
                    FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                    if (apiRes.cmd == 7) {
                        ErrCode err = apiRes.err;
                        if (err == ErrCodeErrNone) {
                            BookChapterRes* res = [BookChapterRes parseFromData:apiRes.body];
                            NSArray* arr = res.chapters;
                            
                            [LMTool archiveBookCatalogListWithBookId:weakSelf.bookId catalogList:apiRes.body];//保存章节目录
                            
                            if (arr != nil && arr.count > 0) {//旧解析方式
                                NSMutableArray* bookChapterArr = [NSMutableArray array];
                                for (NSInteger i = 0; i < arr.count; i ++) {
                                    Chapter* tempChapter = [arr objectAtIndex:i];
                                    LMReaderBookChapter* bookChapter = [LMReaderBookChapter convertReaderBookChapterWithChapter:tempChapter];
                                    [bookChapterArr addObject:bookChapter];
                                }
                                //下载
                                [weakSelf.downloadView startDownloadOldParseBookWithBookId:weakSelf.bookId catalogList:bookChapterArr block:^(BOOL isFinished, BOOL isFailed, NSInteger totalCount, CGFloat progress) {
                                    
                                    NSString* btnTitleStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                                    if (progress == 1) {
                                        btnTitleStr = @"100%完成";
                                    }else {
                                        if (isFailed && totalCount < LMDownloadBookViewMaxCount) {
                                            [weakSelf clickedDownloadButton:weakSelf.downloadBtn];
                                        }else if (isFailed && totalCount >= LMDownloadBookViewMaxCount) {
                                            btnTitleStr = @"部分下载失败，请重试";//[NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];
                                        }
                                    }
                                    [weakSelf.downloadBtn setTitle:btnTitleStr forState:UIControlStateNormal];
                                }];
                                
                            }else {//新解析方式
                                NSArray<UrlReadParse* >* bookParseArr = res.book.parses;
                                NSInteger parseIndex = 0;
                                for (NSInteger i = 0; i < bookParseArr.count; i ++) {
                                    UrlReadParse* parse = [bookParseArr objectAtIndex:i];
                                    if (sourceId == parse.source.id) {
                                        parseIndex = i;
                                        break;
                                    }
                                }
                                if (bookParseArr.count > 0) {
                                    UrlReadParse* parse = [bookParseArr objectAtIndex:parseIndex];
                                    if ([parse hasApi]) {//json解析
                                        [weakSelf LoadJsonParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {
                                            //下载
                                            [weakSelf.downloadView startDownloadNewParseBookWithBookId:weakSelf.bookId catalogList:listArray parse:parse block:^(BOOL isFinished, BOOL isFailed, NSInteger totalCount, CGFloat progress) {
                                                
                                                NSString* btnTitleStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                                                if (progress == 1) {
                                                    btnTitleStr = @"100%完成";
                                                }else {
                                                    if (isFailed && totalCount < LMDownloadBookViewMaxCount) {
                                                        [weakSelf clickedDownloadButton:weakSelf.downloadBtn];
                                                    }else if (isFailed && totalCount >= LMDownloadBookViewMaxCount) {
                                                        btnTitleStr = @"部分下载失败，请重试";//[NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];
                                                    }
                                                }
                                                [weakSelf.downloadBtn setTitle:btnTitleStr forState:UIControlStateNormal];
                                            }];
                                        } failureBlock:^(NSError *error) {
                                            [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
                                        }];
                                    }else {//html解析
                                        [weakSelf loadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {//获取章节列表
                                            //下载
                                            [weakSelf.downloadView startDownloadNewParseBookWithBookId:weakSelf.bookId catalogList:listArray parse:parse block:^(BOOL isFinished, BOOL isFailed, NSInteger totalCount, CGFloat progress) {
                                                
                                                NSString* btnTitleStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                                                if (progress == 1) {
                                                    btnTitleStr = @"100%完成";
                                                }else {
                                                    if (isFailed && totalCount < LMDownloadBookViewMaxCount) {
                                                        [weakSelf clickedDownloadButton:weakSelf.downloadBtn];
                                                    }else if (isFailed && totalCount >= LMDownloadBookViewMaxCount) {
                                                        btnTitleStr = @"部分下载失败，请重试";//[NSString stringWithFormat:@"%.2f%% %@", progress * 100, @"部分下载失败，请重试"];
                                                    }
                                                }
                                                [weakSelf.downloadBtn setTitle:btnTitleStr forState:UIControlStateNormal];
                                            }];
                                            
                                        } failureBlock:^(NSError *error) {
                                            [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
                                        }];
                                    }
                                }else {
                                    [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
                                }
                            }
                        }else {
                            [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
                        }
                    }
                } @catch (NSException *exception) {
                    [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
                } @finally {
                    
                }
            } failureBlock:^(NSError *failureError) {//网络请求失败，获取之前缓存的目录列表
                [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
            }];
        }];
    }
}

//点击 开始阅读 按钮
-(void)clickedReadButton:(UIButton* )sender {
    LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
    readerBookVC.bookId = self.book.bookId;
    readerBookVC.bookName = self.book.name;
    readerBookVC.bookCover = self.book.pic;
    LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
    [self presentViewController:bookNavi animated:YES completion:nil];
}

//Chiang json解析章节列表
-(void)LoadJsonParseBookChaptersWithUrlReadParse:(UrlReadParse* )parse successBlock:(void (^) (NSArray* listArray))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    __weak LMBookDetailViewController* weakSelf = self;
    NSString* urlStr = parse.listUrl;
    [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
        @try {
            NSError* jsonError = nil;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:successData options:NSJSONReadingMutableLeaves error:&jsonError];
            if (jsonError != nil || dic == nil || [dic isKindOfClass:[NSNull class]] || dic.count == 0) {
                failureBlock(nil);
            }
            
            NSArray* tempArr = [LMTool jsonParseChapterListWithParse:parse originalDic:dic];
            
            if (tempArr.count > 0) {
                successBlock(tempArr);
                //保存新解析方式下章节列表
                [LMTool archiveNewParseBookCatalogListWithBookId:weakSelf.bookId catalogList:tempArr];
            }else {
                failureBlock(nil);
            }
        } @catch (NSException *exception) {
            failureBlock(nil);
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        failureBlock(nil);
    }];
}

//新解析方式 加载章节列表
-(void)loadNewParseBookChaptersWithUrlReadParse:(UrlReadParse* )parse successBlock:(void (^) (NSArray* listArray))successBlock failureBlock:(void (^) (NSError* error))failureBlock {
    __weak LMBookDetailViewController* weakSelf = self;
    NSString* urlStr = parse.listUrl;
    [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
        @try {
            NSMutableArray* listArr = [NSMutableArray array];
            
            NSArray* listStrArr = [parse.listParse componentsSeparatedByString:@","];
            NSStringEncoding encoding = [LMTool convertEncodingStringWithEncoding:parse.source.htmlcharset];
            NSString* originStr = [[NSString alloc]initWithData:successData encoding:encoding];
            NSData* changeData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
            TFHpple* doc = [[TFHpple alloc] initWithData:changeData isXML:NO];
            NSString* searchStr = [LMTool convertToHTMLStringWithListArray:listStrArr];
            NSArray* elementArr = [doc searchWithXPathQuery:searchStr];
            NSInteger listOffset = 0;//跳过前n章节
            if ([parse hasIoffset]) {
                listOffset = parse.ioffset;
            }
            for (NSInteger i = 0; i < elementArr.count; i ++) {
                if (i < listOffset) {
                    continue;
                }
                TFHppleElement* element = [elementArr objectAtIndex:i];
                LMReaderBookChapter* bookChapter = [[LMReaderBookChapter alloc]init];
                
                NSString* briefStr = [element objectForKey:@"href"];
                NSString* bookChapterUrlStr = [LMTool getChapterUrlStrWithHostUrlStr:urlStr briefStr:briefStr];
                
                bookChapter.url = bookChapterUrlStr;
                bookChapter.title = element.content;
                bookChapter.chapterId = [NSString stringWithFormat:@"%ld", i - listOffset];
                [listArr addObject:bookChapter];
            }
            if (listArr.count > 0) {
                successBlock(listArr);
                //保存新解析方式下章节列表
                [LMTool archiveNewParseBookCatalogListWithBookId:weakSelf.bookId catalogList:listArr];
            }else {
                failureBlock(nil);
            }
        } @catch (NSException *exception) {
            failureBlock(nil);
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        failureBlock(nil);
    }];
}

//点击 更多 按钮
-(void)clickedSectionMoreButton:(UIButton* )sender {
    //暂时跳转至“精选”-“兴趣推荐”页
    LMRecommandMoreViewController* recommandVC = [[LMRecommandMoreViewController alloc]init];
    [self.navigationController pushViewController:recommandVC animated:YES];
}

//展开 收起来
-(void)clickedShowMoreButton:(UIButton* )sender {
    CGRect briefFrame = self.briefLab.frame;
    CGSize briefSize = [self.briefLab sizeThatFits:CGSizeMake(briefFrame.size.width, CGFLOAT_MAX)];
    CGRect headerViewFrame = self.headerView.frame;
    if (self.showMoreBtn.selected == NO) {
        //展开
        self.showMoreBtn.selected = YES;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefSize.height + 10);
        self.showMoreBtn.frame = CGRectMake(self.headerView.frame.size.width - 20 * 2, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, 20, 20);
        headerViewFrame.size.height = self.showMoreBtn.frame.origin.y + self.showMoreBtn.frame.size.height + 10;//加10裕量
    }else {
        //收起
        self.showMoreBtn.selected = NO;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, self.briefLab.font.lineHeight * 2);
        self.showMoreBtn.frame = CGRectMake(self.headerView.frame.size.width - 20 * 2, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, 20, 20);
        headerViewFrame.size.height = self.showMoreBtn.frame.origin.y + self.showMoreBtn.frame.size.height + 10;//加10裕量
    }
    
    [UIView animateWithDuration:0.2 animations:^{
       self.headerView.frame = headerViewFrame;
        self.tableView.tableHeaderView = self.headerView;
    }];
}

//撰写评论
-(void)clickedEditCommentButton:(UIButton* )sender {
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        LMBookEditCommentViewController* editCommentVC = [[LMBookEditCommentViewController alloc]init];
        editCommentVC.bookId = self.bookId;
        [self.navigationController pushViewController:editCommentVC animated:YES];
        return;
    }else {
        __weak LMBookDetailViewController* weakSelf = self;
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        loginAV.loginBlock = ^(BOOL didLogined) {
            if (didLogined) {
                LMBookEditCommentViewController* editCommentVC = [[LMBookEditCommentViewController alloc]init];
                editCommentVC.bookId = weakSelf.bookId;
                [weakSelf.navigationController pushViewController:editCommentVC animated:YES];
            }
        };
        loginAV.protocolBlock = ^(BOOL clickedProtocol) {
            if (clickedProtocol) {
                LMProfileProtocolViewController* protocolVC = [[LMProfileProtocolViewController alloc]init];
                [weakSelf.navigationController pushViewController:protocolVC animated:YES];
            }
        };
        [loginAV startShow];
    }
}

//更多评论
-(void)clickedShowMoreCommentButton:(UIButton* )sender {
    if (self.commentArray.count > 0) {
        LMBookCommentDetailViewController* commentDetailVC = [[LMBookCommentDetailViewController alloc]init];
        commentDetailVC.bookId = self.bookId;
        commentDetailVC.bookName = self.book.name;
        [self.navigationController pushViewController:commentDetailVC animated:YES];
    }else {//无评论
        
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
        if (self.book != nil) {
            vi.backgroundColor = [UIColor colorWithRed:233/255.f green:233/255.f blue:233/255.f alpha:1];
        }
        return vi;
    }else if (section == 1) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        if (self.book == nil) {
            return vi;
        }
        
        UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 20)];
        lab.font = [UIFont systemFontOfSize:18];
        lab.text = @"用户评论";
        [vi addSubview:lab];
        
        if (self.commentArray.count > 0) {
            UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(vi.frame.size.width - 20 - 115, lab.frame.origin.y, 65, 20)];
            btn.titleLabel.font = [UIFont systemFontOfSize:18];
            [btn setTitle:@"更多评论" forState:UIControlStateNormal];
            [btn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickedShowMoreCommentButton:) forControlEvents:UIControlEventTouchUpInside];
            [vi addSubview:btn];
            
            UILabel* tempBtnLab = [[UILabel alloc]initWithFrame:CGRectZero];
            tempBtnLab.numberOfLines = 0;
            tempBtnLab.lineBreakMode = NSLineBreakByCharWrapping;
            tempBtnLab.font = [UIFont systemFontOfSize:18];
            tempBtnLab.text = @"更多评论";
            CGSize btnLabSize = [tempBtnLab sizeThatFits:CGSizeMake(9999, 20)];
            
            btn.frame = CGRectMake(vi.frame.size.width - 20 - btnLabSize.width, lab.frame.origin.y, btnLabSize.width, 20);
        }
        
        return vi;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
        if (self.book != nil) {
            vi.backgroundColor = [UIColor colorWithRed:233/255.f green:233/255.f blue:233/255.f alpha:1];
        }
        return vi;
    }else if (section == 1) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        if (self.book == nil) {
            return vi;
        }
        
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, vi.frame.size.height)];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(clickedEditCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        [vi addSubview:btn];
        
        UIImageView* writeCommentIV = [[UIImageView alloc]initWithFrame:CGRectMake(vi.frame.size.width / 2 - 50, 10, 20, 20)];
        writeCommentIV.tintColor = THEMEORANGECOLOR;
        writeCommentIV.image = [[UIImage imageNamed:@"editComment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn addSubview:writeCommentIV];
        
        UILabel* writeCommentLab = [[UILabel alloc]initWithFrame:CGRectMake(writeCommentIV.frame.origin.x + writeCommentIV.frame.size.width + 10, writeCommentIV.frame.origin.y, 80, writeCommentIV.frame.size.height)];
        writeCommentLab.textColor = THEMEORANGECOLOR;
        writeCommentLab.font = [UIFont systemFontOfSize:18];
        writeCommentLab.text = @"撰写评论";
        [btn addSubview:writeCommentLab];
        
        return vi;
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.commentArray.count;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }else if (section == 1) {
        return 50;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }else if (section == 1) {
        return 50;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        return cellHeight;
    }else if (section == 1) {
        if (self.commentArray.count > 0) {
            Comment* comment = [self.commentArray objectAtIndex:row];
            NSString* commentStr = comment.text;
            if (commentStr != nil && commentStr.length > 0) {
                CGFloat contentHeight = [LMBookCommentTableViewCell caculateLabelHeightWithWidth:self.view.frame.size.width - CommentAvatorIVWidth - 20 * 3 text:commentStr font:[UIFont systemFontOfSize:CommentContentFontSize] maxLines:0];
                
                return CommentAvatorIVWidth + 10 + contentHeight + 20 * 2;
            }else {
                return CommentAvatorIVWidth + 20 * 2;
            }
        }else {
            return 0;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        LMBookDetailTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMBookDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell showLineView:NO];
        
        NSString* contentStr = @"点击查看目录列表";
        if (self.book.lastChapter.chapterTitle != nil && self.book.lastChapter.chapterTitle.length > 0) {
            contentStr = self.book.lastChapter.chapterTitle;
        }
        cell.contentLab.text = contentStr;
        
        return cell;
    }else if (section == 1) {
        LMBookCommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:commentCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMBookCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commentCellIdentifier];
        }
        [cell showLineView:NO];
        cell.delegate = self;
        
        Comment* comment = [self.commentArray objectAtIndex:row];
        [cell setupContentWithComment:comment];
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            LMBookCatalogViewController* catalogVC = [[LMBookCatalogViewController alloc]init];
            catalogVC.bookId = self.bookId;
            catalogVC.bookNameStr = self.book.name;
            catalogVC.bookCoverStr = self.book.pic;
            catalogVC.fromWhich = 2;
            [self.navigationController pushViewController:catalogVC animated:YES];
        }
    }else if (section == 1) {
        
    }
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    
}

#pragma mark -LMBookCommentTableViewCellDelegate
-(void)bookCommentTableViewCellDidClickedLikeButton:(LMBookCommentTableViewCell *)cell {
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        
    }else {
        __weak LMBookDetailViewController* weakSelf = self;
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        loginAV.loginBlock = ^(BOOL didLogined) {
            if (didLogined) {
                LMBookEditCommentViewController* editCommentVC = [[LMBookEditCommentViewController alloc]init];
                editCommentVC.bookId = weakSelf.bookId;
                [weakSelf.navigationController pushViewController:editCommentVC animated:YES];
            }
        };
        loginAV.protocolBlock = ^(BOOL clickedProtocol) {
            if (clickedProtocol) {
                LMProfileProtocolViewController* protocolVC = [[LMProfileProtocolViewController alloc]init];
                [weakSelf.navigationController pushViewController:protocolVC animated:YES];
            }
        };
        [loginAV startShow];
    }
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    Comment* comment = [self.commentArray objectAtIndex:row];
    CommentDoType type = CommentDoTypeCommentUp;
    if (comment.isUp) {
        return;
    }
    CommentDoReqBuilder* builder = [CommentDoReq builder];
    [builder setType:type];
    [builder setCommentId:comment.id];
    CommentDoReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:38 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            [weakSelf hideNetworkLoadingView];
            
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 38) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    
                    [weakSelf showMBProgressHUDWithText:@"操作成功"];
                    
                    //刷新
                    [weakSelf loadBookDetailData];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

-(LMDownloadBookView *)downloadView {
    if (!_downloadView) {
        CGRect screenRect = [UIScreen mainScreen].bounds;
        _downloadView = [[LMDownloadBookView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 40)];
        [self.view addSubview:_downloadView];
    }
    return _downloadView;
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.relatedArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMChoiceTableViewCellCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cvCellIdentifier forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    
    Book* book = [self.relatedArray objectAtIndex:row];
    
    CGFloat itemHeight = collectionView.frame.size.height - 20 * 2;
    [cell setupWithBook:book ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.bookCoverWidth + 5 * 2 itemHeight:itemHeight nameFontSize:15 briefFontSize:12];
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    Book* book = [self.relatedArray objectAtIndex:row];
    
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.bookId = book.bookId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bookCoverWidth + 5 * 2, collectionView.frame.size.height - 20 * 2);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat spaceX = 20 - 5;
    CGFloat spaceY = 20;
    return UIEdgeInsetsMake(spaceY, spaceX, spaceY, spaceX);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20 - 5;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:weChatShareNotifyName object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshComment" object:nil];
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
