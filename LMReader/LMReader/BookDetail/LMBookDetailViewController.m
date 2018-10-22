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
#import "LMBookDetailCatalogViewController.h"
#import "LMBookCommentTableViewCell.h"
#import "LMBookEditCommentViewController.h"
#import "LMBookCommentDetailViewController.h"
#import "LMLoginAlertView.h"
#import "LMProfileProtocolViewController.h"

@interface LMBookDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMBookCommentTableViewCellDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* relatedArray;
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIView* footerView;
@property (nonatomic, strong) UILabel* briefLab;//小说简介
@property (nonatomic, strong) UIButton* showMoreBtn;//展开按钮
@property (nonatomic, strong) UIView* toolBarView;//toolBar
@property (nonatomic, strong) UIButton* addBtn;//加入书架 按钮
@property (nonatomic, strong) UIButton* downloadBtn;//下载 按钮
@property (nonatomic, strong) UIButton* readBtn;//开始阅读 按钮
@property (nonatomic, strong) Book* book;
@property (nonatomic, strong) NSMutableArray* commentArray;//评论

@property (nonatomic, strong) LMDownloadBookView* downloadView;//下载 视图

@end

@implementation LMBookDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* commentCellIdentifier = @"commentCellIdentifier";

static CGFloat cellHeight = 50;
static CGFloat briefHeight = 50;
static CGFloat bookIVWidth = 75;
static CGFloat bookIVHeight = 100;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"书籍详情";
    
    UIView* moreItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIButton* moreItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, moreItemView.frame.size.width, moreItemView.frame.size.height)];
    [moreItemBtn setImage:[UIImage imageNamed:@"rightBarButtonItem_More_Black"] forState:UIControlStateNormal];
    [moreItemBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [moreItemBtn addTarget:self action:@selector(clickedMoreItemButton:) forControlEvents:UIControlEventTouchUpInside];
    [moreItemView addSubview:moreItemBtn];
    UIBarButtonItem* moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreItemView];
    
    UIView* shareItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIButton* shareItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, shareItemView.frame.size.width, shareItemView.frame.size.height)];
    [shareItemBtn setImage:[UIImage imageNamed:@"rightBarButtonItem_Share"] forState:UIControlStateNormal];
    [shareItemBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
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
    
    UIView* tempVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    self.tableView.tableFooterView = tempVi;
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
    PopoverAction* briefAction = [PopoverAction actionWithTitle:@"书架" handler:^(PopoverAction *action) {
        LMRootViewController* rootVC = [LMRootViewController sharedRootViewController];
        [rootVC backToTabBarControllerWithViewControllerIndex:0];
    }];
    [actionArray addObject:briefAction];
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
                    
                    //
                    [weakSelf setupToolBarView];
                    
                    if (isAdd == 1) {//已加入到书架
                        weakSelf.addBtn.selected = YES;
                    }else {//未加入到书架
                        weakSelf.addBtn.selected = NO;
                    }
                    NSArray* arr = res.relateBooks;
                    if (arr.count > 0) {
                        weakSelf.relatedArray = [NSMutableArray arrayWithArray:arr];
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
    CGFloat headerSpaceY = 10;
    CGFloat labHeight = 40;
    if (!self.headerView) {
        self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerSpaceY + 75 + labHeight * 2)];
        self.headerView.backgroundColor = [UIColor whiteColor];
    }
    for (UIView* subvi in self.headerView.subviews) {
        [subvi removeFromSuperview];
    }
    NSString* picStr = [self.book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(headerSpaceY, headerSpaceY, bookIVWidth, bookIVHeight)];
    iv.layer.borderColor = [UIColor colorWithRed:200.f / 255 green:200.f / 255 blue:200.f / 255 alpha:1].CGColor;
    iv.layer.borderWidth = 0.5;
    iv.layer.shadowColor = [UIColor grayColor].CGColor;
    iv.layer.shadowOffset = CGSizeMake(-5, 5);
    iv.layer.shadowOpacity = 0.4;
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    [iv sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage"]];
    [self.headerView addSubview:iv];
    
    UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width + headerSpaceY, iv.frame.origin.y, self.view.frame.size.width - bookIVWidth - headerSpaceY * 3, 20)];
    nameLab.numberOfLines = 0;
    nameLab.lineBreakMode = NSLineBreakByCharWrapping;
    nameLab.font = [UIFont systemFontOfSize:18];
    nameLab.text = self.book.name;
    [self.headerView addSubview:nameLab];
    CGSize nameSize = [nameLab sizeThatFits:CGSizeMake(self.view.frame.size.width - bookIVWidth - headerSpaceY * 3, 9999)];
    nameLab.frame = CGRectMake(iv.frame.origin.x + iv.frame.size.width + headerSpaceY, iv.frame.origin.y, self.view.frame.size.width - bookIVWidth - headerSpaceY * 3, nameSize.height);
    
    UILabel* authorLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height + 5, 100, 20)];
    authorLab.font = [UIFont systemFontOfSize:16];
    authorLab.textColor = THEMEORANGECOLOR;
    authorLab.text = self.book.author;
    [self.headerView addSubview:authorLab];
    CGRect authorFrame = authorLab.frame;
    CGSize authorSize = [authorLab sizeThatFits:CGSizeMake(9999, authorFrame.size.height)];
    authorLab.frame = CGRectMake(authorFrame.origin.x, authorFrame.origin.y, authorSize.width, authorFrame.size.height);
    
    authorLab.userInteractionEnabled = YES;
    UITapGestureRecognizer* authorTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedAuthorButton)];
    [authorLab addGestureRecognizer:authorTap];
    
    UILabel* typeLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, authorLab.frame.origin.y + authorLab.frame.size.height + 5, 45, 20)];
    typeLab.textAlignment = NSTextAlignmentCenter;
    typeLab.font = [UIFont systemFontOfSize:14];
    typeLab.textColor = [UIColor grayColor];
    NSArray* typeArr = self.book.bookType;
    typeLab.text = [typeArr objectAtIndex:0];
    [self.headerView addSubview:typeLab];
    CGRect typeFrame = typeLab.frame;
    CGSize typeSize = [typeLab sizeThatFits:CGSizeMake(9999, typeFrame.size.height)];
    typeLab.frame = CGRectMake(typeFrame.origin.x, typeFrame.origin.y, typeSize.width, typeFrame.size.height);
    
    UILabel* readersLab = [[UILabel alloc]initWithFrame:CGRectMake(typeLab.frame.origin.x + typeLab.frame.size.width + 10, typeLab.frame.origin.y, 50, 20)];
    readersLab.backgroundColor = [UIColor whiteColor];
    readersLab.textAlignment = NSTextAlignmentCenter;
    readersLab.font = [UIFont systemFontOfSize:14];
    readersLab.textColor = [UIColor grayColor];
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
    readersLab.frame = CGRectMake(readersFrame.origin.x, readersFrame.origin.y, readersSize.width, readersFrame.size.height);
    if (readersLab.frame.origin.x + readersLab.frame.size.width > self.view.frame.size.width) {
        readersLab.hidden = YES;
    }
    
    UILabel* stateLab = [[UILabel alloc]initWithFrame:CGRectMake(typeLab.frame.origin.x, typeLab.frame.origin.y + typeLab.frame.size.height + 5, 50, 20)];
    stateLab.textAlignment = NSTextAlignmentCenter;
    stateLab.layer.cornerRadius = 3;
    stateLab.layer.masksToBounds = YES;
    stateLab.backgroundColor = THEMEORANGECOLOR;
    stateLab.textColor = [UIColor whiteColor];
    stateLab.font = [UIFont systemFontOfSize:14];
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
    
    CGFloat chapterY = iv.frame.origin.y + iv.frame.size.height + 10;
    if (stateLab.frame.origin.y + stateLab.frame.size.height > iv.frame.origin.y + iv.frame.size.height) {
        iv.frame = CGRectMake(headerSpaceY, headerSpaceY, bookIVWidth, stateLab.frame.origin.y + stateLab.frame.size.height - headerSpaceY);
        chapterY = stateLab.frame.origin.y + stateLab.frame.size.height + 10;
    }
    
    UILabel* lab0 = [[UILabel alloc]initWithFrame:CGRectMake(10, chapterY + 10, 5, 20)];
    lab0.layer.cornerRadius = 2.5;
    lab0.layer.masksToBounds = YES;
    lab0.backgroundColor = THEMEORANGECOLOR;
    [self.headerView addSubview:lab0];
    
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(lab0.frame.origin.x + lab0.frame.size.width + 10, chapterY, 200, labHeight)];
    lab1.font = [UIFont boldSystemFontOfSize:18];
    lab1.text = @"小说简介";
    [self.headerView addSubview:lab1];
    
    self.briefLab = [[UILabel alloc]initWithFrame:CGRectMake(10, lab1.frame.origin.y + lab1.frame.size.height, self.headerView.frame.size.width - headerSpaceY * 2, briefHeight)];
    self.briefLab.font = [UIFont systemFontOfSize:16];
    self.briefLab.numberOfLines = 0;
    self.briefLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.briefLab.text = [self.book.abstract stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.briefLab.textColor = [UIColor grayColor];
    [self.headerView addSubview:self.briefLab];
    
    CGRect briefFrame = self.briefLab.frame;
    CGSize briefSize = [self.briefLab sizeThatFits:CGSizeMake(briefFrame.size.width, CGFLOAT_MAX)];
    CGRect headerViewFrame = self.headerView.frame;
    if (briefSize.height > briefHeight) {
        self.briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefHeight);
        self.showMoreBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.headerView.frame.size.width - 20) / 2, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, 20, 20)];
        self.showMoreBtn.selected = NO;
        [self.showMoreBtn setImage:[UIImage imageNamed:@"bookDetail_Show_Normal"] forState:UIControlStateNormal];
        [self.showMoreBtn setImage:[UIImage imageNamed:@"bookDetail_Show_Selected"] forState:UIControlStateSelected];
        [self.showMoreBtn addTarget:self action:@selector(clickedShowMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.showMoreBtn];
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + headerSpaceY + 20;
    }else {
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefSize.height);
        headerViewFrame.size.height = self.briefLab.frame.origin.y + self.briefLab.frame.size.height + headerSpaceY;
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
    [self.addBtn setTitleColor:orangeCo forState:UIControlStateNormal];
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
    [self.downloadBtn setTitleColor:orangeCo forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
    [self.downloadBtn addTarget:self action:@selector(clickedDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.downloadBtn];
    
    UIView* lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.toolBarView.frame.size.width, 1)];
    lineView1.backgroundColor = [UIColor colorWithRed:245 / 255.f green:245 / 255.f blue:245 / 255.f alpha:1];
    [self.toolBarView addSubview:lineView1];
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
        [tool queryBookReadRecordWithBookId:self.bookId recordBlock:^(BOOL hasRecord, UInt32 chapterId, UInt32 sourceId, NSInteger offset) {
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
                                [weakSelf.downloadView startDownloadBookWithBookId:weakSelf.bookId catalogList:bookChapterArr block:^(BOOL isFinished, CGFloat progress) {
                                    
                                    NSString* btnTitleStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                                    if (progress == 1) {
                                        btnTitleStr = @"100%完成";
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
                                    [weakSelf loadNewParseBookChaptersWithUrlReadParse:parse successBlock:^(NSArray *listArray) {//获取章节列表
                                        //下载
                                        [weakSelf.downloadView startDownloadNewParseBookWithBookId:weakSelf.bookId catalogList:listArray parse:parse block:^(BOOL isFinished, CGFloat progress) {
                                            
                                            NSString* btnTitleStr = [NSString stringWithFormat:@"%.2f%%", progress * 100];
                                            if (progress == 1) {
                                                btnTitleStr = @"100%完成";
                                            }
                                            [weakSelf.downloadBtn setTitle:btnTitleStr forState:UIControlStateNormal];
                                        }];
                                        
                                    } failureBlock:^(NSError *error) {
                                        [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
                                    }];
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
        
        
//        [self.downloadBtn setTitle:@"下载中" forState:UIControlStateNormal];
//
//        [self.downloadView startDownloadBookWithBookId:self.book.bookId success:^(BOOL isFinished, CGFloat progress) {
//            if (isFinished) {
//                [weakSelf.downloadBtn setTitle:@"已下载" forState:UIControlStateNormal];
//            }
//        } failure:^(BOOL netFailed) {
//            if (netFailed) {
//                [weakSelf.downloadBtn setTitle:@"下载失败" forState:UIControlStateNormal];
//            }
//        }];
    }
}

//点击 开始阅读 按钮
-(void)clickedReadButton:(UIButton* )sender {
    LMReaderBookViewController* readerBookVC = [[LMReaderBookViewController alloc]init];
    readerBookVC.bookId = self.book.bookId;
    readerBookVC.bookName = self.book.name;
    LMBaseNavigationController* bookNavi = [[LMBaseNavigationController alloc]initWithRootViewController:readerBookVC];
    [self presentViewController:bookNavi animated:YES completion:nil];
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
                bookChapter.chapterId = i - listOffset;
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

//点击 相关推荐 书籍
-(void)clickedBookImageView:(UITapGestureRecognizer* )tapGR {
    UIImageView* iv = (UIImageView* )tapGR.view;
    NSInteger tag = iv.tag;
    Book* selectedBook = [self.relatedArray objectAtIndex:tag];
    LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
    detailVC.bookId = selectedBook.bookId;
    [self.navigationController pushViewController:detailVC animated:YES];
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
        self.showMoreBtn.frame = CGRectMake((self.headerView.frame.size.width - 20) / 2, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, 20, 20);
        headerViewFrame.size.height = self.showMoreBtn.frame.origin.y + self.showMoreBtn.frame.size.height + 10;//加10裕量
    }else {
        //收起
        self.showMoreBtn.selected = NO;
        self.briefLab.frame = CGRectMake(briefFrame.origin.x, briefFrame.origin.y, briefFrame.size.width, briefHeight);
        self.showMoreBtn.frame = CGRectMake((self.headerView.frame.size.width - 20) / 2, self.briefLab.frame.origin.y + self.briefLab.frame.size.height, 20, 20);
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
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        if (self.book != nil) {
            vi.backgroundColor = [UIColor colorWithRed:233/255.f green:233/255.f blue:233/255.f alpha:1];
        }
        return vi;
    }else if (section == 1) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        
        UILabel* lab0 = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 5, 20)];
        lab0.layer.cornerRadius = 2.5;
        lab0.layer.masksToBounds = YES;
        lab0.backgroundColor = THEMEORANGECOLOR;
        [vi addSubview:lab0];
        
        UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(lab0.frame.origin.x + lab0.frame.size.width + 10, 0, 100, 40)];
        lab.font = [UIFont boldSystemFontOfSize:18];
        lab.text = @"用户评论";
        [vi addSubview:lab];
        
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(vi.frame.size.width - 40, lab.frame.origin.y, 40, 40)];
        btn.tintColor = [UIColor colorWithRed:220.f/255 green:110.f/255 blue:100.f/255 alpha:1];
        UIImage* btnImg = [[UIImage imageNamed:@"editComment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setImage:btnImg forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(8, 6, 8, 10)];
        [btn addTarget:self action:@selector(clickedEditCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        [vi addSubview:btn];
        return vi;
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        CGFloat ivSpaceX = (self.view.frame.size.width - bookIVWidth * self.relatedArray.count) / (self.relatedArray.count + 1);
        if (ivSpaceX < 15) {
            ivSpaceX = 15;
        }
        self.footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10 + 45 + ivSpaceX + bookIVHeight + 10 + 40 + ivSpaceX)];
        self.footerView.backgroundColor = [UIColor colorWithRed:233/255.f green:233/255.f blue:233/255.f alpha:1];
        for (UIView* subvi in self.footerView.subviews) {
            [subvi removeFromSuperview];
        }
        UIView* sectionBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, self.footerView.frame.size.width, self.footerView.frame.size.height - 10)];
        sectionBgView.backgroundColor = [UIColor whiteColor];
        [self.footerView addSubview:sectionBgView];
        
        UILabel* lab0 = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 5, 20)];
        lab0.layer.cornerRadius = 2.5;
        lab0.layer.masksToBounds = YES;
        lab0.backgroundColor = THEMEORANGECOLOR;
        [sectionBgView addSubview:lab0];
        
        UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(lab0.frame.origin.x + lab0.frame.size.width + 10, 5, 200, 40)];
        lab1.font = [UIFont boldSystemFontOfSize:18];
        lab1.text = @"相关推荐";
        [sectionBgView addSubview:lab1];
        
        UIButton* sectionMoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(sectionBgView.frame.size.width - 60, lab1.frame.origin.y, 60, lab1.frame.size.height)];
        NSMutableAttributedString* btnStr = [[NSMutableAttributedString alloc]initWithString:@"更多>" attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle), NSForegroundColorAttributeName : [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1], NSFontAttributeName : [UIFont systemFontOfSize:16]}];
        [sectionMoreBtn setAttributedTitle:btnStr forState:UIControlStateNormal];
        [sectionMoreBtn addTarget:self action:@selector(clickedSectionMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [sectionBgView addSubview:sectionMoreBtn];
        
        UIScrollView* footerScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, lab1.frame.origin.y + lab1.frame.size.height + ivSpaceX, self.view.frame.size.width, bookIVHeight + 10 + 40)];
        footerScrollView.showsVerticalScrollIndicator = NO;
        footerScrollView.showsHorizontalScrollIndicator = NO;
        [sectionBgView addSubview:footerScrollView];
        
        for (NSInteger i = 0; i < self.relatedArray.count; i ++) {
            Book* tempBook = [self.relatedArray objectAtIndex:i];
            NSString* picStr = [tempBook.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(ivSpaceX + (ivSpaceX + bookIVWidth)*i, 0, bookIVWidth, bookIVHeight)];
            iv.tag = i;
            iv.userInteractionEnabled = YES;
            iv.layer.shadowColor = [UIColor grayColor].CGColor;
            iv.layer.shadowOffset = CGSizeMake(-5, 5);
            iv.layer.shadowOpacity = 0.4;
            [iv sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage"]];
            [footerScrollView addSubview:iv];
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedBookImageView:)];
            [iv addGestureRecognizer:tap];
            
            UILabel* lab2 = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x - ivSpaceX/2, iv.frame.origin.y + bookIVHeight + 10, bookIVWidth + ivSpaceX, 40)];
            lab2.font = [UIFont systemFontOfSize:14];
            lab2.textAlignment = NSTextAlignmentCenter;
            lab2.numberOfLines = 2;
            lab2.lineBreakMode = NSLineBreakByTruncatingMiddle;
            lab2.text = tempBook.name;
            [footerScrollView addSubview:lab2];
        }
        footerScrollView.contentSize = CGSizeMake(ivSpaceX * (self.relatedArray.count + 1) + bookIVWidth * self.relatedArray.count, 0);
        return self.footerView;
        
    }else if (section == 1) {
        NSString* btnTitleStr = @"暂无评论";
        UIColor* btnTitleColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
        if (self.commentArray.count > 0) {
            btnTitleStr = @"更多评论";
            btnTitleColor = THEMEORANGECOLOR;
        }
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, vi.frame.size.height)];
        btn.backgroundColor = [UIColor whiteColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitleColor:btnTitleColor forState:UIControlStateNormal];
        [btn setTitle:btnTitleStr forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickedShowMoreCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        [vi addSubview:btn];
        
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
        return 1;
    }else if (section == 1) {
        return 40;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        CGFloat ivSpaceX = (self.view.frame.size.width - bookIVWidth * self.relatedArray.count) / (self.relatedArray.count + 1);
        if (ivSpaceX < 15) {
            ivSpaceX = 15;
        }
        return 10 + 45 + ivSpaceX + bookIVHeight + 10 + 40 + ivSpaceX;
    }else if (section == 1) {
        return 50;
    }
    return 10;
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
                CGFloat contentHeight = [LMBookCommentTableViewCell caculateLabelHeightWithWidth:self.view.frame.size.width - 10 * 2 text:commentStr font:[UIFont systemFontOfSize:CommentContentFontSize] maxLines:0];
                
                return CommentAvatorIVWidth + CommentStarViewHeight + contentHeight + 10 * 4;
            }else {
                return CommentAvatorIVWidth + CommentStarViewHeight + 10 * 3;
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
        if (row == self.commentArray.count - 1) {
            [cell showLineView:NO];
        }else {
            [cell showLineView:YES];
        }
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
            LMBookDetailCatalogViewController* catalogVC = [[LMBookDetailCatalogViewController alloc]init];
            catalogVC.bookId = self.bookId;
            catalogVC.bookName = self.book.name;
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
