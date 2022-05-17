//
// Created by ren7995 on 2021-04-25 12:49:50
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/Manager/ARITweakManager.h"
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

- (NSUInteger)ignoresOverscrollOnLastPageOrientations {
	// Why did Apple name it this? lol
	// This code allows App Library on iPad

	// 30 is all
	// 15 is portrait, not landscape
	return 30;
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
	if(!fixedLayoutForAppLibrary) fixedLayoutForAppLibrary = [ARITweakManager sharedInstance].firmware14 ? [objc_getClass("ARIAppLibraryIconListLayoutProvider") new] : nil;
	%orig(fixedLayoutForAppLibrary);
}

%end

%end

%ctor {
	if([ARITweakManager sharedInstance].enabled) {
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();

		if([[ARITweakManager sharedInstance] boolValueForKey:@"layoutEnabled"]) {
			%init(AppLibraryFix);
		}
	}
}
