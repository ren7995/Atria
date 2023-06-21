//
// Created by ren7995 on 2021-05-02 11:19:22
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARIFadeEffectView.h"

@implementation ARIFadeEffectView

- (void)setupFade:(CGRect)frame {
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);

    gradient.frame = frame;
    gradient.colors = @[ (id)[UIColor clearColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor ];
    gradient.locations = @[ @(0.0), @(0.05), @(0.9), @(1.0) ];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end
