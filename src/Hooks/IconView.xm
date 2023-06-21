//
// Created by ren7995 on 2021-04-25 12:49:37
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "Shared.h"
#import "../Manager/ARITweakManager.h"
#import "../Manager/ARIEditManager.h"

#include <objc/runtime.h>

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

%hook SBIconView
// I hope this doesn't cause issues
%property (nonatomic, strong) SBIconListView *_atriaLastIconListView;

- (CGFloat)iconContentScale {
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	// Fixes folder icon bug on open
	CGFloat orig = %orig;
	if([self isFolderIcon]) {
		if(IconIsInRoot(self)) {
			return [manager floatValueForKey:@"hs_iconScale" forListView:self._atriaLastIconListView];
		} else if(IconIsInDock(self)) {
			return [manager floatValueForKey:@"dock_iconScale"];
		}
	}

	return orig;
}

- (void)setAllowsLabelArea:(BOOL)allows {
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	if([manager isShyLabelsInstalled]) {
		%orig(allows);
		return;
	}

	if(IconIsInRoot(self)) {
    	if([manager boolValueForKey:@"hideLabels"]) allows = NO;
	} else if(IconIsInAppLibrary(self) || IconIsInAppLibraryPod(self)) {
		if([manager boolValueForKey:@"hideLabelsAppLibrary"]) allows = NO;
	} else if(IconIsInFolder(self)) {
		if([manager boolValueForKey:@"hideLabelsFolders"]) allows = NO;
	}
	%orig(allows);
}

- (void)_updateIconImageViewAnimated:(BOOL)arg1 {
	%orig(arg1);
	[self _atriaUpdateIconContentScale];
}

- (void)setIconContentScale:(CGFloat)scale {
	%orig(scale);
	[self _atriaUpdateIconContentScale];
}

%new
- (void)_atriaUpdateIconContentScale {
	// Reset icon content scale
	ARITweakManager *manager = [ARITweakManager sharedInstance];
	CATransform3D old = self.layer.sublayerTransform;

	// Use containsString because we need to check for the suggestions location too
	BOOL inDock = IconIsInDock(self) || [self.location containsString:@"Floating"];
	if(!(inDock || IconIsInRoot(self) || (IconIsInFolder(self) && [manager boolValueForKey:@"scaleInsideFolders"]))) {
		if(old.m11 != 1 || old.m22 != 1) self.layer.sublayerTransform = CATransform3DMakeScale(1, 1, 1);
		return;
	}

	CGFloat customScale = 1;
	BOOL isWidget = [self.icon isKindOfClass:objc_getClass("SBWidgetIcon")];
	if(isWidget) {
		customScale = [manager floatValueForKey:@"hs_widgetIconScale" forListView:self._atriaLastIconListView];
	} else {
		if(IconIsInRoot(self) || (IconIsInFolder(self) && [manager boolValueForKey:@"scaleInsideFolders"])) {
			customScale = [manager floatValueForKey:@"hs_iconScale" forListView:self._atriaLastIconListView];
		} else if(inDock) {
			customScale = [manager floatValueForKey:@"dock_iconScale" forListView:self._atriaLastIconListView];
		}
	}

	// "Returns a transform that scales by (sx, sy, sz)."
	// By doing this, we essentially make sure that any icon animations
	// also respect our scaling (since sublayerTransform is set for our icon layer)
	if(old.m11 == customScale && old.m22 == customScale) return;

	void (^resize)() = ^void() {
		self.layer.sublayerTransform = CATransform3DMakeScale(
			customScale,
			customScale,
			1);
	};

	// Animate if in edit mode
	if([ARIEditManager sharedInstance].isEditing) {
		// Stupid Core Animation
		[CATransaction begin];
		[CATransaction setAnimationDuration:0.2f];
		// Setup animation to and from
		CATransform3D from = self.layer.sublayerTransform;
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
		animation.fromValue = [NSValue value:&from withObjCType:@encode(CATransform3D)];
		resize();
		CATransform3D to = self.layer.sublayerTransform;
		animation.toValue = [NSValue value:&to withObjCType:@encode(CATransform3D)];
		// Add completion handler (must be done before adding animation to layer)
		[CATransaction setCompletionBlock:^{ [self _atriaGenerateDropShadow:self.bounds]; }];
		// Add animation to layer and commit
		[self.layer addAnimation:animation forKey:animation.keyPath];
		[CATransaction commit];
	} else {
		// Resize and update drop shadow immediately
		resize();
		[self _atriaGenerateDropShadow:self.bounds];
	}
}

- (void)didMoveToSuperview {
	%orig;
	if(self.superview && [self.superview isKindOfClass:objc_getClass("SBIconListView")]) {
		self._atriaLastIconListView = (SBIconListView *)self.superview;
		// Update allowsLabelArea
		[self setAllowsLabelArea:self.allowsLabelArea];
	}
	[self _atriaSetupDropShadow:[[[objc_getClass("SBIconController") sharedInstance] iconManager] isEditing]];
	[self _updateIconImageViewAnimated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[self _atriaSetupDropShadow:editing];
	%orig(editing, animated);
}

%new
- (void)_atriaGenerateDropShadow:(CGRect)rect {
	if(self.layer.shadowRadius > 0.0F) {
		CGFloat width = rect.size.width;
		CGFloat height = rect.size.height;
		float scale = self.layer.sublayerTransform.m11;
		CGRect scaledRect = CGRectInset(rect, 
			(width - sqrt(width * width * scale)) / 2.0F, 
			(height - sqrt(height * height * scale)) / 2.0F);
		self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:scaledRect cornerRadius:[self iconImageCornerRadius]].CGPath;
	}
}

%new
- (void)_atriaSetupDropShadow:(BOOL)isEditing {
	BOOL enabled = [[ARITweakManager sharedInstance] boolValueForKey:@"dropShadow"];
	SBIcon *icon = [self icon];
	BOOL widgetOrAppIcon = [icon application] || [icon isKindOfClass:objc_getClass("SBWidgetIcon")] || [icon isKindOfClass:objc_getClass("SBBookmarkIcon")];
	// Don't apply shadows in floating dock, because dynamic scaling of the app icons gets weird
	// Use containsString instead of the macro because we need to check for the suggestions location too
	if(enabled && !isEditing && widgetOrAppIcon && ![self.location containsString:@"Floating"]) {
		if(self.layer.shadowRadius > 0.0F) return;
		self.layer.masksToBounds = NO;
		self.layer.shadowOpacity = 0.4F;
		self.layer.shadowRadius = 5.0F;
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.drawsAsynchronously = YES;
		[self _atriaGenerateDropShadow:self.bounds];
	} else {
		self.layer.shadowOpacity = 0.0F;
		self.layer.shadowRadius = 0.0F;
	}
}

- (void)setBounds:(CGRect)arg1 {
	%orig(arg1);
	[self _atriaGenerateDropShadow:arg1];
}

%new
- (SBSApplicationShortcutItem *)_atriaGenerateItemWithTitle:(NSString *)title type:(NSString *)type {
	SBSApplicationShortcutItem *item = [[objc_getClass("SBSApplicationShortcutItem") alloc] init];
	item.localizedTitle = title;
	item.type = type;

	// SFSymbols
	UIImage *image = [UIImage systemImageNamed:@"gear"];

	// Tint our image
	image = [image imageWithTintColor:[UIColor labelColor]];

	// Get data respresentation of the image
	NSData *iconData = UIImagePNGRepresentation(image);
	SBSApplicationShortcutCustomImageIcon *icon = [[objc_getClass("SBSApplicationShortcutCustomImageIcon") alloc] initWithImagePNGData:iconData];
	[item setIcon:icon];

	return item;
}

- (NSArray *)applicationShortcutItems {
	if([[ARITweakManager sharedInstance] boolValueForKey:@"hide3DTouchActions"] || [self isFolderIcon]) return %orig;

	// Add shortcut item to activate editor
	// I found this really cool gist to allow me to do this, tyvm to the author <3
	// Link: https://gist.github.com/MTACS/8e26c4f430b27d6a1d2a11f0a828f250
	NSMutableArray *items = [%orig mutableCopy];
	if(!(IconIsInRoot(self) || IconIsInDock(self))) return items;
	if(!items) items = [NSMutableArray new];

	if(IconIsInRoot(self)) {
		[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Layout" type:@"me.lau.atria.edit.hs"]];
		[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Page Dots" type:@"me.lau.atria.edit.pagedot"]];
		[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Page Labels" type:@"me.lau.atria.edit.label"]];
		if([[ARITweakManager sharedInstance] boolValueForKey:@"showBackground"]) {
			[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Background Blur" type:@"me.lau.atria.edit.blur"]];
		}
	} else if(IconIsInDock(self)) {
		[items addObject:[self _atriaGenerateItemWithTitle:@"Edit Dock" type:@"me.lau.atria.edit.dock"]];
	}

	return items;
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item withBundleIdentifier:(NSString *)bundleID forIconView:(SBIconView *)iconView {
	NSString *prefix = @"me.lau.atria.edit.";
	if([[item type] containsString:prefix]) {
		NSString *loc = [[item type] stringByReplacingOccurrencesOfString:prefix withString:@""];
		[[ARIEditManager sharedInstance] toggleEditView:YES withTargetLocation:loc];
	} else {
		%orig;
	}
}

%end

// I don't think this needs explaining
%hook SBIconBadgeView

- (CGFloat)alpha {
	CGFloat orig = %orig;
	return orig == 1 ? ![[ARITweakManager sharedInstance] boolValueForKey:@"hideBadges"] : orig;
}

- (void)setAlpha:(CGFloat)arg1 {
	%orig(arg1 == 1 ? ![[ARITweakManager sharedInstance] boolValueForKey:@"hideBadges"] : arg1);
}


%end

%hook SBIconListPageControl

- (void)setHidden:(BOOL)arg1  {
	// Hide page dots
	if([[ARITweakManager sharedInstance] boolValueForKey:@"hidePageDots"]) {
		%orig(YES);
		return;
	}
	%orig(arg1);
}

%end

%hook SBFolderIconImageView

- (void)setBackgroundView:(id)arg1 {
	if([[ARITweakManager sharedInstance] boolValueForKey:@"hideFolderIconBG"]) {
		// By setting a fresh UIView, it doesn't bug out, and it fades instead of glitching when closing the folder
		%orig([UIView new]);
		return;
	}

	%orig(arg1);
}

%end

%ctor {
	if([[ARITweakManager sharedInstance] isEnabled]) {
		NSLog(@"[Atria]: Loading hooks from %s", __FILE__);
		%init();
	}
}
