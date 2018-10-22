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
#import "LMAuthorBookViewController.h"
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
@property (nonatomic, strong) UIButton* hotBtn;
@property (nonatomic, strong) UIButton* lastBtn;

@property (nonatomic, strong) UISegmentedControl* segmentedControl;
@property (nonatomic, strong) UISegmentedControl* titleSegmentedControl;

@property (nonatomic, strong) Book* book;

@end

@implementation LMBookCommentDetailViewController

static NSString* cellIdentifier = @"cellIdentifier";

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIView* shareItemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIButton* shareItemBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, shareItemView.frame.size.width, shareItemView.frame.size.height)];
    [shareItemBtn setImage:[UIImage imageNamed:@"rightBarButtonItem_Share"] forState:UIControlStateNormal];
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
                self.segmentedControl.selectedSegmentIndex = 0;
                self.titleSegmentedControl.selectedSegmentIndex = 0;
                
                [self loadBookCommentWithPage:self.page loadMore:NO];
            }
        }
    }
}

-(void)setupTableHeaderView {
    CGFloat headerSpaceY = 10;
    CGFloat bookIVWidth = 75;
    CGFloat bookIVHeight = 100;
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, bookIVHeight + 10 + 15)];
    headerView.backgroundColor = [UIColor whiteColor];
    
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
    [headerView addSubview:iv];
    
    UILabel* nameLab = [[UILabel alloc]initWithFrame:CGRectMake(iv.frame.origin.x + iv.frame.size.width + headerSpaceY, iv.frame.origin.y, self.view.frame.size.width - bookIVWidth - headerSpaceY * 3, 20)];
    nameLab.numberOfLines = 0;
    nameLab.lineBreakMode = NSLineBreakByCharWrapping;
    nameLab.font = [UIFont systemFontOfSize:18];
    nameLab.text = self.book.name;
    [headerView addSubview:nameLab];
    CGRect nameRect = nameLab.frame;
    CGSize nameSize = [nameLab sizeThatFits:CGSizeMake(nameRect.size.width, 9999)];
    nameLab.frame = CGRectMake(iv.frame.origin.x + iv.frame.size.width + headerSpaceY, iv.frame.origin.y, nameRect.size.width, nameSize.height);
    
    UILabel* authorLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, iv.frame.origin.y + (iv.frame.size.height - 20) / 2, 100, 20)];
    authorLab.font = [UIFont systemFontOfSize:16];
    authorLab.textColor = THEMEORANGECOLOR;
    authorLab.text = self.book.author;
    [headerView addSubview:authorLab];
    CGRect authorFrame = authorLab.frame;
    CGSize authorSize = [authorLab sizeThatFits:CGSizeMake(9999, authorFrame.size.height)];
    authorLab.frame = CGRectMake(authorFrame.origin.x, authorFrame.origin.y, authorSize.width, authorFrame.size.height);
    
    authorLab.userInteractionEnabled = YES;
    UITapGestureRecognizer* authorTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedAuthorButton)];
    [authorLab addGestureRecognizer:authorTap];
    
    UIButton* editCommentBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerView.frame.size.width - 10 - 25, iv.frame.origin.y + iv.frame.size.height - 25, 25, 25)];
    editCommentBtn.tintColor = [UIColor colorWithRed:220.f/255 green:110.f/255 blue:100.f/255 alpha:1];
    UIImage* btnImg = [[UIImage imageNamed:@"editComment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [editCommentBtn setImage:btnImg forState:UIControlStateNormal];
    [editCommentBtn setImageEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    [editCommentBtn addTarget:self action:@selector(clickedEditCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:editCommentBtn];
    
    UILabel* commentCountLab = [[UILabel alloc]initWithFrame:CGRectMake(nameLab.frame.origin.x, iv.frame.origin.y + iv.frame.size.height - 20, self.view.frame.size.width - bookIVWidth - headerSpaceY * 3, 20)];
    commentCountLab.font = [UIFont systemFontOfSize:14];
    commentCountLab.textColor = [UIColor grayColor];
    NSString* commentCountStr = @"暂无评论";
    if (self.book.commentsCount > 0) {
        commentCountStr = [NSString stringWithFormat:@"评论：%d条", self.book.commentsCount];
    }
    commentCountLab.text = commentCountStr;
    [headerView addSubview:commentCountLab];
    
    UILabel* lineLab = [[UILabel alloc]initWithFrame:CGRectMake(10, headerView.frame.size.height - 1, headerView.frame.size.width - 10 * 2, 1)];
    lineLab.backgroundColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1];
    [headerView addSubview:lineLab];
    
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"最热评论", @"最新评论"]];
    self.segmentedControl.frame = CGRectMake(10, iv.frame.origin.y + iv.frame.size.height + 20, headerView.frame.size.width - 20, 30);
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.tintColor = THEMEORANGECOLOR;
    if (self.titleSegmentedControl) {
        self.segmentedControl.selectedSegmentIndex = self.titleSegmentedControl.selectedSegmentIndex;
    }else {
        self.segmentedControl.selectedSegmentIndex = 0;
    }
    [self.segmentedControl addTarget:self action:@selector(clickedSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:self.segmentedControl];
    
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height + 10);
    
    if (!self.controlView) {
        self.controlView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        self.controlView.backgroundColor = [UIColor whiteColor];
        
        self.titleSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"最热评论", @"最新评论"]];
        self.titleSegmentedControl.frame = CGRectMake(10, 10, self.controlView.frame.size.width - 20, 30);
        self.titleSegmentedControl.backgroundColor = [UIColor whiteColor];
        self.titleSegmentedControl.tintColor = THEMEORANGECOLOR;
        self.titleSegmentedControl.selectedSegmentIndex = 0;
        [self.titleSegmentedControl addTarget:self action:@selector(clickedSegmentedControl:) forControlEvents:UIControlEventValueChanged];
        [self.controlView addSubview:self.titleSegmentedControl];
        
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

//点击作者名称
-(void)clickedAuthorButton {
    LMAuthorBookViewController* authorBookVC = [[LMAuthorBookViewController alloc]init];
    authorBookVC.author = self.book.author;
    [self.navigationController pushViewController:authorBookVC animated:YES];
}

-(void)loadBookCommentWithPage:(NSInteger )page loadMore:(BOOL )loadMore {
    UInt32 sortType = 1;
    if (self.segmentedControl.selectedSegmentIndex == 1) {
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
-(void)clickedSegmentedControl:(UISegmentedControl* )seg {
    [self.tableView cancelNoRefreshData];
    [self.tableView cancelNoMoreData];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.page = 0;
        [self loadBookCommentWithPage:self.page loadMore:NO];
    }else if (self.segmentedControl.selectedSegmentIndex == 1) {
        self.page = 0;
        [self loadBookCommentWithPage:self.page loadMore:NO];
    }
    
    if (seg == self.titleSegmentedControl) {
        self.segmentedControl.selectedSegmentIndex = seg.selectedSegmentIndex;
    }else if (seg == self.segmentedControl) {
        self.titleSegmentedControl.selectedSegmentIndex = seg.selectedSegmentIndex;
    }
    NSLog(@"###########titleControl = %ld, control = %ld", self.titleSegmentedControl.selectedSegmentIndex, self.segmentedControl.selectedSegmentIndex);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* tempVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
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
    return 0.01;
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
        CGFloat contentHeight = [LMBookCommentTableViewCell caculateLabelHeightWithWidth:self.view.frame.size.width - 10 * 2 text:commentStr font:[UIFont systemFontOfSize:CommentContentFontSize] maxLines:0];
        
        return CommentAvatorIVWidth + CommentStarViewHeight + contentHeight + 10 * 4;
    }else {
        return CommentAvatorIVWidth + CommentStarViewHeight + 10 * 3;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    LMBookCommentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMBookCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
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
                    self.segmentedControl.selectedSegmentIndex = 0;
                    self.titleSegmentedControl.selectedSegmentIndex = 0;
                    
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
        CGFloat originY = self.segmentedControl.frame.origin.y - 10;
        CGFloat contentOffsetY = self.tableView.contentOffset.y;
//        NSLog(@"originY = %f, contentOffsety = %f", originY, contentOffsetY);
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
