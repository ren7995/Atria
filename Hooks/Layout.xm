//
// Created by ren7995 on 2021-04-25 12:49:32
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/ARITweak.h"
#import "src/ARIWelcomeDynamicLabel.h"
#import "src/ARIDynamicBackgroundView.h"

// This struct is not named this, but it does not matter
typedef struct SBIconListPredictableGeneric
{
	NSUInteger field0;
	CGFloat field1;
} SBIconListPredictableGeneric;

@interface SBHDefaultIconListLayoutProvider : NSObject
- (SBIconListFlowExtendedLayout *)layoutForIconLocation:(NSString *)location;
@end

%hook SBIconListView
%property (nonatomic, strong) ARIWelcomeDynamicLabel *welcomeLabel;
%property (nonatomic, strong) ARIDynamicBackgroundView *_atriaBackground;
%property (nonatomic, strong) UITapGestureRecognizer *_atriaTap;

%new
- (void)_atriaBeginEditing
{
	[[NSNotificationCenter defaultCenter]
        	postNotificationName:@"me.ren7995.atria.edit"
                      object:self
                    userInfo:nil];
}

%new
- (void)_updateWelcomeLabelWithPageBeingFirst:(BOOL)isFirst
{
	// Icon count will be zero when editing pages
	if([[self icons] count] == 0) return;
	BOOL showWelcome = [[ARITweak sharedInstance] boolValueForKey:@"showWelcome"];

	// Remove if we don't need it
	if(self.welcomeLabel && (!isFirst || !showWelcome))
	{
		[self.welcomeLabel removeFromSuperview];
		self.welcomeLabel = nil;
	}

	// All past this point, index should be 0. Return if not
	if(!isFirst || !showWelcome) return;

	// Create label if needed
	if(!self.welcomeLabel)
	{
		self.welcomeLabel = [[ARIWelcomeDynamicLabel alloc] init];
	}

	// Add to superview and add inital anchors
	// The dynamic label will constrain itself
	if(!self.welcomeLabel.superview)
	{
		[self addSubview:self.welcomeLabel];
	}

	// Update anchors dynamically without need to recreate
	[self.welcomeLabel _updateLabel];
}

%new 
- (void)_updateAtriaBackground
{
	BOOL showBackground = [[ARITweak sharedInstance] boolValueForKey:@"showBackground"];
	if(self._atriaBackground && (!showBackground || [self.icons count] == 0))
	{
		[self._atriaBackground removeFromSuperview];
		self._atriaBackground = nil;
	}

	if(!showBackground || [self.icons count] == 0) return;

	if(!self._atriaBackground)
	{
		self._atriaBackground = [[ARIDynamicBackgroundView alloc] init];
	}

	if(!self._atriaBackground.superview)
	{
		[self insertSubview:self._atriaBackground atIndex:0];
	}
	[self sendSubviewToBack:self._atriaBackground];

	[self._atriaBackground _updateView];
}

- (SBIconListFlowExtendedLayout *)layout
{
	SBIconListFlowExtendedLayout *orig = %orig;
	ARITweak *manager = [ARITweak sharedInstance];
	if(![[manager allRootListViews] containsObject:self] && kIconListIsRoot(self)) return orig;

	// Update layout
	if(kIconListIsRoot(self))
	{

		// Add tap gesture if we didn't already. Do this here to enable/disable dynamically
		if(!self._atriaTap && ![manager boolValueForKey:@"disableTapGesture"])
		{
			self._atriaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_atriaBeginEditing)];
			[self._atriaTap setNumberOfTapsRequired:3];
			[self addGestureRecognizer:self._atriaTap];
		}
		else if(self._atriaTap && [manager boolValueForKey:@"disableTapGesture"])
		{
			[self removeGestureRecognizer:self._atriaTap];
			self._atriaTap = nil;
		}

		// Per-page layout requires copying this object
		SBIconListGridLayoutConfiguration *gridConfig = [orig.layoutConfiguration copy];
		NSUInteger rows = [manager intValueForKey:@"hs_rows" forListView:self];
		NSUInteger cols = [manager intValueForKey:@"hs_columns" forListView:self];

		BOOL isFirst = [manager firstIconListView] == self;
		CGFloat firstListOffset = 0;
		if(isFirst && [manager boolValueForKey:@"showWelcome"]) firstListOffset = 60;

		// Set row count initially
		if(![[ARITweak sharedInstance] rawValueForKey:@"hs_rows"])
		{
			[[ARITweak sharedInstance] setValue:@(gridConfig.numberOfPortraitRows) forKey:@"hs_rows"];
		}

		if(gridConfig.numberOfPortraitRows != rows)
			[gridConfig setNumberOfPortraitRows:rows];
		if(gridConfig.numberOfPortraitColumns != cols)
			[gridConfig setNumberOfPortraitColumns:cols];
		if(gridConfig.numberOfLandscapeRows != rows)
			[gridConfig setNumberOfLandscapeRows:rows];
		if(gridConfig.numberOfLandscapeColumns != cols)
			[gridConfig setNumberOfLandscapeColumns:cols];

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

		// Set layout insets
		UIEdgeInsets origPortrait = gridConfig.portraitLayoutInsets;
		UIEdgeInsets portraitInsets = UIEdgeInsetsMake(
			origPortrait.top + topInset + topOffset + firstListOffset,
			origPortrait.left + leftInset + leftOffset,
			origPortrait.bottom + bottomInset - topOffset,
			origPortrait.right + rightInset - leftOffset
		);
		self.welcomeLabel.startingLabelXPos = portraitInsets.left;
		// Make final insets with adjustments for icon spacing
		[gridConfig setPortraitLayoutInsets:UIEdgeInsetsMake(
			portraitInsets.top - spaceY/2,
			portraitInsets.left - spaceX/2,
			portraitInsets.bottom - spaceY/2,
			portraitInsets.right - spaceX/2
		)];

		// Landscape insets
		UIEdgeInsets origLandscape = gridConfig.landscapeLayoutInsets;
		UIEdgeInsets landscapeInsets = UIEdgeInsetsMake(
			origLandscape.top + topInset + topOffset + firstListOffset,
			origLandscape.left + leftInset + leftOffset,
			origLandscape.bottom + bottomInset - topOffset,
			origLandscape.right + rightInset - leftOffset
		);
		self.welcomeLabel.startingLabelXPosLandscape = landscapeInsets.left;
		[gridConfig setLandscapeLayoutInsets:UIEdgeInsetsMake(
			landscapeInsets.top - spaceY/2,
			landscapeInsets.left - spaceX/2,
			landscapeInsets.bottom - spaceY/2,
			landscapeInsets.right - spaceX/2
		)];

		// Update background if needed
		if((!UIEdgeInsetsEqualToEdgeInsets(landscapeInsets, self._atriaBackground.landscapeInsets) || 
			!UIEdgeInsetsEqualToEdgeInsets(portraitInsets, self._atriaBackground.portraitInsets))
			&& [manager boolValueForKey:@"showBackground"])
		{
			self._atriaBackground.landscapeInsets = landscapeInsets;
			self._atriaBackground.portraitInsets = portraitInsets;
			[self _updateAtriaBackground];
		}

		// Update label if needed
		if((self.welcomeLabel.startingLabelYPos != origPortrait.top ||
			self.welcomeLabel.startingLabelYPosLandscape != origLandscape.top)
			&& [manager boolValueForKey:@"showWelcome"])
		{
			self.welcomeLabel.startingLabelYPos = origPortrait.top;
			self.welcomeLabel.startingLabelYPosLandscape = origLandscape.top;
			BOOL isFirst = [[ARITweak sharedInstance] firstIconListView] == self;
			[self _updateWelcomeLabelWithPageBeingFirst:isFirst];
		}

		// Create a new flow layout with our modified (and copied) configuration
		// layoutConfiguration is readonly on SBIconListFlowExtendedLayout
		if([manager firmware14])
		{
			return [[objc_getClass("SBIconListFlowExtendedLayout") alloc] initWithLayoutConfiguration:gridConfig];
		}
		else
		{
			// SBIconListFlowExtendedLayout does not exist on 13
			return [[objc_getClass("SBIconListFlowLayout") alloc] initWithLayoutConfiguration:gridConfig];
		}
	}
	else if(kIconListIsDock(self))
	{
		SBIconListGridLayoutConfiguration *gridConfig = orig.layoutConfiguration;

		NSUInteger cols = [manager intValueForKey:@"dock_columns"];
		NSUInteger rows = [manager intValueForKey:@"dock_rows"];
		if(gridConfig.numberOfPortraitColumns != cols)
			[gridConfig setNumberOfPortraitColumns:cols];
		if(gridConfig.numberOfLandscapeColumns != cols)
			[gridConfig setNumberOfLandscapeColumns:cols];
		if(gridConfig.numberOfPortraitRows != rows)
			[gridConfig setNumberOfPortraitRows:rows];
		if(gridConfig.numberOfLandscapeRows != cols)
			[gridConfig setNumberOfLandscapeRows:rows];

		if(manager.firmware14)
		{
			self.additionalLayoutInsets = UIEdgeInsetsMake(
				[manager floatValueForKey:@"dock_inset_top"],
				[manager floatValueForKey:@"dock_inset_left"],
				[manager floatValueForKey:@"dock_inset_bottom"],
				[manager floatValueForKey:@"dock_inset_right"]
			);
		}
		else
		{
			// TODO: Check if this works on 13
			self.layoutInsets = UIEdgeInsetsMake(
				[manager floatValueForKey:@"dock_inset_top"],
				[manager floatValueForKey:@"dock_inset_left"],
				[manager floatValueForKey:@"dock_inset_bottom"],
				[manager floatValueForKey:@"dock_inset_right"]
			);
		}

		// We don't need to copy our grid config for dock, so return
		// original object now that we've modified the layout
		return orig;
	}

	return orig;
}

- (void)layoutIconsNow
{
	%orig;
	if(kIconListIsRoot(self))
	{
		[self _updateAtriaBackground];
		BOOL isFirst = [[ARITweak sharedInstance] firstIconListView] == self;
		[self _updateWelcomeLabelWithPageBeingFirst:isFirst];
	}
}

- (CGSize)iconSpacing
{
	CGSize spacing = %orig;
	if(kIconListIsDock(self))
	{
		ARITweak *manager = [ARITweak sharedInstance];
		CGFloat spaceX = [manager floatValueForKey:@"dock_spacing_x"];
		CGFloat spaceY = [manager floatValueForKey:@"dock_spacing_y"];
		// I divide by 2 to keep it consistent with behavior of root
		return CGSizeMake(spacing.width + spaceX/2, spacing.height + spaceY/2);
	}
	return spacing;
}

- (BOOL)automaticallyAdjustsLayoutMetricsToFit
{
	// automaticallyAdjustsLayoutMetricsToFit makes the icons auto scale
	// and automatically lay themselves out. We don't want this.

	if(kIconListIsRoot(self) || kIconListIsDock(self)) return NO;
	return %orig;
}

%end

// Layout provider hook
%hook SBHDefaultIconListLayoutProvider

- (SBIconListFlowExtendedLayout *)layoutForIconLocation:(NSString *)location
{
	SBIconListFlowExtendedLayout *orig = %orig;
	// We override the original class for root, unless we are the subclass
	if([location isEqualToString:@"SBIconLocationRoot"] && ![self isMemberOfClass:objc_getClass("ARIAppLibraryIconListLayoutProvider")])
	{
		ARITweak *manager = [ARITweak sharedInstance];
		if(!manager.didLoad)
		{
			// This doesn't work great if per page layout is enabled for the current page, but 
			// we can't override per page... This means widget drop location calculations don't work great for
			// per-page layout pages

			// I have tried overriding this per page by hooking SBIconListView's layout provider,
			// but it doesn't fix our issue. SpringBoard pages are not intended to have different layouts.
			// The only reason it was working before was due to our hacky visibleColumns hook.

			// This option allows for more freedom in moving widgets, and ensures they won't get cut off on page boundaries.
			// However, it DOES mean per-page layout kinda breaks. I have found out that as long as this is
			// set, we can return a greater value at a later point in time and widget positioning still works, as
			// well as per-page layout. The only caveat is that this behavior is unavoidable: we can't update
			// the rows/columns for drop calculations once SB launches (with this approach) 

			// Because of this behavior, a respring is needed after changing columns in order for SpringBoard's
			// widget drop location calculations to work properly. This is behavior regardless if I set 0x7F later,
			// or continue setting the columns/rows. This isn't something I can avoid, really

			NSUInteger rows = [manager intValueForKey:@"hs_rows"];
			NSUInteger cols = [manager intValueForKey:@"hs_columns"];
			[orig.layoutConfiguration setNumberOfPortraitRows:rows];
			[orig.layoutConfiguration setNumberOfPortraitColumns:cols];
			[orig.layoutConfiguration setNumberOfLandscapeRows:rows];
			[orig.layoutConfiguration setNumberOfLandscapeColumns:cols];
		}
		else
		{
			// THIS code makes for a more restrictive widget positioning options (if set on SB launch, which we don't),
			// but makes it so per-page layout works without the need for visible column hacks, etc

			// If we set this after springboard launches, all works fine. Widget positioning works,
			// and visible columns works fine! I would assume nobody would set their rows and columns over
			// 0x7F, so this should work pretty damn well. 
			[orig.layoutConfiguration setNumberOfPortraitRows:0x7F];
			[orig.layoutConfiguration setNumberOfPortraitColumns:0x7F];
			[orig.layoutConfiguration setNumberOfLandscapeRows:0x7F];
			[orig.layoutConfiguration setNumberOfLandscapeColumns:0x7F];
		}
	}
	else if([location isEqualToString:@"SBIconLocationDock"])
	{
		// Fix dock layout. This is needed
		ARITweak *manager = [ARITweak sharedInstance];
		NSUInteger cols = [manager intValueForKey:@"dock_columns"];
		NSUInteger rows = [manager intValueForKey:@"dock_rows"];
		[orig.layoutConfiguration setNumberOfPortraitColumns:cols];
		[orig.layoutConfiguration setNumberOfLandscapeColumns:cols];
		[orig.layoutConfiguration setNumberOfPortraitRows:rows];
		[orig.layoutConfiguration setNumberOfLandscapeRows:rows];
	}
	return orig;
}

%end

// Version specific - will crash on 13 due to method signature changes and ARC trying to
// retain a non-object
%group Widgets14

%hook SBIconListView
- (CGPoint)originForIconAtCoordinate:(SBIconCoordinate)co metrics:(id)metrics
{
	// This is sooo hacky but it *works*
	// yayy~

	CGPoint orig = %orig;
	id icon = [self iconAtCoordinate:co metrics:metrics];
	if([icon isKindOfClass:objc_getClass("SBWidgetIcon")] && kIconListIsRoot(self))
	{
		// Get width and height of widget icon
		SBHIconGridSize gridSize = [self iconGridSizeForClass:[icon gridSizeClass]];
		// Get CGSize as well
		CGSize widgetSize = [self iconImageSizeForGridSizeClass:[icon gridSizeClass]];

		// Attempt to find origin of icon below widget.
		SBIconCoordinate modified = co;
		// Go off the grid on purpose to make sure we don't hit another widget
		// This does work, it doesn't crash, for which I am greatful.
		modified.row += 30; 

		CGPoint belowWidgetIconOrigin = [self originForIconAtCoordinate:modified metrics:metrics];
		// Now we have a valid starting point for our widget
		CGFloat iconSpacing = [self effectiveIconSpacing].width;
		// Icon grid size 0 is regular icon
		CGFloat sizeInBetween = [self iconImageSizeForGridSizeClass:0].width * gridSize.width;
		// Add spacing
		sizeInBetween += iconSpacing * (gridSize.width - 1);

		// Add half the remainder of space the widget won't fill (equal padding)
		// to the original icon origin
		CGFloat remainder = sizeInBetween - widgetSize.width;
		CGFloat startX = belowWidgetIconOrigin.x + (remainder / 2);

		ARITweak *manager = [ARITweak sharedInstance];
		CGPoint calc = CGPointMake(
			startX + [manager floatValueForKey:@"hs_widgetXOffset" forListView:self],
			orig.y + [manager floatValueForKey:@"hs_widgetYOffset" forListView:self]
		);
		return calc;
	}
	return orig;
}

%end

%end

static void preferencesChanged()
{
    [[ARITweak sharedInstance] updateLayoutForRoot:YES forDock:YES animated:YES];
}

%ctor
{
	if([ARITweak sharedInstance].enabled && [[ARITweak sharedInstance] boolValueForKey:@"layoutEnabled"])
	{
		NSLog(@"Atria loading hooks from %s", __FILE__);
		%init();

		if([[ARITweak sharedInstance] firmware14])
		{
			%init(Widgets14);
		}

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
