//
//  LMChoiceAdCollectionViewCell.m
//  LMReader
//
//  Created by Jiang Kuan on 2018/10/24.
//  Copyright © 2018 tkmob. All rights reserved.
//

#import "LMChoiceAdCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation LMChoiceAdCollectionViewCell


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!self.bgView) {
            self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            self.bgView.backgroundColor = [UIColor whiteColor];
            self.bgView.layer.masksToBounds = YES;
            self.bgView.layer.cornerRadius = 2;
            self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
            self.bgView.layer.shadowOpacity = 0.8;
            self.bgView.layer.shadowRadius = 6.0f;
            self.bgView.layer.shadowOffset = CGSizeMake(6, 6);
            [self.contentView addSubview:self.bgView];
        }
        if (!self.adIV) {
            self.adIV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, self.bgView.frame.size.width - 10, self.bgView.frame.size.height)];
            [self.bgView addSubview:self.adIV];
        }
        if (!self.infoLab) {
            self.infoLab = [[UILabel alloc]initWithFrame:CGRectMake(10, self.bgView.frame.size.height - 15 - 10, 30, 15)];
            self.infoLab.layer.cornerRadius = 2;
            self.infoLab.layer.masksToBounds = YES;
            self.infoLab.backgroundColor = [UIColor colorWithRed:192.f/255 green:192.f/255 blue:192.f/255 alpha:1];
            self.infoLab.textColor = [UIColor whiteColor];
            self.infoLab.textAlignment = NSTextAlignmentCenter;
            self.infoLab.font = [UIFont systemFontOfSize:13];
            self.infoLab.text = @"广告";
            [self.bgView addSubview:self.infoLab];
            
            self.infoLab.hidden = YES;
        }
        if (!self.closeBtn) {
            CGFloat closeBtnWidth = 15;
            self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bgView.frame.size.width - 10 - closeBtnWidth, 10, closeBtnWidth, closeBtnWidth)];
            [self.closeBtn setImage:[UIImage imageNamed:@"ad_Close"] forState:UIControlStateNormal];
            [self.closeBtn addTarget:self action:@selector(clickedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.bgView addSubview:self.closeBtn];
            
            self.closeBtn.hidden = YES;
        }
    }
    return self;
}

-(void)clickedCloseButton:(UIButton* )sender {
    
}

-(void)setModel:(id )model {
    if ([model isKindOfClass:[TopicAd class]]) {
        TopicAd* topicAd = (TopicAd* )model;
        self.topAd = topicAd;
        Ad* ad;
        if ([topicAd hasBook]) {//图书类型的广告
            self.infoLab.hidden = YES;
            self.closeBtn.hidden = YES;
            ad = self.topAd.book;
        }else {//广告
            self.infoLab.hidden = NO;
            self.closeBtn.hidden = YES;
            ad = self.topAd.ad;
        }
        NSString* imgStr = [ad.pic stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self.adIV sd_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"ad_DefaultImage"]];
    }
}
/*
-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.adIV.frame = CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height);
    if (![self.topAd hasBook]) {
        Ad* ad = self.topAd.ad;
        NSInteger position = ad.pos;//广告标识位置
        CGRect infoRect = CGRectMake(10, self.bgView.frame.size.height - self.infoLab.frame.size.height - 10, self.infoLab.frame.size.width, self.infoLab.frame.size.height);
        CGRect closeRect = CGRectMake(self.bgView.frame.size.width - self.closeBtn.frame.size.width - 10, 10, self.closeBtn.frame.size.width, self.closeBtn.frame.size.height);
        if (position == 1) {//右上角
            infoRect.origin.x = self.bgView.frame.size.width - self.infoLab.frame.size.width - 10;
            infoRect.origin.y = 10;
            closeRect.origin.y = self.bgView.frame.size.height - self.closeBtn.frame.size.height - 10;
        }else if (position == 2) {//右下角
            infoRect.origin.x = self.bgView.frame.size.width - self.infoLab.frame.size.width - 10;
            infoRect.origin.y = self.bgView.frame.size.height - self.infoLab.frame.size.height - 10;
        }else if (position == 3) {//左上角
            infoRect.origin.x = 10;
            infoRect.origin.y = 10;
        }else if (position == 4) {//左下角
            
        }
        self.infoLab.frame = infoRect;
        self.closeBtn.frame = closeRect;
    }
    
}
*/
@end
