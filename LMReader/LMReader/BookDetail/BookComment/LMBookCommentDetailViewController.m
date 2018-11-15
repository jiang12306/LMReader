//
//  LMBookCommentDetailViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/9/25.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBookCommentDetailViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMTool.h"
#import "LMBookCommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "LMBookEditCommentViewController.h"
#import "LMShareView.h"
#import "LMShareMessage.h"
#import "LMLoginAlertView.h"
#import "LMProfileProtocolViewController.h"

@interface LMBookCommentDetailViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMBookCommentTableViewCellDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;//
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UIView* controlView;//
@property (nonatomic, strong) UIButton* controlHotBtn;
@property (nonatomic, strong) UIButton* controlLastBtn;
@property (nonatomic, strong) UIButton* hotBtn;
@property (nonatomic, strong) UIButton* lastBtn;
@property (nonatomic, assign) NSInteger currentIndex;/**<1.最热评论；2.最新评论*/

@property (nonatomic, strong) Book* book;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//

@end

@implementation LMBookCommentDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";

-(void)viewDidLoad {
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
    
    UIView* shareItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIButton* shareItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, shareItemView.frame.size.width, shareItemView.frame.size.height)];
    [shareItemBtn setImage:[[UIImage imageNamed:@"rightBarButtonItem_Share"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareItemBtn setTintColor:UIColorFromRGB(0x656565)];
    [shareItemBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    [shareItemBtn addTarget:self action:@selector(clickedShareButton:) forControlEvents:UIControlEventTouchUpInside];
    [shareItemView addSubview:shareItemBtn];
    UIBarButtonItem* shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareItemView];
    
    self.navigationItem.rightBarButtonItem = shareItem;
    
    NSString* titleStr = @"评论";
    if (self.bookName != nil && self.bookName.length > 0) {
        titleStr = [NSString stringWithFormat:@"《%@》书评", self.bookName];
    }
    self.title = titleStr;
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMBookCommentTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    //评论刷新 通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshComment:) name:@"refreshComment" object:nil];
    
    self.currentIndex = 1;
    self.page = 0;
    self.dataArray = [NSMutableArray array];
    
    [self loadBookCommentWithPage:self.page loadMore:NO];
}

//
-(void)clickedShareButton:(UIButton* )sender {
    __weak LMBookCommentDetailViewController* weakSelf = self;
    
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

//
-(void)refreshComment:(NSNotification* )notify {
    NSDictionary* infoDic = notify.userInfo;
    if (infoDic != nil && ![infoDic isKindOfClass:[NSNull class]] && infoDic.count > 0) {
        NSNumber* bookNum = [infoDic objectForKey:@"bookId"];
        if (bookNum != nil && ![bookNum isKindOfClass:[NSNull class]]) {
            UInt32 bookInt = bookNum.intValue;
            if (bookInt == self.bookId) {
                [self.tableView cancelNoRefreshData];
                
                self.page = 0;
                self.currentIndex = 1;
                self.hotBtn.selected = YES;
                self.controlHotBtn.selected = YES;
                self.lastBtn.selected = NO;
                self.lastBtn.selected = NO;
                
                [self loadBookCommentWithPage:self.page loadMore:NO];
            }
        }
    }
}

-(void)setupTableHeaderView {
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    NSString* picStr = [self.book.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    UIImageView* iv = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, self.bookCoverWidth, self.bookCoverHeight)];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    [iv sd_setImageWithURL:[NSURL URLWithString:picStr] placeholderImage:[UIImage imageNamed:@"defaultBookImage"]];
    [headerView addSubview:iv];
    
    if ([self.book hasMarkUrl]) {
        NSString* markUrlStr = [self.book.markUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        CGFloat markIVWidth = 50;
        CGFloat markTopSpace = 4;
        if (self.view.frame.size.width <= 320) {
            markIVWidth = 40;
            markTopSpace = 3;
        }
        UIImageView* markIV = [[UIImageView alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width - markIVWidth + markTopSpace, iv.frame.origin.y - markTopSpace, markIVWidth, markIVWidth)];
        [headerView addSubview:markIV];
        
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
    
    UILabel* briefLab = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width + 20, iv.frame.origin.y, headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, 20)];
    briefLab.numberOfLines = 0;
    briefLab.lineBreakMode = NSLineBreakByTruncatingTail;
    briefLab.font = [UIFont systemFontOfSize:12];
    NSString* briefStr = self.book.abstract;
    if (briefStr == nil || briefStr.length == 0) {
        briefStr = @"暂无简介";
    }
    briefLab.text = briefStr;
    [headerView addSubview:briefLab];
    CGSize briefSize = [briefLab sizeThatFits:CGSizeMake(headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, 9999)];
    if (briefSize.height > briefLab.font.lineHeight * 3) {
        briefSize.height = briefLab.font.lineHeight * 3;
    }
    
    UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width + 20, iv.frame.origin.y, headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, 20)];
    nameLab.numberOfLines = 0;
    nameLab.lineBreakMode = NSLineBreakByCharWrapping;
    nameLab.font = [UIFont systemFontOfSize:18];
    nameLab.text = self.book.name;
    [headerView addSubview:nameLab];
    CGSize nameSize = [nameLab sizeThatFits:CGSizeMake(headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, 9999)];
    
    CGFloat tempSpaceY = (self.bookCoverHeight - nameSize.height - briefSize.height - 20) / 4;
    if (tempSpaceY < 0) {
        tempSpaceY = 0;
    }
    nameLab.frame = CGRectMake(iv.frame.origin.x + iv.frame.size.width + 20, iv.frame.origin.y + tempSpaceY, headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, nameSize.height);
    briefLab.frame = CGRectMake(nameLab.frame.origin.x, nameLab.frame.origin.y + nameLab.frame.size.height + tempSpaceY, headerView.frame.size.width - iv.frame.origin.x - iv.frame.size.width - 20 * 2, briefSize.height);
    
    UIButton* editCommentBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerView.frame.size.width - 20 - 25, briefLab.frame.origin.y + briefLab.frame.size.height + tempSpaceY, 25, 25)];
    editCommentBtn.tintColor = THEMEORANGECOLOR;
    UIImage* btnImg = [[UIImage imageNamed:@"editComment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [editCommentBtn setImage:btnImg forState:UIControlStateNormal];
    [editCommentBtn setImageEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    [editCommentBtn addTarget:self action:@selector(clickedEditCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editCommentBtn];
    
    UILabel* commentCountLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, editCommentBtn.frame.origin.y, editCommentBtn.frame.origin.x - iv.frame.origin.x - iv.frame.size.width - 20 * 2, 20)];
    commentCountLab.font = [UIFont systemFontOfSize:15];
    commentCountLab.textColor = [UIColor grayColor];
    NSString* commentCountStr = @"暂无评论";
    if (self.book.commentsCount > 0) {
        commentCountStr = [NSString stringWithFormat:@"评论：%d条", self.book.commentsCount];
    }
    commentCountLab.text = commentCountStr;
    [headerView addSubview:commentCountLab];
    
    CGFloat btnStartY = iv.frame.origin.y + iv.frame.size.height + 20;
    if (commentCountLab.frame.origin.y + commentCountLab.frame.size.height > iv.frame.origin.y + iv.frame.size.height) {
        btnStartY = commentCountLab.frame.origin.y + commentCountLab.frame.size.height + 20;
    }
    self.hotBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, btnStartY, (headerView.frame.size.width - 20 * 3) / 2, 40)];
    self.hotBtn.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    self.hotBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.hotBtn setTitle:@"最热评论" forState:UIControlStateNormal];
    [self.hotBtn setTitleColor:[UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1] forState:UIControlStateNormal];
    [self.hotBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateSelected];
    [self.hotBtn addTarget:self action:@selector(clickedHeaderTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.hotBtn];
    
    self.lastBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.hotBtn.frame.origin.x + self.hotBtn.frame.size.width + 20, self.hotBtn.frame.origin.y, self.hotBtn.frame.size.width, self.hotBtn.frame.size.height)];
    self.lastBtn.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    self.lastBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.lastBtn setTitle:@"最新评论" forState:UIControlStateNormal];
    [self.lastBtn setTitleColor:[UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1] forState:UIControlStateNormal];
    [self.lastBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateSelected];
    [self.lastBtn addTarget:self action:@selector(clickedHeaderTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.lastBtn];
    
    if (self.currentIndex == 2) {
        self.lastBtn.selected = YES;
        self.hotBtn.selected = NO;
    }else {
        self.hotBtn.selected = YES;
        self.lastBtn.selected = NO;
    }
    
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.hotBtn.frame.origin.y + self.hotBtn.frame.size.height + 20);
    
    if (!self.controlView) {
        self.controlView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        self.controlView.backgroundColor = [UIColor whiteColor];
        
        self.controlHotBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, self.hotBtn.frame.size.width, 40)];
        self.controlHotBtn.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        self.controlHotBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.controlHotBtn setTitle:@"最热评论" forState:UIControlStateNormal];
        [self.controlHotBtn setTitleColor:[UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1] forState:UIControlStateNormal];
        [self.controlHotBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateSelected];
        [self.controlHotBtn addTarget:self action:@selector(clickedHeaderTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.controlView addSubview:self.controlHotBtn];
        
        self.controlLastBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.controlHotBtn.frame.origin.x + self.controlHotBtn.frame.size.width + 20, self.controlHotBtn.frame.origin.y, self.hotBtn.frame.size.width, self.hotBtn.frame.size.height)];
        self.controlLastBtn.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
        self.controlLastBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.controlLastBtn setTitle:@"最新评论" forState:UIControlStateNormal];
        [self.controlLastBtn setTitleColor:[UIColor colorWithRed:50.f/255 green:50.f/255 blue:50.f/255 alpha:1] forState:UIControlStateNormal];
        [self.controlLastBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateSelected];
        [self.controlLastBtn addTarget:self action:@selector(clickedHeaderTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.controlView addSubview:self.controlLastBtn];
        
        if (self.currentIndex == 2) {
            self.controlLastBtn.selected = YES;
            self.controlHotBtn.selected = NO;
        }else {
            self.controlHotBtn.selected = YES;
            self.controlLastBtn.selected = NO;
        }
        
        [self.view insertSubview:self.controlView aboveSubview:self.tableView];
        self.controlView.hidden = YES;
    }
    
    self.tableView.tableHeaderView = headerView;
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
        __weak LMBookCommentDetailViewController* weakSelf = self;
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

-(void)loadBookCommentWithPage:(NSInteger )page loadMore:(BOOL )loadMore {
    UInt32 sortType = 1;
    if (self.currentIndex == 2) {
        sortType = 0;
    }
    BookCommentsReqBuilder* builder = [BookCommentsReq builder];
    [builder setPage:(UInt32 )page];
    [builder setSort:sortType];
    [builder setBookId:self.bookId];
    BookCommentsReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMBookCommentDetailViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:37 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 37) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookCommentsRes* res = [BookCommentsRes parseFromData:apiRes.body];
                    if (page == 0) {
                        [self.dataArray removeAllObjects];
                    }
                    NSArray* arr = res.commentList;
                    if (arr.count > 0) {
                        [self.dataArray addObjectsFromArray:arr];
                    }else {
                        [self.tableView setupNoMoreData];
                    }
                    self.book = res.book;
                    
                    [self setupTableHeaderView];
                    
                    self.page ++;
                    
                    [self.tableView reloadData];
                    
                    if (self.dataArray.count == 0) {
                        [self showMBProgressHUDWithText:@"暂无评论"];
                    }
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            [weakSelf hideNetworkLoadingView];
            if (loadMore) {
                [weakSelf.tableView stopLoadMoreData];
            }else {
                [weakSelf.tableView stopRefresh];
            }
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
    }];
}

//
-(void)clickedHeaderTitleButton:(UIButton* )sender {
    if (sender.selected == YES) {
        return;
    }
    [self.tableView cancelNoRefreshData];
    [self.tableView cancelNoMoreData];
    
    if (sender == self.hotBtn || sender == self.controlHotBtn) {
        
        self.currentIndex = 1;
        
        self.hotBtn.selected = YES;
        self.controlHotBtn.selected = YES;
        self.lastBtn.selected = NO;
        self.controlLastBtn.selected = NO;
    }else if (sender == self.lastBtn || sender == self.controlLastBtn) {
        
        self.currentIndex = 2;
        
        self.lastBtn.selected = YES;
        self.controlLastBtn.selected = YES;
        self.hotBtn.selected = NO;
        self.controlHotBtn.selected = NO;
    }
    
    self.page = 0;
    [self loadBookCommentWithPage:self.page loadMore:NO];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* tempVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    if (self.book != nil) {
        tempVi.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    }
    return tempVi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.dataArray.count == 0 && self.book != nil) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, vi.frame.size.height)];
        lab.font = [UIFont systemFontOfSize:16];
        lab.textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = @"暂无相关评论";
        [vi addSubview:lab];
        return vi;
    }
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.dataArray.count == 0 && self.book != nil) {
        return 40;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    Comment* comment = [self.dataArray objectAtIndex:row];
    NSString* commentStr = comment.text;
    if (commentStr != nil && commentStr.length > 0) {
        CGFloat contentHeight = [LMBookCommentTableViewCell caculateLabelHeightWithWidth:self.view.frame.size.width - CommentAvatorIVWidth - 20 * 3 text:commentStr font:[UIFont systemFontOfSize:CommentContentFontSize] maxLines:0];
        
        return CommentAvatorIVWidth + 10 + contentHeight + 20 * 2;
    }else {
        return CommentAvatorIVWidth + 20 * 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    LMBookCommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBookCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showLineView:NO];
    cell.delegate = self;
    
    Comment* comment = [self.dataArray objectAtIndex:row];
    [cell setupContentWithComment:comment];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    [self.tableView cancelNoMoreData];
    [self loadBookCommentWithPage:self.page loadMore:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    [self loadBookCommentWithPage:self.page loadMore:YES];
}

#pragma mark -LMBookCommentTableViewCellDelegate
-(void)bookCommentTableViewCellDidClickedLikeButton:(LMBookCommentTableViewCell *)cell {
    LoginedRegUser* regUser = [LMTool getLoginedRegUser];
    if (regUser != nil) {
        
    }else {
        __weak LMBookCommentDetailViewController* weakSelf = self;
        LMLoginAlertView* loginAV = [[LMLoginAlertView alloc]init];
        loginAV.loginBlock = ^(BOOL didLogined) {
            if (didLogined) {
                [weakSelf showMBProgressHUDWithText:@"登录成功"];
            }
        };
        loginAV.protocolBlock = ^(BOOL clickedProtocol) {
            if (clickedProtocol) {
                LMProfileProtocolViewController* protocolVC = [[LMProfileProtocolViewController alloc]init];
                [weakSelf.navigationController pushViewController:protocolVC animated:YES];
            }
        };
        [loginAV startShow];
        return;
    }
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    Comment* comment = [self.dataArray objectAtIndex:row];
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
    __weak LMBookCommentDetailViewController* weakSelf = self;
    
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
                    self.page = 0;
                    self.currentIndex = 1;
                    self.hotBtn.selected = YES;
                    self.controlHotBtn.selected = YES;
                    self.lastBtn.selected = NO;
                    self.lastBtn.selected = NO;
                    
                    [self loadBookCommentWithPage:self.page loadMore:NO];
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

#pragma mark -KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:@"contentOffset"]) {
        CGFloat originY = self.hotBtn.frame.origin.y - 20;
        CGFloat contentOffsetY = self.tableView.contentOffset.y;
        if (contentOffsetY >= originY) {
            self.controlView.hidden = NO;
        }else {
            self.controlView.hidden = YES;
        }
    }
}

-(void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refreshComment" object:nil];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
