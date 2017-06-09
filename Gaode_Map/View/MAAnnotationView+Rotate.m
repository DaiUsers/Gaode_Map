//
//  MAAnnotationView+Rotate.m
//  AliPay_Test
//
//  Created by wheng on 17/6/5.
//  Copyright © 2017年 admin. All rights reserved.
//

#import "MAAnnotationView+Rotate.h"

@implementation MAAnnotationView (Rotate)

- (void)rotateWithHeading:(CLHeading *)heading {
    CGFloat headings = M_PI * heading.magneticHeading / 180;
    CABasicAnimation *rotateAnimation = [[CABasicAnimation alloc] init];
    rotateAnimation.keyPath = @"transform";
    rotateAnimation.fromValue = [NSValue valueWithCATransform3D:self.layer.transform];
    CATransform3D toValue = CATransform3DMakeRotation(headings, 0, 0, 1);
    rotateAnimation.toValue = [NSValue valueWithCATransform3D:toValue];
    rotateAnimation.duration = 0.35;
    [rotateAnimation setRemovedOnCompletion:YES];
    [self.layer setTransform:toValue];
    
    [self.layer addAnimation:rotateAnimation forKey:nil];
}

@end
