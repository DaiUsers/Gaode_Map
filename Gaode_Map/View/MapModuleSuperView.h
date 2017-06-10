//
//  MapModuleSuperView.h
//  Gaode_Map
//
//  Created by wheng on 17/6/10.
//  Copyright © 2017年 admin. All rights reserved.
//

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ScreenHeight        [UIScreen mainScreen].bounds.size.height

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"

@interface MapModuleSuperView : UIView

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *detailLabel;
@property (nonatomic, strong)UIView  *backGroundView;

- (void)showMapLocationView;

- (void)dismissMapLocationView;

- (void)createSubViews;

- (void)createBackGroundView;

- (void)addBlurEffect;

- (void)addPanGesture;

- (void)addFrameObserver;

@end
