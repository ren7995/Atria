//
// Created by ren7995 on 2021-04-25 12:49:12
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SBIconView;
@class SBIconListFlowExtendedLayout;
@class SBIconListViewLayoutMetrics;
@class ARIWelcomeDynamicLabel;
@class ARIDynamicBackgroundView;

typedef struct SBHIconGridSize
{
    short width;
    short height;
} SBHIconGridSize;

typedef struct SBIconCoordinate
{
    NSInteger row;
    NSInteger col;
} SBIconCoordinate;

@interface SBIcon : NSObject
- (NSUInteger)gridSizeClass;
@end

@interface SBDockView : NSObject
- (void)setBackgroundAlpha:(CGFloat)alpha;
@end

@class SBIconListView;
@interface SBIconListModel : NSObject
@property (nonatomic, strong) NSString *_atriaLocation;
@property (nonatomic, strong) id folder;
- (NSUInteger)maxNumberOfIcons;
- (NSUInteger)numberOfNonPlaceholderIcons;
- (NSUInteger)numberOfIcons;
- (SBIconListView *)_atriaListView;
- (NSArray *)icons;
- (void)layout;
@end

@interface SBIconListView : UIView
@property (nonatomic, assign, getter=isEditing, nonatomic) BOOL editing;
@property (nonatomic, strong) NSString *iconLocation;
@property (nonatomic, assign) SBIconListFlowExtendedLayout *layout;
@property (nonatomic, assign) CGFloat iconContentScale;
@property (nonatomic, assign) UIEdgeInsets additionalLayoutInsets;

@property (nonatomic, strong) ARIWelcomeDynamicLabel *welcomeLabel;
@property (nonatomic, strong) ARIDynamicBackgroundView *_atriaBackground;
- (void)_updateWelcomeLabelWithPageBeingFirst:(BOOL)isFirst;
- (void)_updateAtriaBackground;

- (NSArray<SBIconView *> *)icons;
- (SBIconListViewLayoutMetrics *)layoutMetrics;
- (SBIconListModel *)model;
- (SBIcon *)iconAtCoordinate:(SBIconCoordinate)co metrics:(id)metrics;
- (SBIconCoordinate)coordinateForIcon:(id)icon;
- (CGPoint)originForIconAtCoordinate:(SBIconCoordinate)co metrics:(id)metrics;
- (CGSize)iconImageSizeForGridSizeClass:(NSUInteger)size;
- (CGSize)effectiveIconSpacing;
- (SBHIconGridSize)iconGridSizeForClass:(NSUInteger)cls;
- (NSUInteger)iconRowsForCurrentOrientation;
- (NSUInteger)iconColumnsForCurrentOrientation;
- (void)layoutIconsNow;
@end

@interface SBRootFolderView : UIView
@property (nonatomic, readonly, strong) NSArray<SBIconListView *> *iconListViews;
- (SBIconListView *)currentIconListView;
- (SBIconListView *)dockListView;
- (SBIconListView *)firstIconListView;
- (SBDockView *)dockView;
@end

@interface SBRootFolderController : UIViewController
- (SBRootFolderView *)rootFolderView;
@end

@interface SBHIconManager : NSObject
- (SBIconListModel *)iconModel;
- (BOOL)relayout;
@end

@interface SBIconController : UIViewController
- (SBRootFolderController *)_rootFolderController;
- (SBHIconManager *)iconManager;
+ (SBIconController *)sharedInstance;
@end

@interface ARITweak : NSObject
@property (nonatomic, readonly, strong) NSUserDefaults *preferences;
@property (nonatomic, readonly, strong) NSMapTable *listViewModelMap;
@property (nonatomic, readonly, assign) BOOL enabled;
- (void)updateLayoutAnimated:(BOOL)animated;
- (void)feedbackForButton;
- (NSArray<NSString *> *)allSettingsKeys;
- (NSString *)stringRepresentationForSettingsKey:(NSString *)key;
- (NSArray<NSNumber *> *)rangeForSettingsKey:(NSString *)key;
- (NSUInteger)indexOfListView:(SBIconListView *)target;
- (NSString *)stringIndexOfListView:(SBIconListView *)target;
- (SBIconListView *)currentListView;
- (SBIconListView *)firstIconListView;
- (void)deleteCustomForListView:(SBIconListView *)listView;
- (void)createCustomForListView:(SBIconListView *)listView;
- (BOOL)doesCustomConfigForListViewExist:(SBIconListView *)listView;
+ (instancetype)sharedInstance;

// Prefs functions
- (int)intValueForKey:(NSString *)key;
- (float)floatValueForKey:(NSString *)key;
- (BOOL)boolValueForKey:(NSString *)key;
- (id)rawValueForKey:(NSString *)key;
- (void)setValue:(id)val forKey:(NSString *)key;
- (void)resetValueForKey:(NSString *)key;

// Per list
- (int)intValueForKey:(NSString *)key forListView:(SBIconListView *)list;
- (BOOL)boolValueForKey:(NSString *)key forListView:(SBIconListView *)list;
- (id)rawValueForKey:(NSString *)key forListView:(SBIconListView *)list;
- (float)floatValueForKey:(NSString *)key forListView:(SBIconListView *)list;
- (void)setValue:(id)val forKey:(NSString *)key listView:(SBIconListView *)listView;
- (void)resetValueForKey:(NSString *)key listView:(SBIconListView *)listView;
@end
