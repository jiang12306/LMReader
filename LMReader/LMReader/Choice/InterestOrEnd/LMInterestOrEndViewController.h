//
//  LMInterestOrEndViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/2/5.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum {
    LMInterestType = 0,/**<兴趣推荐*/
    LMEndType = 1,/**<经典完结*/
    LMHotBookType = 2,/**<热门图书*/
    LMPublishBookType = 3,/**<出版图书*/
    LMEditorRecommandType = 4,/**<编辑推荐*/
}LMInterestOrEndType;

@interface LMInterestOrEndViewController : LMBaseViewController

@property (nonatomic, assign) LMInterestOrEndType type;

@end
