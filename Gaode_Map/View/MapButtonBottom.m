//
//  MapButtonBottom.m
//  AliPay_Test
//
//  Created by wheng on 17/6/3.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MapButtonBottom.h"

@interface MapButtonBottom ()

@property (nonatomic, strong)id _yt_target;
@property (nonatomic, assign)SEL _yt_actionFirst;
@property (nonatomic, assign)SEL _yt_actionSecond;
@property (nonatomic, assign)SEL _yt_actionThird;

@end

@implementation MapButtonBottom

- (void)setYt_Status:(ButtonStatus)yt_Status {
    _yt_Status = yt_Status;
    [self setTitle:[NSString stringWithFormat:@"%ld",_yt_Status] forState:UIControlStateNormal];
}

- (void)addTarget:(id)target actionFirst:(SEL)action second:(SEL)actions third:(SEL)actiont forControlEvents:(UIControlEvents)controlEvents {
    self.yt_Status = yt_Normal;
    self._yt_target = target;
    self._yt_actionFirst = action;
    self._yt_actionSecond = actions;
    self._yt_actionThird = actiont;
    [self addTarget:self action:@selector(buttonAction) forControlEvents:controlEvents];
}


- (void)buttonAction {
    SEL selector;
    if (self.yt_Status == yt_Normal) {
        
        selector = self._yt_actionFirst;
        self.yt_Status = yt_SelfLocation;

    } else if (self.yt_Status == yt_SelfLocation) {
        
        
        selector = self._yt_actionSecond;
        self.yt_Status = yt_Compass;

    } else {
        
        selector = self._yt_actionThird;
        self.yt_Status = yt_Normal;

    }
    
    IMP imp = [self._yt_target methodForSelector:selector];
    void (*func)(id ,SEL) = (void *)imp;
    func(self._yt_target, selector);
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
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
