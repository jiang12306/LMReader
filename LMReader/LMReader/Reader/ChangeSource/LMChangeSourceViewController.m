//
//  LMChangeSourceViewController.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/1.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMChangeSourceViewController.h"
#import "LMChangeSourceTableViewCell.h"
#import "LMTool.h"
#import "TFHpple.h"
#import "LMReaderBook.h"

@interface LMChangeSourceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableDictionary* lastChapterDic;/**<新解析方式下 每个解析器对应最新章节内容*/

@end

@implementation LMChangeSourceViewController

static NSString* cellIdentifier = @"cellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    
    self.title = @"选择来源";
    
    CGFloat naviHeight = 20 + 44;
    if ([LMTool isBangsScreen]) {
        naviHeight = 44 + 44;
    }
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - naviHeight) style:UITableViewStyleGrouped];
    if (@available(ios 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[LMChangeSourceTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
    
    if (self.isNew && self.sourceArr.count > 0) {
        self.lastChapterDic = [NSMutableDictionary dictionary];
        NSDictionary* sourceDic = [LMTool unArchiveBookSourceDicWithBookId:self.bookId];
        if (sourceDic != nil && ![sourceDic isKindOfClass:[NSNull class]] && sourceDic.count > 0) {
            [self.lastChapterDic addEntriesFromDictionary:sourceDic];
            [self.tableView reloadData];
        }
        [self loadLastChapter];
    }
}

//保存源列表最新章节信息
-(void)saveCurrentBookSourceCache {
    if (self.lastChapterDic.count > 0) {
        [LMTool archiveBookSourceWithBookId:self.bookId sourceDic:self.lastChapterDic];
    }
}

-(void)loadLastChapter {
    [self showNetworkLoadingView];
    
    NSInteger indexLength = self.sourceArr.count;
    if (self.sourceArr.count > 16) {//取前15个源，加载最新章节
        indexLength = 15;
    }
    NSArray* subSourceArr = [self.sourceArr subarrayWithRange:NSMakeRange(0, indexLength)];
    
    __weak LMChangeSourceViewController* weakSelf = self;
    __block NSInteger totalCount = 0;//加载成功的个数
    for (NSInteger i = 0; i < subSourceArr.count; i ++) {
        UrlReadParse* parse = [subSourceArr objectAtIndex:i];
        NSString* urlStr = parse.listUrl;
        NSArray* listArr = [parse.listParse componentsSeparatedByString:@","];
        [[LMNetworkTool sharedNetworkTool]AFNetworkPostWithURLString:urlStr successBlock:^(NSData *successData) {
            NSStringEncoding encoding = [LMTool convertEncodingStringWithEncoding:parse.source.htmlcharset];
            NSString* originStr = [[NSString alloc]initWithData:successData encoding:encoding];
            NSData* changeData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
            TFHpple* doc = [[TFHpple alloc] initWithData:changeData isXML:NO];
            NSString* searchStr = [LMTool convertToHTMLStringWithListArray:listArr];
            NSArray* elementArr = [doc searchWithXPathQuery:searchStr];
            if (elementArr != nil && elementArr.count > 0) {
                
                TFHppleElement* element = [elementArr lastObject];
                
                NSString* titleStr = element.content;
                if (titleStr != nil && ![titleStr isKindOfClass:[NSNull class]]) {
                    [weakSelf.lastChapterDic setObject:titleStr forKey:urlStr];
                }else {
                    [weakSelf.lastChapterDic setObject:@"" forKey:urlStr];
                }
                totalCount ++;
            }else {
                totalCount ++;
            }
            
            if (totalCount % 3 == 0 || totalCount == subSourceArr.count) {
                [weakSelf hideNetworkLoadingView];
                if (weakSelf.lastChapterDic.count > 0) {
                    [weakSelf.tableView reloadData];
                }
                //
                [weakSelf saveCurrentBookSourceCache];
            }
        } failureBlock:^(NSError *failureError) {
            totalCount ++;
            if (totalCount % 3 == 0 || totalCount == subSourceArr.count) {
                [weakSelf hideNetworkLoadingView];
                //
                [weakSelf saveCurrentBookSourceCache];
            }
        }];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    return vi;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView* vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    return vi;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMChangeSourceTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LMChangeSourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell showArrowImageView:NO];
    [cell showLineView:NO];
    
    NSInteger row = indexPath.row;
    BOOL isClicked = NO;
    if (indexPath.row == self.sourceIndex) {
        isClicked = YES;
    }
    if (self.isNew) {
        UrlReadParse* parse = [self.sourceArr objectAtIndex:row];
        NSString* lastStr = @"";
        if (self.lastChapterDic.count > 0) {
            lastStr = [self.lastChapterDic objectForKey:parse.listUrl];
        }
        if (lastStr != nil && ![lastStr isKindOfClass:[NSNull class]] && lastStr.length > 0) {
            
        }else {
            lastStr = @"";
        }
        Source* source = parse.source;
        [cell setupSourceWithSource:source nameStr:lastStr isClicked:isClicked];
    }else {
        SourceLastChapter* lastChapter = [self.sourceArr objectAtIndex:indexPath.row];
        Chapter* chapter = lastChapter.lastChapter;
        Source* source = lastChapter.source;
        NSString* timeStr = [LMTool convertTimeStampToTime:chapter.updatedAt];
        [cell setupSourceWithSource:source nameStr:chapter.chapterTitle isClicked:isClicked];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger row = indexPath.row;
    BOOL isChange = NO;
    if (row != self.sourceIndex) {
        isChange = YES;
        self.sourceIndex = row;
    }
    if (self.callBlock) {
        self.callBlock(isChange, row);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deleteCurrentBookSourceCache" object:nil];
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
