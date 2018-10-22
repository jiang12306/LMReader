//
//  LMBaseRefreshTableView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@class LMBaseRefreshTableView;

@protocol LMBaseRefreshTableViewDelegate <NSObject>

@required
-(void)refreshTableViewDidStartRefresh:(LMBaseRefreshTableView* )tv;//下拉刷新
-(void)refreshTableViewDidStartLoadMoreData:(LMBaseRefreshTableView* )tv;//上拉加载

@end

@interface LMBaseRefreshTableView : UITableView

@property (nonatomic, weak) id<LMBaseRefreshTableViewDelegate> refreshDelegate;

////无 刷
//-(void)setupNoHeaderView;

//开始刷新
-(void)startRefresh;

//停止刷新
-(void)stopRefresh;

//禁止 下拉刷新
-(void)setupNoRefreshData;

//取消 禁止 下拉刷新
-(void)cancelNoRefreshData;

////无 透视图
//-(void)setupNoFooterView;

//开始上拉加载
-(void)startLoadMoreData;

//停止上拉加载
-(void)stopLoadMoreData;

//禁止 上拉加载
-(void)setupNoMoreData;

//取消 禁止 上拉加载
-(void)cancelNoMoreData;





-(void)hideMJRefreshHeader;
-(void)showMJRefreshHeader;

@end
