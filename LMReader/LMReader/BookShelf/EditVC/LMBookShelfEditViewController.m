//
//  LMBookShelfEditViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/29.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfEditViewController.h"
#import "LMBaseRefreshCollectionView.h"
#import "LMBookShelfSquareCollectionViewCell.h"
#import "LMBookShelfListCollectionViewCell.h"
#import "LMDatabaseTool.h"
#import "LMTool.h"

@interface LMBookShelfEditViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView* navigationView;/**<顶视图*/
@property (nonatomic, strong) UIButton* allBtn;/**<全选btn*/
@property (nonatomic, strong) UILabel* titleLab;/**<标题lab*/
@property (nonatomic, strong) UIView* toolBarView;/**<底部视图*/
@property (nonatomic, strong) UIButton* cancelBtn;/**<取消btn*/
@property (nonatomic, strong) UIButton* deleteBtn;/**<删除btn*/

@property (nonatomic, strong) LMBaseRefreshCollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* selectedArray;
@property (nonatomic, assign) CGFloat bookCoverWidth;//
@property (nonatomic, assign) CGFloat bookCoverHeight;//
@property (nonatomic, assign) CGFloat bookFontScale;//


@end

@implementation LMBookShelfEditViewController


static NSString* squareCellIdentifier = @"squareCellIdentifier";
static NSString* listCellIdentifier = @"listCellIdentifier";

-(instancetype)init {
    self = [super init];
    if (self) {
        self.dataArray = [NSMutableArray array];
        self.selectedArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    
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
    
    CGFloat naviHeight = 20 + 44;
    CGFloat statusBarHeight = 20;
    CGFloat toolViewHeight = 49;
    CGFloat toolBtnHeight = 49;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
        statusBarHeight = 44;
        toolViewHeight = 83;
        toolBtnHeight = 49;
    }
    
    self.navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, naviHeight)];
    self.navigationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navigationView];
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, statusBarHeight, 100, naviHeight - statusBarHeight)];
    self.titleLab.font = [UIFont boldSystemFontOfSize:18];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.text = @"批量管理";
    [self.navigationView addSubview:self.titleLab];
    
    self.allBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, statusBarHeight, 120, naviHeight - statusBarHeight)];
    self.allBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.allBtn addTarget:self action:@selector(clickedAllButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:self.allBtn];
    [self setupAllButtonTitle];
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[LMBaseRefreshCollectionView alloc] initWithFrame:CGRectMake(0, naviHeight, self.view.frame.size.width, self.view.frame.size.height - naviHeight - toolViewHeight) collectionViewLayout:layout];
    if (@available(iOS 11.0, *)) {//
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView setupNoRefreshData];
    [self.collectionView setupNoMoreData];
    [self.collectionView registerClass:[LMBookShelfSquareCollectionViewCell class] forCellWithReuseIdentifier:squareCellIdentifier];
    [self.collectionView registerClass:[LMBookShelfListCollectionViewCell class] forCellWithReuseIdentifier:listCellIdentifier];
    [self.view insertSubview:self.collectionView belowSubview:self.navigationView];
    
    self.toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - toolViewHeight, self.view.frame.size.width, toolViewHeight)];
    self.toolBarView.backgroundColor = [UIColor whiteColor];
    self.toolBarView.layer.cornerRadius = 0;
    self.toolBarView.layer.masksToBounds = YES;
    self.toolBarView.layer.borderColor = [UIColor colorWithRed:233.f/255 green:233.f/255 blue:233.f/255 alpha:1].CGColor;
    self.toolBarView.layer.borderWidth = 1;
    [self.view addSubview:self.toolBarView];
    
    self.cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.toolBarView.frame.size.width / 2, toolBtnHeight)];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:116.f/255 green:116.f/255 blue:116.f/255 alpha:1] forState:UIControlStateNormal];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(clickedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.cancelBtn];
    
    self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.cancelBtn.frame.size.width, self.cancelBtn.frame.origin.y, self.cancelBtn.frame.size.width, self.cancelBtn.frame.size.height)];
    self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.deleteBtn setTitleColor:THEMEORANGECOLOR forState:UIControlStateNormal];
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(clickedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.deleteBtn];
    
    UILabel* lineLab = [[UILabel alloc]initWithFrame:CGRectMake(self.cancelBtn.frame.size.width, (self.cancelBtn.frame.size.height - 10) / 2, 1, 10)];
    lineLab.backgroundColor = [UIColor colorWithRed:145.f/255 green:145.f/255 blue:145.f/255 alpha:1];
    [self.toolBarView addSubview:lineLab];
}

//全选 按钮自适应标题
-(void)setupAllButtonTitle {
    NSString* titleStr = @"";
    if (self.selectedArray.count > 0) {
        if (self.selectedArray.count == self.dataArray.count) {
            titleStr = @"取消全选";
        }else {
            titleStr = [NSString stringWithFormat:@"全选(%ld)", self.dataArray.count];
        }
    }else {
        titleStr = [NSString stringWithFormat:@"全选(%ld)", self.dataArray.count];
    }
    
    CGRect btnRect = self.allBtn.frame;
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectZero];
    lab.numberOfLines = 0;
    lab.lineBreakMode = NSLineBreakByTruncatingTail;
    lab.font = self.allBtn.titleLabel.font;
    lab.text = titleStr;
    CGSize labSize = [lab sizeThatFits:CGSizeMake(9999, btnRect.size.height)];
    if (labSize.width > self.titleLab.frame.origin.x - btnRect.origin.x - 20) {
        labSize.width = self.titleLab.frame.origin.x - btnRect.origin.x - 20;
    }
    [self.allBtn setTitle:titleStr forState:UIControlStateNormal];
    self.allBtn.frame = CGRectMake(btnRect.origin.x, btnRect.origin.y, labSize.width, btnRect.size.height);
}

//点击 全选、取消全选 按钮
-(void)clickedAllButton:(UIButton* )sender {
    if (self.selectedArray.count > 0 && self.selectedArray.count == self.dataArray.count) {
        //取消全选
        [self.selectedArray removeAllObjects];
        [self setupAllButtonTitle];
        [self.collectionView reloadData];
        return;
    }
    
    //全选
    [self.selectedArray removeAllObjects];
    [self.selectedArray addObjectsFromArray:self.dataArray];
    [self setupAllButtonTitle];
    [self.collectionView reloadData];
}

//点击 取消 按钮
-(void)clickedCancelButton:(UIButton* )sender {
    BOOL resultChange = NO;
    if (self.deleteBtn.selected == YES) {
        resultChange = YES;
    }
    if (self.backBlock) {
        self.backBlock(YES, YES);//resultChange
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//点击 删除 按钮
-(void)clickedDeleteButton:(UIButton* )sender {
    if (self.selectedArray.count == 0) {
        [self showMBProgressHUDWithText:@"请选择书本"];
        return;
    }
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"确定删除？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self showNetworkLoadingView];
        
        NSMutableArray* delBooksArr = [NSMutableArray array];
        for (LMBookShelfModel* model in self.selectedArray) {
            NSNumber* bookIdNum = [NSNumber numberWithUnsignedInt:model.userBook.book.bookId];
            [delBooksArr addObject:bookIdNum];
        }
        UserBookStoreOperateReqBuilder* builder = [UserBookStoreOperateReq builder];
        [builder setBookId:0];
        [builder setBookIdsArray:delBooksArr];
        [builder setType:UserBookStoreOperateTypeOperateDel];
        UserBookStoreOperateReq* req = [builder build];
        NSData* reqData = [req data];
        
        __weak LMBookShelfEditViewController* weakSelf = self;
        
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:4 ReqData:reqData limitTime:5 successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 4) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {//成功
                        for (LMBookShelfModel* model in self.selectedArray) {
                            UserBook* userBook = model.userBook;
                            
                            //删除数据库 书
                            LMDatabaseTool* tool = [LMDatabaseTool sharedDatabaseTool];
                            [tool deleteUserBookWithBook:userBook.book];
                            
                            //删除数据库 阅读记录
                            [tool deleteBookReadRecordWithBookId:userBook.book.bookId];
                            
                            //删除缓存的目录列表
                            [LMTool deleteArchiveBookCatalogListWithBookId:userBook.book.bookId];
                            [LMTool deleteArchiveBookNewParseCatalogListWithBookId:userBook.book.bookId];
                            
                            //删除缓存的book
                            [LMTool deleteBookWithBookId:userBook.book.bookId];
                            
                            [weakSelf.dataArray removeObject:model];
                        }
                        weakSelf.deleteBtn.selected = YES;
                        
                        [weakSelf.selectedArray removeAllObjects];
                        
                        [weakSelf setupAllButtonTitle];
                        
                    }else if (err == ErrCodeErrCannotadddelmodify) {//无法增删改
                        
                    }else if (err == ErrCodeErrBooknotexist) {//书本不存在
                        
                    }
                }
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            } @finally {
                [weakSelf hideNetworkLoadingView];
                
                //遍历 设置最近阅读记录
                for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++) {
                    LMBookShelfModel* subModel = [weakSelf.dataArray objectAtIndex:i];
                    if (subModel.progressStr != nil && ![subModel.progressStr isKindOfClass:[NSNull class]] && subModel.progressStr.length > 0) {
                        subModel.isLastestRecord = YES;
                        break;
                    }
                }
                
                [weakSelf.collectionView reloadData];
            }
        } failureBlock:^(NSError *failureError) {
            [weakSelf hideNetworkLoadingView];
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        }];
    }];
    [alertController addAction:deleteAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    if (self.type == LMBookShelfTypeList) {
        LMBookShelfListCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:listCellIdentifier forIndexPath:indexPath];
        
        LMBookShelfModel* model = [self.dataArray objectAtIndex:row];
        
        cell.isEditting = YES;
        BOOL cellClicked = NO;
        if ([self.selectedArray containsObject:model]) {
            cellClicked = YES;
        }
        cell.isClicked = cellClicked;
        
        [cell setupSquareCellWithModel:model ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.view.frame.size.width];
        
        return cell;
    }else {
        LMBookShelfSquareCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:squareCellIdentifier forIndexPath:indexPath];
        
        LMBookShelfModel* model = [self.dataArray objectAtIndex:row];
        
        cell.isEditting = YES;
        BOOL cellClicked = NO;
        if ([self.selectedArray containsObject:model]) {
            cellClicked = YES;
        }
        cell.isClicked = cellClicked;
        
        CGFloat itemHeight = 5 + self.bookCoverHeight + 10 + 20 + 10 + 15;
        
        [cell setupSquareCellWithModel:model ivWidth:self.bookCoverWidth ivHeight:self.bookCoverHeight itemWidth:self.bookCoverWidth + 5 * 2 itemHeight:itemHeight];
        
        return cell;
    }
}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSInteger row = indexPath.row;
    LMBookShelfModel* model = [self.dataArray objectAtIndex:row];
    if ([self.selectedArray containsObject:model]) {
        [self.selectedArray removeObject:model];
    }else {
        [self.selectedArray addObject:model];
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    [self setupAllButtonTitle];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == LMBookShelfTypeList) {
        CGFloat itemHeight = self.bookCoverHeight + 20 * 2;
        return CGSizeMake(self.view.frame.size.width, itemHeight);
    }
    
    CGFloat itemHeight = 5 + self.bookCoverHeight + 10 + 20 + 10 + 15;
    return CGSizeMake(self.bookCoverWidth + 5 * 2, itemHeight);
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.type == LMBookShelfTypeList) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    CGFloat tempSpaceX = 20 - 5;
    CGFloat tempSpaceY = 20;
    return UIEdgeInsetsMake(tempSpaceY, tempSpaceX, tempSpaceY, tempSpaceX);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.type == LMBookShelfTypeList) {
        return 0;
    }
    return 20;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (self.type == LMBookShelfTypeList) {
        return 0;
    }
    return 20 - 5;
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
