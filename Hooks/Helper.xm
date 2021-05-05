//
// Created by ren7995 on 2021-04-25 15:48:29
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/ARITweak.h"
#import "src/ARIEditManager.h"
#import "src/ARISplashViewController.h"
#import "src/ARIWelcomeDynamicLabel.h"

%hook SBIconController 

- (void)viewDidAppear:(BOOL)animated
{
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];

    if(![[ARITweak sharedInstance] boolValueForKey:@"_atriaDidSplashGuide"])
    {
        NSArray *entries = @[
            @{
                @"3D touch an icon to access the tweak’s functionalities" : [UIImage systemImageNamed:@"hand.tap.fill"],
            },
            @{
                @"In order to switch between settings, tap on the big label at the top of the view (it will display the currently selected setting)" : [UIImage systemImageNamed:@"dial.min.fill"],
            },
            @{
                @"Tap this icon while selecting a setting to toggle per-page layout for the current page" : [UIImage systemImageNamed:@"doc.plaintext"],
            },
            @{
                @"To edit values use the slider, or tap the label underneath and type a value for precise control" : [UIImage systemImageNamed:@"slider.horizontal.3"],
            },
            @{
                @"Some options are only available in the Settings app" : [UIImage systemImageNamed:@"gearshape.fill"],
            },
        ];

        ARISplashViewController *splash = [[ARISplashViewController alloc] initWithEntries:entries subtitle:@"Getting started"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[objc_getClass("SBIconController") sharedInstance] presentViewController:splash animated:YES completion:^{
                [[ARITweak sharedInstance] setValue:@(YES) forKey:@"_atriaDidSplashGuide"];
            }];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

%end

%hook SBMainSwitcherWindow

- (void)setHidden:(BOOL)arg
{
    %orig;
    [[ARIEditManager sharedInstance] toggleEditView:NO withTargetLocation:nil];
}

%end

%hook SBTodayViewController

- (void)viewWillAppear:(BOOL)arg1
{
    %orig;
    // These next two hooked methods fix label bugging on iPad with today view
    if(![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) return;
    [UIView animateWithDuration:0.3 animations:^{
        [ARIWelcomeDynamicLabel shared].alpha = 0;
    } completion:nil];
}

- (void)viewDidDisappear:(BOOL)arg1
{
    %orig;
    if(![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) return;
    [UIView animateWithDuration:0.3 animations:^{
        [ARIWelcomeDynamicLabel shared].alpha = 1;
    } completion:nil];
}

%end

%ctor
{
	if([ARITweak sharedInstance].enabled)
	{
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();
	}
}
