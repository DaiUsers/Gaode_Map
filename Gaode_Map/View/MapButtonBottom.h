//
//  MapButtonBottom.h
//  AliPay_Test
//
//  Created by wheng on 17/6/3.
//  Copyright © 2017年 admin. All rights reserved.
//  


#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ButtonStatus) {
    yt_Normal = 0,
    yt_SelfLocation,
    yt_Compass,
};

@interface MapButtonBottom : UIButton

@property (nonatomic, assign)ButtonStatus yt_Status;
@property (nonatomic, strong)UIImage *firstImage;

- (void)addTarget:(id)target actionFirst:(SEL)action second:(SEL)action third:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
