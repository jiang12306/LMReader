//
//  LMChoiceAdCollectionViewCell.h
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/24.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCAdViewRenderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LMChoiceAdCollectionViewCell : UICollectionViewCell <SCAdViewRenderDelegate>

@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIImageView* adIV;
@property (nonatomic, strong) UILabel* infoLab;
@property (nonatomic, strong) UIButton* closeBtn;

@property (nonatomic, strong) TopicAd* topAd;

@end

NS_ASSUME_NONNULL_END
