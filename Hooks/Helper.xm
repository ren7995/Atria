//
// Created by ren7995 on 2021-04-25 15:48:29
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/Manager/ARITweak.h"
#import "src/Manager/ARIEditManager.h"
#import "src/UI/ARISplashViewController.h"
#import "src/UI/ARIWelcomeDynamicLabel.h"

%hook SBIconController 

- (void)viewWillAppear:(BOOL)animated {
    ARITweak *manager = [ARITweak sharedInstance];
    [manager notifyDidLoad];
    %orig;
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];

    ARITweak *manager = [ARITweak sharedInstance];
    if(![manager boolValueForKey:@"_atriaDidSplashGuide"]) {
        NSArray *entries = @[
            @{
                @"3D touch an icon to access the tweak’s functionalities, or triple tap the area you want to configure (HS, dock, welcome label)" : [UIImage systemImageNamed:@"square"],
            },
            @{
                @"In order to switch between settings, tap on the big label at the top of the view" : [UIImage systemImageNamed:manager.firmware14 ? @"dial.min" : @"slider.horizontal.below.rectangle"],
            },
            @{
                @"Tap this icon while selecting a setting to toggle per-page layout for the current page" : [UIImage systemImageNamed:@"doc"],
            },
            @{
                @"To edit values use the slider, or tap the label underneath and type a value for precise control" : [UIImage systemImageNamed:@"slider.horizontal.3"],
            },
            @{
                @"Some options are only available in the Settings app" : [UIImage systemImageNamed:manager.firmware14 ? @"gearshape.fill" : @"gear"],
            },
        ];

        ARISplashViewController *splash = [[ARISplashViewController alloc] initWithEntries:entries subtitle:@"Getting started"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[objc_getClass("SBIconController") sharedInstance] presentViewController:splash animated:YES completion:^{
                [manager setValue:@(YES) forKey:@"_atriaDidSplashGuide"];
            }];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
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

%hook SBTodayViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    // These next two hooked methods fix label bugging on iPad with today view
    if(![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) return;
    [UIView animateWithDuration:0.3 animations:^{
        [ARIWelcomeDynamicLabel shared].alpha = 0;
    } completion:nil];
}

- (void)viewDidDisappear:(BOOL)arg1 {
    %orig;
    if(![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) return;
    [UIView animateWithDuration:0.3 animations:^{
        [ARIWelcomeDynamicLabel shared].alpha = 1;
    } completion:nil];
}

%end

%ctor {
	if([ARITweak sharedInstance].enabled) {
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();
	}
}
