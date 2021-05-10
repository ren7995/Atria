//
// Created by ren7995 on 2021-04-25 21:49:03
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARIEditingControlsView : UIView <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *currentValueTextEntry;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *lowerLabel;
@property (nonatomic, strong) UILabel *upperLabel;
@property (nonatomic, strong) NSString *targetSetting;
@property (nonatomic, assign) float lowerLimit;
@property (nonatomic, assign) float upperLimit;
- (instancetype)initWithTargetSetting:(NSString *)setting lowerLimit:(float)lower upperLimit:(float)upper;
- (void)updateSliderValue;
- (void)updateCurrentText;
@end
