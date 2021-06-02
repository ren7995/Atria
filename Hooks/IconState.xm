//
// Created by ren7995 on 2021-04-27 18:35:28
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/Manager/ARITweak.h"

%hook SBDefaultIconModelStore

- (id)loadCurrentIconState:(NSError **)error {
    NSUserDefaults *saveStore = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];

    id lastKnownState = [saveStore objectForKey:@"saveState"];
    if(lastKnownState) {
        return lastKnownState;
    }

    id orig = %orig;
    [saveStore setObject:orig forKey:@"saveState"];
    return orig;
}

- (BOOL)saveCurrentIconState:(id)state error:(NSError **)error {
    NSUserDefaults *saveStore = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
    [saveStore setObject:state forKey:@"saveState"];

    return %orig;
}

%end

%ctor {
    // A user might want to disable this if they have a tweak like Velox Reloaded 2 which auto saves
    if([ARITweak sharedInstance].enabled && [[ARITweak sharedInstance] boolValueForKey:@"saveIconState"]) {
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();
	}
}
