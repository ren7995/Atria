//
// Created by ren7995 on 2021-04-25 17:41:15
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ARIEditingControlsView.h"

@interface ARIEditingMainView : UIView
@property (nonatomic, readonly, strong) NSMutableArray *validsettingsForTarget;
@property (nonatomic, strong) UIVisualEffectView *matEffect;
@property (nonatomic, strong) ARIEditingControlsView *currentControls;
@property (nonatomic, strong) UILabel *currentSettingLabel;
@property (nonatomic, strong) UILabel *perPageIndicator;
@property (nonatomic, strong) NSString *currentSetting;
- (instancetype)initWithTarget:(NSString *)targetLoc;
- (void)setupForSettingKey:(NSString *)key;
- (void)updateForPan:(UIPanGestureRecognizer *)recognizer;
- (void)closeButtonTapped:(UITapGestureRecognizer *)tap;
- (void)resetSetting:(UITapGestureRecognizer *)tap;
- (void)toggleOptionsView:(UITapGestureRecognizer *)tap;
- (void)handePerPageTap:(UITapGestureRecognizer *)tap;
- (void)updateIsSingleListView;
@end
