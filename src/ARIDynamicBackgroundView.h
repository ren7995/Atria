//
// Created by ren7995 on 2021-05-03 09:05:52
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARIDynamicBackgroundView : UIView
@property (nonatomic, assign) UIEdgeInsets portraitInsets;
@property (nonatomic, assign) UIEdgeInsets landscapeInsets;
- (instancetype)init;
- (void)_updateView;
- (void)_updateAnchors;
@end
