//
// Created by ren7995 on 2021-04-27 18:35:28
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Shared.h"
#import "../Manager/ARITweakManager.h"

%hook SBDefaultIconModelStore

- (id)loadCurrentIconState:(NSError **)error {
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    id lastKnownState = [manager rawValueForKey:@"_saveState"];
    if(lastKnownState) {
        return lastKnownState;
    }

    id orig = %orig;
    [manager setValue:orig forKey:@"_saveState"];
    return orig;
}

- (BOOL)saveCurrentIconState:(id)state error:(NSError **)error {
    [[ARITweakManager sharedInstance] setValue:state forKey:@"_saveState"];
    return %orig;
}

%end

%ctor {
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    if([manager isEnabled]) {
        // A user might want to disable this if they have a tweak like Velox Reloaded 2 which also saves icon state
        if([manager boolValueForKey:@"saveIconState"]) {
            NSLog(@"[Atria]: Loading hooks from %s", __FILE__);
		    %init();
        } else {
            // Clear the existing saved icon state so that the user's layout doesn't revert when re-enabling the option
            [[ARITweakManager sharedInstance] resetValueForKey:@"_saveState"];
        }
	}
}
