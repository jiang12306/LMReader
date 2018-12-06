//
//  LMSearchViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/10.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMSearchViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMTypeBookStoreTableViewCell.h"
#import "LMBookDetailViewController.h"
#import "LMSearchBarView.h"
#import "LMSearchRelatedTableViewCell.h"
#import "LMPinYinSearch.h"
#import "LMTool.h"
#import "LMSearchBeforeViewController.h"
#import "LMAuthorBookViewController.h"
#import "LMSearchRelatedModel.h"
#import "LMSearchAuthorTableViewCell.h"
#import "LMSearchHelpBottomAlertView.h"
#import "LMSearchHelpBookAlertView.h"
#import "LMSearchUserInstructionsView.h"

@interface LMSearchViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, LMSearchBarViewDelegate>

@property (nonatomic, strong) LMSearchBeforeViewController* searchBeforeVC;

@property (nonatomic, strong) NSMutableArray* matchArray;/**<匹配结果数组*/
@property (nonatomic, strong) UITableView* matchTableView;/**<*/
@property (nonatomic, strong) NSMutableArray* historyArray;/**<搜索历史*/

@property (nonatomic, strong) LMSearchHelpBottomAlertView* bottomAV;/**<找书提示bottom条*/

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, strong) NSMutableArray* authorsArray;//搜索结果作者数组
@property (nonatomic, strong) NSMutableArray* resultArray;//搜索结果
@property (nonatomic, strong) NSMutableArray* relatedArray;//相关结果
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isEnd;//是否最后一页
@property (nonatomic, assign) BOOL isRefreshing;//是否正在刷新中
@property (nonatomic, copy) NSString* searchStr;

@property (nonatomic, strong) LMSearchBarView* titleView;

@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//
@property (nonatomic, assign) CGFloat bookNameFontSize;//
@property (nonatomic, assign) CGFloat bookBriefFontSize;//

@end

@implementation LMSearchViewController

static NSString* cellIdentifier = @"cellIdentifier";
static NSString* adCellIdentifier = @"adCellIdentifier";
static NSString* historyCellIdentifier = @"historyCellIdentifier";
static NSString* authorCellIdentifier = @"authorCellIdentifier";

static NSString* searchDataKey = @"searchHistoryData";

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.titleView resignFirstResponse];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bookCoverWidth = 105.f;
    self.bookCoverHeight = 145.f;
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
    
    self.titleView = [[LMSearchBarView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 60 - 20, 30)];
    self.titleView.delegate = self;
    self.navigationItem.titleView = self.titleView;
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMSearchAuthorTableViewCell class] forCellReuseIdentifier:authorCellIdentifier];
    [self.tableView registerClass:[LMTypeBookStoreTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    __weak LMSearchViewController* weakSelf = self;
    self.bottomAV = [[LMSearchHelpBottomAlertView alloc]initWithFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, 30)];// + self.tableView.frame.size.height - 30
    self.bottomAV.backgroundColor = [UIColor colorWithRed:240.f/255 green:240.f/255 blue:240.f/255 alpha:1];
    self.bottomAV.clickBlock = ^(BOOL didClick) {
        CGFloat spaceX = 40;
        if (weakSelf.view.frame.size.width <= 320) {
            spaceX = 20;
        }
        LMSearchHelpBookAlertView* av = [[LMSearchHelpBookAlertView alloc]initWithFrame:CGRectMake(0, 0, weakSelf.view.frame.size.width - spaceX * 2, 100)];
        [av startShow];
    };
    [self.view insertSubview:self.bottomAV aboveSubview:self.tableView];
    self.bottomAV.hidden = YES;
    
    self.searchBeforeVC = [[LMSearchBeforeViewController alloc]init];
    self.searchBeforeVC.cleanBlock = ^(BOOL didClean) {
        [weakSelf deleteAllSearchHistoryData];
    };
    self.searchBeforeVC.historyBlock = ^(NSString *selectedStr) {
        [weakSelf.titleView resignFirstResponse];
        [weakSelf.titleView startInputWithText:selectedStr shouldBecomeFirstResponse:NO];
        weakSelf.searchStr = selectedStr;
        weakSelf.page = 0;
        weakSelf.isEnd = NO;
        [weakSelf.tableView cancelNoMoreData];
        [weakSelf loadSearchDataWithPage:weakSelf.page isRefreshingOrLoadMoreData:NO];
        
        weakSelf.matchTableView.hidden = YES;
        weakSelf.searchBeforeVC.view.hidden = YES;
        [weakSelf saveSearchHistoryWithText:selectedStr];
    };
    self.searchBeforeVC.stringBlock = ^(NSString *selectedStr) {
        LMAuthorBookViewController* authorBookVC = [[LMAuthorBookViewController alloc]init];
        authorBookVC.author = selectedStr;
        [weakSelf.navigationController pushViewController:authorBookVC animated:YES];
        
        [weakSelf saveSearchHistoryWithText:selectedStr];
    };
    self.searchBeforeVC.bookBlock = ^(UInt32 selectedBookId) {
        [weakSelf.titleView resignFirstResponse];
        
        LMBookDetailViewController* detailVC =  [[LMBookDetailViewController alloc]init];
        detailVC.bookId = selectedBookId;
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    };
    [self.view addSubview:self.searchBeforeVC.view];
    
    self.matchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    self.matchTableView.delegate = self;
    self.matchTableView.dataSource = self;
    self.matchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.matchTableView registerClass:[LMSearchRelatedTableViewCell class] forCellReuseIdentifier:historyCellIdentifier];
    [self.view addSubview:self.matchTableView];
    self.matchTableView.hidden = YES;
    
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
        self.matchTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
//    tap.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tap];
    
    self.page = 0;
    self.authorsArray = [NSMutableArray array];
    self.resultArray = [NSMutableArray array];
    self.relatedArray = [NSMutableArray array];
    self.matchArray = [NSMutableArray array];
    self.historyArray = [NSMutableArray array];
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSArray* arr = [userDefault objectForKey:searchDataKey];
    if (arr != nil && ![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
        [self.historyArray addObjectsFromArray:arr];
        
        [self.searchBeforeVC resetupSearchHistoryDataWithArray:arr];
    }
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    [self.titleView resignFirstResponse];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        CGRect viRect = CGRectMake(0, 0, self.view.frame.size.width, 0);
        CGRect labRect = CGRectMake(20, 20, viRect.size.width, 0);
        NSString* str = @"搜索结果";
        if (self.isRefreshing) {
            if (section == 0) {
                if (self.resultArray.count == 0) {
                    str = @"无相关搜索结果";
                    viRect.size.height = 0;
                    labRect.origin.y = 0;
                    labRect.size.height = 0;
                }else {
                    viRect.size.height = 60 + self.bottomAV.frame.size.height;
                    labRect.origin.y = self.bottomAV.frame.size.height;
                    labRect.size.height = viRect.size.height - self.bottomAV.frame.size.height;
                }
            }else if (section == 1) {
                viRect.size.height = 0.01;
                labRect.size.height = 0.01;
                str = @"";
            }else if (section == 2) {
                if (self.relatedArray.count == 0) {
                    str = @"暂无相关推荐";
                    viRect.size.height = 0;
                    labRect.origin.y = 0;
                    labRect.size.height = 0;
                }else {
                    str = @"相关推荐";
                    viRect.size.height = 60;
                    labRect.origin.y = 0;
                    labRect.size.height = viRect.size.height;
                }
            }
        }else {
            if (section == 0) {
                if (self.resultArray.count == 0) {
                    str = @"无相关搜索结果";
                }
                viRect.size.height = 60 + self.bottomAV.frame.size.height;
                labRect.origin.y = self.bottomAV.frame.size.height;
                labRect.size.height = viRect.size.height - self.bottomAV.frame.size.height;
            }else if (section == 1) {
                viRect.size.height = 0.01;
                labRect.size.height = 0.01;
                str = @"";
            }else if (section == 2) {
                if (self.relatedArray.count == 0) {
                    str = @"暂无相关推荐";
                }else {
                    str = @"相关推荐";
                }
                viRect.size.height = 60;
                labRect.origin.y = 0;
                labRect.size.height = viRect.size.height;
            }
        }
        
        UIView* vi = [[UIView alloc]initWithFrame:viRect];
        vi.backgroundColor = [UIColor whiteColor];
        UILabel* lab = [[UILabel alloc]initWithFrame:labRect];
        lab.font = [UIFont systemFontOfSize:18];
        lab.text = str;
        [vi addSubview:lab];
        return vi;
    }else {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
        vi.backgroundColor = [UIColor whiteColor];
        
        return vi;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
        UIColor* viBGColor = [UIColor whiteColor];
        //    if (section == 2) {
        //        viBGColor = [UIColor grayColor];
        //    }
        vi.backgroundColor = viBGColor;
        return vi;
    }else {
        return [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return 3;
    }else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (section == 0) {
            return self.authorsArray.count;
        }else if (section == 1) {
            return self.resultArray.count;
        }else if (section == 2) {
            return self.relatedArray.count;
        }
        return 0;
    }else {
        return self.matchArray.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (self.isRefreshing) {
            if (section == 0) {
                if (self.authorsArray.count > 0) {
                    return 60 + self.bottomAV.frame.size.height;
                }
            }else if (section == 1) {
                return 0.01;
            }else if (section == 2) {
                if (self.relatedArray.count > 0) {
                    return 60;
                }
            }
            return 0.01;
        }
        
        if (section == 0) {
            return 60 + self.bottomAV.frame.size.height;
        }else if (section == 1) {
            return 0.01;
        }else if (section == 2) {
            return 60;
        }
        return 0;
    }else {
        return 0.01;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            return 60;
        }
        return self.bookCoverHeight + 20 * 2;
    }else {
        return 60;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (tableView == self.tableView) {
        if (section == 0) {
            LMSearchAuthorTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:authorCellIdentifier forIndexPath:indexPath];
            if (!cell) {
                cell = [[LMSearchAuthorTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:authorCellIdentifier];
            }
            [cell showLineView:NO];
            
            NSString* authorString = [self.authorsArray objectAtIndex:row];
            [cell setupWithAuthorString:authorString];
            
            return cell;
        }
        LMTypeBookStoreTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMTypeBookStoreTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        Book* book;
        if (section == 1) {
            book = [self.resultArray objectAtIndex:row];
        }else if (section == 2) {
            book = [self.relatedArray objectAtIndex:row];
        }
        
        [cell setupContentBook:book cellHeight:self.bookCoverHeight + 20 * 2 ivWidth:self.bookCoverWidth nameFontSize:self.bookNameFontSize briefFontSize:self.bookBriefFontSize];
        if (row == 0) {
            [self showBottomAlertView];
            if ([LMTool shouldShowSearchUserInstructionsView]) {
                CGFloat naviHeight = 20 + 44;
                if ([LMTool isBangsScreen]) {
                    naviHeight = 44 + 44;
                }
                LMSearchUserInstructionsView* searchUIV = [[LMSearchUserInstructionsView alloc]init];
                [searchUIV startShowWithStartPoint:CGPointMake(self.view.frame.size.width, naviHeight + self.bottomAV.frame.size.height)];
                //
                [LMTool updateSetShowSearchUserInstructionsView];
            }
        }
        return cell;
    }else {
        LMSearchRelatedTableViewCell* cell = [self.matchTableView dequeueReusableCellWithIdentifier:historyCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[LMSearchRelatedTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:historyCellIdentifier];
        }
        [cell showLineView:NO];
        
        LMSearchRelatedModel* model = [self.matchArray objectAtIndex:row];
        if (model.type == LMSearchRelatedModelAuthor) {
            cell.coverIV.image = [UIImage imageNamed:@"search_Author"];
            cell.textLab.text = model.bookAuthor;
        }else if (model.type == LMSearchRelatedModelBook) {
            cell.coverIV.image = [UIImage imageNamed:@"search_Book"];
            cell.textLab.text = model.bookName;
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.titleView resignFirstResponse];
    
    if (tableView == self.tableView) {
        Book* book;
        if (indexPath.section == 0) {
            NSString* authorStr = [self.authorsArray objectAtIndex:indexPath.row];
            LMAuthorBookViewController* authorBookVC = [[LMAuthorBookViewController alloc]init];
            authorBookVC.author = authorStr;
            [self.navigationController pushViewController:authorBookVC animated:YES];
            return;
        }else if (indexPath.section == 1) {
            book = [self.resultArray objectAtIndex:indexPath.row];
        }else if (indexPath.section == 2) {
            book = [self.relatedArray objectAtIndex:indexPath.row];
        }
        LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
        detailVC.bookId = book.bookId;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else {
        LMSearchRelatedModel* model = [self.matchArray objectAtIndex:indexPath.row];
        if (model.type == LMSearchRelatedModelAuthor) {
            LMAuthorBookViewController* authorBookVC = [[LMAuthorBookViewController alloc]init];
            authorBookVC.author = model.bookAuthor;
            [self.navigationController pushViewController:authorBookVC animated:YES];
        }else if (model.type == LMSearchRelatedModelBook) {
            LMBookDetailViewController* detailVC = [[LMBookDetailViewController alloc]init];
            detailVC.bookId = model.bookId;
            [self.navigationController pushViewController:detailVC animated:YES];
        }else {
            
        }
    }
}

//
-(void)loadSearchDataWithPage:(NSInteger )page isRefreshingOrLoadMoreData:(BOOL )loadMore {
    self.isRefreshing = YES;
    [self.tableView reloadData];
    
    BookSearchReqBuilder* builder = [BookSearchReq builder];
    [builder setPage:(UInt32)page];
    [builder setKw:self.searchStr];
    BookSearchReq* req = [builder build];
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMSearchViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:6 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 6) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    BookSearchRes* res = [BookSearchRes parseFromData:apiRes.body];
                    
                    NSArray* arr0 = res.authors;
                    NSArray* arr1 = res.books;
                    NSArray* arr2 = res.relateBooks;
                    
                    if (weakSelf.page == 0) {//第一页
                        [weakSelf.resultArray removeAllObjects];
                    }
                    
                    [weakSelf.authorsArray removeAllObjects];
                    [weakSelf.relatedArray removeAllObjects];
                    
                    [weakSelf.authorsArray addObjectsFromArray:arr0];
                    [weakSelf.resultArray addObjectsFromArray:arr1];
                    [weakSelf.relatedArray addObjectsFromArray:arr2];
                    
                    if (arr1 == nil || arr1.count == 0) {//最后一页
                        weakSelf.isEnd = YES;
                        [weakSelf.tableView setupNoMoreData];
                    }
                    weakSelf.page ++;
                    [weakSelf.tableView reloadData];
                }
            }
            
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
        weakSelf.isRefreshing = NO;
        [weakSelf hideNetworkLoadingView];
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
    } failureBlock:^(NSError *failureError) {
        weakSelf.isRefreshing = NO;
        [weakSelf hideNetworkLoadingView];
        if (loadMore) {
            [weakSelf.tableView stopLoadMoreData];
        }else {
            [weakSelf.tableView stopRefresh];
        }
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

//显示底部提示框
-(void)showBottomAlertView {
    self.bottomAV.hidden = NO;
}

//隐藏底部提示框
-(void)hideBottomAlertView {
    self.bottomAV.hidden = YES;
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [self.titleView resignFirstResponse];
    }else {
        
    }
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    self.page = 0;
    self.isEnd = NO;
    [self.tableView cancelNoMoreData];
    
    [self loadSearchDataWithPage:self.page isRefreshingOrLoadMoreData:NO];
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    if (self.isEnd) {
        return;
    }
    
    [self loadSearchDataWithPage:self.page isRefreshingOrLoadMoreData:YES];
}

#pragma mark -LMSearchBarViewDelegate
-(void)searchBarViewDidStartSearch:(NSString *)inputText {
    NSString* str = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.matchTableView.hidden = YES;
    
    if (str.length > 0) {
        self.searchBeforeVC.view.hidden = YES;
        
        //保存搜索历史
        [self saveSearchHistoryWithText:inputText];
        
        self.searchStr = inputText;
        self.page = 0;
        [self loadSearchDataWithPage:0 isRefreshingOrLoadMoreData:NO];
    }else {
        self.searchBeforeVC.view.hidden = NO;
    }
}

-(void)searchBarDidStartEditting:(NSString *)inputText {
    NSString* str = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (str.length > 0) {
        self.searchBeforeVC.view.hidden = YES;
        self.matchTableView.hidden = NO;
    }else {
        self.searchBeforeVC.view.hidden = NO;
        self.matchTableView.hidden = YES;
    }
}

-(void)searchBarDidStopEditting:(NSString *)inputText {
    NSString* str = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (self.isRefreshing) {
        self.searchBeforeVC.view.hidden = YES;
        self.matchTableView.hidden = YES;
    }else {
        if (str.length > 0) {
            self.searchBeforeVC.view.hidden = YES;
            self.matchTableView.hidden = NO;
        }else {
            self.searchBeforeVC.view.hidden = NO;
            self.matchTableView.hidden = YES;
        }
    }
}

-(void)searchBarDidChangeText:(NSString *)inputText {
    NSString* str = [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (str.length > 0) {
        self.matchTableView.hidden = NO;
        self.searchBeforeVC.view.hidden = YES;
        BookSearchReqBuilder* builder = [BookSearchReq builder];
        [builder setPage:0];
        [builder setKw:str];
        BookSearchReq* req = [builder build];
        NSData* reqData = [req data];
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:6 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 6) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        BookSearchRes* res = [BookSearchRes parseFromData:apiRes.body];
                        NSArray* arr1 = res.authors;
                        NSArray* arr2 = res.books;
                        NSArray* resultArr1 = [LMSearchRelatedModel convertToElementArrayWithAuthorArray:arr1];
                        NSArray* resultArr2 = [LMSearchRelatedModel convertToElementArrayWithBookArray:arr2];
                        
                        [self.matchArray removeAllObjects];
                        
                        NSArray* authorArr = [LMPinYinSearch searchWithOriginalArray:resultArr1 andSearchText:str andSearchByPropertyName:@"bookAuthor"];
                        if (authorArr != nil && authorArr.count > 0) {
                            [self.matchArray addObjectsFromArray:authorArr];
                        }
                        NSArray* bookArr = [LMPinYinSearch searchWithOriginalArray:resultArr2 andSearchText:str andSearchByPropertyName:@"bookName"];
                        if (bookArr != nil && bookArr.count > 0) {
                            [self.matchArray addObjectsFromArray:bookArr];
                        }
                        if (self.matchArray.count == 0) {
                            self.matchTableView.hidden = YES;
                        }
                        
                    }else {
                        [self.matchArray removeAllObjects];
                        self.matchTableView.hidden = YES;
                    }
                    [self.matchTableView reloadData];
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        } failureBlock:^(NSError *failureError) {
            
        }];
    }else {
        [self.matchArray removeAllObjects];
        [self.matchTableView reloadData];
        
        self.matchTableView.hidden = YES;
        self.searchBeforeVC.view.hidden = NO;
    }
}

//保存某一条搜索记录
-(void)saveSearchHistoryWithText:(NSString* )text {
    if (text != nil && ![text isKindOfClass:[NSNull class]] && text.length > 0) {
        if (self.historyArray.count > 0) {
            if ([self.historyArray containsObject:text]) {
                [self.historyArray removeObject:text];
            }
            if (self.historyArray.count >= 100) {
                [self.historyArray removeObjectAtIndex:99];
            }
            [self.historyArray insertObject:text atIndex:0];
        }else {
            [self.historyArray addObject:text];
        }
        NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
        if (self.historyArray.count > 0) {
            [userDefault setObject:self.historyArray forKey:searchDataKey];
        }else {
            [userDefault removeObjectForKey:searchDataKey];
        }
        [userDefault synchronize];
        
        //
        [self.searchBeforeVC resetupSearchHistoryDataWithArray:self.historyArray];
    }
}

//删除所有搜索记录
-(void)deleteAllSearchHistoryData {
    [self.historyArray removeAllObjects];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:searchDataKey];
    [userDefaults synchronize];
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
