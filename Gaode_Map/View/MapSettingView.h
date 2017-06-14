//
//  MapSettingView.h
//  Gaode_Map
//
//  Created by wheng on 17/6/9.
//  Copyright © 2017年 admin. All rights reserved.
//  地图设置

#import <UIKit/UIKit.h>

typedef void(^MapTypeBlock)(NSInteger);

typedef void(^MapSettingHideBlock)(void);

typedef void(^MapTrafficStatus)(BOOL);

@interface MapSettingView : UIView

@property (nonatomic, copy)MapTypeBlock block;
@property (nonatomic, copy)MapSettingHideBlock settingHideBlock;
@property (nonatomic, copy)MapTrafficStatus trafficBlock;

+ (instancetype)shareManager;

- (void)showMapViewSettingsHandler:(void(^)(void))block;

- (void)dismissMapViewSettings;

@end
