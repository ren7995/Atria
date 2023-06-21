//
// Created by ren7995 on 2023-05-25 21:53:27
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

// RGB: 81, 8, 126
#define kPrefTintColor [UIColor colorWithRed:0.32 green:0.03 blue:0.49 alpha:1.00]
static NSString *const ARIPreferenceDomain = @"me.lau.AtriaPrefs";

@interface ARIListController : PSListController
- (void)promptRespring:(id)sender;
- (void)respringWithAnimation;
@end

@interface NSTask : NSObject
@property (copy) NSArray *arguments;
@property (copy) NSString *launchPath;
- (id)init;
- (void)waitUntilExit;
- (void)launch;
@end
