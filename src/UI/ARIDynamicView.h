//
// Created by ren7995 on 2023-01-05 14:55:28
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARIDynamicView : UIView
- (instancetype)init;
- (void)updateView;
- (void)updateAnchors;
+ (UIColor *)colorFromHexString:(NSString *)str withAlpha:(CGFloat)alpha;
@end