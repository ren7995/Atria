//
// Created by ren7995 on 2021-04-25 12:49:32
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Shared.h"
#import "../Manager/ARITweakManager.h"
#import "../Manager/ARIEditManager.h"
#import "../UI/Label/ARILabelView.h"
#import "../UI/Label/ARIPageLabelView.h"
#import "../UI/Label/ARIWelcomeLabelView.h"
#import "../UI/ARIBackgroundView.h"

@interface SBHDefaultIconListLayoutProvider : NSObject
- (SBIconListFlowExtendedLayout *)layoutForIconLocation:(NSString *)location;
@end

%hook SBIconListView
%property (nonatomic, strong) ARILabelView *_atriaPageLabel;
%property (nonatomic, strong) ARIBackgroundView *_atriaBackground;
%property (nonatomic, strong) UITapGestureRecognizer *_atriaTap;
%property (nonatomic, strong) SBIconListFlowExtendedLayout *_atriaCachedLayout;
%property (nonatomic, strong) SBIconListFlowExtendedLayout *_originalLayout;
%property (nonatomic, assign) BOOL _atriaNeedsLayout;

%new
- (void)_atriaBeginEditing {
	[[ARIEditManager sharedInstance] presentEditAlert];
}

- (SBIconListFlowExtendedLayout *)layout {
	SBIconListFlowExtendedLayout *orig = %orig;

	SBIconListModel *model = [self model];
	ARITweakManager *manager = [ARITweakManager sharedInstance];
 	if(!model._atriaLocation) model._atriaLocation = self.iconLocation;
 	[manager.listViewModelMap setObject:self forKey:model];

	if(self._originalLayout != orig || self._atriaNeedsLayout) {
		self._originalLayout = orig;
		[self _atriaUpdateLayoutCache];
		[model _atriaUpdateModelGridSizes];
		self._atriaNeedsLayout = NO;
	}

	return self._atriaCachedLayout ?: orig;
}

- (void)layoutIconsNow {
	self._atriaNeedsLayout = YES;
	%orig;
}

- (void)didAddIconView:(id)arg1 {
	%orig(arg1);
	// Once an icon has been added, update layout
	if(IconListIsRoot(self) && [self.icons count] == 1) self._atriaNeedsLayout = YES;
}

%new
- (void)_atriaUpdateLayoutCache {
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	SBIconListFlowExtendedLayout *orig = self._originalLayout;

	// Update layout
	if(IconListIsRoot(self)) {
		// Don't update layout if there are 0 icons
		// This helps prevent unnecessary work, and additionally prevents issues related to the page reordering view
		if([self.icons count] == 0) return;

		// Checks if the icon list is actually in the root views
		BOOL isInRootViews = [[manager allRootListViews] containsObject:self];
		BOOL isFirstIconList = [manager firstIconListView] == self;
		BOOL showPageLabel = (isFirstIconList && [manager boolValueForKey:@"showWelcome"]) || (isInRootViews && [manager boolValueForKey:@"showPageLabels"]);

		// Add tap gesture if we didn't already. Do this here to enable/disable dynamically
		if(!self._atriaTap && ![manager boolValueForKey:@"disableTapGesture"]) {
			self._atriaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_atriaBeginEditing)];
			[self._atriaTap setNumberOfTapsRequired:3];
			[self addGestureRecognizer:self._atriaTap];
		} else if(self._atriaTap && [manager boolValueForKey:@"disableTapGesture"]) {
			[self removeGestureRecognizer:self._atriaTap];
			self._atriaTap = nil;
		}

		// Per-page layout requires copying this object
		SBIconListGridLayoutConfiguration *config = [orig.layoutConfiguration copy];

		NSUInteger cols = [manager intValueForKey:@"hs_columns" forListView:self];
		NSUInteger rows = [manager intValueForKey:@"hs_rows" forListView:self];

		// Set number of columns/rows, inverting for landscape
		[config setNumberOfPortraitColumns:cols];
		[config setNumberOfPortraitRows:rows];
		[config setNumberOfLandscapeColumns:rows];
		[config setNumberOfLandscapeRows:cols];

		// Offset moves the whole page
		CGFloat topOffset = [manager floatValueForKey:@"hs_offset_top" forListView:self];
		CGFloat leftOffset = [manager floatValueForKey:@"hs_offset_left" forListView:self];

		// Insets
		CGFloat topInset = [manager floatValueForKey:@"hs_inset_top" forListView:self];
		CGFloat bottomInset = [manager floatValueForKey:@"hs_inset_bottom" forListView:self];
		CGFloat leftInset = [manager floatValueForKey:@"hs_inset_left" forListView:self];
		CGFloat rightInset = [manager floatValueForKey:@"hs_inset_right" forListView:self];

		// Spacing is actually just inset adjustments that give the use the illusion of change
		CGFloat spaceX = [manager floatValueForKey:@"hs_spacing_x" forListView:self];
		CGFloat spaceY = [manager floatValueForKey:@"hs_spacing_y" forListView:self];

		// Add spacing for page label
		if(showPageLabel) topInset += 60;

		// Set layout insets
		UIEdgeInsets origPortrait = config.portraitLayoutInsets;
		UIEdgeInsets portraitInsets = UIEdgeInsetsMake(
			origPortrait.top + topInset + topOffset,
			origPortrait.left + leftInset + leftOffset,
			origPortrait.bottom + bottomInset - topOffset,
			origPortrait.right + rightInset - leftOffset
		);
		// Make final insets with adjustments for icon spacing
		[config setPortraitLayoutInsets:UIEdgeInsetsMake(
			portraitInsets.top - spaceY / 2,
			portraitInsets.left - spaceX / 2,
			portraitInsets.bottom - spaceY / 2,
			portraitInsets.right - spaceX / 2
		)];

		// Landscape insets
		UIEdgeInsets origLandscape = config.landscapeLayoutInsets;
		UIEdgeInsets landscapeInsets = UIEdgeInsetsMake(
			origLandscape.top + topInset + topOffset,
			origLandscape.left + leftInset + leftOffset,
			origLandscape.bottom + bottomInset - topOffset,
			origLandscape.right + rightInset - leftOffset
		);
		[config setLandscapeLayoutInsets:UIEdgeInsetsMake(
			landscapeInsets.top - spaceY / 2,
			landscapeInsets.left - spaceX / 2,
			landscapeInsets.bottom - spaceY / 2,
			landscapeInsets.right - spaceX / 2
		)];

		// Update background
		if(!(isInRootViews && [manager boolValueForKey:@"showBackground"])) {
			// Remove background if not needed
			if(self._atriaBackground) {
				[self._atriaBackground removeFromSuperview];
				self._atriaBackground = nil;
			}
		} else {
			// Create background
			if(!self._atriaBackground) self._atriaBackground = [[ARIBackgroundView alloc] init];
			// Insert subview at index 0
			if(!self._atriaBackground.superview) [self insertSubview:self._atriaBackground atIndex:0];
			else [self sendSubviewToBack:self._atriaBackground];

			self._atriaBackground.portraitLayoutGuide = portraitInsets;
			self._atriaBackground.landscapeLayoutGuide = landscapeInsets;
			[self._atriaBackground updateView];
		}

		// Update page label
		if(!showPageLabel) {
			// Remove page label if not needed
			if(self._atriaPageLabel) {
				[self._atriaPageLabel removeFromSuperview];
				self._atriaPageLabel = nil;
			}
		} else {
			// Create label if needed
			if(!self._atriaPageLabel) {
				if (isFirstIconList) self._atriaPageLabel = [[ARIWelcomeLabelView alloc] init];
				else self._atriaPageLabel = [[ARIPageLabelView alloc] init];
			}
			// Add to superview and add inital anchors
			// The dynamic label will constrain itself
			if(!self._atriaPageLabel.superview) [self addSubview:self._atriaPageLabel];

			self._atriaPageLabel.portraitOrigin = CGPointMake(portraitInsets.left, origPortrait.top);
			self._atriaPageLabel.landscapeOrigin = CGPointMake(landscapeInsets.left, origLandscape.top);;
			[self._atriaPageLabel updateView];
		}

		// Create a new flow layout with our modified (and copied) configuration
		// layoutConfiguration is readonly on SBIconListFlowExtendedLayout
		if([manager firmwareVersion] >= 14) {
			self._atriaCachedLayout = [[objc_getClass("SBIconListFlowExtendedLayout") alloc] initWithLayoutConfiguration:config];
		} else {
			// SBIconListFlowExtendedLayout does not exist on 13
			self._atriaCachedLayout = [[objc_getClass("SBIconListFlowLayout") alloc] initWithLayoutConfiguration:config];
		}
	} else if(IconListIsDock(self)) {
		SBIconListGridLayoutConfiguration *config = orig.layoutConfiguration;

		NSUInteger cols = [manager intValueForKey:@"dock_columns"];
		NSUInteger rows = [manager intValueForKey:@"dock_rows"];

		// Disable dock
		if([manager boolValueForKey:@"disableDock"]) cols = rows = 0;

		[config setNumberOfPortraitColumns:cols];
		[config setNumberOfPortraitRows:rows];
		// Flip for landscape
		[config setNumberOfLandscapeColumns:rows];
		[config setNumberOfLandscapeRows:cols];

		if([manager firmwareVersion] >= 14) {
			self.additionalLayoutInsets = UIEdgeInsetsMake(
				[manager floatValueForKey:@"dock_inset_top"],
				[manager floatValueForKey:@"dock_inset_left"],
				[manager floatValueForKey:@"dock_inset_bottom"],
				[manager floatValueForKey:@"dock_inset_right"]
			);
		} else {
			CGFloat spaceX = [manager floatValueForKey:@"dock_spacing_x"];
			CGFloat spaceY = [manager floatValueForKey:@"dock_spacing_y"];

			self.layoutInsets = UIEdgeInsetsMake(
				[manager floatValueForKey:@"dock_inset_top"] - spaceY / 2,
				[manager floatValueForKey:@"dock_inset_left"] - spaceX / 2,
				[manager floatValueForKey:@"dock_inset_bottom"] - spaceY / 2,
				[manager floatValueForKey:@"dock_inset_right"] - spaceX / 2
			);
		}

		// We don't need to copy our grid config for dock, so set it
		// to the original object now that we've modified the layout.
		self._atriaCachedLayout = orig;
	}
}

- (CGSize)iconSpacing {
	CGSize spacing = %orig;
	// This doesn't work on iOS 13
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	if([manager firmwareVersion] >= 14 && IconListIsDock(self)) {
		CGFloat spaceX = [manager floatValueForKey:@"dock_spacing_x"];
		CGFloat spaceY = [manager floatValueForKey:@"dock_spacing_y"];
		// I divide by 2 to keep it consistent with behavior of root
		// Root icon spacing is managed by adjusting insets, since that is what works
		return CGSizeMake(spacing.width + spaceX / 2, spacing.height + spaceY / 2);
	}
	return spacing;
}

- (BOOL)automaticallyAdjustsLayoutMetricsToFit {
	// automaticallyAdjustsLayoutMetricsToFit makes the icons auto scale
	// and automatically lay themselves out. We don't want this.

	if(IconListIsRoot(self) || IconListIsDock(self)) return NO;
	return %orig;
}

%end

// Layout provider hook
%hook SBHDefaultIconListLayoutProvider

- (SBIconListFlowExtendedLayout *)layoutForIconLocation:(NSString *)location {
	SBIconListFlowExtendedLayout *orig = %orig;
	// We override the original class for root, unless we are the subclass
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	if(IsLocationRoot(location) && ![self isMemberOfClass:objc_getClass("ARIAppLibraryIconListLayoutProvider")]) {
		// By setting the cols and rows to 0x7F (127), it fixes a bug where icons 
		// would disappear before they scroll visually offscreen on iOS 14.
		NSUInteger cols = 0x7F; // [manager intValueForKey:@"hs_columns"];
		NSUInteger rows = 0x7F; // [manager intValueForKey:@"hs_rows"];

		[orig.layoutConfiguration setNumberOfPortraitColumns:cols];
		[orig.layoutConfiguration setNumberOfPortraitRows:rows];
		[orig.layoutConfiguration setNumberOfLandscapeColumns:rows];
		[orig.layoutConfiguration setNumberOfLandscapeRows:cols];
	} else if(IsLocationDock(location)) {
		// Fix dock layout. This is needed, do not remove!
		NSUInteger cols = [manager intValueForKey:@"dock_columns"];
		NSUInteger rows = [manager intValueForKey:@"dock_rows"];
		[orig.layoutConfiguration setNumberOfPortraitColumns:cols];
		[orig.layoutConfiguration setNumberOfPortraitRows:rows];
		[orig.layoutConfiguration setNumberOfLandscapeColumns:rows];
		[orig.layoutConfiguration setNumberOfLandscapeRows:cols];
	}
	return orig;
}

%end

static void preferencesChanged() {
    [[ARITweakManager sharedInstance] updateLayoutForRoot:YES forDock:YES animated:YES];
}

%ctor {
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	if([manager isEnabled] && [manager boolValueForKey:@"layoutEnabled"]) {
		NSLog(@"[Atria]: Loading hooks from %s", __FILE__);
		%init();

		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			(CFNotificationCallback)preferencesChanged,
			(CFStringRef)@"me.lau.Atria/ReloadPrefs",
			NULL,
			CFNotificationSuspensionBehaviorDeliverImmediately
		);
	}
}
