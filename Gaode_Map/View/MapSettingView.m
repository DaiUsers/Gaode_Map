//
//  MapSettingView.m
//  Gaode_Map
//
//  Created by wheng on 17/6/9.
//  Copyright © 2017年 admin. All rights reserved.
//

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ScreenHeight        [UIScreen mainScreen].bounds.size.height

#import "MapSettingView.h"
#import "UIView+Frame.h"

@interface MapSettingView ()

@property (nonatomic, strong)UIView *backGroundView;

@end

@implementation MapSettingView

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static MapSettingView *manager;
    dispatch_once(&onceToken, ^{
        manager = [[MapSettingView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight * 2 / 3)];
        [manager setBackgroundColor:[UIColor clearColor]];
       
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        [window addSubview:manager];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [effectView setFrame:manager.bounds];
        [manager addSubview:effectView];
        
        
        [manager createSubViews];
    });
    return manager;
}

- (void)showMapViewSettingsHandler:(void (^)(void))block {
    [self showSettingViewHandler:block];
}

- (void)dismissMapViewSettings {
    [self removeBackGroundView];
    if (self.settingHideBlock) {
        self.settingHideBlock();
    }
    [self hideSettingView];
}

- (void)createBackGroundView {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.backGroundView = [[UIView alloc] initWithFrame:window.bounds];
    [window insertSubview:self.backGroundView belowSubview:self];
    
    [self.backGroundView setBackgroundColor:[UIColor blackColor]];
    [self.backGroundView setAlpha:0.3f];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMapViewSettings)];
    [self.backGroundView addGestureRecognizer:tap];
}

- (void)showSettingViewHandler:(void(^)())block {
    [UIView animateWithDuration:0.4f animations:^{
        self.y = ScreenHeight / 3;
    } completion:^(BOOL finished) {
        block();
        [self createBackGroundView];
    }];

}

- (void)hideSettingView {
    [UIView animateWithDuration:0.4f animations:^{
        self.y = ScreenHeight;
    }];
}

- (void)removeBackGroundView {
    [self.backGroundView removeFromSuperview];
}

- (void)createSubViews {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
    [self addSubview:titleLabel];
    [titleLabel setText:@"地图设置"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 44, 20, 25, 25)];
    [self addSubview:closeButton];
    [closeButton addTarget:self action:@selector(dismissMapViewSettings) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];

    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"地图",@"公交",@"卫星"]];
    [segment setFrame:CGRectMake(20, 60, self.bounds.size.width - 40, 30)];
    [self addSubview:segment];
    
    [segment setSelectedSegmentIndex:0];
    [segment setTintColor:[UIColor blueColor]];
    [segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIView *segmentLine = [[UIView alloc] initWithFrame:CGRectMake(20, 100, segment.width, 1)];
    [self addSubview:segmentLine];
    [segmentLine setBackgroundColor:[UIColor lightGrayColor]];
    
    UILabel *trafficLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, titleLabel.width, 30)];
    [self addSubview:trafficLabel];
    [trafficLabel setText:@"交通状况"];
    [trafficLabel setFont:[UIFont systemFontOfSize:17.f]];
    
    UISwitch *trafficSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth - 70, trafficLabel.y, 50, trafficLabel.height)];
    [self addSubview:trafficSwitch];
    [trafficSwitch setOn:YES];
    [trafficSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    maskLayer.frame = rect;
    self.layer.mask = maskLayer;
}

#pragma mark ACTION

- (void)switchAction:(UISwitch *)sender {
    if (self.trafficBlock) {
        self.trafficBlock(sender.isOn);
    }
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    if (self.block) {
        self.block(sender.selectedSegmentIndex);
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
