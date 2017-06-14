//
//  MapModuleSuperView.h
//  Gaode_Map
//
//  Created by wheng on 17/6/10.
//  Copyright © 2017年 admin. All rights reserved.
//  superView

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ScreenHeight        [UIScreen mainScreen].bounds.size.height

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface MapModuleSuperView : UIView

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *detailLabel;
@property (nonatomic, strong)UIView  *backGroundView;
@property (nonatomic, assign)CGFloat normalHeight;
@property (nonatomic, assign)BOOL    isShow;

//显示view
- (void)showMapLocationView;
//隐藏view
- (void)dismissMapLocationView;
//创建通用布局
- (void)createSubViews;
//创建遮盖view
- (void)createBackGroundView;
//设置view模糊
- (void)addBlurEffect;
//添加手势
- (void)addPanGesture;
//监听布局变化
- (void)addFrameObserver;

@end
