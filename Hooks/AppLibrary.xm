//
// Created by ren7995 on 2021-04-25 12:49:50
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/ARITweak.h"

%hook SBIconController

// Option to disable AppLibrary
- (BOOL)isAppLibrarySupported
{
	static BOOL enabled = [[ARITweak sharedInstance] boolValueForKey:@"enableAppLibrary"];
	return enabled;
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
