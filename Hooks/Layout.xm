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

@interface SBIconListGridLayoutConfiguration : NSObject
@property (nonatomic, readwrite, assign) NSUInteger numberOfPortraitColumns;
@property (nonatomic, readwrite, assign) NSUInteger numberOfPortraitRows;
@property (nonatomic, readwrite, assign) NSUInteger numberOfLandscapeColumns;
@property (nonatomic, readwrite, assign) NSUInteger numberOfLandscapeRows;
@property (nonatomic, readwrite, assign) UIEdgeInsets portraitLayoutInsets;
@property (nonatomic, readwrite, assign) UIEdgeInsets landscapeLayoutInsets;
@end

@interface SBIconListFlowExtendedLayout : NSObject
@property (nonatomic, strong) SBIconListGridLayoutConfiguration *layoutConfiguration;
- (id)initWithLayoutConfiguration:(SBIconListGridLayoutConfiguration *)config;
@end

@interface SBIconListGridLayout : NSObject
@property (nonatomic, strong) SBIconListGridLayoutConfiguration *layoutConfiguration;
@end

@interface SBIconListViewLayoutMetrics : NSObject
@property (nonatomic, readwrite, assign) NSUInteger columns;
@property (nonatomic, readwrite, assign) NSUInteger rows;
@end

@interface SBIconScrollView : UIScrollView
- (BOOL)isScrolling;
@end

%hook SBIconListView
%property (nonatomic, strong) ARIWelcomeDynamicLabel *welcomeLabel;
%property (nonatomic, strong) ARIDynamicBackgroundView *_atriaBackground;

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
	if(self._atriaBackground && !showBackground)
	{
		[self._atriaBackground removeFromSuperview];
		self._atriaBackground = nil;
	}

	if(!showBackground) return;

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

- (SBIconListFlowExtendedLayout *)layout {
	SBIconListFlowExtendedLayout *orig = %orig;

	// Tell our model what it's representing
	SBIconListModel *model = [self model];
	if(!model._atriaLocation) model._atriaLocation = self.iconLocation;
	[[ARITweak sharedInstance].listViewModelMap setObject:self forKey:model];

	if(kIconListIsRoot(self))
	{
		SBIconListGridLayoutConfiguration *old = orig.layoutConfiguration;

		// This is literally the one line that fixes all app library issues
		// Copying it so it's not the one associated with SBHDefaultIconListLayoutProvider
		// Technically per-iconlist layout is possible with this
		SBIconListGridLayoutConfiguration *gridConfig = [old copy];

		ARITweak *manager = [ARITweak sharedInstance];
		NSUInteger rows = [manager intValueForKey:@"hs_rows" forListView:self];
		NSUInteger cols = [manager intValueForKey:@"hs_columns" forListView:self];

		BOOL isFirst = [manager firstIconListView] == self;
		CGFloat firstListOffset = 0;
		if(isFirst && [manager boolValueForKey:@"showWelcome"]) firstListOffset = 60;

		// Set row count initially
		if(![[ARITweak sharedInstance].preferences objectForKey:@"hs_rows"])
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

		// Set layout insets
		UIEdgeInsets original = gridConfig.portraitLayoutInsets;
		self.welcomeLabel.startingLabelYPos = original.top;
		UIEdgeInsets portraitInsets = UIEdgeInsetsMake(
			original.top + topInset + topOffset + firstListOffset,
			original.left + leftInset + leftOffset,
			original.bottom + bottomInset - topOffset,
			original.right + rightInset - leftOffset
		);
		self.welcomeLabel.startingLabelXPos = portraitInsets.left;
		self._atriaBackground.portraitInsets = portraitInsets;
		[gridConfig setPortraitLayoutInsets:portraitInsets];

		original = gridConfig.landscapeLayoutInsets;
		self.welcomeLabel.startingLabelYPosLandscape = original.top;
		UIEdgeInsets landscapeInsets = UIEdgeInsetsMake(
			original.top + topInset + topOffset + firstListOffset,
			original.left + leftInset + leftOffset,
			original.bottom + bottomInset - topOffset,
			original.right + rightInset - leftOffset
		);
		self.welcomeLabel.startingLabelXPosLandscape = landscapeInsets.left;
		self._atriaBackground.landscapeInsets = landscapeInsets;
		[gridConfig setLandscapeLayoutInsets:landscapeInsets];

		// Update welcome label and BG. Done here so it gets called when -layoutIconsNow
		// is. This allows us to make it easy to update dynamically
		[self _updateWelcomeLabelWithPageBeingFirst:isFirst];
		[self _updateAtriaBackground];

		// Create a new flow layout with our modified (and copied) configuration
		// layoutConfiguration is readonly on SBIconListFlowExtendedLayout
		return [[objc_getClass("SBIconListFlowExtendedLayout") alloc] initWithLayoutConfiguration:gridConfig];
	}
	else if(kIconListIsDock(self))
	{
		SBIconListGridLayoutConfiguration *gridConfig = orig.layoutConfiguration;

		ARITweak *manager = [ARITweak sharedInstance];
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

		// We can just add
		self.additionalLayoutInsets = UIEdgeInsetsMake(
			[manager floatValueForKey:@"dock_inset_top"],
			[manager floatValueForKey:@"dock_inset_left"],
			[manager floatValueForKey:@"dock_inset_bottom"],
			[manager floatValueForKey:@"dock_inset_right"]
		);

		// We don't need to copy our grid config for dock, so return
		// original object now that we've modified the layout
		return orig;
	}

	return orig;
}

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

- (BOOL)automaticallyAdjustsLayoutMetricsToFit
{
	// automaticallyAdjustsLayoutMetricsToFit makes the icons auto scale
	// and automatically lay themselves out. We don't want this.

	if(kIconListIsRoot(self) || kIconListIsDock(self)) return NO;
	return %orig;
}

// iOS 14-14.5 (doesn't exist on higher versions)
- (void)setVisibleColumnRange:(NSRange)range predictedVisibleColumn:(SBIconListPredictableGeneric)col visibleRowRange:(NSRange)rowRange
{
	// Essentially what I'm trying to do is force the range of showing columns to *not*
	// cut off at 4 when scrolling. This does not break the icon "pausing", so it doesn't
	// completely jank up memory (luckily) when we aren't scrolling

	// The most it could cause to show at once is 2 full pages
	// This will also fix the icon disappearing issue with the "Central" tweak

	// If we aren't the current page, and scrolling isn't happening, we don't let any columns show
	// The fact I have to do this is a sign I broke something else

	SBIconScrollView *scroll = (SBIconScrollView *)self.superview;
	if(kIconListIsRoot(self) && scroll && [scroll isKindOfClass:objc_getClass("SBIconScrollView")])
	{
		if(![scroll isScrolling])
		{
			SBIconListView *current = [[ARITweak sharedInstance] currentListView];
			// If not current and not scrolling, hide all icons
			if(current != self)
			{
				%orig(NSMakeRange(0, 0), col, NSMakeRange(0, 0));
				return;
			}
		}

		// Perform hacked math if scrolling or current icon list view
		%orig(
			NSMakeRange(range.location, 0xFFFFFFFFFFFFFFFF),
			col,
			rowRange
		);
		return;
	}

	%orig(range, col, rowRange);
}

// iOS 14.6+ (doesn't exist below)
- (void)setVisibleColumnRange:(NSRange)range predictedVisibleColumn:(SBIconListPredictableGeneric)col visibleRowRange:(NSRange)rowRange predictedVisibleRow:(SBIconListPredictableGeneric)row
{
	// Same code as above
	SBIconScrollView *scroll = (SBIconScrollView *)self.superview;
	if(kIconListIsRoot(self) && scroll && [scroll isKindOfClass:objc_getClass("SBIconScrollView")])
	{
		if(![scroll isScrolling])
		{
			SBIconListView *current = [[ARITweak sharedInstance] currentListView];
			if(current != self)
			{
				%orig(NSMakeRange(0, 0), col, NSMakeRange(0, 0), row);
				return;
			}
		}
		%orig(
			NSMakeRange(range.location, 0xFFFFFFFFFFFFFFFF),
			col,
			rowRange,
			row
		);
		return;
	}
	%orig(range, col, rowRange, row);
}

// Unused (?)
- (void)setVisibleColumnRange:(NSRange)range
{
	SBIconScrollView *scroll = (SBIconScrollView *)self.superview;
	if(kIconListIsRoot(self) && scroll && [scroll isKindOfClass:objc_getClass("SBIconScrollView")])
	{
		if(![scroll isScrolling])
		{
			SBIconListView *current = [[ARITweak sharedInstance] currentListView];
			// If not current and not scrolling, hide all icons
			if(current != self)
			{
				%orig(NSMakeRange(0, 0));
				return;
			}
		}

		// Perform hacked math if scrolling or current icon list view
		%orig(NSMakeRange(range.location, 0xFFFFFFFFFFFFFFFF));
		return;
	}

	%orig(range);
}

%end

%hook SBIconListModel
%property (nonatomic, strong) NSString *_atriaLocation;

%new 
- (SBIconListView *)_atriaListView
{
	return [[ARITweak sharedInstance].listViewModelMap objectForKey:self];
}

- (SBHIconGridSize)gridSize
{
	// Fix icon limit. Yes, this is needed with our approach
	SBHIconGridSize size = %orig;
	if(!self._atriaLocation)
	{
		size.height = 0x7FFF;
		size.width = 0x7FFF;
	}
	else if([self._atriaLocation isEqualToString:@"SBIconLocationRoot"])
	{
		// Set to upper limit while we don't know location, or we are root
		ARITweak *manager = [ARITweak sharedInstance];
		size.height = [manager intValueForKey:@"hs_rows" forListView:[self _atriaListView]];
		size.width = [manager intValueForKey:@"hs_columns" forListView:[self _atriaListView]];
	}
	else if([self._atriaLocation isEqualToString:@"SBIconLocationDock"])
	{
		ARITweak *manager = [ARITweak sharedInstance];
		NSUInteger rows = [manager intValueForKey:@"dock_rows"];
		NSUInteger cols = [manager intValueForKey:@"dock_columns"];
		size.height = rows;
		size.width = cols;
	}
	return size;
}

- (NSUInteger)maxNumberOfIcons
{
	// Fix icon limit
	if(!self._atriaLocation)
	{
		// Set to upper limit while we don't know location
		return 0xFFFFFFFFFFFFFFFF;
	}
	else if([self._atriaLocation isEqualToString:@"SBIconLocationRoot"])
	{
		ARITweak *manager = [ARITweak sharedInstance];
		NSUInteger rows = [manager intValueForKey:@"hs_rows" forListView:[self _atriaListView]];
		NSUInteger cols = [manager intValueForKey:@"hs_columns" forListView:[self _atriaListView]];
		return rows * cols;
	}
	else if([self._atriaLocation isEqualToString:@"SBIconLocationDock"])
	{
		ARITweak *manager = [ARITweak sharedInstance];
		NSUInteger rows = [manager intValueForKey:@"dock_rows"];
		NSUInteger cols = [manager intValueForKey:@"dock_columns"];
		return rows * cols;
	}

	return %orig;
}

- (NSUInteger)numberOfFreeSlots
{
	if([self._atriaLocation isEqualToString:@"SBIconLocationRoot"])
	{
		ARITweak *manager = [ARITweak sharedInstance];
		NSUInteger rows = [manager intValueForKey:@"hs_rows" forListView:[self _atriaListView]];
		NSUInteger cols = [manager intValueForKey:@"hs_columns" forListView:[self _atriaListView]];
		return [self numberOfNonPlaceholderIcons] - (rows * cols);
	}
	return %orig;
}

/*
- (BOOL)isGridLayoutValid
{
	return YES;
}*/

%end

static void preferencesChanged()
{
    [[ARITweak sharedInstance] updateLayoutAnimated:YES];
}

%ctor
{
	if([ARITweak sharedInstance].enabled && [[ARITweak sharedInstance] boolValueForKey:@"layoutEnabled"])
	{
		NSLog(@"Atria loading hooks from %s", __FILE__);
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
