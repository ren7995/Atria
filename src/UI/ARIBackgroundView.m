//
// Created by ren7995 on 2021-05-03 09:07:52
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARIBackgroundView.h"
#import "../Manager/ARITweakManager.h"

#include <objc/runtime.h>

@implementation ARIBackgroundView {
    NSLayoutConstraint *_viewTopAnchor;
    NSLayoutConstraint *_viewBottomAnchor;
    NSLayoutConstraint *_viewLeadingAnchor;
    NSLayoutConstraint *_viewTrailingAnchor;
    UIVisualEffectView *_effectView;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.masksToBounds = YES;

        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]];
        [self addSubview:_effectView];
        _effectView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_effectView.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [_effectView.heightAnchor constraintEqualToAnchor:self.heightAnchor],
            [_effectView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_effectView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];
    }
    return self;
}

- (void)updateView {
    if(!self.superview) return;

    ARITweakManager *manager = [ARITweakManager sharedInstance];
    SBIconListView *superv = (SBIconListView *)self.superview;
    self.layer.cornerRadius = [manager floatValueForKey:@"blur_corner_radius" forListView:superv];

    _effectView.alpha = [manager floatValueForKey:@"blur_alpha" forListView:superv];
    if([manager boolValueForKey:@"blurTintEnabled"]) {
        self.backgroundColor = [[self class] colorFromHexString:[manager rawValueForKey:@"blurTintColor"]
                                                      withAlpha:[manager floatValueForKey:@"blur_intensity"]];
    } else {
        self.backgroundColor = nil;
    }

    [self updateAnchors];
}

- (void)updateAnchors {
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    // Allow per-page customization
    SBIconListView *superv = (SBIconListView *)self.superview;
    CGFloat topInset = [manager floatValueForKey:@"blur_inset_top" forListView:superv];
    CGFloat bottomInset = [manager floatValueForKey:@"blur_inset_bottom" forListView:superv];
    CGFloat leftInset = [manager floatValueForKey:@"blur_inset_left" forListView:superv];
    CGFloat rightInset = [manager floatValueForKey:@"blur_inset_right" forListView:superv];

    UIEdgeInsets insets = UIInterfaceOrientationIsPortrait([ARITweakManager currentDeviceOrientation])
                              ? self.portraitLayoutGuide
                              : self.landscapeLayoutGuide;

    _viewTopAnchor.constant = insets.top - 10 + topInset;
    _viewBottomAnchor.constant = -insets.bottom + 10 + bottomInset;
    _viewLeadingAnchor.constant = insets.left - 10 + leftInset;
    _viewTrailingAnchor.constant = -insets.right + 10 + rightInset;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if(!self.superview) return;

    // Setup initial anchors
    _viewTopAnchor = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor];
    _viewLeadingAnchor = [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor];
    _viewTrailingAnchor = [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor];
    _viewBottomAnchor = [self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor];

    [NSLayoutConstraint activateConstraints:@[
        _viewTopAnchor,
        _viewLeadingAnchor,
        _viewBottomAnchor,
        _viewTrailingAnchor,
    ]];
}

@end
