//
//  LMReaderRecommandViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/30.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMReaderRecommandViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMReaderRecommandTableViewCell.h"
#import "LMTool.h"

@interface LMReaderRecommandViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMReaderRecommandTableViewCellDelegate>

@property (nonatomic, strong) UILabel* explainLab;
@property (nonatomic, strong) UIButton* editCommentBtn;
@property (nonatomic, strong) UIButton* bookStoreBtn;
@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* readArray;
@property (nonatomic, strong) NSMutableArray* authorArray;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//
@property (nonatomic, assign) CGFloat bookFontScale;/**<封面 缩放比例*/

@end

@implementation LMReaderRecommandViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.readArray = [NSMutableArray array];
    self.authorArray = [NSMutableArray array];
    
    //
    [self loadReaderRecommandData];
}

-(void)setupViews {
    if (self.tableView != nil) {
        [self.tableView reloadData];
        return;
    }
    
    self.bookCoverWidth = 105.f;
    self.bookCoverHeight = 145.f;
    self.bookNameFontSize = 15;
    self.bookBriefFontSize = 12;
    
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
    
    self.bookCoverWidth -= 3;
    self.bookCoverHeight -= 5;
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView* topIV = [[UIImageView alloc]initWithFrame:CGRectMake((headerView.frame.size.width - 70) / 2, 20, 70, 70)];
    topIV.image = [UIImage imageNamed:@"readerRecommand_Top"];
    [headerView addSubview:topIV];
    
    self.explainLab = [[UILabel alloc]initWithFrame:CGRectMake(0, topIV.frame.origin.y + topIV.frame.size.height + 15, headerView.frame.size.width, 20)];
    self.explainLab.font = [UIFont systemFontOfSize:15];
    self.explainLab.textAlignment = NSTextAlignmentCenter;
    self.explainLab.textColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1];
    self.explainLab.text = @"恭喜你，读完最后一个章节啦";
    [headerView addSubview:self.explainLab];
    
    CGFloat btnWidth = 100;
    CGFloat btnSpace = (self.view.frame.size.width - btnWidth * 2) / 3;
    self.editCommentBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnSpace, self.explainLab.frame.origin.y + self.explainLab.frame.size.height + 20, btnWidth, 35)];
    self.editCommentBtn.layer.cornerRadius = self.editCommentBtn.frame.size.height / 2;
    self.editCommentBtn.layer.masksToBounds = YES;
    self.editCommentBtn.layer.borderWidth = 1;
    self.editCommentBtn.layer.borderColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1].CGColor;
    self.editCommentBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.editCommentBtn setTitle:@"写书评" forState:UIControlStateNormal];
    [self.editCommentBtn setTitleColor:[UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1] forState:UIControlStateNormal];
    [self.editCommentBtn addTarget:self action:@selector(clickedEditCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.editCommentBtn];
    
    self.bookStoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.editCommentBtn.frame.origin.x + self.editCommentBtn.frame.size.width + btnSpace, self.editCommentBtn.frame.origin.y, self.editCommentBtn.frame.size.width, self.editCommentBtn.frame.size.height)];
    self.bookStoreBtn.layer.cornerRadius = self.bookStoreBtn.frame.size.height / 2;
    self.bookStoreBtn.layer.masksToBounds = YES;
    self.bookStoreBtn.layer.borderWidth = 1;
    self.bookStoreBtn.layer.borderColor = [UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1].CGColor;
    self.bookStoreBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.bookStoreBtn setTitle:@"逛书城" forState:UIControlStateNormal];
    [self.bookStoreBtn setTitleColor:[UIColor colorWithRed:150.f/255 green:150.f/255 blue:150.f/255 alpha:1] forState:UIControlStateNormal];
    [self.bookStoreBtn addTarget:self action:@selector(clickedBookStoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.bookStoreBtn];
    
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.editCommentBtn.frame.origin.y + self.editCommentBtn.frame.size.height + 20);
    
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, naviHeight, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMReaderRecommandTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.tableView setupNoRefreshData];
    [self.tableView setupNoMoreData];
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = headerView;
}

//
-(void)loadReaderRecommandData {
    [self showNetworkLoadingView];
    
    CorrelationReqBuilder* builder = [CorrelationReq builder];
    [builder setBookid:self.bookId];
    CorrelationReq* req = [builder build];
    NSData* reqData = [req data];
    __weak LMReaderRecommandViewController* weakSelf = self;
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:48 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            [weakSelf hideReloadButton];
            
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 48) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    CorrelationRes* res = [CorrelationRes parseFromData:apiRes.body];
                    NSArray* arr = res.read;
                    if (arr.count > 0) {
                        [weakSelf.readArray removeAllObjects];
                        weakSelf.readArray = [NSMutableArray arrayWithArray:arr];
                    }
                    NSArray* arr2 = res.author;
                    if (arr2.count > 0) {
                        [weakSelf.authorArray removeAllObjects];
                        weakSelf.authorArray = [NSMutableArray arrayWithArray:arr2];
                    }
                    
                    [weakSelf setupViews];
                    
                    [weakSelf.tableView reloadData];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            [weakSelf showReloadButton];
        } @finally {
            [weakSelf hideNetworkLoadingView];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

//刷新
-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self loadReaderRecommandData];
}

//写书评
-(void)clickedEditCommentButton:(UIButton* )sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(readerRecommandViewControllerDidClickedEditCommentButton)]) {
        [self.delegate readerRecommandViewControllerDidClickedEditCommentButton];
    }
}

//逛书城
-(void)clickedBookStoreButton:(UIButton* )sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(readerRecommandViewControllerDidClickedBookStoreButton)]) {
        [self.delegate readerRecommandViewControllerDidClickedBookStoreButton];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    if (self.readArray.count > 0) {
        sectionCount ++;
    }
    if (self.authorArray.count > 0) {
        sectionCount ++;
    }
    return sectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10 + 20 + 25)];
    vi.backgroundColor = [UIColor whiteColor];
    
    UIView* grayVi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, 10)];
    grayVi.backgroundColor = [UIColor colorWithRed:230.f/255 green:230.f/255 blue:230.f/255 alpha:1];
    [vi addSubview:grayVi];
    
    UILabel* lab0 = [[UILabel alloc]initWithFrame:CGRectMake(20, grayVi.frame.origin.y + grayVi.frame.size.height + 20, 3, 25)];
    lab0.backgroundColor = THEMEORANGECOLOR;
    lab0.layer.cornerRadius = 1.5;
    lab0.layer.masksToBounds = YES;
    [vi addSubview:lab0];
    
    NSString* labText = @"";
    if (self.readArray.count > 0) {
        if (section == 0) {
            labText = @"读过本书用户还读过";
        }else if (section == 1) {
            labText = @"该作者还写过";
        }
    }else {
        if (self.authorArray.count > 0) {
            if (section == 0) {
                labText = @"该作者还写过";
            }
        }
    }
    
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(lab0.frame.origin.x + lab0.frame.size.width + 7, lab0.frame.origin.y, vi.frame.size.width - 20 * 2, 25)];
    lab.font = [UIFont systemFontOfSize:18];
    lab.text = labText;
    [vi addSubview:lab];
    
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.01)];
    vi.backgroundColor = [UIColor whiteColor];
    return vi;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10 + 20 + 25;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemHeight = 10 + self.bookCoverHeight + 10 + 20 + 10 + 20;
    CGFloat cellHeight = 20 * 2 + itemHeight;
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMReaderRecommandTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMReaderRecommandTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showLineView:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSArray* arr = nil;
    if (self.readArray.count > 0) {
        if (section == 0) {
            arr = self.readArray;
        }else if (section == 1) {
            arr = self.authorArray;
        }
    }else {
        if (self.authorArray.count > 0) {
            if (section == 0) {
                arr = self.authorArray;
            }
        }
    }
    
    if (arr != nil && arr.count > row) {
        CGFloat itemHeight = 10 + self.bookCoverHeight + 10 + 20 + 10 + 20;
        CGFloat cellHeight = 20 * 2 + itemHeight;
        [cell setupContentBookArray:arr cellHeight:cellHeight ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.bookCoverWidth + 5 * 2 nameFontSize:15 briefFontSize:12];
    }
    
    cell.delegate = self;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    [self.tableView stopRefresh];
    return;
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    [self.tableView stopLoadMoreData];
    return;
}

#pragma mark -LMReadRecommandTableViewCellDelegate
-(void)didClickedReaderRecommandTableViewCellCollectionViewCellOfBook:(id)clickedBook {
    if (clickedBook == nil) {
        return;
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(readerRecommandViewControllerDidClickedBook:)]) {
        [self.delegate readerRecommandViewControllerDidClickedBook:clickedBook];
    }
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
