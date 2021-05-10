//
// Created by ren7995 on 2021-04-25 12:49:50
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/ARITweak.h"
#include <objc/runtime.h>

static id fixedLayoutForAppLibrary = [ARITweak sharedInstance].firmware14 ? [objc_getClass("ARIAppLibraryIconListLayoutProvider") new] : nil;

%hook SBIconController

// Option to disable AppLibrary
- (BOOL)isAppLibrarySupported
{
	static BOOL enabled = [[ARITweak sharedInstance] boolValueForKey:@"enableAppLibrary"];
	return enabled;
}

%end

%group AppLibraryFix

// Subclass layout provider. I could have just added a property to tag an instance as our fix,
// but this allows for future expansion (also it's fun to use this :P)
%subclass ARIAppLibraryIconListLayoutProvider : SBHDefaultIconListLayoutProvider
%end

// Patch the app library layout provider methods

%hook SBHLibraryViewController
- (id)listLayoutProvider
{
	return fixedLayoutForAppLibrary;
}
- (void)setListLayoutProvider:(id)list
{
	%orig(fixedLayoutForAppLibrary);
}
%end

%end

%ctor
{
	//fixedLayoutForAppLibrary = [objc_getClass("ARIAppLibraryIconListLayoutProvider") new];
	if([ARITweak sharedInstance].enabled)
	{
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();

		if([[ARITweak sharedInstance] boolValueForKey:@"layoutEnabled"])
		{
			%init(AppLibraryFix);
		}
	}
}
