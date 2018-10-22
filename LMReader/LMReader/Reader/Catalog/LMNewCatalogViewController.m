//
//  LMNewCatalogViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/17.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMNewCatalogViewController.h"
#import "LMBaseRefreshTableView.h"
#import "LMCatalogTableViewCell.h"
#import "LMReaderBook.h"
#import "LMTool.h"

@interface LMNewCatalogViewController () <UITableViewDelegate, UITableViewDataSource, LMBaseRefreshTableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) LMBaseRefreshTableView* tableView;
@property (nonatomic, assign) BOOL isDecend;/**<倒序，取角标用*/

@property (nonatomic, strong) UIView* referenceView;
@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, assign) CGFloat startPanY;

@end

@implementation LMNewCatalogViewController

static NSString* cellIdentifier = @"cellIdentifier";
static CGFloat cellHeight = 44;

-(instancetype)init {
    self = [super init];
    if (self) {
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"目录";
    self.isDecend = NO;
    
    UIView* rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    UIButton* rightItemBtn = [[UIButton alloc]initWithFrame:rightView.frame];
    [rightItemBtn setImage:[UIImage imageNamed:@"catalog_Decend"] forState:UIControlStateNormal];
    [rightItemBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 12.5, 0, 12.5)];
    [rightItemBtn addTarget:self action:@selector(clickedRightBarButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    rightItemBtn.selected = NO;
    [rightView addSubview:rightItemBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightView];
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[LMBaseRefreshTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStylePlain];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refreshDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMCatalogTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.tableView setupNoRefreshData];
    [self.tableView setupNoMoreData];
    [self.view addSubview:self.tableView];
    
    self.referenceView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 30, self.tableView.frame.origin.y, 30, 30)];
    self.referenceView.backgroundColor = [UIColor colorWithRed:220.f/255 green:220.f/255 blue:220.f/255 alpha:1];
    self.referenceView.layer.cornerRadius = 1;
    self.referenceView.layer.masksToBounds = YES;
    self.referenceView.layer.borderColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1].CGColor;
    self.referenceView.layer.borderWidth = 0.5f;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanReferenceView:)];
    self.panGestureRecognizer.delegate = self;
    [self.referenceView addGestureRecognizer:self.panGestureRecognizer];
    [self.view insertSubview:self.referenceView aboveSubview:self.tableView];
    UIImageView* catalogIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.referenceView.frame.size.height - 10, self.referenceView.frame.size.height - 10)];
    catalogIV.tintColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1];
    UIImage* tempImg = [UIImage imageNamed:@"catalog_Index"];
    catalogIV.image = [tempImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.referenceView addSubview:catalogIV];
    
    //
    [self scrollToCurrentRow];
}

#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        CGRect startFrame = self.referenceView.frame;
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        CGFloat contentSizeHeight = self.tableView.contentSize.height;
        
        CGFloat bottomHeight = startFrame.size.height;
        if ([LMTool isBangsScreen]) {
            bottomHeight += 44;
        }
        CGFloat maxViewHeight = self.view.frame.size.height - bottomHeight;
        CGFloat startY = contentOffsetY / contentSizeHeight * maxViewHeight;
        if (startY < 0) {
            startY = 0;
        }else if (startY > maxViewHeight) {
            startY = maxViewHeight;
        }
        startFrame.origin.y = startY;
        self.referenceView.frame = startFrame;
    }
}

-(void)didPanReferenceView:(UIPanGestureRecognizer* )panGR {
    if (panGR.state == UIGestureRecognizerStateBegan) {
        self.startPanY = [panGR locationInView:self.referenceView].y;
    }else if (panGR.state == UIGestureRecognizerStateChanged) {
        CGRect startFrame = self.referenceView.frame;
        startFrame.origin.y = startFrame.origin.y + [panGR locationInView:self.referenceView].y - self.startPanY;
        CGFloat bottomHeight = startFrame.size.height;
        if ([LMTool isBangsScreen]) {
            bottomHeight += 44;
        }
        CGFloat maxViewHeight = self.view.frame.size.height - bottomHeight;
        if (startFrame.origin.y < 0) {
            startFrame.origin.y = 0;
        }else if (startFrame.origin.y > maxViewHeight) {
            startFrame.origin.y = maxViewHeight;
        }
        
        self.referenceView.frame = startFrame;
        CGFloat pointY = self.referenceView.frame.origin.y / maxViewHeight * self.tableView.contentSize.height;
        if (pointY > self.tableView.contentSize.height) {
            pointY = self.tableView.contentSize.height;
        }
        if (self.dataArray.count > 0) {
            self.tableView.contentOffset = CGPointMake(0, pointY);
        }
    }
}

//
-(void)clickedRightBarButtonItem:(UIButton* )sender {
    if (self.dataArray.count == 0) {
        return;
    }
    if (sender.selected == NO) {
        sender.selected = YES;
        self.isDecend = YES;
    }else {
        sender.selected = NO;
        self.isDecend = NO;
    }
    NSArray* arr = [NSArray arrayWithArray:self.dataArray];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[[arr reverseObjectEnumerator]allObjects]];
    [self.tableView reloadData];
    
    [self scrollToTop];
}

//滚动至顶部
-(void)scrollToTop {
    if (self.dataArray.count == 0) {
        return;
    }
    NSInteger index = self.chapterIndex;
    if (self.isDecend) {
        index = 0;
    }
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//滚动至当前章节
-(void)scrollToCurrentRow {
    if (self.dataArray.count == 0) {
        return;
    }
    NSInteger index = self.chapterIndex;
    if (self.isDecend) {
        index = self.dataArray.count - self.chapterIndex - 1;
    }
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMCatalogTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMCatalogTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    LMReaderBookChapter* chapter = [self.dataArray objectAtIndex:indexPath.row];
    NSString* num = @"";//[NSString stringWithFormat:@"%ld", indexPath.row];
    NSString* name = [NSString stringWithFormat:@"%@", chapter.title];
    
    BOOL isClicked = NO;
    if (self.isDecend) {
        NSInteger index = self.dataArray.count - self.chapterIndex - 1;
        if (indexPath.row == index) {
            isClicked = YES;
        }
    }else {
        if (indexPath.row == self.chapterIndex) {
            isClicked = YES;
        }
    }
    
    [cell setContentWithNumberStr:num nameStr:name timeStr:nil isClicked:isClicked];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BOOL didChange = YES;
    if (self.isDecend) {
        NSInteger index = self.dataArray.count - self.chapterIndex - 1;
        if (indexPath.row == index) {
            didChange = NO;
        }
    }else {
        if (indexPath.row == self.chapterIndex) {
            didChange = NO;
        }
    }
    if (self.callBack) {
        NSInteger index = indexPath.row;
        if (self.isDecend) {
            index = self.dataArray.count - index - 1;
            if (index < 0 || index > self.dataArray.count - 1) {//谨防数组越界
                index = 0;
            }
        }
        self.callBack(didChange, index);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -LMBaseRefreshTableViewDelegate
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView *)tv {
    
}

-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView *)tv {
    
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
