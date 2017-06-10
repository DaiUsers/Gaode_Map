//
//  MapLocationView.h
//  Gaode_Map
//
//  Created by wheng on 17/6/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MapModuleSuperView.h"
#import <AMapSearchKit/AMapSearchKit.h>

typedef void(^RouteBlock)(AMapGeoPoint *);

@interface MapLocationView : MapModuleSuperView

@property (nonatomic, copy)RouteBlock block;

+ (instancetype)defaultView;

- (void)setPointInfo:(AMapPOI *)poi;

@end
