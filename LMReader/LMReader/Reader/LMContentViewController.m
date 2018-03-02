//
//  LMContentViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/31.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMContentViewController.h"
#import "LMTool.h"

@interface LMContentViewController ()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation LMContentViewController

-(instancetype)initWithReadModel:(LMReadModel)readModel fontSize:(CGFloat)fontSize content:(NSString *)content {
    self = [super init];
    if (self) {
        self.readModel = readModel;
        self.fontSize = fontSize;
        self.content = content;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(ios 11.0, *)) {
        
    }else {
        //表头底下不算面积
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    self.contentLabel = [[UILabel alloc]initWithFrame:contentRect];
//    self.contentLabel.backgroundColor = [UIColor greenColor];
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.contentLabel.font = [UIFont systemFontOfSize:self.fontSize];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    if (self.readModel == LMReadModelDay) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.contentLabel.textColor = [UIColor blackColor];
    }else {
        self.view.backgroundColor = [UIColor colorWithRed:15/255.f green:15/255.f blue:15/255.f alpha:1];
        self.contentLabel.textColor = [UIColor colorWithRed:80/255.f green:80/255.f blue:80/255.f alpha:1];
    }
    [self.view addSubview:self.contentLabel];
    
    self.contentLabel.text = self.content;
    
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
