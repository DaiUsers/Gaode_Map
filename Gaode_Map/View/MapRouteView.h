//
//  MapRouteView.h
//  Gaode_Map
//
//  Created by wheng on 17/6/10.
//  Copyright © 2017年 admin. All rights reserved.
//  路线规划

#import "MapModuleSuperView.h"

typedef void(^RouteBlockType)(NSInteger);

@interface MapRouteView : MapModuleSuperView <UITextViewDelegate,UITabBarDelegate>

@property (nonatomic, copy)RouteBlockType block;
@property (nonatomic, strong)UITextView *textView;

+ (instancetype)defaultView;
//设置始点终点信息
- (void)setPointInfo:(AMapPOI *)poi;
//添加路线view 和 信息(驾车、步行、)
- (void)addRouteView:(AMapRoute *)route;
//添加路线view 和 信息(公交)
- (void)addBusRouteView:(AMapTransit *)transit;
//移除路线view
- (void)removeRouteSubView;

@end
