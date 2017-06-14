//
//  MapLocationView.h
//  Gaode_Map
//
//  Created by wheng on 17/6/9.
//  Copyright © 2017年 admin. All rights reserved.
//  标注位置

#import "MapModuleSuperView.h"

typedef void(^RouteBlock)(AMapReGeocode *);

@interface MapLocationView : MapModuleSuperView

@property (nonatomic, copy)RouteBlock block;
//创建view
+ (instancetype)defaultView;
//添加标注信息
- (void)setPointInfo:(AMapReGeocode *)regeo;

@end
