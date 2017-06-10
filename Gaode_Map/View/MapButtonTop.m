//
//  MapButtonTop.m
//  AliPay_Test
//
//  Created by wheng on 17/6/3.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MapButtonTop.h"

@implementation MapButtonTop

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:[UIImage imageNamed:@"mapT"] forState:UIControlStateNormal];
        [self setAdjustsImageWhenHighlighted:NO];
    }
    return self;
}



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
