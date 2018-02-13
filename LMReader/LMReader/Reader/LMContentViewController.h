//
//  LMContentViewController.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/1/31.
//  Copyright © 2018年 tkmob. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum {
    LMReadModelDay = 1,
    LMReadModelNight = 2
}LMReadModel;

#define contentNaviHeight ([LMTool isIPhoneX]?88:64)
#define contentToolHeight ([LMTool isIPhoneX]?83:49)
#define contentScreenWidth [UIScreen mainScreen].bounds.size.width
#define contentScreenHeight [UIScreen mainScreen].bounds.size.height
#define contentRect CGRectMake(10, contentNaviHeight, contentScreenWidth - 10*2, contentScreenHeight - contentNaviHeight - contentToolHeight)

@interface LMContentViewController : LMBaseViewController

-(instancetype )initWithReadModel:(LMReadModel )readModel fontSize:(CGFloat )fontSize content:(NSString* )content;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) LMReadModel readModel;
@property (nonatomic, assign) CGFloat fontSize;


@end
