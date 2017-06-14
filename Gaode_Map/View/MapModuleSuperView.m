//
//  MapModuleSuperView.m
//  Gaode_Map
//
//  Created by wheng on 17/6/10.
//  Copyright © 2017年 admin. All rights reserved.
//


#import "MapModuleSuperView.h"

@implementation MapModuleSuperView
//显示view
- (void)showMapLocationView {
    if (self.isShow == NO) {
        [UIView animateWithDuration:0.4f animations:^{
            self.y = ScreenHeight * 2 / 3;
        }];
        self.isShow = YES;
    }
}
//隐藏view
- (void)dismissMapLocationView {
    if (self.isShow) {
        [self hideLocationView];
        self.isShow = NO;
    }
}

- (void)hideLocationView {
    [UIView animateWithDuration:0.4f animations:^{
        self.y = ScreenHeight;
    }];
}
//创建遮盖view
- (void)createBackGroundView {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.backGroundView = [[UIView alloc] initWithFrame:window.bounds];
    [window insertSubview:self.backGroundView belowSubview:self];
    
    [self.backGroundView setBackgroundColor:[UIColor blackColor]];
    [self.backGroundView setAlpha:0.f];

}
//创建通用布局
- (void)createSubViews {
    UIView *touchLine = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - 15, 5, 40, 5)];
    [self addSubview:touchLine];
    [touchLine setBackgroundColor:[UIColor lightGrayColor]];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:touchLine.bounds cornerRadius:2.f];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame   = touchLine.bounds;
    maskLayer.path    = maskPath.CGPath;
    touchLine.layer.mask = maskLayer;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, ScreenWidth - 70, 20)];
    [self addSubview:self.titleLabel];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17.f]];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 42, ScreenWidth - 70, 20)];
    [self addSubview:self.detailLabel];
    [self.detailLabel setFont:[UIFont systemFontOfSize:15.f]];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 44, 20, 25, 25)];
    [self addSubview:closeButton];
    [closeButton addTarget:self action:@selector(dismissMapLocationView) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
}
//设置view模糊
- (void)addBlurEffect {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [effectView setFrame:self.bounds];
    
    [self addSubview:effectView];
}
//添加手势
- (void)addPanGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanGestureAction:)];
    
    [self addGestureRecognizer:pan];
    self.normalHeight = ScreenHeight * 2 / 3;
}
//监听布局变化
- (void)addFrameObserver {
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        if (self.y < ScreenHeight * 2 / 5) {
            CGFloat h = ScreenHeight * 2.0 / 5;
            self.backGroundView.alpha = (h - self.y) * 0.5 / (h - 40);
        } else {
            self.backGroundView.alpha = 0.f;
        }
    }
}

//拖拽手势
- (void)viewPanGestureAction:(UIPanGestureRecognizer *)sender {
    
    UIView *view = sender.view;
    CGPoint point = [sender translationInView:view.superview];
    
    view.y = view.y + point.y;
    
    if (view.y <= 50) {
        //
        
        view.y = view.y - point.y*2/3;
        
        if (view.y <= 30) {
            view.y = 30;
        }
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
            [UIView animateWithDuration:0.3f animations:^{
                view.y = 50;
            }];
        }
    } else if (view.y >= ScreenHeight - 70) {
        view.y = ScreenHeight - 70;
    } else {
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
            if (view.y <= ScreenHeight * 2 / 5) {
                [UIView animateWithDuration:0.2f animations:^{
                    view.y = 50;
                }];
            } else if (view.y >= ScreenHeight * 3 / 4) {
                [UIView animateWithDuration:0.1f animations:^{
                    view.y = ScreenHeight - 70;
                }];
            } else {
                [UIView animateWithDuration:0.2f animations:^{
                    view.y = self.normalHeight;
                }];
            }
            
        }
    }
    
    [sender setTranslation:CGPointZero inView:view.superview];
}

//绘制圆角
- (void)drawRect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path  = maskPath.CGPath;
    self.layer.mask = maskLayer;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
