//
// Created by ren7995 on 2023-05-30 18:39:12
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import "ARIWelcomeLabelView.h"
#import "../../Manager/ARITweakManager.h"

#import <objc/runtime.h>

@implementation ARIWelcomeLabelView {
    NSCalendar *_calendar;
    NSTimer *_updateTimer;
    UIImageView *_imageView;
    WALockscreenWidgetViewController *_weatherUpdater;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        // Get calendar components of current date
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [_calendar components:NSCalendarUnitHour fromDate:[NSDate date]];
        // Set to the next hour on the dot
        components.minute = 0;
        components.hour = components.hour + 1;

        // Add timer
        _updateTimer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(updateText:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSDefaultRunLoopMode];

        // System time was set listener
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateText:) name:NSSystemClockDidChangeNotification object:nil];

        // Notification for showing/hiding label
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabelVisibility:) name:ARIUpdateLabelVisibilityNotification object:nil];

        _weatherUpdater = [[objc_getClass("WALockscreenWidgetViewController") alloc] init];
        [_weatherUpdater updateWeather];
    }
    return self;
}

- (void)setupTextField:(UITextField *)textField {
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_imageView.widthAnchor constraintEqualToConstant:30],
        [_imageView.heightAnchor constraintEqualToConstant:30],
    ]];

    textField.leftView = _imageView;
}

- (NSString *)loadRawText {
    return [[ARITweakManager sharedInstance] rawValueForKey:@"labelText"];
}

- (NSString *)processRawText:(NSString *)rawText isScheduledUpdate:(BOOL)scheduled {
    NSString *greeting = @"Welcome";
    NSDateComponents *components = [_calendar components:NSCalendarUnitHour fromDate:[NSDate date]];
    if(components.hour >= 4 && components.hour < 12) {
        greeting = @"Good morning";
    } else if(components.hour >= 12 && components.hour < 18) {
        greeting = @"Good afternoon";
    } else if(components.hour >= 18 || components.hour < 4) {
        greeting = @"Good evening";
    }

    rawText = [rawText stringByReplacingOccurrencesOfString:@"\%GREETING\%" withString:greeting];
    rawText = [rawText stringByReplacingOccurrencesOfString:@"\%TEMPERATURE\%" withString:[_weatherUpdater _temperature] ?: @"--"];
    rawText = [rawText stringByReplacingOccurrencesOfString:@"\%LOCATION\%" withString:[_weatherUpdater _locationName] ?: @"Unknown"];
    _imageView.image = [_weatherUpdater _conditionsImage];
    return rawText;
}

- (void)saveTextValue:(NSString *)text {
    [[ARITweakManager sharedInstance] setValue:text forKey:@"labelText"];
}

- (void)updateView {
    [super updateView];
    self.textField.leftViewMode = [[ARITweakManager sharedInstance] boolValueForKey:@"showWeatherIcon"]
                                      ? UITextFieldViewModeAlways // UnlessEditing
                                      : UITextFieldViewModeNever;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [_updateTimer invalidate];
}

@end