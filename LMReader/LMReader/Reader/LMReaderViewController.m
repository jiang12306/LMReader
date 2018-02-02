//
//  LMReaderViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/31.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMReaderViewController.h"
#import "LMContentViewController.h"
#import "LMCatalogViewController.h"
#import "LMChangeSourceViewController.h"

@interface LMReaderViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController* pageVC;
@property (nonatomic, strong) NSMutableArray* dataArray;
//@property (nonatomic, strong) UIView* naviView;
//@property (nonatomic, strong) UIView* toolView;

@end

@implementation LMReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"正文阅读";
    
    UIView* leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 52, 30)];//12,24
    UIImage* leftImage = [UIImage imageNamed:@"navigationItem_Back"];
    UIImage* tintImage = [leftImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* leftButton = [[UIButton alloc]initWithFrame:leftView.frame];
    [leftButton setTintColor:BACKCOLOR];
    [leftButton setImage:tintImage forState:UIControlStateNormal];
    [leftButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 40)];
    [leftButton addTarget:self action:@selector(clickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton setTitleColor:BACKCOLOR forState:UIControlStateNormal];
    [leftView addSubview:leftButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftView];
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 30)];
    UIImage* rightImage = [UIImage imageNamed:@"navigationItem_More"];
    UIImage* tintLeftImage = [rightImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* rightButton = [[UIButton alloc]initWithFrame:rightView.frame];
    [rightButton setTintColor:BACKCOLOR];
    [rightButton setImage:tintLeftImage forState:UIControlStateNormal];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(5, 45, 5, 0)];
    [rightButton addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightButton setTitle:@"换源" forState:UIControlStateNormal];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 15)];
    [rightButton setTitleColor:BACKCOLOR forState:UIControlStateNormal];
    [rightView addSubview:rightButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    
    NSArray* titleArr = @[@"夜间", @"字体", @"目录", @"下载", @"分享"];
    NSMutableArray* itemsArr = [NSMutableArray array];
    for (NSInteger i = 0; i < titleArr.count; i ++) {
        UIBarButtonItem* leftSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* item = [self createBarButtonItemWithTitle:titleArr[i] tag:i + 1];
        UIBarButtonItem* rightSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [itemsArr addObjectsFromArray:@[leftSpaceItem, item, rightSpaceItem]];
    }
    self.toolbarItems = itemsArr;
    
    // 根据给定的属性实例化UIPageViewController
    self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    // 设置UIPageViewController代理和数据源
    self.pageVC.delegate = self;
    self.pageVC.dataSource = self;
    
    // 设置UIPageViewController初始化数据, 将数据放在NSArray里面
    // 如果 options 设置了 UIPageViewControllerSpineLocationMid,注意viewControllers至少包含两个数据,且 doubleSided = YES
    
    LMBaseViewController *initialViewController = [self viewControllerAtIndex:0];//得到第一页
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
    // 设置UIPageViewController 尺寸
    self.pageVC.view.frame = self.view.bounds;
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tap];
}

//创建toolBar上按钮
-(UIBarButtonItem* )createBarButtonItemWithTitle:(NSString* )title tag:(NSInteger )tag {
    UIView* itemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    itemView.tag = tag;
//    itemView.backgroundColor = [UIColor redColor];
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, itemView.frame.size.width, itemView.frame.size.height)];
    btn.tag = tag;
    [btn addTarget:self action:@selector(clickedToolBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"nightMode"] forState:UIControlStateNormal];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 20, 10)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(24, -22, 0, 0)];
    [itemView addSubview:btn];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:itemView];
    item.tag = tag;
    return item;
}

//返回
-(void)clickedBackButton:(UIButton* )sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//换源
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    LMChangeSourceViewController* sourceVC = [[LMChangeSourceViewController alloc]init];
    [self presentViewController:sourceVC animated:YES completion:nil];
}

//点击toolBar
-(void)clickedToolBarButtonItem:(UIButton* )sender {
    switch (sender.tag) {
        case 1://夜间
            
            break;
        case 2://字体
            
            break;
        case 3://目录
        {
            LMCatalogViewController* catalogVC = [[LMCatalogViewController alloc]init];
            [self presentViewController:catalogVC animated:YES completion:nil];
        }
            break;
        case 4://下载
            
            break;
        case 5://分享
            
            break;
        default:
            break;
    }
}

-(void)tapped:(UITapGestureRecognizer* )tapGR {
    CGPoint tapPoint = [tapGR locationInView:self.view];
    NSLog(@"x = %f, y = %f", tapPoint.x, tapPoint.y);
    
    BOOL isHiden = self.navigationController.toolbar.isHidden;
    if (isHiden) {
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate
#pragma mark 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(LMContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
    // 不用我们去操心每个ViewController的顺序问题
    return [self viewControllerAtIndex:index];
}

#pragma mark 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(LMContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.dataArray count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSMutableArray *arrayM = [[NSMutableArray alloc] init];
        for (int i = 1; i < 10; i++) {
            NSString *contentString = [[NSString alloc] initWithFormat:@"This is the page %d of content displayed using UIPageViewController", i];
            [arrayM addObject:contentString];
        }
        _dataArray = [NSMutableArray arrayWithArray:arrayM];
    }
    return _dataArray;
}

#pragma mark - 根据index得到对应的UIViewController
- (LMContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.dataArray count] == 0) || (index >= [self.dataArray count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    LMContentViewController *contentVC = [[LMContentViewController alloc] init];
    contentVC.content = [self.dataArray objectAtIndex:index];
    return contentVC;
}

#pragma mark - 数组元素值，得到下标值
- (NSUInteger)indexOfViewController:(LMContentViewController *)viewController {
    return [self.dataArray indexOfObject:viewController.content];
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
