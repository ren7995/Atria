//
// Created by ren7995 on 2021-04-27 18:20:43
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARILabelView.h"
#import "../../Manager/ARITweakManager.h"

#import <CoreText/CTFont.h>
#import <CoreText/CTFontDescriptor.h>
#import <CoreText/CTFontManager.h>

@implementation ARILabelView {
    NSString *_rawText;
    NSLayoutConstraint *_labelTopAnchor;
    NSLayoutConstraint *_labelLeadingAnchor;
    NSLayoutConstraint *_labelTrailingAnchor;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.translucent = YES;
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(endTextEntry)];
        UIBarButtonItem *spacingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(textFieldShouldReturn:)];
        [toolbar setItems:@[ cancelItem, spacingItem, doneItem ] animated:NO];
        [toolbar sizeToFit];

        _textField = [UITextField new];
        _textField.adjustsFontSizeToFitWidth = YES;
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.delegate = self;
        _textField.inputAccessoryView = toolbar;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:_textField];
        [NSLayoutConstraint activateConstraints:@[
            [_textField.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [_textField.heightAnchor constraintEqualToAnchor:self.heightAnchor],
            [_textField.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_textField.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];

        [self setupTextField:_textField];
    }
    return self;
}

- (void)updateText:(NSTimer *)timer {
    // Don't update the text while the user is editing, or we will discard what they typed
    if([_textField isEditing]) return;

    BOOL scheduled = timer != nil;
    // If wasn't a scheduled update, reload raw text
    if(!scheduled) _rawText = [self loadRawText];
    // Process text
    _textField.text = [self processRawText:_rawText isScheduledUpdate:scheduled];
}

- (void)setupTextField:(UITextField *)textField {
}

- (NSString *)loadRawText {
    // Implemented in inheriting classes
    return nil;
}

- (NSString *)processRawText:(NSString *)rawText isScheduledUpdate:(BOOL)scheduled {
    // Implemented in inheriting classes
    return nil;
}

- (void)updateLabelVisibility:(NSNotification *)notification {
    if(!notification.userInfo) return;
    [UIView animateWithDuration:((NSNumber *)notification.userInfo[@"animationDuration"]).floatValue
                     animations:^{
                         self.alpha = ((NSNumber *)notification.userInfo[@"alpha"]).floatValue;
                     }
                     completion:nil];
}

- (void)updateView {
    if(!self.superview) return;
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    SBIconListView *superv = (SBIconListView *)self.superview;

    [self updateText:nil];

    // Get text size
    CGFloat textSize = [manager floatValueForKey:@"label_textSize" forListView:superv];

    // Load font
    CTFontDescriptorRef cfdesc = [[self class] getCustomFontDescriptorOrNull];

    // Update text size
    if(cfdesc != NULL) {
        CTFontRef ctfont = CTFontCreateWithFontDescriptor(cfdesc, textSize, nil);
        _textField.font = CFBridgingRelease(ctfont);
    } else {
        _textField.font = [UIFont systemFontOfSize:textSize weight:UIFontWeightSemibold];
    }

    // Text color
    _textField.textColor = [[self class] colorFromHexString:[manager rawValueForKey:@"labelTextColor"] withAlpha:1.0F];

    // Text shadow
    if([manager boolValueForKey:@"pageLabelShadow"] && _textField.layer.shadowOpacity == 0.0) {
        _textField.layer.shadowOpacity = 0.5F;
        _textField.layer.shadowRadius = 5.0F;
        _textField.layer.shadowColor = [UIColor blackColor].CGColor;
        _textField.layer.shadowOffset = CGSizeZero;
        _textField.layer.shouldRasterize = YES;
        _textField.layer.rasterizationScale = UIScreen.mainScreen.scale;
    } else if(![manager boolValueForKey:@"pageLabelShadow"] && _textField.layer.shadowOpacity > 0.0) {
        _textField.layer.shadowOpacity = 0.0F;
        _textField.layer.shadowRadius = 0.0F;
    }

    [self updateAnchors];
}

- (void)updateAnchors {
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    SBIconListView *superv = (SBIconListView *)self.superview;
    CGFloat leftInset = [manager floatValueForKey:@"label_inset_left" forListView:superv];
    CGFloat topInset = [manager floatValueForKey:@"label_inset_top" forListView:superv];

    CGPoint origin = UIInterfaceOrientationIsPortrait([ARITweakManager currentDeviceOrientation])
                         ? self.portraitOrigin
                         : self.landscapeOrigin;

    if([manager isDeviceIPad]) {
        // fr
        origin.x -= 40;
        origin.y -= 50;
    }

    _labelLeadingAnchor.constant = origin.x + leftInset;
    _labelTrailingAnchor.constant = leftInset;
    _labelTopAnchor.constant = origin.y + topInset;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [ARITweakManager dismissFloatingDockIfPossible];
    // Set to the raw text
    _textField.text = _rawText;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Save text
    [self saveTextValue:_textField.text];
    [self endTextEntry];
    return YES;
}

- (void)saveTextValue:(NSString *)text {
    // Implemented in inheriting classes
}

- (void)endTextEntry {
    [_textField resignFirstResponder];
    [ARITweakManager presentFloatingDockIfPossible];
    [self updateText:nil];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if(!self.superview) return;

    [self updateText:nil];

    // Setup initial anchors
    _labelTopAnchor = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor];
    _labelLeadingAnchor = [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor];
    _labelTrailingAnchor = [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor];

    [NSLayoutConstraint activateConstraints:@[
        _labelTopAnchor,
        _labelLeadingAnchor,
        [self.heightAnchor constraintEqualToConstant:50],
        _labelTrailingAnchor
    ]];
}

- (void)removeFromSuperview {
    [self endTextEntry];
    [super removeFromSuperview];
}

+ (CTFontDescriptorRef)getCustomFontDescriptorOrNull {
    static CTFontDescriptorRef cfdesc = NULL;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        // Load font once
        NSData *fileData = [NSData dataWithContentsOfFile:@THEOS_PACKAGE_INSTALL_PREFIX "/Library/PreferenceBundles/AtriaPrefs.bundle/Custom.ttf"];
        if(fileData) {
            cfdesc = CTFontManagerCreateFontDescriptorFromData((CFDataRef)fileData);
        }
    });
    return cfdesc;
}

@end
