//
// Created by ren7995 on 2023-01-05 15:47:33
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import "Shared.h"
#import "../Manager/ARITweakManager.h"
#import <substrate.h>

// Small macro to round to nearest short assuming x is positive
#define ROUND_SHORT(x) (short)(x + 0.5)

// Function to calculate the widget grid sizes to be appropriate for the amount of columns and rows
// Messy math
static struct SBHIconGridSizeClassSizes generateGridSizeClassSizes(double cols, double rows, BOOL landscape) {
	struct SBHIconGridSizeClassSizes sizes = {};
	if([[ARITweakManager sharedInstance] isDeviceIPad]) {
		// Usually 1x1, 2x1, 2x2, 2x3
		if (landscape) {
			// Use rows to calculate widths and columns to calculate height since it is inverted
			sizes.small = (struct SBHIconGridSize) { .width = ROUND_SHORT(rows / 6), .height = ROUND_SHORT(cols / 4) };
			sizes.medium = (struct SBHIconGridSize) { .width = ROUND_SHORT(rows / 3), .height = ROUND_SHORT(cols / 4) };
			sizes.large = (struct SBHIconGridSize) { .width = ROUND_SHORT(rows / 3), .height = ROUND_SHORT(cols / 2) };
			sizes.extraLarge = (struct SBHIconGridSize) { .width = ROUND_SHORT(rows / 3), .height = ROUND_SHORT(cols / 1.5) };
		} else {
			sizes.small = (struct SBHIconGridSize) { .width = ROUND_SHORT(cols / 4), .height = ROUND_SHORT(rows / 5) };
			sizes.medium = (struct SBHIconGridSize) { .width = ROUND_SHORT(cols / 2), .height = ROUND_SHORT(rows / 5) };
			sizes.large = (struct SBHIconGridSize) { .width = ROUND_SHORT(cols / 2), .height = ROUND_SHORT(rows / 3) };
			sizes.extraLarge = (struct SBHIconGridSize) { .width = ROUND_SHORT(cols / 2), .height = ROUND_SHORT(rows / 1.5) };
		}
	} else {
		// Usually 2x2, 4x2, 4x4, 4x6
		sizes.small = (struct SBHIconGridSize) { .width = ROUND_SHORT(cols / 2), .height = ROUND_SHORT(rows / 3) };
		sizes.medium = (struct SBHIconGridSize) { .width = cols, .height = ROUND_SHORT(rows / 3) };
		sizes.large = (struct SBHIconGridSize) { .width = cols, .height = ROUND_SHORT(rows * 2 / 3) };
		sizes.extraLarge = (struct SBHIconGridSize) { .width = cols, .height = rows };
	}
	return sizes;
}

// List model hook
%hook SBIconListModel
%property (nonatomic, strong) NSString *_atriaLocation;

%new 
- (SBIconListView *)_atriaListView {
	return [[ARITweakManager sharedInstance].listViewModelMap objectForKey:self];
}

%new
- (void)_atriaUpdateModelGridSizes {
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	if([manager firmwareVersion] < 14 || !self._atriaLocation || !IsLocationRoot(self._atriaLocation)) return;

	struct SBHIconGridSize gridSize = [self gridSize];
	// Get the number of columns and rows for the associated list view
	// This allows different pages to have differently sized widgets!
	NSUInteger cols = [manager intValueForKey:@"hs_columns" forListView:[self _atriaListView]];
	NSUInteger rows = [manager intValueForKey:@"hs_rows" forListView:[self _atriaListView]];

	// Update grid size
	gridSize.height = rows;
	gridSize.width = cols;
	// setGridSize method only exists on iOS 15+, but the ivar exists on 14 too
	MSHookIvar<struct SBHIconGridSize>(self, "_gridSize") = gridSize;

	// Update grid size class sizes
	if([manager boolValueForKey:@"dynamicWidgetSizing"]) {
		MSHookIvar<struct SBHIconGridSizeClassSizes>(self, "_gridSizeClassSizes") = 
			generateGridSizeClassSizes(cols, rows, UIInterfaceOrientationIsLandscape([ARITweakManager currentDeviceOrientation]));
	}
}

- (struct SBHIconGridSize)gridSize {
	if(!self._atriaLocation) {
		struct SBHIconGridSize size = { .height = 0x7FFF, .width = 0x7FFF };
		return size;
	}
	// If location is already set, size should have been modified as needed
	return %orig;
}

- (NSUInteger)maxNumberOfIcons {
	// Fix icon limit
	if(!self._atriaLocation) {
		// This is done so that icons are not pushed off the page
		return NSUIntegerMax;
	}

	return %orig;
}

- (NSUInteger)numberOfFreeSlots {
	if(!self._atriaLocation || IsLocationRoot(self._atriaLocation)) {
		// This is done so that icons are not pushed off the page
		return NSUIntegerMax;
	}
	return %orig;
}

%end

// Version specific hooks for widget support
%group Widgets14

%hook SBIconListView

// Will crash on iOS 13 due to method signature changes and ARC trying to retain a non-object
// This hook is to center widgets in their available grid space. By default, they align with the left
// side of the space, which isn't desirable when the layout gets changed. This hook injects our own
// icon origin calculation method that is designed to work outside of the default layout.
- (CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)co metrics:(SBIconListViewLayoutMetrics *)metrics {
	CGPoint orig = %orig;

	SBIcon *icon = [self iconAtCoordinate:co metrics:metrics];
	if([icon isKindOfClass:objc_getClass("SBWidgetIcon")] && IconListIsRoot(self)) {
		ARITweakManager *manager = [ARITweakManager sharedInstance];
		NSUInteger iconGridSizeClass = [icon gridSizeClass];
		// This is the actual widget icon display size
		CGSize iconImageSize = [self iconImageSizeForGridSizeClass:iconGridSizeClass];
		// Spacing between icons on the page
		CGSize iconSpacing = [self effectiveIconSpacing];
		// The width that a single icon will take up (plus spacing)
		CGFloat columnWidth = metrics.alignmentIconSize.width + iconSpacing.width;

		// This is the space that we have available to center the widget in
		CGFloat spaceForWidget = columnWidth * [self iconGridSizeForClass:iconGridSizeClass].width;
		// Apple reordered the fields of the struct for iOS 16
		NSUInteger column = [manager firmwareVersion] >= 16 ? co.row : co.col;
		// Calculate horizontal space before the widget on the page (hence the column - 1)
		CGFloat spaceBeforeWidget = columnWidth * (column - 1) - iconSpacing.width / 2.0F;
		// Calculate icon origin using metrics and calculated spacing
		// Ensures the widget has equal horizontal spacing on both sides
		CGFloat originX = metrics.iconInsets.left + spaceBeforeWidget + (spaceForWidget - iconImageSize.width) / 2.0F;

		return CGPointMake(
		 	originX + [manager floatValueForKey:@"hs_widgetXOffset" forListView:self],
			orig.y + [manager floatValueForKey:@"hs_widgetYOffset" forListView:self]
		);
	}
	return orig;
}

// This hook forces the list view to respect the adjusted grid size of the widgets
- (struct SBHIconGridSize)iconGridSizeForClass:(NSUInteger)arg1 {
	if(!IconListIsRoot(self)) return %orig;

	// Determine if we need to override the grid sizes
	// Size 0 is a 1x1 icon (not a widget)
	if(![[ARITweakManager sharedInstance] boolValueForKey:@"dynamicWidgetSizing"] || arg1 == 0) return %orig;
	return [[self model] gridSizeForGridSizeClass:arg1];
}

%end

%end

%group IconListModelFix14

%hook SBIconListModel

// Unfortunately, the gridSizeForGridSizeClass method on SBIconListModel only exists on iOS 15+
// On iOS 14, we add this method to make it work across versions

%new
- (struct SBHIconGridSize)gridSizeForGridSizeClass:(NSUInteger)arg1 {
	struct SBHIconGridSizeClassSizes gridSizes = [self iconGridSizeClassSizes];
	switch (arg1) {
		case 1:
		return gridSizes.small;
		case 2:
		return gridSizes.medium;
		case 3:
		return gridSizes.large;
		case 4:
		return gridSizes.extraLarge;
		default:
		struct SBHIconGridSize defaultSize;
		return defaultSize;
	}
}

%end

%end

%ctor {
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	if([manager isEnabled] && [manager boolValueForKey:@"layoutEnabled"]) {
		NSLog(@"[Atria]: Loading hooks from %s", __FILE__);

        %init();

		if([manager firmwareVersion] >= 14) {
			if([manager firmwareVersion] < 15) {
				%init(IconListModelFix14);
			}
			%init(Widgets14);
        }
	}
}
