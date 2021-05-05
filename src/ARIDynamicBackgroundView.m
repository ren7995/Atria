//
// Created by ren7995 on 2021-05-03 09:07:52
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/ARIDynamicBackgroundView.h"
#import "src/ARITweak.h"

// https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromHexValue(rgbValue, y) [UIColor               \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
           green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
            blue:((float)(rgbValue & 0xFF)) / 255.0             \
           alpha:y]

@implementation ARIDynamicBackgroundView
{
    NSLayoutConstraint *_viewTopAnchor;
    NSLayoutConstraint *_viewBottomAnchor;
    NSLayoutConstraint *_viewLeadingAnchor;
    NSLayoutConstraint *_viewTrailingAnchor;
    UIVisualEffectView *_effectView;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]];
        [self addSubview:_effectView];
        _effectView.translatesAutoresizingMaskIntoConstraints = NO;
        _effectView.layer.masksToBounds = YES;
        [NSLayoutConstraint activateConstraints:@[
            [_effectView.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [_effectView.heightAnchor constraintEqualToAnchor:self.heightAnchor],
            [_effectView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_effectView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];
    }
    return self;
}

- (void)_updateView
{
    if(!self.superview) return;

    ARITweak *manager = [ARITweak sharedInstance];
    SBIconListView *superv = (SBIconListView *)self.superview;
    _effectView.layer.cornerRadius = [manager floatValueForKey:@"background_corner_radius" forListView:superv];

    self.alpha = [manager floatValueForKey:@"background_bg" forListView:superv];
    if([manager boolValueForKey:@"blurTintEnabled"])
    {
        NSString *textColorString = [[manager rawValueForKey:@"blurTintColor"] stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
        NSScanner *scanner = [NSScanner scannerWithString:textColorString];
        unsigned int hexCode;
        [scanner scanHexInt:&hexCode];
        // Get color code and set it
        _effectView.backgroundColor = UIColorFromHexValue(hexCode, [manager floatValueForKey:@"background_intensity"]);
    }

    [self _updateAnchors];
}

- (void)_updateAnchors
{
    ARITweak *manager = [ARITweak sharedInstance];
    // Allow per-page customization
    SBIconListView *superv = (SBIconListView *)self.superview;
    CGFloat topInset = [manager floatValueForKey:@"background_inset_top" forListView:superv];
    CGFloat bottomInset = [manager floatValueForKey:@"background_inset_bottom" forListView:superv];
    CGFloat leftInset = [manager floatValueForKey:@"background_inset_left" forListView:superv];
    CGFloat rightInset = [manager floatValueForKey:@"background_inset_right" forListView:superv];

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIEdgeInsets insets = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? self.portraitInsets : self.landscapeInsets;

    _viewTopAnchor.constant = insets.top - 10 + topInset;
    _viewBottomAnchor.constant = -insets.bottom + 10 + bottomInset;
    _viewLeadingAnchor.constant = insets.left - 10 + leftInset;
    _viewTrailingAnchor.constant = -insets.right + 10 + rightInset;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator
{
    // On rotate or frame update
    [self _updateAnchors];
}

- (void)didMoveToSuperview
{
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
