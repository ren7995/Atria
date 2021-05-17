//
// Created by ren7995 on 2021-04-25 17:41:17
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/Editor/ARIEditingView.h"
#import "src/Editor/ARISettingsCollectionViewHost.h"
#import "src/Manager/ARIEditManager.h"
#import "src/Manager/ARITweak.h"

@implementation ARIEditingView
{
    NSMutableArray *_validsettingsForTarget;
    NSLayoutConstraint *_topAnchor;
    NSLayoutConstraint *_heightAnchor;
    ARISettingsCollectionViewHost *_collection;
    UIImageView *_reset;
    UIImageView *_perPage;
    UIImageView *_xButton;
}

@synthesize validsettingsForTarget = _validsettingsForTarget;

- (instancetype)initWithTarget:(NSString *)targetLoc
{
    self = [super init];
    if(self)
    {
        NSArray *allSettingsKeys = [[ARITweak sharedInstance] allSettingsKeys];
        _validsettingsForTarget = [NSMutableArray new];
        for(NSString *setting in allSettingsKeys)
        {
            if([setting hasPrefix:targetLoc])
            {
                [_validsettingsForTarget addObject:setting];
            }
        }

        CGFloat sw = UIScreen.mainScreen.bounds.size.width;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 12;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.translatesAutoresizingMaskIntoConstraints = NO;

        _heightAnchor = [self.heightAnchor constraintEqualToConstant:100],
        [NSLayoutConstraint activateConstraints:@[
            [self.widthAnchor constraintEqualToConstant:sw < 500 ? sw - 25 : 475],
            _heightAnchor,
        ]];

        // Background blur
        UIVisualEffectView *matEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial]];
        [self addSubview:matEffect];
        matEffect.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [matEffect.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [matEffect.heightAnchor constraintEqualToAnchor:self.heightAnchor],
            [matEffect.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [matEffect.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];
        self.matEffect = matEffect;

        // Label
        UILabel *currentSettingLabel = [UILabel new];
        currentSettingLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        currentSettingLabel.textAlignment = NSTextAlignmentCenter;
        currentSettingLabel.adjustsFontSizeToFitWidth = YES;
        currentSettingLabel.minimumFontSize = 10;
        [self addSubview:currentSettingLabel];
        currentSettingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            /*[currentSettingLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor
                                                          multiplier:0.7],*/
            [currentSettingLabel.heightAnchor constraintEqualToConstant:30],
            [currentSettingLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [currentSettingLabel.topAnchor constraintEqualToAnchor:self.topAnchor
                                                          constant:5],
        ]];
        self.currentSettingLabel = currentSettingLabel;

        // Label
        UILabel *ppi = [UILabel new];
        ppi.font = [UIFont systemFontOfSize:9 weight:UIFontWeightRegular];
        ppi.textAlignment = NSTextAlignmentCenter;
        [self.currentSettingLabel addSubview:ppi];
        ppi.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [ppi.widthAnchor constraintEqualToAnchor:currentSettingLabel.widthAnchor],
            [ppi.heightAnchor constraintEqualToConstant:10],
            [ppi.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [ppi.topAnchor constraintEqualToAnchor:currentSettingLabel.bottomAnchor],
        ]];
        self.perPageIndicator = ppi;

        // Close button
        _xButton = [UIImageView new];
        _xButton.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_xButton];
        _xButton.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_xButton.widthAnchor constraintEqualToConstant:22.5],
            [_xButton.heightAnchor constraintEqualToConstant:22.5],
            [_xButton.topAnchor constraintEqualToAnchor:self.topAnchor
                                               constant:7.5],
            [_xButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor
                                                    constant:-7.5],
        ]];
        _xButton.image = [UIImage systemImageNamed:@"xmark"];
        _xButton.tintColor = currentSettingLabel.textColor; // Adaptive color

        // Reset button
        _reset = [UIImageView new];
        [self addSubview:_reset];
        _reset.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_reset.widthAnchor constraintEqualToConstant:22.5],
            [_reset.heightAnchor constraintEqualToConstant:22.5],
            [_reset.topAnchor constraintEqualToAnchor:self.topAnchor
                                             constant:7.5],
            [_reset.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                 constant:7.5],
        ]];
        _reset.image = [UIImage systemImageNamed:@"gobackward"];
        _reset.tintColor = currentSettingLabel.textColor; // Adaptive color

        // Toggle per-page
        _perPage = [UIImageView new];
        [self addSubview:_perPage];
        _perPage.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_perPage.widthAnchor constraintEqualToConstant:22.5],
            [_perPage.heightAnchor constraintEqualToConstant:22.5],
            [_perPage.topAnchor constraintEqualToAnchor:self.topAnchor
                                               constant:7.5],
            [_perPage.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                   constant:7.5],
        ]];
        _perPage.tintColor = currentSettingLabel.textColor; // Adaptive color
        _perPage.alpha = 0;
        // No per-page dock
        if([targetLoc isEqualToString:@"dock"] || [targetLoc isEqualToString:@"welcome"]) _perPage.hidden = YES;

        // Add tap gestures and pan
        UITapGestureRecognizer *close = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView:)];
        [_xButton addGestureRecognizer:close];
        _xButton.userInteractionEnabled = YES;

        UITapGestureRecognizer *resetAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetSetting:)];
        [_reset addGestureRecognizer:resetAction];
        _reset.userInteractionEnabled = YES;

        UITapGestureRecognizer *openOptions = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleConfig:)];
        [currentSettingLabel addGestureRecognizer:openOptions];
        currentSettingLabel.userInteractionEnabled = YES;

        UITapGestureRecognizer *togglePerPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handePerPageTap:)];
        [_perPage addGestureRecognizer:togglePerPage];
        _perPage.userInteractionEnabled = YES;

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateForPan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)setupForSettingKey:(NSString *)key
{
    // Queue update if adjusting dock columns/rows
    if([key isEqualToString:@"dock_columns"] || [key isEqualToString:@"dock_rows"])
    {
        [[ARIEditManager sharedInstance] setDockLayoutQueued];
    }
    ARITweak *manager = [ARITweak sharedInstance];

    self.currentSetting = key;
    self.currentSettingLabel.text = [manager stringRepresentationForSettingsKey:key];
    [self.currentSettingLabel sizeToFit];
    NSArray *lowerUpper = [manager rangeForSettingsKey:key];
    float lower = [lowerUpper[0] floatValue];
    float upper = [lowerUpper[1] floatValue];

    [self.currentControls removeFromSuperview];
    self.currentControls = nil;
    ARIEditingControlsView *controls = [[ARIEditingControlsView alloc] initWithTargetSetting:key lowerLimit:lower upperLimit:upper];
    [self addSubview:controls];
    controls.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [controls.widthAnchor constraintEqualToAnchor:self.widthAnchor],
        [controls.heightAnchor constraintEqualToConstant:65],
        [controls.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [controls.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
    [self layoutIfNeeded];
    self.currentControls = controls;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    // Set up initial layout anchor for y pos
    [self resetAnchor];
}

- (void)resetAnchor
{
    if(!self.superview) return;
    if(!_topAnchor)
        _topAnchor = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor
                                                    constant:50];
    [self.superview layoutIfNeeded];
    _topAnchor.constant = 50;
    [self.superview layoutIfNeeded];
    _topAnchor.active = YES;
}

- (void)updateForPan:(UIPanGestureRecognizer *)recognizer
{
    // Move y pos with drag
    if(!self.superview) return;
    CGPoint pos = [recognizer locationInView:self.superview];
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.superview layoutIfNeeded];
                         _topAnchor.constant =
                             pos.y >= 50 && pos.y <= UIScreen.mainScreen.bounds.size.height - self.frame.size.height - 100
                                 ? pos.y
                                 : _topAnchor.constant;
                         [self.superview layoutIfNeeded];
                     }];
}

- (void)closeView:(UITapGestureRecognizer *)tap
{
    [[ARITweak sharedInstance] feedbackForButton];
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

- (void)resetSetting:(UITapGestureRecognizer *)tap
{
    // Just set default value for the key
    ARITweak *manager = [ARITweak sharedInstance];
    [manager feedbackForButton];
    [manager resetValueForKey:self.currentSetting listView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]];
    [self.currentControls updateSliderValue];
    [manager updateLayoutForEditing:YES];
}

- (void)handePerPageTap:(UITapGestureRecognizer *)tap
{
    // Just set default value for the key
    ARITweak *manager = [ARITweak sharedInstance];
    [manager feedbackForButton];
    [[ARIEditManager sharedInstance] toggleSingleListMode];

    [self updateIsSingleListView];
}

- (void)updateIsSingleListView
{
    // Let the user know
    if([ARIEditManager sharedInstance].singleListMode)
    {
        // Single list mode
        ARITweak *manager = [ARITweak sharedInstance];
        self.perPageIndicator.text = [NSString stringWithFormat:@"Page Only (%lu)", [manager indexOfListView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]]];

        _perPage.image = [UIImage systemImageNamed:@"doc.fill"];
    }
    else
    {
        // Global
        self.perPageIndicator.text = @"";

        _perPage.image = [UIImage systemImageNamed:@"doc"];
    }
    [self.currentControls updateSliderValue];
}

- (void)toggleConfig:(UITapGestureRecognizer *)tap
{
    // Present table view with settings options
    ARITweak *manager = [ARITweak sharedInstance];
    [manager feedbackForButton];

    if(_heightAnchor.constant == 100)
    {
        // Activate

        _collection = [[ARISettingsCollectionViewHost alloc] init];
        _collection.translatesAutoresizingMaskIntoConstraints = NO;
        _collection.alpha = 0;
        [self addSubview:_collection];
        [NSLayoutConstraint activateConstraints:@[
            [_collection.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [_collection.topAnchor constraintEqualToAnchor:self.currentSettingLabel.bottomAnchor
                                                  constant:15],
            [_collection.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                     constant:-5],
            [_collection.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        ]];
        [self layoutIfNeeded];
        [_collection setupGradient];

        [UIView animateWithDuration:0.4f
                         animations:^{
                             // Anchor
                             [self.superview layoutIfNeeded];
                             _heightAnchor.constant = 130;
                             [self.superview layoutIfNeeded];

                             _collection.alpha = 1;

                             // Fade
                             self.currentSettingLabel.alpha = 0.4;
                             self.currentControls.alpha = 0;
                             _reset.alpha = 0;
                             _perPage.alpha = 1;
                         }];
    }
    else
    {
        // End
        [UIView animateWithDuration:0.4f
            animations:^{
                // Anchor
                [self.superview layoutIfNeeded];
                _heightAnchor.constant = 100;
                [self.superview layoutIfNeeded];

                _collection.alpha = 0;

                // Unfade
                self.currentSettingLabel.alpha = 1;
                self.currentControls.alpha = 1;
                _reset.alpha = 1;
                _perPage.alpha = 0;
            }
            completion:^(BOOL finished) {
                [_collection removeFromSuperview];
                _collection = nil;
            }];
    }
}

@end
