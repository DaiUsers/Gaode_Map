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
#import "MapRouteView.h"

@interface MapController ()<MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong)MAMapView *mapView;
@property (nonatomic, strong)AMapSearchAPI *searchAPI;
//定位蓝点
@property (nonatomic, strong)MAUserLocationRepresentation *r;

@property (nonatomic, strong)MapButtonBottom *bottom;
@property (nonatomic, strong)MapButtonTop    *top;

//点击地图标注点弹出视图（标注点信息）
@property (nonatomic, strong)MapLocationView *touchView;
//路线规划view
@property (nonatomic, strong)MapRouteView    *routeView;

@property (nonatomic, strong)UIVisualEffectView *searchEffectView;

@property (nonatomic, strong)UITableView *tableView;

//@property (nonatomic, strong)AMapGeoPoint *origin;
//@property (nonatomic, strong)AMapGeoPoint *destination;

@property (nonatomic, assign)BOOL isBus;

@end

@implementation MapController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createMapView];
    //添加地图点击响应
    [self createMapTapGesture];
    //状态栏模糊
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [effectView setFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    [self.view addSubview:effectView];
    
}
//添加地图点击响应
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
    ///交通状况
    [self.mapView setShowTraffic:YES];
    ///地图比例大小
    [self.mapView setZoomLevel:15.f animated:YES];
    ///当前位置
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setDelegate:self];
    ///设置地图状态按钮
    [self setMapStatusButton];
    ///当前位置标注
    [self setMapUserLocationRepresentation];
    ///比例尺
    [self setMapScale];
    ///指南针
    [self setMapCompass];
}
//设置地图状态按钮 (右上角两个按钮)
- (void)setMapStatusButton {
    self.top = [[MapButtonTop alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 30,42 , 42)];
    [self.view addSubview:self.top];
    [self.top addTarget:self action:@selector(topButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.bottom = [[MapButtonBottom alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 72, 42, 42)];
    [self.view addSubview:self.bottom];
    [self.bottom addTarget:self actionFirst:@selector(bottomFirstAction) second:@selector(bottomSecondAction) third:@selector(bottomThirdAction) forControlEvents:UIControlEventTouchUpInside];
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
    
#pragma mark locationView
    
    self.touchView = [MapLocationView defaultView];
    self.routeView = [MapRouteView defaultView];
    
    [self.touchView showMapLocationView];
    [self.routeView dismissMapLocationView];

    __block typeof(self)weakSelf = self;
    //路线Action
    self.touchView.block = ^(AMapReGeocode *regeo) {

#pragma mark RouteView
        AMapPOI *poi = regeo.pois.firstObject;
        [weakSelf.routeView setPointInfo:poi];
        
        //起始点
        AMapGeoPoint *origin      = [AMapGeoPoint locationWithLatitude:weakSelf.mapView.userLocation.coordinate.latitude longitude:weakSelf.mapView.userLocation.coordinate.longitude];
        //终点
        AMapGeoPoint *destination = [AMapGeoPoint locationWithLatitude:poi.location.latitude longitude:poi.location.longitude];
        
        __block typeof(weakSelf)awSelf = weakSelf;
        weakSelf.routeView.block = ^(NSInteger typeIndex) {
            [awSelf.routeView removeRouteSubView];
            
            if (typeIndex == 0) {//驾车
                [awSelf setIsBus:NO];
                AMapDrivingRouteSearchRequest *drivingRoute = [[AMapDrivingRouteSearchRequest alloc] init];
                [drivingRoute setOrigin:origin];
                [drivingRoute setDestination:destination];
                [drivingRoute setRequireExtension:YES];
                [awSelf.searchAPI AMapDrivingRouteSearch:drivingRoute];
            } else if (typeIndex == 1){//步行
                [awSelf setIsBus:NO];
                AMapWalkingRouteSearchRequest *walkingSearch = [[AMapWalkingRouteSearchRequest alloc] init];
                [walkingSearch setOrigin:origin];
                [walkingSearch setDestination:destination];
                [awSelf.searchAPI AMapWalkingRouteSearch:walkingSearch];
            } else if (typeIndex == 2) {
                [awSelf setIsBus:YES];//公交路线
                AMapTransitRouteSearchRequest *busSearch = [[AMapTransitRouteSearchRequest alloc] init];
                
                [busSearch setOrigin:origin];
                [busSearch setDestination:destination];
                [busSearch setRequireExtension:YES];
                //最少步行
                [busSearch setStrategy:3];
                [busSearch setCity:regeo.addressComponent.city];
                [busSearch setDestinationCity:regeo.addressComponent.city];
                [awSelf.searchAPI AMapTransitRouteSearch:busSearch];
            } else if (typeIndex == 3) {
                awSelf.isBus = NO;

            }
            
        };
        
        awSelf.isBus = NO;

        [weakSelf.routeView showMapLocationView];
        [weakSelf.touchView dismissMapLocationView];
        
        //default route type (driving)
        AMapDrivingRouteSearchRequest *drivingRoute = [[AMapDrivingRouteSearchRequest alloc] init];
        [drivingRoute setRequireExtension:YES];
        [drivingRoute setOrigin:origin];
        [drivingRoute setDestination:destination];
        [weakSelf.searchAPI AMapDrivingRouteSearch:drivingRoute];
    };

    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCorrdinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:touchMapCorrdinate.latitude longitude:touchMapCorrdinate.longitude];
    regeo.requireExtension = YES;
    //地理查找
    [self.searchAPI AMapReGoecodeSearch:regeo];
}

#pragma mark ------ Search_DELEGATE

- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    //路线查找结果，先移除之前的路线规划（公交和其它方式有区别）
    [self.mapView removeOverlays:self.mapView.overlays];
    
    if (self.isBus) {
        NSLog(@"%@",response.formattedDescription);
        //公交路线
        NSArray *transitsArr = response.route.transits;//公交方案
        
        for (AMapTransit *transit in transitsArr) {
            //添加路线信息
            [[MapRouteView defaultView] addBusRouteView:transit];
            //
            NSArray *segmentsArr = transit.segments;//换乘路段
            for (AMapSegment *segment in segmentsArr) {
                ///公交换乘路段，如果walking和buslines同时有值，则是先walking后buslines
                if (segment.walking != nil) {
                    NSArray *stepsArr = segment.walking.steps;
                    for (AMapStep *step in stepsArr) {
                        //坐标串转polyline
                        MAPolyline *polyline = [self transformFromCoordString:step.polyline];
                        polyline.title = @"walking";
                        [self.mapView addOverlay:polyline];
                    }
                }
                
                if (segment.buslines.count > 0) {
                    NSArray *busLinesArr = segment.buslines;
                    for (AMapBusLine *busline in busLinesArr) {
                        //坐标串转polyline
                        MAPolyline *polyline = [self transformFromCoordString:busline.polyline];
                        polyline.title = @"busline";
                        [self.mapView addOverlay:polyline];
                    }
                }
                
            }
            //暂时只写一条公交路线
            return;
        }
        return;
    } else {
        //添加路线信息
        [[MapRouteView defaultView] addRouteView:response.route];
        MAAnimatedAnnotation *annotation = [[MAAnimatedAnnotation alloc] init];
        annotation.coordinate = self.mapView.userLocation.coordinate;
        [self.mapView addAnnotation:annotation];
   
        for (AMapPath *obj in response.route.paths) {
                   NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
            for (AMapStep *step in obj.steps) {
                MAPolyline *polyline = [self transformFromCoordString:step.polyline];
                [overlayArray addObject:polyline];
            }
            [self.mapView addOverlays:overlayArray];
        }
    }
}
//绘制路线折线
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        MAPolyline *polyline = (MAPolyline *)overlay;
        if ([polyline.title isEqualToString:@"walking"]) {
            polylineRenderer.strokeColor = [UIColor darkGrayColor];
            polylineRenderer.lineDash = YES;
        } else {
            polylineRenderer.strokeColor = [UIColor redColor];
        }
        polylineRenderer.lineWidth   = 5.f;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.lineCapType  = kMALineCapRound;
        
        return polylineRenderer;
    }
    return nil;
}
//查询失败回调
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"Error");
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {

    if (response.regeocode != nil) {
        //
        //pois
        NSArray *poisArray = response.regeocode.pois;
        
        if (poisArray.count > 0) {
            AMapPOI *poi = [poisArray firstObject];
            //添加标注，在代理中设置标注形式
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
            [annotation setCoordinate:coordinate];
            [annotation setTitle:poi.name];
            [self.mapView removeOverlays:self.mapView.overlays];
            [self.mapView addAnnotation:annotation];
            [self.mapView selectAnnotation:annotation animated:YES];
            
#pragma mark locationShow
            
            [self.touchView showMapLocationView];
            [self.touchView setPointInfo:response.regeocode];
        }
    }
}
#pragma mark ------ MAPVIEW_DELEGATE


- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    CLHeading *heading = userLocation.heading;
    
    MAAnnotationView *view = [mapView viewForAnnotation:userLocation];
    [view rotateWithHeading:heading];
    
}
//设置地图标注点形式 （代理）
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
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


#pragma mark FUNC

//坐标串转polyline
- (MAPolyline *)transformFromCoordString:(NSString *)polylineString {
    NSArray *array = [polylineString componentsSeparatedByString:@";"];
    CLLocationCoordinate2D coords[array.count];
    for (int i = 0; i < array.count; i ++) {
        NSArray *temp = [[array objectAtIndex:i] componentsSeparatedByString:@","];
        coords[i].longitude = [temp.firstObject doubleValue];
        coords[i].latitude  = [temp.lastObject doubleValue];
    }
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:array.count];
    return polyline;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
