//
// Created by ren7995 on 2021-04-25 12:49:50
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Shared.h"
#import "../Manager/ARITweakManager.h"

#include <objc/runtime.h>

static id fixedLayoutForAppLibrary = nil;

%hook SBIconController

// Option to disable AppLibrary
- (BOOL)isAppLibrarySupported {
	static const BOOL enabled = [[ARITweakManager sharedInstance] boolValueForKey:@"enableAppLibrary"];
	return enabled;
}

%end

%hook SBRootFolderControllerConfiguration

- (UIInterfaceOrientationMask)ignoresOverscrollOnFirstPageOrientations {
	static const BOOL disableTodayGesture = [[ARITweakManager sharedInstance] boolValueForKey:@"disableTodayGesture"];
	return disableTodayGesture ? 0 : %orig;
}

- (UIInterfaceOrientationMask)ignoresOverscrollOnLastPageOrientations {
	static const BOOL disableGesture = ![[ARITweakManager sharedInstance] boolValueForKey:@"enableAppLibrary"] || [[ARITweakManager sharedInstance] boolValueForKey:@"disableAppLibraryGesture"];
	return disableGesture ? 0 : UIInterfaceOrientationMaskAll;
}

%end

%group AppLibraryFix

// Subclass layout provider. I could have just added a property to tag an instance as our fix,
// but this allows for future expansion (also it's fun to use this :P)
%subclass ARIAppLibraryIconListLayoutProvider : SBHDefaultIconListLayoutProvider
%end

// Patch the app library layout provider methods

%hook SBHLibraryViewController

- (id)listLayoutProvider {
	return fixedLayoutForAppLibrary;
}

- (void)setListLayoutProvider:(id)list {
    if(!fixedLayoutForAppLibrary)
        fixedLayoutForAppLibrary = [[ARITweakManager sharedInstance] firmwareVersion] >= 14
                                       ? [objc_getClass("ARIAppLibraryIconListLayoutProvider") new]
                                       : nil;
    %orig(fixedLayoutForAppLibrary);
}

%end

%end

%ctor {
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	if([manager isEnabled]) {
		NSLog(@"[Atria]: Loading hooks from %s", __FILE__);
		%init();

		if([manager boolValueForKey:@"layoutEnabled"]) {
			%init(AppLibraryFix);
		}
	}
}
