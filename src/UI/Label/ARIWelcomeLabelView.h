//
// Created by ren7995 on 2023-05-30 18:39:01
// Copyright (c) 2023 ren7995. All rights reserved.
//

#include "ARILabelView.h"

@interface ARIWelcomeLabelView : ARILabelView
- (instancetype)init;
@end

@interface WALockscreenWidgetViewController : UIView
- (void)updateWeather;
//- (void)setDelegate:(id)arg1;
- (NSString *)_temperature;
- (UIImage *)_conditionsImage;
- (NSString *)_locationName;
@end