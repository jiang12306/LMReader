//
//  LMBookShelfDetailAlertView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/4.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

typedef void (^LMBookShelfDetailAlertViewDownload) (BOOL download);
typedef void (^LMBookShelfDetailAlertViewRead) (BOOL read);
typedef void (^LMBookShelfDetailAlertViewDetail) (BOOL detail);

@interface LMBookShelfDetailAlertView : LMBaseAlertView

@property (nonatomic, copy) LMBookShelfDetailAlertViewDownload downloadBlock;
@property (nonatomic, copy) LMBookShelfDetailAlertViewRead readBlock;
@property (nonatomic, copy) LMBookShelfDetailAlertViewDetail detailBlock;

-(void)startShow;

-(void)startHide;

-(void)setupContentsWithBook:(UserBook* )userBook;

-(void)setupDownloadTitleWithString:(NSString* )titleStr;

@end
