//
// Created by ren7995 on 2021-04-25 12:49:07
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/Manager/ARITweakManager.h"
#import "src/Manager/ARIEditManager.h"
#import "src/Options/ARIOption.h"

#import <objc/runtime.h>

@implementation ARITweakManager {
    NSUserDefaults *_preferences;
    NSMutableArray<NSString *> *_orderedSettingKeys;
    NSMutableDictionary<NSString *, ARIOption *> *_optionsRegistry;
    NSMapTable *_listViewModelMap;
    BOOL _firmware14;
    BOOL _didLoad;
}

@synthesize preferences = _preferences;
@synthesize firmware14 = _firmware14;
@synthesize didLoad = _didLoad;
@synthesize listViewModelMap = _listViewModelMap;

// Shared instance and init methods

- (instancetype)init {
    self = [super init];
    if(self) {
        // Detect iOS version
        _firmware14 = [[[UIDevice currentDevice] systemVersion] compare:@"14.0" options:NSNumericSearch] != NSOrderedAscending;
        // NSUserDefaults to get what values the user set
        _preferences = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
        _enabled = [_preferences objectForKey:@"enabled"] ? [[_preferences objectForKey:@"enabled"] boolValue] : YES;
        _listViewModelMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];

        // Create settings
        NSArray *optionList = @[
            //[[ARIOption alloc] initWithKey:nil translation:nil defaultValue:nil range:nil],

            // Non editor default values
            [[ARIOption alloc] initWithKey:@"showWelcome"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"showTooltips"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"welcomeText"
                               translation:nil
                              defaultValue:@"\%GREETING\%, user"
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"welcomeTextColor"
                               translation:nil
                              defaultValue:@"#FFFFFF"
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"blurTintColor"
                               translation:nil
                              defaultValue:@"#FFFFFF"
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"layoutEnabled"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"enableAppLibrary"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"saveIconState"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"hideLabelsAppLibrary"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"hideLabels"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"hideLabelsFolders"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],
            [[ARIOption alloc] initWithKey:@"scaleInsideFolders"
                               translation:nil
                              defaultValue:@(YES)
                                     range:nil],

            // Homescreen
            [[ARIOption alloc] initWithKey:@"hs_rows"
                               translation:@"Rows"
                              defaultValue:@(6)
                                     range:@[ @(2), @(20) ]],
            [[ARIOption alloc] initWithKey:@"hs_columns"
                               translation:@"Columns"
                              defaultValue:@(4)
                                     range:@[ @(2), @(20) ]],
            [[ARIOption alloc] initWithKey:@"hs_iconScale"
                               translation:@"Icon Scale"
                              defaultValue:@(1.0)
                                     range:@[ @(0.01), @(2) ]],
            [[ARIOption alloc] initWithKey:@"hs_widgetIconScale"
                               translation:@"Widget Scale"
                              defaultValue:@(1.0)
                                     range:@[ @(0.01), @(3) ]],
            [[ARIOption alloc] initWithKey:@"hs_inset_top"
                               translation:@"Top Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_inset_left"
                               translation:@"Left Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_inset_bottom"
                               translation:@"Bottom Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_inset_right"
                               translation:@"Right Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_offset_top"
                               translation:@"Page Top Offset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_offset_left"
                               translation:@"Page Left Offset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_widgetXOffset"
                               translation:@"Widget X Offset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_widgetYOffset"
                               translation:@"Widget Y Offset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"hs_spacing_x"
                               translation:@"Icon Spacing X"
                              defaultValue:@(0)
                                     range:@[ @(-100), @(100) ]],
            [[ARIOption alloc] initWithKey:@"hs_spacing_y"
                               translation:@"Icon Spacing Y"
                              defaultValue:@(0)
                                     range:@[ @(-100), @(100) ]],

            // Dock options
            [[ARIOption alloc] initWithKey:@"dock_inset_top"
                               translation:@"Top Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"dock_inset_left"
                               translation:@"Left Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"dock_inset_bottom"
                               translation:@"Bottom Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"dock_inset_right"
                               translation:@"Right Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"dock_columns"
                               translation:@"Columns"
                              defaultValue:@(4)
                                     range:@[ @(2), @(20) ]],
            [[ARIOption alloc] initWithKey:@"dock_rows"
                               translation:@"Rows"
                              defaultValue:@(1)
                                     range:@[ @(1), @(5) ]],
            [[ARIOption alloc] initWithKey:@"dock_iconScale"
                               translation:@"Icon Scale"
                              defaultValue:@(1)
                                     range:@[ @(0.01), @(3) ]],
            [[ARIOption alloc] initWithKey:@"dock_bg"
                               translation:@"Background Alpha"
                              defaultValue:@(1)
                                     range:@[ @(0), @(1) ]],
            [[ARIOption alloc] initWithKey:@"dock_spacing_x"
                               translation:@"Icon Spacing X"
                              defaultValue:@(0)
                                     range:@[ @(-100), @(100) ]],
            [[ARIOption alloc] initWithKey:@"dock_spacing_y"
                               translation:@"Icon Spacing Y"
                              defaultValue:@(0)
                                     range:@[ @(-100), @(100) ]],

            // Label
            [[ARIOption alloc] initWithKey:@"welcome_textSize"
                               translation:@"Text Size"
                              defaultValue:@(27)
                                     range:@[ @(1), @(60) ]],
            [[ARIOption alloc] initWithKey:@"welcome_inset_left"
                               translation:@"Side Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"welcome_inset_top"
                               translation:@"Vertical Inset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],

            // Blur background
            [[ARIOption alloc] initWithKey:@"blur_alpha"
                               translation:@"Background Alpha"
                              defaultValue:@(1)
                                     range:@[ @(0), @(1) ]],
            [[ARIOption alloc] initWithKey:@"blur_corner_radius"
                               translation:@"Corner Radius"
                              defaultValue:@(12)
                                     range:@[ @(0), @(100) ]],
            [[ARIOption alloc] initWithKey:@"blur_intensity"
                               translation:@"Tint Intensity"
                              defaultValue:@(1)
                                     range:@[ @(0), @(1) ]],

            [[ARIOption alloc] initWithKey:@"blur_inset_top"
                               translation:@"Top Position"
                              defaultValue:@(1)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"blur_inset_left"
                               translation:@"Left Position"
                              defaultValue:@(1)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"blur_inset_bottom"
                               translation:@"Bottom Position"
                              defaultValue:@(1)
                                     range:@[ @(-200), @(200) ]],
            [[ARIOption alloc] initWithKey:@"blur_inset_right"
                               translation:@"Right Position"
                              defaultValue:@(1)
                                     range:@[ @(-200), @(200) ]],

            // Page dots
            [[ARIOption alloc] initWithKey:@"pagedot_offsetX"
                               translation:@"Dot X Offset"
                              defaultValue:@(0)
                                     range:@[ @(-150), @(150) ]],
            [[ARIOption alloc] initWithKey:@"pagedot_offsetY"
                               translation:@"Dot Y Offset"
                              defaultValue:@(0)
                                     range:@[ @(-200), @(200) ]],

        ];

        // Add to dictionary and array
        _orderedSettingKeys = [[NSMutableArray alloc] init];
        _optionsRegistry = [[NSMutableDictionary alloc] init];
        for(ARIOption *option in optionList) {
            [_orderedSettingKeys addObject:option.settingKey];
            [_optionsRegistry setObject:option forKey:option.settingKey];
        }
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

// Runtime manager methods

- (void)updateLayoutForEditing:(BOOL)animated {
    NSString *editingLocation = [ARIEditManager sharedInstance].editingLocation;
    if(!editingLocation) return;

    if([editingLocation isEqualToString:@"pagedot"]) {
        SBRootFolderView *rootFolderView = [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView];
        // Will use cached metrics (see hook)
        [rootFolderView layoutPageControlWithMetrics:NULL];
        return;
    }

    BOOL root = NO, dock = NO;
    if([editingLocation isEqualToString:@"dock"])
        dock = YES;
    else if([editingLocation isEqualToString:@"hs"] || [editingLocation isEqualToString:@"welcome"] || [editingLocation isEqualToString:@"background"])
        root = YES;
    [self updateLayoutForRoot:root forDock:dock animated:animated];
}

// Updates all layout
- (void)updateLayoutForRoot:(BOOL)forRoot forDock:(BOOL)forDock animated:(BOOL)animated {
    SBRootFolderView *rootFolderView = [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView];

    // What tf is this. Objc explain
    void (^updateVisible)(BOOL finished) = ^void(BOOL finished) {
        SBIconListView *current = [self currentListView];
        // Update visible columns and rows for current list view. Otherwise, SB doesn't
        // update this until we start scrolling
        if([current respondsToSelector:@selector(setVisibleColumnRange:)])
            [current setVisibleColumnRange:NSMakeRange(0, [self intValueForKey:@"hs_columns" forListView:current])];
        if([current respondsToSelector:@selector(setVisibleRowRange:)])
            [current setVisibleRowRange:NSMakeRange(0, [self intValueForKey:@"hs_rows" forListView:current])];
    };

    void (^layout)() = ^void() {
        if(forDock) {
            // Layout dock icons and set alpha
            // -dockListView doesn't exist on 13 but the ivar does
            SBIconListView *listView = (SBIconListView *)[rootFolderView valueForKeyPath:@"_dockListView"];
            listView._atriaNeedsLayout = YES;
            [listView layoutIconsNow];
            [[rootFolderView dockView] _atriaUpdateDockForSettingsChanged];
        }

        if(forRoot) {
            // Enumerate list views in root and lay them out as well
            for(SBIconListView *listView in rootFolderView.iconListViews) {
                listView._atriaNeedsLayout = YES;
                [listView layoutIconsNow];
            }
        }
    };

    // If we want animation, pass the block here. Otherwise, call the block directly
    if(animated) {
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:layout
                         completion:updateVisible];
    } else {
        layout();
        updateVisible(YES);
    }
}

// Util

- (void)feedbackForButton {
    // Create a generator (just like in AppStore apps) and make it give feedback
    static UIImpactFeedbackGenerator *generator = nil;
    if(!generator) generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleSoft];
    [generator impactOccurred];
}

- (void)notifyDidLoad {
    _didLoad = YES;
}

- (NSArray<SBIconListView *> *)allRootListViews {
    return [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView].iconListViews;
}

- (NSUInteger)indexOfListView:(SBIconListView *)target {
    return [[self allRootListViews] indexOfObject:target];
}

- (SBIconListView *)firstIconListView {
    return [[[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView] firstIconListView];
}

- (NSString *)stringIndexOfListView:(SBIconListView *)target {
    // Fallback to global
    if(!target || [target.iconLocation isEqualToString:@"SBIconLocationDock"]) return @"";

    // Return an empty string if list view is not setup for individual config
    int index = (int)[self indexOfListView:target];
    return [NSString stringWithFormat:@"_%d_", index];
}

- (NSArray<NSString *> *)editorSettingsKeys {
    return _orderedSettingKeys;
}

- (NSString *)stringRepresentationForSettingsKey:(NSString *)key {
    return _optionsRegistry[key].settingTranslation;
}

- (NSArray<NSNumber *> *)rangeForSettingsKey:(NSString *)key {
    return _optionsRegistry[key].range;
}

- (SBIconListView *)currentListView {
    return [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView].currentIconListView;
}

// Settings helper methods for use elsewhere
// Beware, boilerplate code below

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
        [self.preferences removeObjectForKey:key];
    } else {
        if(![val isEqual:[self.preferences valueForKey:key]])
            [self.preferences setValue:val forKey:key];
    }
}

- (void)resetValueForKey:(NSString *)key {
    [self.preferences removeObjectForKey:key];
}

// Per page layout settings helpers
// We try to locate value for the current list view, if it exists

- (int)intValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] integerValue] : [self intValueForKey:key];
}

- (BOOL)boolValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] boolValue] : [self boolValueForKey:key];
}

- (id)rawValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ?: [self rawValueForKey:key];
}

- (float)floatValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] floatValue] : [self floatValueForKey:key];
}

- (void)setValue:(id)val forKey:(NSString *)key forListView:(SBIconListView *)listView {
    if(!listView) {
        [self setValue:val forKey:key];
        return;
    }
    [self setValue:val forKey:[NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:listView], key]];
}

- (void)resetValueForKey:(NSString *)key forListView:(SBIconListView *)listView {
    if(!listView) {
        [self resetValueForKey:key];
        return;
    }
    [self.preferences removeObjectForKey:[NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:listView], key]];
}

// Per-page layout creation/deletion and management

- (void)deleteCustomForListView:(SBIconListView *)listView {
    // Delete any keys for that list view
    NSString *prefix = [self stringIndexOfListView:listView];
    NSDictionary *preferences = [_preferences dictionaryRepresentation];
    for(NSString *key in [preferences allKeys]) {
        if([key hasPrefix:prefix]) {
            [self.preferences removeObjectForKey:key];
        }
    }

    NSMutableArray *perPage = [(NSArray *)[self rawValueForKey:@"_perPageListViews"] mutableCopy] ?: [NSMutableArray new];
    [perPage removeObject:prefix];
    [self setValue:perPage forKey:@"_perPageListViews"];

    [self updateLayoutForEditing:YES];
}

- (void)createCustomForListView:(SBIconListView *)listView {
    // Freeze list view settings to what the current global config is
    NSString *prefix = [self stringIndexOfListView:listView];

    NSMutableArray *perPage = [(NSArray *)[self rawValueForKey:@"_perPageListViews"] mutableCopy] ?: [NSMutableArray new];
    [perPage addObject:prefix];
    [self setValue:perPage forKey:@"_perPageListViews"];

    for(ARIOption *option in _optionsRegistry) {
        if(option.editorOption)
            [self.preferences setObject:[self rawValueForKey:option.settingKey]
                                 forKey:[NSString stringWithFormat:@"%@%@", prefix, option.settingKey]];
    }
    [self updateLayoutForEditing:YES];
}

- (BOOL)doesCustomConfigForListViewExist:(SBIconListView *)listView {
    NSArray *perPage = [self rawValueForKey:@"_perPageListViews"];
    if(!perPage) return NO;

    NSString *prefix = [self stringIndexOfListView:listView];

    return [perPage containsObject:prefix];
}

@end
