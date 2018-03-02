//
//  LMReadPreferencesViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/26.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReadPreferencesViewController.h"
#import "LMFirstLaunch2ViewController.h"

@interface LMReadPreferencesViewController ()

@property (nonatomic, strong) NSMutableDictionary* interestDic;

@end

@implementation LMReadPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"阅读偏好";
    
    __weak LMReadPreferencesViewController* weakSelf = self;
    
    LMFirstLaunch2ViewController* launch2 = [[LMFirstLaunch2ViewController alloc]init];
    launch2.callBlock = ^(NSDictionary *blockDic) {
        if (blockDic != nil && ![blockDic isKindOfClass:[NSNull class]] && blockDic.count > 0) {
            weakSelf.interestDic = [NSMutableDictionary dictionaryWithDictionary:blockDic];
            
            GenderType genderType = GenderTypeGenderUnknown;
            NSInteger maleInteger = [[weakSelf.interestDic objectForKey:@"male"] integerValue];
            NSInteger femaleInteger = [[weakSelf.interestDic objectForKey:@"female"] integerValue];
            if (maleInteger == 1) {
                genderType = GenderTypeGenderMale;
            }else if (maleInteger == 0) {
                if (femaleInteger == 1) {
                    genderType = GenderTypeGenderFemale;
                }
            }
            NSArray* interestArr = [weakSelf.interestDic objectForKey:@"interest"];
            if (interestArr != nil && ![interestArr isKindOfClass:[NSNull class]] && interestArr.count > 0) {
                
            }
        }
        //将兴趣传值过来
    };
    [self addChildViewController:launch2];
    launch2.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:launch2.view];
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
