//
// Created by ren7995 on 2021-04-25 15:48:29
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Shared.h"
#import "../Manager/ARITweakManager.h"
#import "../Manager/ARIEditManager.h"
#import "../UI/Splash/ARISplashViewController.h"
#import "../UI/Label/ARILabelView.h"

#include <dlfcn.h>


%hook SBIconController 

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];

    ARITweakManager *manager = [ARITweakManager sharedInstance];
    if(![manager boolValueForKey:ARIDidSplashPreferenceKey]) {
        ARISplashViewController *splash = [[ARISplashViewController alloc] initWithSubtitle:@"Getting started"];
        [splash addEntry:@"3D touch an icon or triple tap your wallpaper to edit layout" image:[UIImage systemImageNamed:[manager firmwareVersion] >= 14 ? @"square.grid.3x3.fill.square" : @"square"]];
        [splash addEntry:@"Drag the slider on the editor to see changes in real-time" image:[UIImage systemImageNamed:@"slider.horizontal.3"]];
        [splash addEntry:@"Tap the label underneath the slider and type in a value for precise control" image:[UIImage systemImageNamed:@"wand.and.rays"]];
        [splash addEntry:@"Tap this icon on the editor to edit layout for the current page only" image:[UIImage systemImageNamed:@"doc"]];
        [splash addEntry:@"See the preference pane in the Settings app for even more options" image:[UIImage systemImageNamed:[manager firmwareVersion] >= 14 ? @"gearshape" : @"gear"]];
        [splash addEntry:@"If you encounter a bug, don't hesitate to report it! Please include your device and iOS version." image:[UIImage systemImageNamed:[manager firmwareVersion] >= 14 ? @"ladybug" : @"ant"]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[objc_getClass("SBIconController") sharedInstance] presentViewController:splash animated:YES completion:nil];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

%end


%hook SBMainSwitcherWindow

- (void)setHidden:(BOOL)arg {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

%end


%hook SBIconScrollView

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    // Prevents the scroll view from scrolling on its own when typing in text fields
    // for homescreen page labels. Crossing my fingers this doesn't break anything.
}

%end


%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    [[ARITweakManager sharedInstance] onSpringboardLaunched];
}

%end


%group TodayViewFixiPad
%hook SBTodayViewController

// These next two hooked methods fix label bugging on iPad with today view

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter]
            postNotificationName:ARIUpdateLabelVisibilityNotification
                          object:nil
                        userInfo:@{@"alpha" : @(0.0F), @"animationDuration" : @(0.3F)}];
}

- (void)viewDidDisappear:(BOOL)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter]
            postNotificationName:ARIUpdateLabelVisibilityNotification
                          object:nil
                        userInfo:@{@"alpha" : @(1.0F), @"animationDuration" : @(0.3F)}];
}

%end
%end

%group ZenithFix
%hook SBIconListModel

// Prevents a crash seeimingly caused by an interaction between Atria and Zenith.
// Zenith attempts to insert icons in a way that doesn't work with modified layout, leading to an exception.

- (id)insertIcons:(id)arg1 atIndex:(NSUInteger)arg2 options:(NSUInteger)arg3 {
    // Amazing..
	@try {
		return %orig;
	} @catch(NSException *exc) {
		return nil;
	}
}

// Fix for a crash with Zenith that occurs when its installed on its own (related to App Library).
// When -[SBHLibraryCategory updateCategoryWithIcons:] is invoked, it calls this method.

- (id)insertIcon:(id)arg1 atIndex:(NSUInteger)arg2 {
	@try {
		return %orig;
	} @catch(NSException *exc) {
		return nil;
	}
}

%end
%end

%ctor {
    ARITweakManager *manager = [ARITweakManager sharedInstance];
	if([manager isEnabled]) {
		NSLog(@"[Atria]: Loading hooks from %s", __FILE__);
		%init();

        if([manager isDeviceIPad]) {
            %init(TodayViewFixiPad);
        }

        // Zenith compatibility
        NSString *const zenithPath = @THEOS_PACKAGE_INSTALL_PREFIX "/Library/MobileSubstrate/DynamicLibraries/Zenith.dylib";
        if([[NSFileManager defaultManager] fileExistsAtPath:zenithPath]) {
            dlopen([zenithPath UTF8String], RTLD_NOW);
            %init(ZenithFix);
        }
	}
}
