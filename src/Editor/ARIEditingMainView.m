//
// Created by ren7995 on 2021-04-25 17:41:17
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARIEditingMainView.h"
#import "../Manager/ARIEditManager.h"
#import "../Manager/ARITweakManager.h"
#import "ARISettingCollectionViewHost.h"

#define CLAMP(x, min, max) x<min ? min : x> max ? max : x;

@implementation ARIEditingMainView {
    NSMutableArray *_validsettingsForTarget;
    NSLayoutConstraint *_topAnchor;
    NSLayoutConstraint *_heightAnchor;
    ARISettingCollectionViewHost *_collection;
    UIImageView *_reset;
    UIImageView *_perPage;
    UIImageView *_xButton;
    UILabel *_instructions;
    BOOL _showTooltips;
    CGFloat _panTouchdownOffset;
    CGFloat _editorSpace;
}

@synthesize validsettingsForTarget = _validsettingsForTarget;

- (instancetype)initWithTarget:(NSString *)targetLoc {
    self = [super init];
    if(self) {
        NSArray *allSettingsKeys = [[ARITweakManager sharedInstance] editorSettingsKeys];
        _validsettingsForTarget = [NSMutableArray new];
        for(NSString *setting in allSettingsKeys) {
            if([setting hasPrefix:targetLoc]) {
                [_validsettingsForTarget addObject:setting];
            }
        }
        _showTooltips = [[ARITweakManager sharedInstance] boolValueForKey:@"showTooltips"];

        // Subtle shadow to make the editor pop from the homescreen background
        self.layer.cornerRadius = 12;
        self.layer.cornerCurve = kCACornerCurveContinuous;
        self.layer.shadowOpacity = 0.5F;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 5;
        self.translatesAutoresizingMaskIntoConstraints = NO;

        CGFloat sw = UIScreen.mainScreen.bounds.size.width;
        _heightAnchor = [self.heightAnchor constraintEqualToConstant:[self getBaseHeight]],
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
        matEffect.layer.masksToBounds = YES;
        matEffect.layer.cornerRadius = 12;
        matEffect.layer.cornerCurve = kCACornerCurveContinuous;
        self.matEffect = matEffect;

        // Label
        UILabel *currentSettingLabel = [UILabel new];
        currentSettingLabel.text = @"Choose a setting";
        currentSettingLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        currentSettingLabel.textAlignment = NSTextAlignmentCenter;
        currentSettingLabel.numberOfLines = 1;
        currentSettingLabel.adjustsFontSizeToFitWidth = YES;
        currentSettingLabel.minimumScaleFactor = 0.5F;
        [self addSubview:currentSettingLabel];
        currentSettingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [currentSettingLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor
                                                            constant:-90],
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

        _instructions = [UILabel new];
        _instructions.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        [_instructions setLineBreakMode:NSLineBreakByWordWrapping];
        _instructions.textAlignment = NSTextAlignmentCenter;
        [self.currentSettingLabel addSubview:_instructions];
        _instructions.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [_instructions.widthAnchor constraintEqualToAnchor:self.widthAnchor
                                                      constant:-20],
            [_instructions.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                       constant:-5],
            [_instructions.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_instructions.heightAnchor constraintEqualToConstant:15],
        ]];
        if(!_showTooltips) {
            [_instructions setHidden:YES];
        }

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
        _xButton.tintColor = [UIColor labelColor];

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
        _reset.tintColor = [UIColor labelColor];

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
        _perPage.tintColor = [UIColor labelColor];
        _perPage.alpha = 0;
        // No per-page
        if([targetLoc isEqualToString:@"dock"] || [targetLoc isEqualToString:@"pagedot"]) _perPage.hidden = YES;

        // Add tap gestures and pan
        UITapGestureRecognizer *xTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonTapped:)];
        [_xButton addGestureRecognizer:xTapped];
        _xButton.userInteractionEnabled = YES;

        UITapGestureRecognizer *resetAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetSetting:)];
        [_reset addGestureRecognizer:resetAction];
        _reset.userInteractionEnabled = YES;

        UITapGestureRecognizer *openOptions = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOptionsView:)];
        [currentSettingLabel addGestureRecognizer:openOptions];
        currentSettingLabel.userInteractionEnabled = YES;

        UITapGestureRecognizer *togglePerPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handePerPageTap:)];
        [_perPage addGestureRecognizer:togglePerPage];
        _perPage.userInteractionEnabled = YES;

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateForPan:)];
        [self addGestureRecognizer:pan];

        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];

        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(keyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];

        [self updateIsSingleListView];
    }
    return self;
}

- (void)setupForSettingKey:(NSString *)key {
    // Queue update if adjusting dock columns/rows
    if([key isEqualToString:@"dock_columns"] || [key isEqualToString:@"dock_rows"]) {
        [[ARIEditManager sharedInstance] setDockLayoutQueued];
    }
    ARITweakManager *manager = [ARITweakManager sharedInstance];

    self.currentSetting = key;
    self.currentSettingLabel.text = [manager getSettingByKey:key].translation;

    if(!self.currentControls) {
        ARIEditingControlsView *controls = [[ARIEditingControlsView alloc] initWithTargetSetting:key];
        [self addSubview:controls];
        controls.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [controls.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [controls.heightAnchor constraintEqualToConstant:65],
            [controls.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [controls.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                  constant:_showTooltips ? -15 : 0],
        ]];
        [self layoutIfNeeded];
        self.currentControls = controls;
    } else {
        [self.currentControls setupForSettingKey:key];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if(!self.superview) return;
    [self _resetEditorSpace];
    // Set up initial layout anchor for y pos
    BOOL openFromTop = [[ARITweakManager sharedInstance] intValueForKey:@"editorOpenFrom"] == 1;
    _topAnchor = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor
                                                constant:openFromTop ? 50 : _editorSpace - _heightAnchor.constant];
    _topAnchor.active = YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self setEditorSpace:((NSValue *)notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"]).CGRectValue.origin.y - 25];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    [self _resetEditorSpace];
}

- (void)_resetEditorSpace {
    [self setEditorSpace:fmax(UIScreen.mainScreen.bounds.size.height * 0.85F, UIScreen.mainScreen.bounds.size.height - 140.0F)];
}

- (void)updateForPan:(UIPanGestureRecognizer *)recognizer {
    // Move y pos with drag
    if(!self.superview) return;
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        _panTouchdownOffset = [recognizer locationInView:self.superview].y - self.frame.origin.y;
    } else if(recognizer.state == UIGestureRecognizerStateChanged || recognizer.state != UIGestureRecognizerStateEnded) {
        [self _animateToPosition:[recognizer locationInView:self.superview].y - _panTouchdownOffset];
    }
}

- (void)setEditorSpace:(CGFloat)space {
    _editorSpace = space;
    if(_topAnchor.constant + _heightAnchor.constant > _editorSpace) [self _animateToPosition:_editorSpace - _heightAnchor.constant];
}

- (void)_animateToPosition:(CGFloat)position {
    [UIView animateWithDuration:0.1f
                     animations:^{
                         [self.superview layoutIfNeeded];
                         _topAnchor.constant =
                             CLAMP(position, 50, _editorSpace - _heightAnchor.constant);
                         [self.superview layoutIfNeeded];
                     }];
}

- (void)closeButtonTapped:(UITapGestureRecognizer *)tap {
    [[ARITweakManager sharedInstance] feedbackForButton];
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

- (void)resetSetting:(UITapGestureRecognizer *)tap {
    // Just set default value for the key
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    [manager feedbackForButton];
    [manager resetValueForKey:self.currentSetting forListView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]];
    [self.currentControls updateSliderValue];

    [manager updateLayoutForEditing:YES];
}

- (void)handePerPageTap:(UITapGestureRecognizer *)tap {
    // Just set default value for the key
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    [manager feedbackForButton];
    [[ARIEditManager sharedInstance] toggleSingleListMode];

    [self updateIsSingleListView];
}

- (void)updateIsSingleListView {
    // Let the user know
    if([ARIEditManager sharedInstance].singleListMode) {
        // Single list mode
        ARITweakManager *manager = [ARITweakManager sharedInstance];
        self.perPageIndicator.text = [NSString stringWithFormat:@"Page %lu Only", [manager indexOfListView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]] + 1];

        _perPage.image = [UIImage systemImageNamed:@"doc.fill"];
    } else {
        // Global
        self.perPageIndicator.text = @"";

        _perPage.image = [UIImage systemImageNamed:@"doc"];
    }
    [self.currentControls updateSliderValue];
}

- (void)toggleOptionsView:(UITapGestureRecognizer *)tap {
    // Present collection view with settings options
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    [manager feedbackForButton];

    if(_heightAnchor.constant == [self getBaseHeight]) {
        // Activate
        [self.currentSettingLabel setText:@"Choose a setting"];
        [_instructions setText:@"Click the page icon to edit this page only"];

        if(self.currentControls) {
            [self.currentControls endTextEntry];
        }

        _collection = [[ARISettingCollectionViewHost alloc] init];
        _collection.translatesAutoresizingMaskIntoConstraints = NO;
        _collection.alpha = 0;
        [self addSubview:_collection];
        [NSLayoutConstraint activateConstraints:@[
            [_collection.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [_collection.topAnchor constraintEqualToAnchor:self.currentSettingLabel.bottomAnchor
                                                  constant:15],
            [_collection.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                     constant:_showTooltips ? -20 : -5],
            [_collection.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        ]];
        [self layoutIfNeeded];
        [_collection setupGradient];

        [UIView animateWithDuration:0.3f
                         animations:^{
                             _collection.alpha = 1;
                             _instructions.alpha = 1;

                             [self.superview layoutIfNeeded];
                             // Set height anchor
                             _heightAnchor.constant = [self getBaseHeight] + 30;
                             [self _resetEditorSpace];
                             [self.superview layoutIfNeeded];

                             // Fade
                             self.currentSettingLabel.alpha = 0.4;
                             self.currentControls.alpha = 0;
                             _reset.alpha = 0;
                             _perPage.alpha = 1;
                         }];
    } else {
        // End
        [_instructions setText:@"Click the label at the top to go back"];

        [UIView animateWithDuration:0.3f
            animations:^{
                _collection.alpha = 0;
                _instructions.alpha = 0.5f;

                [self.superview layoutIfNeeded];
                // Set height anchor
                _heightAnchor.constant = [self getBaseHeight];
                [self _resetEditorSpace];
                [self.superview layoutIfNeeded];

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

- (float)getBaseHeight {
    return _showTooltips ? 110.0f : 100.0f;
}

@end
