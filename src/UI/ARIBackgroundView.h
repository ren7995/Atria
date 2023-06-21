//
// Created by ren7995 on 2021-05-03 09:05:52
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARIDynamicView.h"

@interface ARIBackgroundView : ARIDynamicView
@property (nonatomic, assign) UIEdgeInsets portraitLayoutGuide;
@property (nonatomic, assign) UIEdgeInsets landscapeLayoutGuide;
- (instancetype)init;
@end
