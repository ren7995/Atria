//
// Created by ren7995 on 2021-04-28 08:04:19
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const ARIDidSplashPreferenceKey = @"_atriaDidSplashGuide_v2";

@interface ARISplashViewController : UIViewController
- (instancetype)initWithSubtitle:(NSString *)subtitle;
- (void)addEntry:(NSString *)text image:(UIImage *)image;
@end
