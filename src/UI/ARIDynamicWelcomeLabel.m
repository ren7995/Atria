//
// Created by ren7995 on 2021-04-27 18:20:43
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/UI/ARIDynamicWelcomeLabel.h"
#import <CoreText/CTFont.h>
#import <CoreText/CTFontDescriptor.h>
#import <CoreText/CTFontManager.h>
#import "src/Manager/ARITweakManager.h"

static ARIDynamicWelcomeLabel *shared;

// https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromHexValue(rgbValue) [UIColor                  \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
           green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
            blue:((float)(rgbValue & 0xFF)) / 255.0             \
           alpha:1.0]

@implementation ARIDynamicWelcomeLabel {
    NSString *_preText;
    NSCalendar *_calendar;
    NSLayoutConstraint *_welcomeTopAnchor;
    NSLayoutConstraint *_welcomeLeadingAnchor;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        shared = self;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.minimumFontSize = 16;
        self.adjustsFontSizeToFitWidth = YES;

        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        // Get components of current date
        NSDateComponents *components = [_calendar components:NSCalendarUnitHour fromDate:[NSDate date]];

        // Setup timers for 4 am, 12 pm, 6 pm
        int targetHours[] = {4, 12, 18};
        for(int i = 0; i < sizeof(targetHours); i++) {
            [components setHour:targetHours[i]];
            NSTimer *timer = [[NSTimer alloc]
                initWithFireDate:[_calendar dateFromComponents:components]
                        interval:1
                          target:self
                        selector:@selector(updateText:)
                        userInfo:nil
                         repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }

        // System time was set listener
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateText:) name:NSSystemClockDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateText:(NSTimer *)timer {
    if(timer == nil) {
        // Reload text from preferences
        _preText = [[ARITweakManager sharedInstance] rawValueForKey:@"welcomeText"];
    }

    NSString *greeting = nil;
    NSDateComponents *components = [_calendar components:NSCalendarUnitHour fromDate:[NSDate date]];
    if(components.hour >= 4 && components.hour < 12) {
        greeting = @"Good morning";
    } else if(components.hour >= 12 && components.hour < 18) {
        greeting = @"Good afternoon";
    } else if(components.hour >= 18 || components.hour < 4) {
        greeting = @"Good evening";
    } else {
        // How are you literally off the 24 hour day calendar
        // This code will never run
        greeting = @"Welcome";
    }

    self.text = [_preText stringByReplacingOccurrencesOfString:@"\%GREETING\%" withString:greeting];
}

- (void)_updateLabel {
    if(!self.superview) return;
    ARITweakManager *manager = [ARITweakManager sharedInstance];

    [self updateText:nil];

    // Get text size
    CGFloat textSize = [manager floatValueForKey:@"welcome_textSize"];

    // Load font
    static CTFontDescriptorRef cfdesc = NULL;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        // Load font once
        NSData *fileData = [NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/AtriaPrefs.bundle/Custom.ttf"];
        if(fileData) {
            cfdesc = CTFontManagerCreateFontDescriptorFromData((CFDataRef)fileData);
        }
    });

    // Update text size
    if(cfdesc != NULL) {
        CTFontRef ctfont = CTFontCreateWithFontDescriptor(cfdesc, textSize, nil);
        UIFont *font = CFBridgingRelease(ctfont);
        self.font = font;
    } else {
        self.font = [UIFont systemFontOfSize:textSize weight:UIFontWeightSemibold];
    }

    // Scan into integer value for our macro
    NSString *textColorString = [[manager rawValueForKey:@"welcomeTextColor"] stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
    NSScanner *scanner = [NSScanner scannerWithString:textColorString];
    unsigned int hexCode;
    [scanner scanHexInt:&hexCode];
    // Get color code and set it
    self.textColor = UIColorFromHexValue(hexCode);

    [self _updateAnchors];
}

- (void)_updateAnchors {
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    CGFloat leftInset = [manager floatValueForKey:@"welcome_inset_left"];
    CGFloat topInset = [manager floatValueForKey:@"welcome_inset_top"];

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat x = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? self.startingLabelXPos : self.startingLabelXPosLandscape;
    CGFloat y = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? self.startingLabelYPos : self.startingLabelYPosLandscape;
    ;
    _welcomeTopAnchor.constant = y + topInset;
    _welcomeLeadingAnchor.constant = x + leftInset;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    // On rotate or frame update
    [self _updateAnchors];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if(!self.superview) return;

    // Setup initial anchors
    _welcomeTopAnchor = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor];
    _welcomeLeadingAnchor = [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor];

    [NSLayoutConstraint activateConstraints:@[
        _welcomeTopAnchor,
        _welcomeLeadingAnchor,
        [self.heightAnchor constraintEqualToConstant:50],
        [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor],
    ]];
}

+ (instancetype)shared {
    return shared;
}

@end
