//
//  MapRouteView.m
//  Gaode_Map
//
//  Created by wheng on 17/6/10.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MapRouteView.h"
#import "MapLocationView.h"

@interface MapRouteView ()

@property (nonatomic, strong)UIView *routeGroundView;
@property (nonatomic, strong)NSArray *titleArray;
@property (nonatomic, strong)NSArray *imageArray;
@property (nonatomic, strong)UITabBar *tabBar;
@end

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
//设置始点终点信息
- (void)setPointInfo:(AMapPOI *)poi {
    //点击路线，切换方式，关闭再点击路线，默认是car
    self.tabBar.selectedItem = self.tabBar.items.firstObject;
    
    [self.titleLabel setText:[NSString stringWithFormat:@"终点：%@",poi.name]];
    NSString *string = @"起点  我的位置";
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range = [string rangeOfString:@"我的位置"];
    [attribute addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSLinkAttributeName:@"myLocationAction"} range:range];

    [self.textView setAttributedText:attribute];
    self.textView.delegate = self;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([[NSString stringWithFormat:@"%@",URL] isEqualToString: @"myLocationAction"]) {
        NSLog(@"change start point");
    }
    return YES;
}

- (void)showMapLocationView {
    if (self.isShow == NO) {
        [UIView animateWithDuration:0.4f animations:^{
            self.y = ScreenHeight * 2 / 3 - 49;
        }];
        self.isShow = YES;
    }
    
}

- (void)dismissMapLocationView {
    [[MapLocationView defaultView] showMapLocationView];
    [super dismissMapLocationView];
}

- (void)addFrameObserver {
    [super addFrameObserver];
}

- (void)addPanGesture {
    return;
    [super addPanGesture];
    self.normalHeight = self.normalHeight - 49;
}
//移除路线view
- (void)removeRouteSubView {
    [self.routeGroundView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
//
//添加路线view 和 信息(公交)
- (void)addBusRouteView:(AMapTransit *)transit {
    [self removeRouteSubView];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
    [self.routeGroundView addSubview:timeLabel];
    [timeLabel setFont:[UIFont boldSystemFontOfSize:17]];
    
    UILabel *disLabel  = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 200, 44)];
    [self.routeGroundView addSubview:disLabel];
    [disLabel setFont:[UIFont systemFontOfSize:15]];
    [disLabel setTextColor:[UIColor lightGrayColor]];
    [disLabel setNumberOfLines:2];
    
    
    for (AMapSegment *segment in transit.segments) {
        for (NSInteger i = 0 ; i < segment.buslines.count; i ++) {
            AMapBusLine *busline = [segment.buslines objectAtIndex:i];
            UILabel *busNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + 51 * i, 84, 49, 20)];
            [self.routeGroundView addSubview:busNumLabel];
            [busNumLabel setBackgroundColor:[UIColor blueColor]];
            [busNumLabel setText:[[busline.name componentsSeparatedByString:@"路"] firstObject]];
            [busNumLabel setTextColor:[UIColor whiteColor]];
            [busNumLabel setFont:[UIFont systemFontOfSize:15]];
            [busNumLabel setTextAlignment:NSTextAlignmentCenter];
        }
    }
    
    
    
    NSInteger time   = transit.duration / 60;
    
    [disLabel setText:[NSString stringWithFormat:@"步行 %ld米 · ￥%.1f\n最少步行",transit.walkingDistance,transit.cost]];
    [timeLabel setText:[NSString stringWithFormat:@"%ld分钟",time]];
}
//添加路线view 和 信息(驾车、步行、)
- (void)addRouteView:(AMapRoute *)route {
    [self removeRouteSubView];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 20)];
    [self.routeGroundView addSubview:timeLabel];
    [timeLabel setFont:[UIFont boldSystemFontOfSize:17]];
    
    UILabel *disLabel  = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 100, 44)];
    [self.routeGroundView addSubview:disLabel];
    [disLabel setFont:[UIFont systemFontOfSize:15]];
    [disLabel setTextColor:[UIColor lightGrayColor]];
    [disLabel setNumberOfLines:2];
    
    CGFloat distance = route.paths.firstObject.distance * 1.0 / 1000;
    NSInteger time   = route.paths.firstObject.duration / 60;
    
    [disLabel setText:[NSString stringWithFormat:@"%.1f公里\n最快路线",distance]];
    [timeLabel setText:[NSString stringWithFormat:@"%ld分钟",time]];
}

- (void)createSubViews {
    [super createSubViews];
    
//    CGRect frame = self.detailLabel.frame;
    [self.detailLabel removeFromSuperview];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 40, ScreenWidth - 70, 25)];
    [self addSubview:self.textView];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    [self.textView setFont:[UIFont systemFontOfSize:18]];
    [self.textView setEditable:NO];
    
    UIView *titleLine = [[UIView alloc] initWithFrame:CGRectMake(20, 70, ScreenWidth - 40, 0.5)];
    [self addSubview:titleLine];
    [titleLine setBackgroundColor:[UIColor lightGrayColor]];
    ///
    self.routeGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 71, ScreenWidth, ScreenHeight / 2 - 71)];
    [self addSubview:self.routeGroundView];
    
    self.tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, ScreenHeight / 3, ScreenWidth, 49)];

    [self addSubview:self.tabBar];
    self.titleArray = @[@"驾车",@"步行",@"公交",@"叫车"];
    self.imageArray = @[@"car",@"walk",@"bus",@"tax"];

    NSMutableArray *itemsArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.titleArray.count; i ++) {
        UITabBarItem *item = [self createItem:i];
        [itemsArr addObject:item];
    }

    [self.tabBar setItems:itemsArr];
    self.tabBar.delegate = self;
    self.tabBar.selectedItem = itemsArr.firstObject;
}

- (UITabBarItem *)createItem:(NSInteger)index {
    
    UIImage *image = [[UIImage imageNamed:[self.imageArray objectAtIndex:index]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",[self.imageArray objectAtIndex:index]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:[self.titleArray objectAtIndex:index] image:image selectedImage:selectedImage];

    item.tag = index;
    return item;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"%@",item.title);
    if (self.block) {
        self.block(item.tag);
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
