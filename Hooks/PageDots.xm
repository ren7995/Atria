//
// Created by ren7995 on 2021-07-06 14:59:57
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/Manager/ARITweakManager.h"

// Instead of hooking the page dots directly, we hijack the layout method
// on the root folder view for optimal performance
%hook SBRootFolderView

- (void)layoutPageControlWithMetrics:(const struct SBRootFolderViewMetrics *)metrics {
    static SBRootFolderViewMetrics cachedMetrics;
    if(!metrics) {
        metrics = &cachedMetrics;
    } else {
        cachedMetrics = *metrics;
    }

    %orig(metrics);

    ARITweakManager *manager = [ARITweakManager sharedInstance];
	UIView *view = self.pageControl;
	CGRect newFrame = view.frame;
	newFrame.origin.x += [manager floatValueForKey:@"pagedot_offsetX"];
    newFrame.origin.y += [manager floatValueForKey:@"pagedot_offsetY"];
	view.frame = newFrame;
}

%end

%ctor {
	if([ARITweakManager sharedInstance].enabled) {
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();
	}
}

