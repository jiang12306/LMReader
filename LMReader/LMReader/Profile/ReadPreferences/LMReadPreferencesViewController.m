//
//  LMReadPreferencesViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReadPreferencesViewController.h"
#import "LMReadPreferencesCollectionViewCell.h"
#import "LMNetworkTool.h"
#import "LMTool.h"

@interface LMReadPreferencesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) GenderType genderType;/**<默认 男*/
@property (nonatomic, strong) UIImageView* maleIV;
@property (nonatomic, strong) UIImageView* femaleIV;
@property (nonatomic, strong) UIImageView* maleSelectIV;
@property (nonatomic, strong) UIImageView* femaleSelectIV;
@property (nonatomic, strong) NSMutableArray* maleArray;
@property (nonatomic, strong) NSMutableArray* femaleArray;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSMutableArray* interestArray;
@property (nonatomic, strong) UICollectionView* collectionView;

@property (nonatomic, strong) UIButton* sendBtn;//提交 按钮

@end

@implementation LMReadPreferencesViewController

static NSString* cellId = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"阅读偏好";
    
    self.genderType = GenderTypeGenderMale;
    
    self.dataArray = [NSMutableArray array];
    self.interestArray = [NSMutableArray array];
    self.maleArray = [NSMutableArray array];
    self.femaleArray = [NSMutableArray array];
    
    
    
    [self loadMaleType];
    [self loadFemaleType];
}

-(void)setupSubviews {
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 40)];
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.font = [UIFont boldSystemFontOfSize:18];
    lab1.text = @"请选择您的读书类型";
    [self.view addSubview:lab1];
    
    UILabel* lab2 = [[UILabel alloc]initWithFrame:CGRectMake(0, lab1.frame.origin.y + lab1.frame.size.height, self.view.frame.size.width, 30)];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.font = [UIFont systemFontOfSize:15];
    lab2.text = @"我们将为您推荐更合适您的小说";
    [self.view addSubview:lab2];
    
    CGFloat viewWidth = self.view.frame.size.width/4;
    CGFloat viewHeight = viewWidth + 30;
    
    UIView* maleView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - viewWidth - 20, lab2.frame.origin.y + lab2.frame.size.height + 20, viewWidth, viewHeight)];
    maleView.backgroundColor = [UIColor whiteColor];
    maleView.layer.shadowColor = [UIColor grayColor].CGColor;
    maleView.layer.shadowOffset = CGSizeMake(0, 0);
    maleView.layer.shadowOpacity = 0.4;
    [self.view addSubview:maleView];
    
    UIBezierPath * malePath = [UIBezierPath bezierPath];
    float maleWidth = maleView.bounds.size.width;
    float maleHeight = maleView.bounds.size.height;
    float maleX = maleView.bounds.origin.x;
    float maleY = maleView.bounds.origin.y;
    float maleAdd = 2;
    CGPoint maleTopLeft = maleView.bounds.origin;
    CGPoint maleTopMiddle = CGPointMake(maleX+(maleWidth/2),maleY-maleAdd);
    CGPoint maleTopRight = CGPointMake(maleX+maleWidth,maleY);
    CGPoint maleRightMiddle = CGPointMake(maleX+maleWidth+maleAdd,maleY+(maleHeight/2));
    CGPoint maleBottomRight  = CGPointMake(maleX+maleWidth,maleY+maleHeight);
    CGPoint maleBottomMiddle = CGPointMake(maleX+(maleWidth/2),maleY+maleHeight+maleAdd);
    CGPoint maleBottomLeft   = CGPointMake(maleX,maleY+maleHeight);
    CGPoint maleLeftMiddle = CGPointMake(maleX-maleAdd,maleY+(maleHeight/2));
    [malePath  moveToPoint:maleTopLeft];
    [malePath addQuadCurveToPoint:maleTopRight controlPoint:maleTopMiddle];
    [malePath addQuadCurveToPoint:maleBottomRight controlPoint:maleRightMiddle];
    [malePath addQuadCurveToPoint:maleBottomLeft controlPoint:maleBottomMiddle];
    [malePath addQuadCurveToPoint:maleTopLeft controlPoint:maleLeftMiddle];
    maleView.layer.shadowPath = malePath.CGPath;
    
    
    UITapGestureRecognizer* maleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedMaleView:)];
    [maleView addGestureRecognizer:maleTap];
    
    self.maleIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, viewWidth - 20, viewWidth - 20)];
    self.maleIV.image = [UIImage imageNamed:@"male"];
    [maleView addSubview:self.maleIV];
    
    self.maleSelectIV = [[UIImageView alloc]initWithFrame:CGRectMake((viewWidth - 20) / 2, viewHeight - 20 - 10, 20, 20)];
    self.maleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
    [maleView addSubview:self.maleSelectIV];
    
    UIView* femaleView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 + 20, maleView.frame.origin.y, viewWidth, viewHeight)];
    femaleView.backgroundColor = [UIColor whiteColor];
    femaleView.layer.shadowColor = [UIColor grayColor].CGColor;
    femaleView.layer.shadowOffset = CGSizeMake(0, 0);
    femaleView.layer.shadowOpacity = 0.5;
    [self.view addSubview:femaleView];
    
    UIBezierPath * femalePath = [UIBezierPath bezierPath];
    float femaleWidth = femaleView.bounds.size.width;
    float femaleHeight = femaleView.bounds.size.height;
    float femaleX = femaleView.bounds.origin.x;
    float femaleY = femaleView.bounds.origin.y;
    float femaleAdd = 2;
    CGPoint femaleTopLeft = femaleView.bounds.origin;
    CGPoint femaleTopMiddle = CGPointMake(femaleX+(femaleWidth/2),femaleY-femaleAdd);
    CGPoint femaleTopRight = CGPointMake(femaleX+femaleWidth,femaleY);
    CGPoint femaleRightMiddle = CGPointMake(femaleX+femaleWidth+femaleAdd,femaleY+(femaleHeight/2));
    CGPoint femaleBottomRight  = CGPointMake(femaleX+femaleWidth,femaleY+femaleHeight);
    CGPoint femaleBottomMiddle = CGPointMake(femaleX+(femaleWidth/2),femaleY+femaleHeight+femaleAdd);
    CGPoint femaleBottomLeft   = CGPointMake(femaleX,femaleY+femaleHeight);
    CGPoint femaleLeftMiddle = CGPointMake(femaleX-femaleAdd,femaleY+(femaleHeight/2));
    [femalePath  moveToPoint:femaleTopLeft];
    [femalePath addQuadCurveToPoint:femaleTopRight controlPoint:femaleTopMiddle];
    [femalePath addQuadCurveToPoint:femaleBottomRight controlPoint:femaleRightMiddle];
    [femalePath addQuadCurveToPoint:femaleBottomLeft controlPoint:femaleBottomMiddle];
    [femalePath addQuadCurveToPoint:femaleTopLeft controlPoint:femaleLeftMiddle];
    femaleView.layer.shadowPath = femalePath.CGPath;
    
    
    UITapGestureRecognizer* femaleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedFemaleView:)];
    [femaleView addGestureRecognizer:femaleTap];
    
    self.femaleIV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, viewWidth - 20, viewWidth - 20)];
    self.femaleIV.image = [UIImage imageNamed:@"female"];
    [femaleView addSubview:self.femaleIV];
    
    self.femaleSelectIV = [[UIImageView alloc]initWithFrame:CGRectMake((viewWidth - 20) / 2, viewHeight - 20 - 10, 20, 20)];
    self.femaleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
    [femaleView addSubview:self.femaleSelectIV];
    
    if (self.genderType == GenderTypeGenderFemale) {
        self.maleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
        self.femaleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Selected"];
    }else {
        self.maleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Selected"];
        self.femaleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
    }
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, self.view.frame.size.height - 100, self.view.frame.size.width - 60 * 2, 45)];
    self.sendBtn.backgroundColor = THEMEORANGECOLOR;
    self.sendBtn.layer.cornerRadius = self.sendBtn.frame.size.height / 2;
    self.sendBtn.layer.masksToBounds = YES;
    [self.sendBtn setTitle:@"提 交" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendBtn];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, maleView.frame.origin.y + maleView.frame.size.height + 20, self.view.frame.size.width, self.sendBtn.frame.origin.y - maleView.frame.origin.y - maleView.frame.size.height - 20 * 2) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMReadPreferencesCollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.collectionView];
}

-(void)loadMaleType {
    __weak LMReadPreferencesViewController* weakSelf = self;
    
    [self showNetworkLoadingView];
    
    FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
    [builder setGender:GenderTypeGenderMale];
    FirstBookTypeReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 1) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        
                        FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                        NSArray* arr = res.bookType;
                        
                        if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                            [weakSelf.maleArray removeAllObjects];
                            [weakSelf.maleArray addObjectsFromArray:arr];
                            if (weakSelf.femaleArray.count > 0) {
                                [weakSelf loadPreferencesSetting];
                            }
                        }
                    }
                }
                
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            } @finally {
                
            }
        }
        
        [weakSelf hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

-(void)loadFemaleType {
    __weak LMReadPreferencesViewController* weakSelf = self;
    
    [self showNetworkLoadingView];
    
    FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
    [builder setGender:GenderTypeGenderFemale];
    FirstBookTypeReq* req = [builder build];
    NSData* reqData = [req data];
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 1) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        
                        FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                        NSArray* arr = res.bookType;
                        
                        if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                            [weakSelf.femaleArray removeAllObjects];
                            [weakSelf.femaleArray addObjectsFromArray:arr];
                            if (weakSelf.maleArray.count > 0) {
                                [weakSelf loadPreferencesSetting];
                            }
                        }
                    }
                }
                
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            } @finally {
                
            }
        }
        
        [weakSelf hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

-(void)loadPreferencesSetting {
    [self showNetworkLoadingView];
    
    __weak LMReadPreferencesViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:24 ReqData:nil successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 24) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    UserLikeRes* res = [UserLikeRes parseFromData:apiRes.body];
                    if (res.gender == GenderTypeGenderFemale) {
                        weakSelf.genderType = GenderTypeGenderFemale;
                    }else {
                        weakSelf.genderType = GenderTypeGenderMale;
                    }
                    //初始化视图
                    [weakSelf setupSubviews];
                    
                    if (weakSelf.genderType == GenderTypeGenderFemale) {
                        weakSelf.dataArray = [NSMutableArray arrayWithArray:weakSelf.femaleArray];
                    }else {
                        weakSelf.dataArray = [NSMutableArray arrayWithArray:weakSelf.maleArray];
                    }
                    NSArray* tempArr = res.bookType;
                    if (tempArr != nil && ![tempArr isKindOfClass:[NSNull class]] && tempArr.count > 0) {
                        
                        weakSelf.interestArray = [NSMutableArray arrayWithArray:tempArr];
                    }
                    [weakSelf.collectionView reloadData];
                }
            }
        } @catch (NSException *exception) {
            [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        } @finally {
            
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
        [weakSelf showReloadButton];
    }];
}

-(void)clickedSelfReloadButton:(UIButton *)sender {
    [super clickedSelfReloadButton:sender];
    
    [self loadMaleType];
    [self loadFemaleType];
}

//男 按钮
-(void)tappedMaleView:(UITapGestureRecognizer* )tapGR {
    if (self.genderType == GenderTypeGenderMale && self.maleArray.count > 0) {
        return;
    }
    self.genderType = GenderTypeGenderMale;
    self.maleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Selected"];
    self.femaleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
    [self.interestArray removeAllObjects];
    [self.dataArray removeAllObjects];
    
    if (self.maleArray != nil && self.maleArray.count > 0) {
        [self.dataArray addObjectsFromArray:self.maleArray];
        [self.collectionView reloadData];
    }else {
        [self loadMaleType];
    }
}

//女 按钮
-(void)tappedFemaleView:(UITapGestureRecognizer* )tapGR {
    if (self.genderType == GenderTypeGenderFemale && self.femaleArray.count > 0) {
        return;
    }
    self.genderType = GenderTypeGenderFemale;
    self.femaleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Selected"];
    self.maleSelectIV.image = [UIImage imageNamed:@"bookShelf_Edit_Normal"];
    [self.interestArray removeAllObjects];
    [self.dataArray removeAllObjects];
    
    if (self.femaleArray != nil && self.femaleArray.count > 0) {
        [self.dataArray addObjectsFromArray:self.femaleArray];
        [self.collectionView reloadData];
    }else {
        [self loadFemaleType];
        
    }
}

-(void)clickedSendButton:(UIButton* )sender {
    if (self.genderType == GenderTypeGenderUnknown) {
        [self showMBProgressHUDWithText:@"请选择性别"];
        return;
    }
    if (self.genderType == GenderTypeGenderMale) {
        [LMTool saveFirstLaunchGenderType:GenderTypeGenderMale];
    }else if (self.genderType == GenderTypeGenderFemale) {
        [LMTool saveFirstLaunchGenderType:GenderTypeGenderFemale];
    }
    SetUserLikeReqBuilder* builder = [SetUserLikeReq builder];
    if (self.interestArray.count > 0) {
        [builder setBookTypeArray:self.interestArray];
    }
    [builder setGender:self.genderType];
    SetUserLikeReq* req = [builder build];
    
    NSData* reqData = [req data];
    
    [self showNetworkLoadingView];
    __weak LMReadPreferencesViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:25 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 25) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        
                        [weakSelf showMBProgressHUDWithText:@"更改成功"];
                        
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
                
            } @catch (NSException *exception) {
                [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
            } @finally {
                
            }
        }
        
        [weakSelf hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        [weakSelf showMBProgressHUDWithText:NETWORKFAILEDALERT];
    }];
}

#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LMReadPreferencesCollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    NSString* str = [self.dataArray objectAtIndex:indexPath.row];
    BOOL isClicked = NO;
    if ([self.interestArray containsObject:str]) {
        isClicked = YES;
    }
    cell.nameLab.text = str;
    [cell setClicked:isClicked genderType:self.genderType];
    
    return cell;
}

#pragma mark -UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* str = [self.dataArray objectAtIndex:indexPath.row];
    BOOL isContain = NO;
    if ([self.interestArray containsObject:str]) {
        [self.interestArray removeObject:str];
    }else {
        [self.interestArray addObject:str];
        isContain = YES;
    }
    LMReadPreferencesCollectionViewCell* cell = (LMReadPreferencesCollectionViewCell* )[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setClicked:isContain genderType:self.genderType];
}

#pragma mark -UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = (self.view.frame.size.width)/4;
    return (CGSize){cellWidth, 40};
}

//cell 上下左右相距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat cellSpace = self.view.frame.size.width / 16;
    return UIEdgeInsetsMake(10, cellSpace, 10, cellSpace);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.view.frame.size.width / 16;
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
