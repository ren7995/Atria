//
// Created by ren7995 on 2021-04-25 21:49:35
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARIEditingControlsView.h"
#import "../Manager/ARIEditManager.h"
#import "../Manager/ARITweakManager.h"

@implementation ARIEditingControlsView

- (instancetype)initWithTargetSetting:(NSString *)key {
    self = [super init];
    if(self) {
        ARIOption *option = [[ARITweakManager sharedInstance] getSettingByKey:key];
        float lower = option.lowerLimit;
        float upper = option.upperLimit;

        self.targetSetting = key;
        self.lowerLimit = lower;
        self.upperLimit = upper;

        // Create slider with labels for low/high limit
        UISlider *slider = [[UISlider alloc] init];
        [slider addTarget:self action:@selector(sliderDidChange:event:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderDidBegin:) forControlEvents:UIControlEventTouchDown];
        [slider setBackgroundColor:[UIColor clearColor]];
        slider.minimumValue = lower;
        slider.maximumValue = upper;
        slider.continuous = YES;
        [self addSubview:slider];
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [slider.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                                constant:-15],
            [slider.widthAnchor constraintEqualToAnchor:self.widthAnchor
                                               constant:-140],
            [slider.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                constant:-15],
            [slider.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        ]];
        self.slider = slider;

        UILabel *lowerLabel = [UILabel new];
        lowerLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        lowerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lowerLabel];
        lowerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [lowerLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                                    constant:-15],
            [lowerLabel.widthAnchor constraintEqualToConstant:50],
            [lowerLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                    constant:-15],
            [lowerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                     constant:15],
        ]];
        self.lowerLabel = lowerLabel;

        UILabel *upperLabel = [UILabel new];
        upperLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        upperLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:upperLabel];
        upperLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [upperLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                                    constant:-15],
            [upperLabel.widthAnchor constraintEqualToConstant:50],
            [upperLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                    constant:-15],
            [upperLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor
                                                      constant:-15],
        ]];
        self.upperLabel = upperLabel;

        // Create toolbar and text field
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.translucent = YES;
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(endTextEntry)];
        UIBarButtonItem *spacingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldShouldReturn:)];
        [toolbar setItems:@[ cancelItem, spacingItem, doneItem ] animated:NO];
        [toolbar sizeToFit];

        UITextField *textEntry = [UITextField new];
        textEntry.backgroundColor = [UIColor clearColor];
        textEntry.keyboardType = UIKeyboardTypeDecimalPad;
        textEntry.delegate = self;
        textEntry.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        textEntry.textAlignment = NSTextAlignmentCenter;
        textEntry.inputAccessoryView = toolbar;
        [self addSubview:textEntry];
        textEntry.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [textEntry.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                                   constant:-30],
            [textEntry.widthAnchor constraintEqualToConstant:50],
            [textEntry.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [textEntry.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        ]];
        self.currentValueTextEntry = textEntry;

        [self updateSliderValue];

        // Detect rotation changes and update text label
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(updateCurrentText)
                   name:UIDeviceOrientationDidChangeNotification
                 object:nil];
    }
    return self;
}

- (NSString *)_formatValue:(float)val {
    if(fmod(val, 1.0F) == 0.0F || [self.targetSetting containsString:@"rows"] || [self.targetSetting containsString:@"columns"])
        return [NSString stringWithFormat:@"%d", (int)val];
    return [NSString stringWithFormat:@"%.02f", val];
}

- (NSString *)_adjustedKeyForCurrentOrientation {
    BOOL portrait = UIInterfaceOrientationIsPortrait([ARITweakManager currentDeviceOrientation]);
    if(portrait) return self.targetSetting;
    if([self.targetSetting hasSuffix:@"rows"])
        return [self.targetSetting stringByReplacingOccurrencesOfString:@"rows" withString:@"columns"];
    if([self.targetSetting hasSuffix:@"columns"])
        return [self.targetSetting stringByReplacingOccurrencesOfString:@"columns" withString:@"rows"];
    return self.targetSetting;
}

- (void)setupForSettingKey:(NSString *)key {
    ARIOption *option = [[ARITweakManager sharedInstance] getSettingByKey:key];
    float lower = option.lowerLimit;
    float upper = option.upperLimit;

    self.targetSetting = key;
    self.lowerLimit = lower;
    self.upperLimit = upper;
    self.slider.minimumValue = lower;
    self.slider.maximumValue = upper;

    // Update to display approproate info for the new setting
    [self updateSliderValue];
}

- (void)updateCurrentText {
    float val = [[ARITweakManager sharedInstance]
        floatValueForKey:[self _adjustedKeyForCurrentOrientation]
             forListView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]];

    self.currentValueTextEntry.text = [self _formatValue:val];
}

- (void)updateSliderValue {
    // -currentIconListViewIfSinglePage will return nil if not in single page mode, thus applying our config globally
    float val = [[ARITweakManager sharedInstance]
        floatValueForKey:[self _adjustedKeyForCurrentOrientation]
             forListView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]];
    self.slider.value = val;
    self.lowerLabel.text = [self _formatValue:self.lowerLimit];
    self.upperLabel.text = [self _formatValue:self.upperLimit];

    [self updateCurrentText];
}

- (void)sliderDidChange:(UISlider *)slider event:(UIEvent *)event {
    [self updateCurrentText];
    float value = slider.value;

    ARITweakManager *manager = [ARITweakManager sharedInstance];
    // -currentIconListViewIfSinglePage will return nil if not in single page mode, thus reading our global config
    NSString *key = [self _adjustedKeyForCurrentOrientation];
    SBIconListView *list = [[ARIEditManager sharedInstance] currentIconListViewIfSinglePage];
    if([manager floatValueForKey:key forListView:list] != value) {
        [manager setValue:@(value) forKey:key forListView:list];
        [manager updateLayoutForEditing:YES];
    }
}

- (void)sliderDidBegin:(UISlider *)slider {
    [[ARITweakManager sharedInstance] feedbackForButton];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [ARITweakManager dismissFloatingDockIfPossible];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Get numberical value
    if(self.currentValueTextEntry.text) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *num = [nf numberFromString:self.currentValueTextEntry.text];

        if(num) {
            // I INTENTIONALLY allow numbers outside of the slider range
            // If you want 1000000 icons in a row, be my guest.
            ARITweakManager *manager = [ARITweakManager sharedInstance];
            [manager setValue:num
                       forKey:[self _adjustedKeyForCurrentOrientation]
                  forListView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]];
            [manager updateLayoutForEditing:YES];

            [self updateSliderValue];
        }
    }

    // We can call this method now that we updated our value
    [self endTextEntry];

    return YES;
}

- (void)endTextEntry {
    [self.currentValueTextEntry resignFirstResponder];
    // Restore/update text
    [self updateCurrentText];
    [ARITweakManager presentFloatingDockIfPossible];
}

- (void)removeFromSuperview {
    [self endTextEntry];
    [super removeFromSuperview];
}

@end
