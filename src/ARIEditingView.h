//
// Created by ren7995 on 2021-04-25 17:41:15
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "src/ARIEditingControls.h"

@interface ARIEditingView : UIView
@property (nonatomic, strong) UIVisualEffectView *matEffect;
@property (nonatomic, strong) ARIEditingControls *currentControls;
@property (nonatomic, readonly, strong) NSMutableArray *validsettingsForTarget;
@property (nonatomic, strong) UILabel *currentSettingLabel;
@property (nonatomic, strong) UILabel *perPageIndicator;
@property (nonatomic, strong) NSString *currentSetting;
- (void)resetAnchor;
- (void)setupForSettingKey:(NSString *)key;
- (void)updateForPan:(UIPanGestureRecognizer *)recognizer;
- (void)closeView:(UITapGestureRecognizer *)tap;
- (void)resetSetting:(UITapGestureRecognizer *)tap;
- (void)toggleConfig:(UITapGestureRecognizer *)tap;
- (void)handePerPageTap:(UITapGestureRecognizer *)tap;
- (void)updateIsSingleListView;
- (instancetype)initWithTarget:(NSString *)targetLoc;
@end
