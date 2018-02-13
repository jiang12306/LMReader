//
//  LMBaseRefreshTableView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseRefreshTableView.h"

@implementation LMBaseRefreshTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self setupHeaderView];
        [self setupFooterView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHeaderView];
    }
    return self;
}

//下拉刷新
-(void)setupHeaderView {
    __weak LMBaseRefreshTableView* weakSelf = self;
    MJRefreshNormalHeader * header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //下拉刷新 网络请求
        if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(refreshTableViewDidStartRefresh:)]) {
            [weakSelf.refreshDelegate refreshTableViewDidStartRefresh:self];
        }
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.mj_header = header;
}

//上拉加载
-(void)setupFooterView {
    __weak LMBaseRefreshTableView* weakSelf = self;
    MJRefreshBackNormalFooter* footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(refreshTableViewDidStartLoadMoreData:)]) {
            [weakSelf.refreshDelegate refreshTableViewDidStartLoadMoreData:self];
        }
    }];
    self.mj_footer = footer;
}

//开始刷新
-(void)startRefresh {
    [self.mj_header beginRefreshing];
}

//停止刷新
-(void)stopRefresh {
    [self.mj_header endRefreshing];
}

//禁止 下拉刷新
-(void)setupNoRefreshData {
    [self.mj_header endRefreshing];
    self.mj_header = nil;
}

//取消 禁止 下拉刷新
-(void)cancelNoRefreshData {
    [self setupHeaderView];
}

//开始上拉加载
-(void)startLoadMoreData {
    [self.mj_footer beginRefreshing];
}

//停止上拉加载
-(void)stopLoadMoreData {
    [self.mj_footer endRefreshing];
}

//禁止 上拉加载
-(void)setupNoMoreData {
    [self.mj_footer endRefreshing];
    self.mj_footer = nil;
}

//取消 禁止 上拉加载
-(void)cancelNoMoreData {
    [self setupFooterView];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
