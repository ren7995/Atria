//
// Created by ren7995 on 2021-04-25 12:49:07
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARITweakManager.h"
#import "ARIEditManager.h"

#import "../Hooks/Shared.h"

#import <objc/runtime.h>

@implementation ARITweakManager {
    BOOL _enabled;
    NSUserDefaults *_preferences;
    NSMutableOrderedSet<NSString *> *_orderedSettingKeys;
    NSMutableDictionary<NSString *, ARIOption *> *_optionsRegistry;
    NSMapTable *_listViewModelMap;
    NSUInteger _firmwareVersion;
    BOOL _deviceIPad;
    BOOL _shyLabelsInstalled;
}

@synthesize enabled = _enabled;
@synthesize preferences = _preferences;
@synthesize firmwareVersion = _firmwareVersion;
@synthesize deviceIPad = _deviceIPad;
@synthesize shyLabelsInstalled = _shyLabelsInstalled;
@synthesize listViewModelMap = _listViewModelMap;

// Shared instance and init methods

- (instancetype)init {
    self = [super init];
    if(self) {
        // Detect iOS version and model
        UIDevice *device = [UIDevice currentDevice];
        _firmwareVersion = [[[device systemVersion] componentsSeparatedByString:@"."][0] integerValue];
        _deviceIPad = [[device model] hasPrefix:@"iPad"];
        // ShyLabels compatibility
        _shyLabelsInstalled = [[NSFileManager defaultManager] fileExistsAtPath:@THEOS_PACKAGE_INSTALL_PREFIX "/Library/MobileSubstrate/DynamicLibraries/ShyLabels.dylib"];
        // NSUserDefaults to get what values the user set
        _preferences = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
        _enabled = [_preferences objectForKey:@"enabled"] ? [[_preferences objectForKey:@"enabled"] boolValue] : YES;
        _listViewModelMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];

        // Migrate old settings
        [self _migrateSettings];

        // Create settings
        _orderedSettingKeys = [[NSMutableOrderedSet alloc] initWithCapacity:50];
        _optionsRegistry = [[NSMutableDictionary alloc] init];

        [self _registerOption:@"showWelcome"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"showWeatherIcon"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"showTooltips"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"labelText"
                  translation:nil
                 defaultValue:@"\%GREETING\%, user"
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"labelTextColor"
                  translation:nil
                 defaultValue:@"#FFFFFF"
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"blurTintColor"
                  translation:nil
                 defaultValue:@"#FFFFFF"
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"layoutEnabled"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"enableAppLibrary"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"saveIconState"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"hideLabelsAppLibrary"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"hideLabels"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"hideLabelsFolders"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"scaleInsideFolders"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"dynamicWidgetSizing"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"floatingDockAppLibrary"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"floatingDockRecents"
                  translation:nil
                 defaultValue:@(YES)
                   lowerLimit:0
                   upperLimit:0];
        [self _registerOption:@"maxFloatingDockRecents"
                  translation:nil
                 defaultValue:@(3)
                   lowerLimit:0
                   upperLimit:0];

        // Homescreen
        [self _registerOption:@"hs_rows"
                  translation:@"Rows"
                 defaultValue:@(6)
                   lowerLimit:2.0F
                   upperLimit:20.0F];
        [self _registerOption:@"hs_columns"
                  translation:@"Columns"
                 defaultValue:@(4)
                   lowerLimit:2.0F
                   upperLimit:20.0F];
        [self _registerOption:@"hs_iconScale"
                  translation:@"Icon Scale"
                 defaultValue:@(1.0)
                   lowerLimit:0.01F
                   upperLimit:2.0F];
        [self _registerOption:@"hs_widgetIconScale"
                  translation:@"Widget Scale"
                 defaultValue:@(1.0)
                   lowerLimit:0.01F
                   upperLimit:3.0F];
        [self _registerOption:@"hs_spacing_x"
                  translation:@"Icon Spacing X"
                 defaultValue:@(0)
                   lowerLimit:-100.0F
                   upperLimit:100.0F];
        [self _registerOption:@"hs_spacing_y"
                  translation:@"Icon Spacing Y"
                 defaultValue:@(0)
                   lowerLimit:-100.0F
                   upperLimit:100.0F];
        [self _registerOption:@"hs_inset_top"
                  translation:@"Top Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"hs_inset_left"
                  translation:@"Left Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"hs_inset_bottom"
                  translation:@"Bottom Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"hs_inset_right"
                  translation:@"Right Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"hs_offset_top"
                  translation:@"Page Top Offset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"hs_offset_left"
                  translation:@"Page Left Offset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"hs_widgetXOffset"
                  translation:@"Widget X Offset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"hs_widgetYOffset"
                  translation:@"Widget Y Offset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];

        // Dock options
        // For some reason, on iOS 15 only (not 13-14 or 16+), calling +isFloatingDockSupported leads to a respring loop.
        // Once SpringBoard launches, this option will be re-registered to adjust the default value if floating dock is enabled.
        [self _registerOption:@"dock_columns"
                  translation:@"Columns"
                 defaultValue:@(4)
                   lowerLimit:2.0F
                   upperLimit:20.0F];
        [self _registerOption:@"dock_rows"
                  translation:@"Rows"
                 defaultValue:@(1)
                   lowerLimit:1.0F
                   upperLimit:5.0F];
        [self _registerOption:@"dock_iconScale"
                  translation:@"Icon Scale"
                 defaultValue:@(1)
                   lowerLimit:0.01F
                   upperLimit:2.0F];
        [self _registerOption:@"dock_bg"
                  translation:@"Background Alpha"
                 defaultValue:@(1)
                   lowerLimit:0.0F
                   upperLimit:1.0F];
        [self _registerOption:@"dock_spacing_x"
                  translation:@"Icon Spacing X"
                 defaultValue:@(0)
                   lowerLimit:-100.0F
                   upperLimit:100.0F];
        [self _registerOption:@"dock_spacing_y"
                  translation:@"Icon Spacing Y"
                 defaultValue:@(0)
                   lowerLimit:-100.0F
                   upperLimit:100.0F];
        [self _registerOption:@"dock_inset_top"
                  translation:@"Top Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"dock_inset_left"
                  translation:@"Left Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"dock_inset_bottom"
                  translation:@"Bottom Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"dock_inset_right"
                  translation:@"Right Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];

        // Page labels
        [self _registerOption:@"label_textSize"
                  translation:@"Text Size"
                 defaultValue:@(27)
                   lowerLimit:1.0F
                   upperLimit:60.0F];
        [self _registerOption:@"label_inset_left"
                  translation:@"Side Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"label_inset_top"
                  translation:@"Vertical Inset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];

        // Blur background
        [self _registerOption:@"blur_alpha"
                  translation:@"Background Alpha"
                 defaultValue:@(1)
                   lowerLimit:0.0F
                   upperLimit:1.0F];
        [self _registerOption:@"blur_corner_radius"
                  translation:@"Corner Radius"
                 defaultValue:@(14)
                   lowerLimit:0.0F
                   upperLimit:100.0F];
        [self _registerOption:@"blur_intensity"
                  translation:@"Tint Intensity"
                 defaultValue:@(0.5F)
                   lowerLimit:0.0F
                   upperLimit:1.0F];

        [self _registerOption:@"blur_inset_top"
                  translation:@"Top Position"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"blur_inset_left"
                  translation:@"Left Position"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"blur_inset_bottom"
                  translation:@"Bottom Position"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
        [self _registerOption:@"blur_inset_right"
                  translation:@"Right Position"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];

        // Page dots
        [self _registerOption:@"pagedot_offsetX"
                  translation:@"Dot X Offset"
                 defaultValue:@(0)
                   lowerLimit:-150.0F
                   upperLimit:150.0F];
        [self _registerOption:@"pagedot_offsetY"
                  translation:@"Dot Y Offset"
                 defaultValue:@(0)
                   lowerLimit:-200.0F
                   upperLimit:200.0F];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static ARITweakManager *manager;
    dispatch_once(&token, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)_migrateSettings {
    // Horrible code but I just need it to work, this only runs once ever
    if([self intValueForKey:@"_settingsMigrationVersion"] >= 1) {
        return;
    }

    // Save state
    [self _migrateSettingFromKey:@"saveState" toKey:@"_saveState"];

    // Update list of per-page layout enabled list views
    NSMutableArray *perPage = [(NSArray *)[self rawValueForKey:@"_perPageListViews"] mutableCopy] ?: [NSMutableArray new];
    NSUInteger itemCount = [perPage count];
    for(NSUInteger i = 0; i < itemCount; i++) {
        NSString *newValue = [NSString stringWithFormat:@"Page%@_", [perPage[i] stringByReplacingOccurrencesOfString:@"_" withString:@""]];
        [perPage replaceObjectAtIndex:i withObject:newValue];
    }
    [self setValue:perPage forKey:@"_perPageListViews"];

    NSDictionary *dict = [_preferences dictionaryRepresentation];
    for(NSString *key in [dict allKeys]) {
        // Welcome is now renamed to label
        if([key hasPrefix:@"welcome"]) {
            NSString *newKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:@"label"];
            [self _migrateSettingFromKey:key toKey:newKey];
            continue;
        }

        if([key length] <= 3) continue;
        // Previous per-page layout prefix was formatted as _%d_ and now is Page%d_
        NSString *sub = [key substringToIndex:3];
        if([sub hasPrefix:@"_"] && [sub hasSuffix:@"_"]) {
            NSString *newKey = [NSString
                stringWithFormat:@"Page%@_%@",
                                 [sub stringByReplacingOccurrencesOfString:@"_"
                                                                withString:@""],
                                 [key stringByReplacingOccurrencesOfString:sub
                                                                withString:@""]];
            [self _migrateSettingFromKey:key toKey:newKey];
            continue;
        }
    }

    // Set migration Version
    [self setValue:@(1) forKey:@"_settingsMigrationVersion"];
}

- (void)_migrateSettingFromKey:(NSString *)oldKey toKey:(NSString *)newKey {
    [_preferences setObject:[self rawValueForKey:oldKey] forKey:newKey];
    [_preferences removeObjectForKey:oldKey];
}

- (void)_registerOption:(NSString *)key
            translation:(NSString *)translation
           defaultValue:(id)defaultValue
             lowerLimit:(float)lower
             upperLimit:(float)upper {
    float range[] = {lower, upper};
    ARIOption *option = [[ARIOption alloc] initWithKey:key
                                           translation:translation
                                          defaultValue:defaultValue
                                                 range:range];
    if(option.accessibleWithEditor)
        [_orderedSettingKeys addObject:option.settingKey];
    [_optionsRegistry setObject:option forKey:option.settingKey];
}

// Runtime manager methods

- (void)updateLayoutForEditing:(BOOL)animated {
    NSString *editingLocation = [ARIEditManager sharedInstance].editingLocation;
    if(!editingLocation) return;

    if([editingLocation isEqualToString:@"pagedot"]) {
        // Will use cached metrics (see hook in PageDots.xm)
        [[self rootFolderView] layoutPageControlWithMetrics:NULL];
        return;
    }

    BOOL updateRoot = [editingLocation isEqualToString:@"hs"] || [editingLocation isEqualToString:@"label"] || [editingLocation isEqualToString:@"blur"];
    [self updateLayoutForRoot:updateRoot forDock:[editingLocation isEqualToString:@"dock"] animated:animated];
}

// Updates all layout

- (void)updateLayoutForRoot:(BOOL)forRoot forDock:(BOOL)forDock animated:(BOOL)animated {
    SBRootFolderView *rootFolderView = [self rootFolderView];

    void (^updateVisibleIcons)(BOOL finished) = ^void(BOOL finished) {
        SBIconListView *current = [self currentListView];
        // Update visible columns and rows for current list view. Otherwise, SB doesn't
        // update this until we start scrolling
        if([current respondsToSelector:@selector(setVisibleColumnRange:)])
            [current setVisibleColumnRange:NSMakeRange(0, [self intValueForKey:@"hs_columns" forListView:current])];
        if([current respondsToSelector:@selector(setVisibleRowRange:)])
            [current setVisibleRowRange:NSMakeRange(0, [self intValueForKey:@"hs_rows" forListView:current])];
    };

    void (^applyLayout)() = ^void() {
        if(forDock) {
            // Layout dock icons and set alpha
            if(![[self class] isUsingFloatingDock]) {
                // -dockListView doesn't exist on 13 but the ivar does
                SBIconListView *listView = (SBIconListView *)[rootFolderView valueForKeyPath:@"_dockListView"];
                [[rootFolderView dockView] _atriaUpdateDockForSettingsChanged];
                [listView layoutIconsNow];
            } else {
                SBFloatingDockController *fdController = [objc_getClass("SBFloatingDockController") _atriaSharedInstance];
                // Icon list and suggestions
                [[fdController userIconListView] layoutIconsNow];
                [[fdController suggestionsIconListView] layoutIconsNow];
                SBFloatingDockViewController *fdvc = [fdController floatingDockViewController];
                // Fix for library pod icon
                if([fdvc respondsToSelector:@selector(libraryPodIconView)])
                    [[fdvc libraryPodIconView] _atriaUpdateIconContentScale];
                // Update dock background
                [[fdvc dockView] _atriaUpdateDockForSettingsChanged];
            }
        }

        if(forRoot) {
            // Enumerate list views in root and lay them out as well
            for(SBIconListView *listView in rootFolderView.iconListViews) {
                [listView layoutIconsNow];
            }
        }
    };

    // If we want animation, pass the block here. Otherwise, call the block directly
    if(animated) {
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:applyLayout
                         completion:updateVisibleIcons];
    } else {
        applyLayout();
        updateVisibleIcons(YES);
    }
}

// This lags the device somewhat, so limit this as much as possible!
- (void)relayoutEntireIconModel {
    // This will cause the entire icon model to re-layout
    [[[[objc_getClass("SBIconController") sharedInstance] iconManager] iconModel] layout];
    // In order to fix the custom widget sizing, we need to call this
    [self updateLayoutForRoot:YES forDock:NO animated:NO];
}

// Util

- (void)feedbackForButton {
    // Create a generator (just like in AppStore apps) and make it give feedback
    static UIImpactFeedbackGenerator *generator = nil;
    if(!generator) generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleSoft];
    [generator impactOccurred];
}

- (void)onSpringboardLaunched {
    // If floating dock is enabled, default to 6 dock columns. See explanation in init method for why this is done here.
    if([self boolValueForKey:@"forceFloatingDock"] || [[self class] isUsingFloatingDock]) {
        [self _registerOption:@"dock_columns"
                  translation:@"Columns"
                 defaultValue:@(6)
                   lowerLimit:2.0F
                   upperLimit:20.0F];
        [self relayoutEntireIconModel];
    }

    if([[self class] isUsingFloatingDock]) {
        // Update floating dock background alpha to fix a bug specific to iOS 14
        SBFloatingDockController *fdController = [objc_getClass("SBFloatingDockController") _atriaSharedInstance];
        [[[fdController floatingDockViewController] dockView] _atriaUpdateDockForSettingsChanged];
    }
}

- (SBRootFolderView *)rootFolderView {
    return [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView];
}

- (NSArray<SBIconListView *> *)allRootListViews {
    return [self rootFolderView].iconListViews;
}

- (NSUInteger)indexOfListView:(SBIconListView *)target {
    return [[self allRootListViews] indexOfObject:target];
}

- (SBIconListView *)firstIconListView {
    return [[self rootFolderView] firstIconListView];
}

- (SBIconListView *)currentListView {
    return [self rootFolderView].currentIconListView;
}

// Returns a string which serves as a prefix for per-page layout settings

- (NSString *)prefixForListView:(SBIconListView *)target {
    if(!target || !IconListIsRoot(target)) return @"";
    return [NSString stringWithFormat:@"Page%d_", (int)[self indexOfListView:target]];
}

// Obtain information about available settings

- (NSMutableOrderedSet<NSString *> *)editorSettingsKeys {
    return _orderedSettingKeys;
}

- (ARIOption *)getSettingByKey:(NSString *)key {
    return _optionsRegistry[key];
}

// Get/set preference values

- (int)intValueForKey:(NSString *)key {
    return [_preferences objectForKey:key]
               ? [[_preferences objectForKey:key] integerValue]
               : [[_optionsRegistry objectForKey:key].defaultValue integerValue];
}

- (BOOL)boolValueForKey:(NSString *)key {
    return [_preferences objectForKey:key]
               ? [[_preferences objectForKey:key] boolValue]
               : [[_optionsRegistry objectForKey:key].defaultValue boolValue];
}

- (float)floatValueForKey:(NSString *)key {
    return [_preferences objectForKey:key]
               ? [[_preferences objectForKey:key] floatValue]
               : [[_optionsRegistry objectForKey:key].defaultValue floatValue];
}

- (id)rawValueForKey:(NSString *)key {
    return [_preferences objectForKey:key] ?: [_optionsRegistry objectForKey:key].defaultValue;
}

- (void)setValue:(id)val forKey:(NSString *)key {
    if([val isEqual:_optionsRegistry[key].defaultValue]) {
        // Matches default value, remove from preferences
        [self resetValueForKey:key];
    } else {
        if(![val isEqual:[_preferences valueForKey:key]])
            [_preferences setValue:val forKey:key];
    }
}

- (void)resetValueForKey:(NSString *)key {
    [_preferences removeObjectForKey:key];
}

// Get/set preference values by icon list view
// We try to locate value for the current list view, if it exists

- (int)intValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self prefixForListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] integerValue] : [self intValueForKey:key];
}

- (BOOL)boolValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self prefixForListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] boolValue] : [self boolValueForKey:key];
}

- (id)rawValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self prefixForListView:list], key];
    return [_preferences objectForKey:pageKey] ?: [self rawValueForKey:key];
}

- (float)floatValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self prefixForListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] floatValue] : [self floatValueForKey:key];
}

- (void)setValue:(id)val forKey:(NSString *)key forListView:(SBIconListView *)listView {
    if(!listView)
        [self setValue:val forKey:key];
    else
        [self setValue:val forKey:[NSString stringWithFormat:@"%@%@", [self prefixForListView:listView], key]];
}

- (void)resetValueForKey:(NSString *)key forListView:(SBIconListView *)listView {
    if(!listView)
        [self resetValueForKey:key];
    else
        [self resetValueForKey:[NSString stringWithFormat:@"%@%@", [self prefixForListView:listView], key]];
}

// Per-page layout creation/deletion and management

- (void)deleteCustomForListView:(SBIconListView *)listView {
    // Delete any keys for that list view
    NSString *prefix = [self prefixForListView:listView];
    NSDictionary *preferences = [_preferences dictionaryRepresentation];
    for(NSString *key in [preferences allKeys]) {
        if([key hasPrefix:prefix]) [self resetValueForKey:key];
    }

    NSMutableArray *perPage = [(NSArray *)[self rawValueForKey:@"_perPageListViews"] mutableCopy] ?: [NSMutableArray new];
    [perPage removeObject:prefix];
    [self setValue:perPage forKey:@"_perPageListViews"];

    [self updateLayoutForEditing:YES];
}

- (void)createCustomForListView:(SBIconListView *)listView {
    // Freeze list view settings to what the current global config is
    NSString *prefix = [self prefixForListView:listView];

    NSMutableArray *perPage = [(NSArray *)[self rawValueForKey:@"_perPageListViews"] mutableCopy] ?: [NSMutableArray new];
    [perPage addObject:prefix];
    [self setValue:perPage forKey:@"_perPageListViews"];

    for(NSString *key in _orderedSettingKeys) {
        [_preferences setObject:[self rawValueForKey:key]
                         forKey:[NSString stringWithFormat:@"%@%@", prefix, key]];
    }
    [self updateLayoutForEditing:YES];
}

- (BOOL)doesCustomConfigForListViewExist:(SBIconListView *)listView {
    NSArray *perPage = [self rawValueForKey:@"_perPageListViews"];
    if(!perPage) return NO;
    return [perPage containsObject:[self prefixForListView:listView]];
}

+ (UIInterfaceOrientation)currentDeviceOrientation {
    return [[[UIApplication sharedApplication] windows] firstObject].windowScene.interfaceOrientation;
}

+ (BOOL)isUsingFloatingDock {
    return [objc_getClass("SBFloatingDockController") isFloatingDockSupported];
}

+ (void)dismissFloatingDockIfPossible {
    if([self isUsingFloatingDock]) {
        [[objc_getClass("SBFloatingDockController") _atriaSharedInstance] _dismissFloatingDockIfPresentedAnimated:YES completionHandler:nil];
    }
}

+ (void)presentFloatingDockIfPossible {
    if([self isUsingFloatingDock]) {
        [[objc_getClass("SBFloatingDockController") _atriaSharedInstance] _presentFloatingDockIfDismissedAnimated:YES completionHandler:nil];
    }
}

@end
