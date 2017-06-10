//
//  MapRouteView.m
//  Gaode_Map
//
//  Created by wheng on 17/6/10.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MapRouteView.h"

@implementation MapRouteView

+ (instancetype)defaultView {
    static MapRouteView *routeView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routeView = [[MapRouteView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - 20)];
        [routeView setBackgroundColor:[UIColor clearColor]];
        
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        [window addSubview:routeView];
        
        [routeView addBlurEffect];
        //添加手势
        [routeView addPanGesture];
        [routeView addFrameObserver];
        
        [routeView createSubViews];
        [routeView createBackGroundView];

    });
    return routeView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
