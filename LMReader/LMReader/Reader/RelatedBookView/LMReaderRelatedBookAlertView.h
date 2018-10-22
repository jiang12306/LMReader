//
//  LMReaderRelatedBookAlertView.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/7/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseAlertView.h"

typedef void (^LMReaderRelatedBookAlertViewCloseBlock) (BOOL close);
typedef void (^LMReaderRelatedBookAlertViewBookBlock) (Book* clickedBook);
typedef void (^LMReaderRelatedBookAlertViewCollectBlock) (BOOL collect);

@interface LMReaderRelatedBookAlertView : LMBaseAlertView

@property (nonatomic, copy) LMReaderRelatedBookAlertViewCloseBlock closeBlock;
@property (nonatomic, copy) LMReaderRelatedBookAlertViewBookBlock clickedBookBlock;
@property (nonatomic, copy) LMReaderRelatedBookAlertViewCollectBlock collectBlock;

-(void)startShow;

-(void)startHide;

-(void)setupAlertViewWithArray:(NSArray* )booksArr isCollected:(BOOL )isCollected;

@end
