//
// Created by ren7995 on 2021-04-27 18:20:41
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARIWelcomeDynamicLabel : UILabel
@property (nonatomic, assign) CGFloat startingLabelYPos;
@property (nonatomic, assign) CGFloat startingLabelXPos;
@property (nonatomic, assign) CGFloat startingLabelYPosLandscape;
@property (nonatomic, assign) CGFloat startingLabelXPosLandscape;
- (instancetype)init;
- (void)_updateLabel;
- (void)_updateAnchors;
+ (instancetype)shared;
@end
