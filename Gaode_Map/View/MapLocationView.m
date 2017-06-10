//
//  MapLocationView.m
//  Gaode_Map
//
//  Created by wheng on 17/6/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MapLocationView.h"

@interface MapLocationView ()

@property (nonatomic, strong)AMapGeoPoint *geo;
@property (nonatomic, strong)UIButton *wayButton;

@end

@implementation MapLocationView


+ (instancetype)defaultView {
    static dispatch_once_t onceToken;
    static MapLocationView *locationView;
    dispatch_once(&onceToken, ^{
        
        locationView = [[MapLocationView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - 20)];
        [locationView setBackgroundColor:[UIColor clearColor]];

        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        [window addSubview:locationView];
        
        [locationView addBlurEffect];
        //添加手势
        [locationView addPanGesture];
        [locationView addFrameObserver];
        
        [locationView createSubViews];
        [locationView createBackGroundView];
    });
    return locationView;
}

#pragma mark Func

- (void)setPointInfo:(AMapPOI *)poi {
    [self.titleLabel setText:poi.name];
    NSString *detail = [[poi.type componentsSeparatedByString:@";"] lastObject];
    [self.detailLabel setText:detail];
    self.geo = [AMapGeoPoint locationWithLatitude:poi.location.latitude longitude:poi.location.longitude];
}

#pragma mark ACTION

//路线按钮
- (void)wayButtonAction:(UIButton *)sender {
    if (self.block) {
        self.block(self.geo);
    }
}

//
- (void)createSubViews {
    [super createSubViews];
    self.wayButton  = [[UIButton alloc] initWithFrame:CGRectMake(20, 80, ScreenWidth - 40, 50)];
    [self addSubview:self.wayButton];
    self.wayButton.layer.cornerRadius = 6.f;
    [self.wayButton setBackgroundColor:[UIColor blueColor]];
    [self.wayButton setTitle:@"路线" forState:UIControlStateNormal];
    [self.wayButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.wayButton addTarget:self action:@selector(wayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

@end
