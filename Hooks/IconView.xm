//
// Created by ren7995 on 2021-04-25 12:49:37
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Hooks/Shared.h"
#import "src/ARITweak.h"
#import "src/ARIEditManager.h"

@interface SBSApplicationShortcutIcon : NSObject
@end

@interface SBSApplicationShortcutItem : NSObject
@property (nonatomic, retain) NSString *type;
@property (nonatomic, copy) NSString *localizedTitle;
@property (nonatomic, copy) SBSApplicationShortcutIcon *icon;
@property (nonatomic, copy) NSString *bundleIdentifierToLaunch;
- (void)setIcon:(SBSApplicationShortcutIcon *)arg1;
@end

@interface SBSApplicationShortcutCustomImageIcon : SBSApplicationShortcutIcon
@property (nonatomic, readwrite) BOOL isTemplate;   
- (id)initWithImagePNGData:(id)arg1;
- (BOOL)isTemplate;
@end

@interface SBIconView : UIView
@property (nonatomic, strong) SBIconListView *_atriaLastIconListView;
@property (nonatomic, strong) id icon;
@property (nonatomic, assign) BOOL allowsLabelArea;
@property (nonatomic, assign) CGFloat iconContentScale;
@property (nonatomic, assign) CGFloat iconLabelAlpha;
@property (nonatomic, assign, getter=isIconContentScalingEnabled) BOOL iconContentScalingEnabled;
@property (nonatomic, strong) NSString *location;
- (BOOL)isFolderIcon;
- (void)_updateIconImageViewAnimated:(BOOL)arg1;
- (void)_atriaUpdateIconContentScale;
- (SBSApplicationShortcutItem *)_atriaGenerateItemWithTitle:(NSString *)title type:(NSString *)type;
@end

%hook SBIconView
// Weak is not supported by logos -_-
// I hope this doesn't cause issues
%property (nonatomic, strong) SBIconListView *_atriaLastIconListView;

- (CGFloat)iconContentScale
{
	// Fixes folder icon bug on open
	CGFloat orig = %orig;
	if(kIconIsInRoot(self) && [self isFolderIcon])
	{
		return [[ARITweak sharedInstance] floatValueForKey:@"hs_iconScale" forListView:self._atriaLastIconListView];
	}
	return orig;
}

- (void)_updateLabelArea {
    %orig;

	ARITweak *manager = [ARITweak sharedInstance];
	if(kIconIsInRoot(self) || kIconIsInAppLibraryExpanded(self))
	{
    	if([manager boolValueForKey:@"hideLabels"]) self.allowsLabelArea = NO;
	}
	else if(kIconIsInAppLibrary(self))
	{
		if([manager boolValueForKey:@"hideLabelsAppLibrary"]) self.allowsLabelArea = NO;
	}
	else if(kIconIsInFolder(self))
	{
		if([manager boolValueForKey:@"hideLabelsFolders"]) self.allowsLabelArea = NO;
	}
}

- (void)_updateIconImageViewAnimated:(BOOL)arg1
{
	%orig(arg1);
	[self _atriaUpdateIconContentScale];
}

- (void)setIconContentScale:(CGFloat)scale
{
	%orig(scale);
	[self _atriaUpdateIconContentScale];
}

// Neat little trick I learned with %new
// WARNING TO FUTURE SELF: don't spend another hour
// just forgetting the %new
%new
- (void)_atriaUpdateIconContentScale
{
	// Reset icon content scale
	ARITweak *manager = [ARITweak sharedInstance];

	if(!(kIconIsInDock(self) || kIconIsInRoot(self)))
	{
		self.layer.sublayerTransform = CATransform3DMakeScale(1, 1, 1);
		return;
	}

	CGFloat customScale = 1;
	BOOL isWidget = [self.icon isKindOfClass:objc_getClass("SBWidgetIcon")];
	if(isWidget)
	{
		customScale = [manager floatValueForKey:@"hs_widgetIconScale" forListView:self._atriaLastIconListView];
	}
	else
	{
		if(kIconIsInRoot(self))
		{
			customScale = [manager floatValueForKey:@"hs_iconScale" forListView:self._atriaLastIconListView];
		}
		else if(kIconIsInDock(self))
		{
			customScale = [manager floatValueForKey:@"dock_iconScale" forListView:self._atriaLastIconListView];
		}
	}

	// "Returns a transform that scales by (sx, sy, sz)."
	// By doing this, we essentially make sure that any icon animations
	// also respect our scaling (since sublayerTransform is set for our icon layer)

	BOOL shouldAnimate = [ARIEditManager sharedInstance].isEditing;

	void (^resize)() = ^void()
	{
		self.layer.sublayerTransform = CATransform3DMakeScale(
			customScale,
			customScale,
			1);
	};

	if(shouldAnimate)
	{
		// Stupid Core Animation
		[CATransaction begin];
		[CATransaction setAnimationDuration:0.2f];

		CATransform3D transform = self.layer.sublayerTransform;
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
		animation.fromValue = [NSValue value:&transform withObjCType:@encode(CATransform3D)];
		resize();
		CATransform3D to = self.layer.sublayerTransform;
		animation.toValue = [NSValue value:&to withObjCType:@encode(CATransform3D)];
		animation.duration = 0.2f;
		[self.layer addAnimation:animation forKey:animation.keyPath];
		[CATransaction commit];
	}
	else
	{
		resize();
	}
}

- (void)didMoveToSuperview
{
	%orig;
	if(self.superview && [self.superview isKindOfClass:objc_getClass("SBIconListView")]) self._atriaLastIconListView = (SBIconListView *)self.superview;
	[self _updateIconImageViewAnimated:YES];
}

%new
- (SBSApplicationShortcutItem *)_atriaGenerateItemWithTitle:(NSString *)title type:(NSString *)type
{
	SBSApplicationShortcutItem *item = [[objc_getClass("SBSApplicationShortcutItem") alloc] init];
	item.localizedTitle = title;
	item.type = type;

	// SFSymbols
	UIImage *image = [UIImage systemImageNamed:@"slider.horizontal.3"];

	// Sample our image in either black (for light mode) or white (for dark mode)
	image = [image imageWithTintColor:(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor blackColor])];

	// Get data respresentation of the image
	NSData *iconData = UIImagePNGRepresentation(image);
	SBSApplicationShortcutCustomImageIcon *icon = [[objc_getClass("SBSApplicationShortcutCustomImageIcon") alloc] initWithImagePNGData:iconData];
	[item setIcon:icon];

	return item;
}

- (NSArray *)applicationShortcutItems
{
	if([[ARITweak sharedInstance] boolValueForKey:@"hide3DTouchActions"] || [self isFolderIcon]) return %orig;

	// Add shortcut item to activate editor
	// I found this really cool gist to allow me to do this, tyvm to the author <3
	// Link: https://gist.github.com/MTACS/8e26c4f430b27d6a1d2a11f0a828f250
	NSMutableArray *items = [%orig mutableCopy];
	if(!kIconIsInRoot(self) && !kIconIsInDock(self)) return items;
	if(!items) items = [NSMutableArray new];

	if(kIconIsInRoot(self))
	{
		[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Layout" type:@"me.ren7995.atria.edit.hs"]];
		if([[ARITweak sharedInstance] boolValueForKey:@"showWelcome"])
		{
			[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Welcome" type:@"me.ren7995.atria.edit.welcome"]];
		}
		if([[ARITweak sharedInstance] boolValueForKey:@"showBackground"])
		{
			[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Background" type:@"me.ren7995.atria.edit.background"]];
		}
	}
	else if(kIconIsInDock(self))
	{
		[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Dock" type:@"me.ren7995.atria.edit.dock"]];
	}

	return items;
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item withBundleIdentifier:(NSString *)bundleID forIconView:(SBIconView *)iconView {
	NSString *prefix = @"me.ren7995.atria.edit.";
	if([[item type] containsString:prefix]) {
		NSString *loc = [[item type] stringByReplacingOccurrencesOfString:prefix withString:@""];
		[[NSNotificationCenter defaultCenter]
        	postNotificationName:@"me.ren7995.atria.edit"
                      object:self
                    userInfo:@{
						@"tag" : @(1),
						@"loc" : loc
					}];
	} else {
		%orig;
	}
}

%end

// I don't think this needs explaining
%hook SBIconBadgeView

- (CGFloat)alpha
{
	CGFloat orig = %orig;
	return orig == 1 ? ![[ARITweak sharedInstance] boolValueForKey:@"hideBadges"] : orig;
}

- (void)setAlpha:(CGFloat)arg1
{
	%orig(arg1 == 1 ? ![[ARITweak sharedInstance] boolValueForKey:@"hideBadges"] : arg1);
}


%end

%hook SBIconListPageControl

- (void)setHidden:(BOOL)arg1 
{
	// Hide page dots
	if([[ARITweak sharedInstance] boolValueForKey:@"hidePageDots"])
	{
		%orig(YES);
		return;
	}
	%orig(arg1);
}

%end

%hook SBFolderIconImageView

- (void)setBackgroundView:(id)arg1
{
	if([[ARITweak sharedInstance] boolValueForKey:@"hideFolderIconBG"])
	{
		// By setting a fresh UIView, it doesn't bug out, and it fades instead of glitching when closing the folder
		%orig([UIView new]);
		return;
	}

	%orig(arg1);
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
