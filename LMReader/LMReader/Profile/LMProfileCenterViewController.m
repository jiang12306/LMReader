//
//  LMProfileCenterViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMProfileCenterViewController.h"
#import "LMProfileCenterTableViewCell.h"
#import "LMResetPasswordViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface LMProfileCenterViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* titleArray;
@property (nonatomic, strong) NSMutableArray* dataArray;

@property (nonatomic, strong) UIView* bgView;

@property (nonatomic, strong) UIView* dateView;
@property (nonatomic, strong) UIDatePicker* datePicker;
@property (nonatomic, strong) UIView* placeView;
@property (nonatomic, strong) UIPickerView* placePicker;
@property (nonatomic, strong) NSMutableArray* provinceArray;
@property (nonatomic, strong) NSMutableDictionary* cityDic;
@property (nonatomic, strong) NSMutableArray* cityArray;

@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation LMProfileCenterViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人中心";
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMProfileCenterTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.titleArray = [NSMutableArray arrayWithObjects:@"性别", @"出生日期", @"所在地区", @"修改密码", nil];
    NSString* genderStr = @"";
    GenderType type = self.loginedUser.user.gender;
    if (type == GenderTypeGenderMale) {
        genderStr = @"男";
    }else if (type == GenderTypeGenderFemale) {
        genderStr = @"女";
    }
    self.dataArray = [NSMutableArray arrayWithObjects:genderStr, self.loginedUser.user.birthday, self.loginedUser.user.localArea, nil];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMProfileCenterTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMProfileCenterTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSInteger row = indexPath.row;
    cell.nameLab.text = [self.titleArray objectAtIndex:row];
    if (row == 3) {
        
    }else {
        cell.contentLab.text = [self.dataArray objectAtIndex:row];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    if (row == 0) {
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* maleAction = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction* femaleAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [controller addAction:maleAction];
        [controller addAction:femaleAction];
        [controller addAction:cancelAction];
        [self presentViewController:controller animated:YES completion:nil];
    }else if (row == 1) {
        [self showDateView];
    }else if (row == 2) {
        CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
        if (locationStatus == kCLAuthorizationStatusDenied || locationStatus == kCLAuthorizationStatusRestricted) {//禁止使用GPS时
            
            [self loadPlacePickerViewData];
        }else {
            self.locationManager = [[CLLocationManager alloc]init];
            [self.locationManager requestWhenInUseAuthorization];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = 5.0;
            [self.locationManager startUpdatingLocation];
        }
    }else if (row == 3) {
        LMResetPasswordViewController* resetPwdVC = [[LMResetPasswordViewController alloc]init];
        [self.navigationController pushViewController:resetPwdVC animated:YES];
    }
}

//
-(UIView *)bgView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, screenRect.size.height)];
        _bgView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_bgView];
        
        UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedBgView:)];
        [_bgView addGestureRecognizer:tapGR];
    }
    return _bgView;
}

//
-(void)tappedBgView:(UITapGestureRecognizer* )tapGR {
    [self hideDateView];
    [self hidePlacePickerView];
}

//选择日期
-(void)showDateView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.dateView) {
        self.dateView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250)];
        self.dateView.backgroundColor = [UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:0.8];
        [self.view insertSubview:self.dateView aboveSubview:self.bgView];
        
        UIButton* cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(clickedDateViewCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.dateView addSubview:cancelBtn];
        
        UIButton* sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.dateView.frame.size.width - 50, 0, 50, 30)];
        [sureBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(clickedDateViewSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.dateView addSubview:sureBtn];
        
        self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, cancelBtn.frame.size.height, self.dateView.frame.size.width, self.dateView.frame.size.height - cancelBtn.frame.size.height)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        [self.datePicker setLocale:[NSLocale currentLocale]];
        [self.datePicker setTimeZone:[NSTimeZone systemTimeZone]];
        [self.datePicker setDate:[NSDate date]];
        [self.dateView addSubview:self.datePicker];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        self.dateView.frame = CGRectMake(0, screenRect.size.height - 250, self.view.frame.size.width, 250);
    }];
}

//隐藏日期
-(void)hideDateView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, screenRect.size.height);
        self.dateView.frame = CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250);
    }];
}

//取消选择日期
-(void)clickedDateViewCancelButton:(UIButton* )sender {
    [self hideDateView];
}

//确定选择日期
-(void)clickedDateViewSureButton:(UIButton* )sender {
    
    
    [self hideDateView];
}

//获取地区数据
-(void)loadPlacePickerViewData {
    if (self.provinceArray.count > 0) {
        [self showPlacePickerView];
        return;
    }
    
    [self showNetworkLoadingView];//loadingView
    
    ProvinceCityReqBuilder* builder = [ProvinceCityReq builder];
    ProvinceCityReq* req = [builder build];
    
    NSData* reqData = [req data];
    
    [[LMNetworkTool sharedNetworkTool] postWithCmd:15 ReqData:reqData successBlock:^(NSData *successData) {
        if (![successData isKindOfClass:[NSNull class]] && successData.length > 0) {
            FtBookApiRes* apiRes = [FtBookApiRes parseFromData:successData];
            if (apiRes.cmd == 15) {
                ErrCode err = apiRes.err;
                if (err == ErrCodeErrNone) {
                    ProvinceCityRes* res = [ProvinceCityRes parseFromData:apiRes.body];
                    NSArray* arr = res.provinces;
                    NSArray* arr2 = res.citys;
                    if (![arr isKindOfClass:[NSNull class]] && arr.count > 0) {
                        self.cityDic = [NSMutableDictionary dictionary];
                        for (NSInteger i = 0; i < arr.count; i ++) {
                            Province* provice = [arr objectAtIndex:i];
                            UInt32 proviceId = provice.id;
                            NSMutableArray* tempCityArr = [NSMutableArray array];
                            for (City* city in arr2) {
                                if (proviceId == city.provinceId) {
                                    [tempCityArr addObject:city];
                                }
                            }
                            if (tempCityArr.count > 0) {
                                [self.cityDic setObject:tempCityArr forKey:[NSNumber numberWithUnsignedInt:proviceId]];
                                if (i == 0) {
                                    self.cityArray = [tempCityArr mutableCopy];
                                }
                            }
                        }
                        self.provinceArray = [NSMutableArray arrayWithArray:arr];
                    }
                    
                    [self showPlacePickerView];
                }
            }
        }
        
        [self hideNetworkLoadingView];
        
    } failureBlock:^(NSError *failureError) {
        [self hideNetworkLoadingView];
    }];
}

//选择地区
-(void)showPlacePickerView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (!self.placeView) {
        self.placeView = [[UIView alloc]initWithFrame:CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250)];
        self.placeView.backgroundColor = [UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:0.8];
        [self.view insertSubview:self.placeView aboveSubview:self.bgView];
        
        UIButton* cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [cancelBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(clickedPlacePickerViewCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.placeView addSubview:cancelBtn];
        
        UIButton* sureBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.placeView.frame.size.width - 50, 0, 50, 30)];
        [sureBtn setTitleColor:THEMECOLOR forState:UIControlStateNormal];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(clickedPlacePickerViewSureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.placeView addSubview:sureBtn];
        
        self.placePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 220)];
        self.placePicker.dataSource = self;
        self.placePicker.delegate = self;
        [self.placeView addSubview:self.placePicker];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        self.placeView.frame = CGRectMake(0, screenRect.size.height - 250, self.view.frame.size.width, 250);
    }];
}

//隐藏 地区
-(void)hidePlacePickerView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = CGRectMake(0, screenRect.size.height, screenRect.size.width, screenRect.size.height);
        self.placeView.frame = CGRectMake(0, screenRect.size.height, self.view.frame.size.width, 250);
    }];
}

//取消选择 地区
-(void)clickedPlacePickerViewCancelButton:(UIButton* )sender {
    [self hidePlacePickerView];
}

//选择 地区
-(void)clickedPlacePickerViewSureButton:(UIButton* )sender {
//    NSInteger proviceInt = [self.placePicker selectedRowInComponent:0];
//    NSInteger cityInt = [self.placePicker selectedRowInComponent:1];
//    Province* province = [self.provinceArray objectAtIndex:proviceInt];
    
    
//    self.dataArray replaceObjectAtIndex:2 withObject:
    
    [self hidePlacePickerView];
}

#pragma mark -UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    }else if (component == 1) {
        return self.cityArray.count;
    }
    return 0;
}

#pragma mark -UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return @"省份";
    }else if (component == 1) {
        return @"城市";
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 30)];
    UILabel* lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, vi.frame.size.width, vi.frame.size.height)];
    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentCenter;
    NSString* text = @"";
    if (component == 0) {
        Province* province = [self.provinceArray objectAtIndex:row];
        text = province.name;
    }else if (component == 1) {
        City* city = [self.cityArray objectAtIndex:row];
        text = city.name;
    }
    lab.text = text;
    [vi addSubview:lab];
    return vi;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        Province* provice = [self.provinceArray objectAtIndex:row];
        NSArray* arr = [self.cityDic objectForKey:[NSNumber numberWithUnsignedInt:provice.id]];
        if (arr.count > 0) {
            self.cityArray = [NSMutableArray arrayWithArray:arr];
            
            [self.placePicker reloadComponent:1];
        }
    }
}

#pragma mark -CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    [self loadPlacePickerViewData];
//    [self showMBProgressHUDWithText:@"获取位置失败"];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    //这里的代码是为了判断didUpdateLocations调用了几次 有可能会出现多次调用 为了避免不必要的麻烦 在这里加个if判断 如果大于1.0就return
    NSTimeInterval locationAge = -[currentLocation.timestamp timeIntervalSinceNow];
    NSLog(@"locationAge = %f", locationAge);
    if (locationAge > 1.0){//如果调用已经一次，不再执行
        return;
    }
    //当前的经纬度
    NSLog(@"当前的经纬度 %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    
    
    //To Do...
    //Upload Location
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
