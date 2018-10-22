//
//  LMFirstLaunchViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/29.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMFirstLaunchViewController.h"
#import "LMRootViewController.h"
#import "LMReadPreferencesCollectionViewCell.h"
#import "LMTool.h"

@interface LMFirstLaunchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) GenderType genderType;
@property (nonatomic, strong) UIImageView* maleIV;
@property (nonatomic, strong) UIImageView* femaleIV;
@property (nonatomic, strong) NSMutableArray* maleArray;
@property (nonatomic, strong) NSMutableArray* femaleArray;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSMutableArray* interestArray;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UIButton* sendBtn;

@end

@implementation LMFirstLaunchViewController

static NSString* cellId = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat viewWidth = self.view.frame.size.width/4;
    
    CGFloat originalY = 40;
    if ([LMTool isBangsScreen]) {
        originalY = 60;
    }
    
    UILabel* lab1 = [[UILabel alloc]initWithFrame:CGRectMake(0, originalY, self.view.frame.size.width, 40)];
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.font = [UIFont systemFontOfSize:20];
    lab1.text = @"请选择您的性别及阅读偏好";
    [self.view addSubview:lab1];
    
    UILabel* lab2 = [[UILabel alloc]initWithFrame:CGRectMake(0, lab1.frame.origin.y + lab1.frame.size.height, self.view.frame.size.width, 30)];
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.font = [UIFont systemFontOfSize:16];
    lab2.text = @"以便推荐更适合您的小说";
    [self.view addSubview:lab2];
    
    UIView* maleView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - viewWidth - 20, lab2.frame.origin.y + lab2.frame.size.height + 10, viewWidth, viewWidth)];
    [self.view addSubview:maleView];
    
    UITapGestureRecognizer* maleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedMaleView:)];
    [maleView addGestureRecognizer:maleTap];
    
    UIImageView* maleAvator = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, viewWidth - 20, viewWidth - 20)];
    maleAvator.image = [UIImage imageNamed:@"male"];
    [maleView addSubview:maleAvator];
    
    self.maleIV = [[UIImageView alloc]initWithFrame:CGRectMake(maleAvator.frame.origin.x + maleAvator.frame.size.width / 4, maleAvator.frame.origin.y + maleAvator.frame.size.height / 2, maleAvator.frame.size.width / 2, maleAvator.frame.size.height / 2)];
    self.maleIV.image = [UIImage imageNamed:@"sex_Selected"];
    [maleView addSubview:self.maleIV];
    
    UILabel* maleLab = [[UILabel alloc]initWithFrame:CGRectMake(maleAvator.frame.origin.x, maleView.frame.size.height - 20, maleAvator.frame.size.width, 20)];
    maleLab.font = [UIFont systemFontOfSize:15];
    maleLab.textAlignment = NSTextAlignmentCenter;
    maleLab.text = @"男生";
    [maleView addSubview:maleLab];
    
    UIView* femaleView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 + 20, maleView.frame.origin.y, viewWidth, viewWidth)];
    [self.view addSubview:femaleView];
    
    UITapGestureRecognizer* femaleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedFemaleView:)];
    [femaleView addGestureRecognizer:femaleTap];
    
    UIImageView* femaleAvator = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, viewWidth - 20, viewWidth - 20)];
    femaleAvator.image = [UIImage imageNamed:@"female"];
    [femaleView addSubview:femaleAvator];
    
    self.femaleIV = [[UIImageView alloc]initWithFrame:CGRectMake(femaleAvator.frame.origin.x + femaleAvator.frame.size.width / 4, femaleAvator.frame.origin.y + femaleAvator.frame.size.height / 2, femaleAvator.frame.size.width / 2, femaleAvator.frame.size.height / 2)];
    self.femaleIV.image = [UIImage imageNamed:@"sex_Selected"];
    self.femaleIV.alpha = 0.3f;
    [femaleView addSubview:self.femaleIV];
    
    UILabel* femaleLab = [[UILabel alloc]initWithFrame:CGRectMake(femaleAvator.frame.origin.x, femaleView.frame.size.height - 20, femaleAvator.frame.size.width, 20)];
    femaleLab.font = [UIFont systemFontOfSize:15];
    femaleLab.textAlignment = NSTextAlignmentCenter;
    femaleLab.text = @"女生";
    [femaleView addSubview:femaleLab];
    
    CGFloat bottomHeight = 10 + 40 + 30;
    if ([LMTool isBangsScreen]) {
        bottomHeight = 10 + 40 + 60;
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, maleView.frame.origin.y + maleView.frame.size.height + 10, self.view.frame.size.width, self.view.frame.size.height - maleView.frame.origin.y - maleView.frame.size.height - bottomHeight) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[LMReadPreferencesCollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.collectionView];
    
    self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, self.collectionView.frame.origin.y + self.collectionView.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
    self.sendBtn.backgroundColor = THEMEORANGECOLOR;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    self.sendBtn.selected = NO;
    [self.sendBtn setTitle:@"开始阅读之旅" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(clickedSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendBtn];
    
    self.genderType = GenderTypeGenderMale;
    
    self.dataArray = [NSMutableArray array];
    self.interestArray = [NSMutableArray array];
    self.maleArray = [NSMutableArray array];
    self.femaleArray = [NSMutableArray array];
    
    //
    [self tappedMaleView:nil];
}

//男 按钮
-(void)tappedMaleView:(UITapGestureRecognizer* )tapGR {
    if (self.genderType == GenderTypeGenderMale && self.maleArray.count > 0) {
        return;
    }
    
    self.genderType = GenderTypeGenderMale;
    self.maleIV.alpha = 1;
    self.femaleIV.alpha = 0.3;
    [self.interestArray removeAllObjects];
    [self.dataArray removeAllObjects];
    
    if (self.maleArray != nil && self.maleArray.count > 0) {
        [self.dataArray addObjectsFromArray:self.maleArray];
        [self.collectionView reloadData];
    }else {
        __weak LMFirstLaunchViewController* weakSelf = self;
        
        [self showNetworkLoadingView];
        
        FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
        [builder setGender:GenderTypeGenderMale];
        FirstBookTypeReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 1) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        
                        FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                        NSArray* arr = res.bookType;
                        
                        if (![arr isKindOfClass:[NSNull class]] && arr.count > 0 && weakSelf.genderType == GenderTypeGenderMale) {
                            [weakSelf.maleArray addObjectsFromArray:arr];
                            [weakSelf.dataArray removeAllObjects];
                            [weakSelf.dataArray addObjectsFromArray:arr];
                            [weakSelf.collectionView reloadData];
                        }
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
}

//女 按钮
-(void)tappedFemaleView:(UITapGestureRecognizer* )tapGR {
    if (self.genderType == GenderTypeGenderFemale && self.femaleArray.count > 0) {
        return;
    }
    
    self.genderType = GenderTypeGenderFemale;
    self.femaleIV.alpha = 1;
    self.maleIV.alpha = 0.3;
    [self.interestArray removeAllObjects];
    [self.dataArray removeAllObjects];
    
    if (self.femaleArray != nil && self.femaleArray.count > 0) {
        [self.dataArray addObjectsFromArray:self.femaleArray];
        [self.collectionView reloadData];
    }else {
        __weak LMFirstLaunchViewController* weakSelf = self;
        
        [self showNetworkLoadingView];
        
        FirstBookTypeReqBuilder* builder = [FirstBookTypeReq builder];
        [builder setGender:GenderTypeGenderFemale];
        FirstBookTypeReq* req = [builder build];
        NSData* reqData = [req data];
        LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
        [tool postWithCmd:1 ReqData:reqData successBlock:^(NSData *successData) {
            @try {
                FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
                if (apiRes.cmd == 1) {
                    ErrCode err = apiRes.err;
                    if (err == ErrCodeErrNone) {
                        
                        FirstBookTypeRes* res = [FirstBookTypeRes parseFromData:apiRes.body];
                        NSArray* arr = res.bookType;
                        
                        if (![arr isKindOfClass:[NSNull class]] && arr.count > 0 && weakSelf.genderType == GenderTypeGenderFemale) {
                            [weakSelf.femaleArray addObjectsFromArray:arr];
                            [weakSelf.dataArray removeAllObjects];
                            [weakSelf.dataArray addObjectsFromArray:arr];
                            [weakSelf.collectionView reloadData];
                        }
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
}

//
-(void)clickedSendButton:(UIButton* )sender {
    if (self.sendBtn.selected == YES) {
        return;
    }
    if (self.genderType == GenderTypeGenderMale) {
        [LMTool saveFirstLaunchGenderType:GenderTypeGenderMale];
    }else if (self.genderType == GenderTypeGenderFemale) {
        [LMTool saveFirstLaunchGenderType:GenderTypeGenderFemale];
    }
    self.sendBtn.selected = YES;
    
    [self showNetworkLoadingView];
    
    FirstBookReqBuilder* builder = [FirstBookReq builder];
    
    if (self.interestArray.count > 0) {
        [builder setBookTypeArray:self.interestArray];
    }
    if (self.genderType == GenderTypeGenderMale || self.genderType == GenderTypeGenderFemale) {
        [builder setGender:self.genderType];
    }
    FirstBookReq* req = [builder build];
    
    NSData* reqData = [req data];
    
    __weak LMFirstLaunchViewController* weakSelf = self;
    
    LMNetworkTool* tool = [LMNetworkTool sharedNetworkTool];
    [tool postWithCmd:2 ReqData:reqData successBlock:^(NSData *successData) {
        @try {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 2) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    FirstBookRes* res = [FirstBookRes parseFromData:apiRes.body];
                    NSArray* booksArr = res.books;
                    
                    if (booksArr != nil && booksArr.count > 0) {
                        
                    }
                }
            }
        } @catch (NSException *exception) {
            
        } @finally {
            [weakSelf hideNetworkLoadingView];
            
            //进入app
            [[LMRootViewController sharedRootViewController] exchangeLaunchState:NO];
        }
    } failureBlock:^(NSError *failureError) {
        [weakSelf hideNetworkLoadingView];
        
        //进入app
        [[LMRootViewController sharedRootViewController] exchangeLaunchState:NO];
        [[LMRootViewController sharedRootViewController] backToTabBarControllerWithViewControllerIndex:2];//进入书城界面
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
    return 20.f;
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
