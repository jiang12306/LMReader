//
//  LMBookShelfCollectionReusableView.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/11/29.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMBookShelfCollectionReusableView.h"

#ifdef __IPHONE_11_0
@interface CustomLayer : CALayer

@end
#endif

#ifdef __IPHONE_11_0
@implementation CustomLayer

- (CGFloat) zPosition {
    return 0;
}

@end
#endif

@implementation LMBookShelfCollectionReusableView

-(void)layoutSubviews {
    [super layoutSubviews];
    
}

#ifdef __IPHONE_11_0
+ (Class)layerClass {
    return [CustomLayer class];
}
#endif

@end
