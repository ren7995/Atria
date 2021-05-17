//
// Created by ren7995 on 2021-04-27 18:20:43
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/UI/ARIWelcomeDynamicLabel.h"
#import <CoreText/CTFont.h>
#import <CoreText/CTFontDescriptor.h>
#import <CoreText/CTFontManager.h>
#import "src/Manager/ARITweak.h"

static ARIWelcomeDynamicLabel *shared;

// https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromHexValue(rgbValue) [UIColor                  \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
           green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
            blue:((float)(rgbValue & 0xFF)) / 255.0             \
           alpha:1.0]

@implementation ARIWelcomeDynamicLabel
{
    NSLayoutConstraint *_welcomeTopAnchor;
    NSLayoutConstraint *_welcomeLeadingAnchor;
    NSLayoutConstraint *_welcomeTrailingAnchor;
    CTFontDescriptorRef _cfdesc;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        shared = self;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.minimumFontSize = 16;
        self.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)_updateLabel
{
    if(!self.superview) return;
    ARITweak *manager = [ARITweak sharedInstance];

    // Update text
    self.text = [manager rawValueForKey:@"welcomeText"];

    // Get text size
    CGFloat textSize = [manager floatValueForKey:@"welcome_textSize"];

    // Load font
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        // Load font once
        NSData *fileData = [NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/AtriaPrefs.bundle/Custom.ttf"];
        if(fileData)
        {
            _cfdesc = CTFontManagerCreateFontDescriptorFromData((CFDataRef)fileData);
        }
    });

    // Update text size
    if(_cfdesc != NULL)
    {
        CTFontRef ctfont = CTFontCreateWithFontDescriptor(_cfdesc, textSize, nil);
        UIFont *font = CFBridgingRelease(ctfont);
        self.font = font;
    }
    else
    {
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

- (void)_updateAnchors
{
    ARITweak *manager = [ARITweak sharedInstance];
    CGFloat leftInset = [manager floatValueForKey:@"welcome_inset_left"];
    CGFloat topInset = [manager floatValueForKey:@"welcome_inset_top"];

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat x = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? self.startingLabelXPos : self.startingLabelXPosLandscape;
    CGFloat y = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? self.startingLabelYPos : self.startingLabelYPosLandscape;
    ;
    _welcomeTopAnchor.constant = y + topInset;
    _welcomeLeadingAnchor.constant = x + leftInset;
    _welcomeTrailingAnchor.constant = -x + leftInset;
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
    _welcomeTopAnchor = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor];
    _welcomeLeadingAnchor = [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor];
    _welcomeTrailingAnchor = [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor];

    [NSLayoutConstraint activateConstraints:@[
        _welcomeTopAnchor,
        _welcomeLeadingAnchor,
        [self.heightAnchor constraintEqualToConstant:50],
        _welcomeTrailingAnchor,
    ]];
}

+ (instancetype)shared
{
    return shared;
}

@end
