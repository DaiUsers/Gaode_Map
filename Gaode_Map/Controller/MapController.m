//
//  MapController.m
//  AliPay_Test
//
//  Created by wheng on 17/6/3.
//  Copyright © 2017年 admin. All rights reserved.
//

#define ScreenWidth     [UIScreen mainScreen].bounds.size.width
#define ScreenHeight    [UIScreen mainScreen].bounds.size.height


#import "MapController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MapButtonTop.h"
#import "MapButtonBottom.h"
#import "MAAnnotationView+Rotate.h"

#import "MapSettingView.h"
#import "MapLocationView.h"

@interface MapController ()<MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong)MAMapView *mapView;
@property (nonatomic, strong)AMapSearchAPI *searchAPI;
@property (nonatomic, strong)MAUserLocationRepresentation *r;

@property (nonatomic, strong)MapButtonBottom *bottom;
@property (nonatomic, strong)MapButtonTop    *top;

//点击地图标注点弹出视图
@property (nonatomic, strong)MapLocationView *touchView;

@property (nonatomic, strong)UIVisualEffectView *searchEffectView;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)AMapGeoPoint *origin;
@property (nonatomic, strong)AMapGeoPoint *destination;

@end

@implementation MapController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createMapView];
    [self createMapTapGesture];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [effectView setFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    [self.view addSubview:effectView];
    
}

- (void)createMapTapGesture {
    
    self.searchAPI = [[AMapSearchAPI alloc] init];
    self.searchAPI.delegate = self;
    
    UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapAction:)];
    [self.mapView addGestureRecognizer:mapTap];
}
//创建地图
- (void)createMapView {
    
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    

    
    //
    [self.mapView setShowTraffic:YES];
    [self.mapView setZoomLevel:15.f animated:YES];
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setDelegate:self];
    
    [self setMapStatusButton];
    [self setMapUserLocationRepresentation];
    [self setMapScale];
    [self setMapCompass];
    
    //
//    [self.mapView addSubview:self.touchView];
}
//设置地图状态按钮
- (void)setMapStatusButton {
    self.top = [[MapButtonTop alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 30,42 , 42)];
    [self.view addSubview:self.top];
    [self.top addTarget:self action:@selector(topButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.top.backgroundColor = [UIColor redColor];
    
    
    self.bottom = [[MapButtonBottom alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 72, 42, 42)];
    [self.view addSubview:self.bottom];
    [self.bottom addTarget:self actionFirst:@selector(bottomFirstAction) second:@selector(bottomSecondAction) third:@selector(bottomThirdAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottom setBackgroundColor:[UIColor whiteColor]];
    [self.bottom setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

//设置定位蓝点
- (void)setMapUserLocationRepresentation {
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    
    self.r = [[MAUserLocationRepresentation alloc] init];
    self.r.showsHeadingIndicator = YES;
    self.r.image = [UIImage imageNamed:@"arrow"];
    
    [self.mapView updateUserLocationRepresentation:self.r];
}
//设置比例尺
- (void)setMapScale {
    [self.mapView setScaleOrigin:CGPointMake(20, 20)];
    [self.mapView setShowsScale:NO];
}
//设置指南针
- (void)setMapCompass {
    [self.mapView setShowsCompass:NO];
    [self.mapView setCompassOrigin:CGPointMake(ScreenWidth - 45, 120)];
}

#pragma mark ------ MapStatusButton_ACTION

- (void)bottomFirstAction {
    if (self.mapView.zoomLevel < 15.f) {
         [self.mapView setZoomLevel:15.f animated:YES];
    }
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    self.bottom.yt_Status = yt_SelfLocation;
}

- (void)bottomSecondAction {
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading animated:YES];
    self.bottom.yt_Status = yt_Compass;
}

- (void)bottomThirdAction {
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    self.bottom.yt_Status = yt_Normal;
}

- (void)topButtonAction {
    
    MapSettingView *settingsView = [MapSettingView shareManager];
    __block typeof(self)weakSelf = self;
    
    [settingsView showMapViewSettingsHandler:^{
        [weakSelf.top       setAlpha:0.f];
        [weakSelf.bottom    setAlpha:0.f];
        
    }];
    
    settingsView.trafficBlock = ^(BOOL value) {
        [weakSelf.mapView setShowTraffic:value];
    };
    
    settingsView.settingHideBlock = ^() {
        [weakSelf.top       setAlpha:1.f];
        [weakSelf.bottom    setAlpha:1.f];
    };
    settingsView.block = ^(NSInteger index) {
        switch (index) {
            case 0: {
                [weakSelf.mapView setMapType:MAMapTypeStandard];
            }
                break;
            case 1: {
                [weakSelf.mapView setMapType:MAMapTypeBus];
            }
                break;
                
            case 2: {
                [weakSelf.mapView setMapType:MAMapTypeSatellite];
            }
                break;
            default:
                break;
        }
    };
    
    
}

//地图点击响应
- (void)mapTapAction:(UIGestureRecognizer *)gestureRecognizer {
    self.touchView = [MapLocationView defaultView];
    __block typeof(self)weakSelf = self;
    self.touchView.block = ^(AMapGeoPoint *destination) {
        AMapRidingRouteSearchRequest *ridingSearch = [[AMapRidingRouteSearchRequest alloc] init];
        ridingSearch.origin = [AMapGeoPoint locationWithLatitude:weakSelf.mapView.userLocation.coordinate.latitude longitude:weakSelf.mapView.userLocation.coordinate.longitude];
        ridingSearch.destination = destination;
        [weakSelf.searchAPI AMapRidingRouteSearch:ridingSearch];
    };

    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCorrdinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:touchMapCorrdinate.latitude longitude:touchMapCorrdinate.longitude];
    regeo.requireExtension = YES;
    //地理查找
    [self.searchAPI AMapReGoecodeSearch:regeo];
    
    //终点
    self.destination = [AMapGeoPoint locationWithLatitude:touchMapCorrdinate.latitude longitude:touchMapCorrdinate.longitude];
}

#pragma mark ------ Search_DELEGATE

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    
    MAAnimatedAnnotation *annotation = [[MAAnimatedAnnotation alloc] init];
    annotation.coordinate = self.mapView.userLocation.coordinate;
    [self.mapView addAnnotation:annotation];
//    for (AMapPath *obj in response.route.paths) {
//        NSLog(@"===距离：%ld",(long)obj.distance);
        NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
        for (AMapStep *step in response.route.paths[0].steps) {
            /*
             ///行走指示
             @property (nonatomic, copy)   NSString  *instruction;
             ///方向
             @property (nonatomic, copy)   NSString  *orientation;
             ///道路名称
             @property (nonatomic, copy)   NSString  *road;
             ///此路段长度（单位：米）
             @property (nonatomic, assign) NSInteger  distance;
             ///此路段预计耗时（单位：秒）
             @property (nonatomic, assign) NSInteger  duration;
             ///此路段坐标点串
             @property (nonatomic, copy)   NSString  *polyline;
             */
            NSArray *array = [step.polyline componentsSeparatedByString:@";"];
            CLLocationCoordinate2D coords[array.count];
            for (int i = 0; i < array.count; i ++) {
                NSArray *temp = [[array objectAtIndex:i] componentsSeparatedByString:@","];
                coords[i].longitude = [temp.firstObject doubleValue];
                coords[i].latitude  = [temp.lastObject doubleValue];
            }
            MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:array.count];
            [overlayArray addObject:polyline];
            
            
            [annotation addMoveAnimationWithKeyCoordinates:coords count:array.count withDuration:5.f withName:@"" completeCallback:nil];
        }
        [self.mapView addOverlays:overlayArray];
//    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.strokeColor = [UIColor redColor];
        polylineRenderer.lineWidth   = 5.f;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType  = kMALineCapRound;
        
        
        
        return polylineRenderer;
    }
    
    return nil;

}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {

    if (response.regeocode != nil) {
        //
        //pois
        NSArray *poisArray = response.regeocode.pois;
        
        if (poisArray.count > 0) {
            AMapPOI *poi = [poisArray firstObject];
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);

            [annotation setCoordinate:coordinate];
            [annotation setTitle:poi.name];
            [self.mapView removeOverlays:self.mapView.overlays];
            [self.mapView addAnnotation:annotation];
            [self.mapView selectAnnotation:annotation animated:YES];
            
            [self.touchView showMapLocationView];
            [self.touchView setPointInfo:poi];
        }
    }
}
#pragma mark ------ MAPVIEW_DELEGATE


- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    CLHeading *heading = userLocation.heading;
    
    MAAnnotationView *view = [mapView viewForAnnotation:userLocation];
    [view rotateWithHeading:heading];
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
//    NSLog(@"%@",annotation);
//    return nil;
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
//        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
//        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
//        annotationView.pinColor = MAPinAnnotationColorPurple;
        
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    } else if ([annotation isKindOfClass:[MAAnimatedAnnotation class]]) {
        NSLog(@"MAAnimatedAnnotation");
    }
    return nil;
}

/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //旋转左右5°的时候隐藏指南针
    if (abs((int)self.mapView.rotationDegree - 180) >= 175) {
        self.mapView.rotationDegree = 0;
        [self.mapView setShowsCompass:NO];

    } else {

        [self.mapView setShowsCompass:YES];
    }
}

/**
 * @brief 地图将要发生移动时调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    self.bottom.yt_Status = yt_Normal;
}

/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
//    self.bottom.yt_Status = yt_Normal;
}


/**
 * @brief 地图将要发生缩放时调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction {
    [self.mapView setShowsScale:YES];
}

/**
 * @brief 地图缩放结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction {
    [self.mapView setShowsScale:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
