//
// Created by ren7995 on 2021-04-25 21:49:35
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/Editor/ARIEditingControlsView.h"
#import "src/Manager/ARIEditManager.h"
#import "src/Manager/ARITweak.h"

@implementation ARIEditingControlsView

- (instancetype)initWithTargetSetting:(NSString *)setting lowerLimit:(float)lower upperLimit:(float)upper
{
    self = [super init];
    if(self)
    {
        self.lowerLimit = lower;
        self.upperLimit = upper;
        self.targetSetting = setting;

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

        UITextField *currentValueTextEntry = [UITextField new];
        currentValueTextEntry.backgroundColor = [UIColor clearColor];
        [currentValueTextEntry setReturnKeyType:UIReturnKeyDone];
        currentValueTextEntry.delegate = self;
        currentValueTextEntry.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        currentValueTextEntry.textAlignment = NSTextAlignmentCenter;
        [self addSubview:currentValueTextEntry];
        currentValueTextEntry.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [currentValueTextEntry.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                                               constant:-30],
            [currentValueTextEntry.widthAnchor constraintEqualToConstant:50],
            [currentValueTextEntry.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [currentValueTextEntry.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        ]];
        self.currentValueTextEntry = currentValueTextEntry;

        [self updateSliderValue];
    }
    return self;
}

- (void)updateCurrentText
{
    float val = self.slider.value;

    if([self.targetSetting containsString:@"rows"] || [self.targetSetting containsString:@"columns"])
    {
        self.currentValueTextEntry.text = [NSString stringWithFormat:@"%d", (int)val];
    }
    else
    {
        self.currentValueTextEntry.text = [NSString stringWithFormat:@"%.02f", val];
    }
}

- (void)updateSliderValue
{
    // -currentIconListViewIfSinglePage will return nil if not in single page mode, thus applying our config globally
    float val = [[ARITweak sharedInstance] floatValueForKey:self.targetSetting forListView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]];
    self.slider.value = val;
    self.lowerLabel.text = [NSString stringWithFormat:@"%.02f", self.lowerLimit];
    self.upperLabel.text = [NSString stringWithFormat:@"%.02f", self.upperLimit];

    [self updateCurrentText];
}

- (void)sliderDidChange:(UISlider *)slider event:(UIEvent *)event
{
    [self updateCurrentText];
    float value = slider.value;

    ARITweak *manager = [ARITweak sharedInstance];
    // -currentIconListViewIfSinglePage will return nil if not in single page mode, thus reading our global config
    SBIconListView *list = [[ARIEditManager sharedInstance] currentIconListViewIfSinglePage];
    if([manager floatValueForKey:self.targetSetting forListView:list] != value)
    {
        [manager setValue:@(value) forKey:self.targetSetting listView:list];
        [manager updateLayoutForEditing:YES];
    }
}

- (void)sliderDidBegin:(UISlider *)slider
{
    [[ARITweak sharedInstance] feedbackForButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.currentValueTextEntry resignFirstResponder];

    // Get numberical value
    if(self.currentValueTextEntry.text)
    {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *num = [nf numberFromString:self.currentValueTextEntry.text];

        if(num)
        {
            // I INTENTIONALLY allow numbers outside of the slider range
            // If you want 1000000 icons in a row, be my guest.
            // Set val
            ARITweak *manager = [ARITweak sharedInstance];
            [manager setValue:num forKey:self.targetSetting listView:[[ARIEditManager sharedInstance] currentIconListViewIfSinglePage]];
            [manager updateLayoutForEditing:YES];

            [self updateSliderValue];
        }
    }

    // Restore text
    [self updateCurrentText];

    return YES;
}

- (void)removeFromSuperview
{
    // Dismiss keyboard
    [self.currentValueTextEntry resignFirstResponder];
    [super removeFromSuperview];
}

@end
