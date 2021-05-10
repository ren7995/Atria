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

@interface SBDockView : UIView
- (void)setBackgroundAlpha:(CGFloat)alpha;
- (void)_atriaUpdateDockForSettingsChanged;
@end

@class SBIconListView;
@interface SBIconListModel : NSObject
@property (nonatomic, strong) id folder;
- (NSUInteger)maxNumberOfIcons;
- (NSUInteger)numberOfNonPlaceholderIcons;
- (NSUInteger)numberOfIcons;
- (SBIconListView *)_atriaListView;
- (NSArray *)icons;
- (void)layout;
@end

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

@interface SBIconListView : UIView
@property (nonatomic, assign, getter=isEditing, nonatomic) BOOL editing;
@property (nonatomic, strong) NSString *iconLocation;
@property (nonatomic, assign) SBIconListFlowExtendedLayout *layout;
@property (nonatomic, assign) CGFloat iconContentScale;
@property (nonatomic, assign) UIEdgeInsets additionalLayoutInsets; // iOS 14
@property (nonatomic, assign) UIEdgeInsets layoutInsets;           // iOS 13

@property (nonatomic, strong) ARIWelcomeDynamicLabel *welcomeLabel;
@property (nonatomic, strong) ARIDynamicBackgroundView *_atriaBackground;
@property (nonatomic, strong) UITapGestureRecognizer *_atriaTap;
- (void)_atriaBeginEditing;
- (void)_updateWelcomeLabelWithPageBeingFirst:(BOOL)isFirst;
- (void)_updateAtriaBackground;

- (NSArray<SBIconView *> *)icons;
- (SBIconListViewLayoutMetrics *)layoutMetrics;
- (SBIcon *)iconAtCoordinate:(SBIconCoordinate)co metrics:(id)metrics;
- (SBIconCoordinate)coordinateForIcon:(id)icon;
- (CGPoint)originForIconAtCoordinate:(SBIconCoordinate)co metrics:(id)metrics;
- (CGSize)iconImageSizeForGridSizeClass:(NSUInteger)size;
- (CGSize)effectiveIconSpacing;
- (SBHIconGridSize)iconGridSizeForClass:(NSUInteger)cls;
- (void)setVisibleColumnRange:(NSRange)range;
- (void)setVisibleRowRange:(NSRange)range;
- (void)layoutIconsNow;
@end

@interface SBRootFolderView : UIView
@property (nonatomic, readonly, strong) NSArray<SBIconListView *> *iconListViews;
- (SBIconListView *)currentIconListView;
- (SBIconListView *)firstIconListView;
- (SBDockView *)dockView;
@end

@interface SBRootFolderController : UIViewController
- (SBRootFolderView *)rootFolderView;
@end

@interface SBHIconManager : NSObject
@property (nonatomic, assign, getter=isEditing) BOOL editing;
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
@property (nonatomic, readonly, assign) BOOL enabled;
@property (nonatomic, readonly, assign) BOOL firmware14;
@property (nonatomic, readonly, assign) BOOL didLoad;
- (void)updateLayoutForEditing:(BOOL)animated;
- (void)updateLayoutForRoot:(BOOL)forRoot forDock:(BOOL)forDock animated:(BOOL)animated;
- (void)feedbackForButton;
- (NSArray<NSString *> *)allSettingsKeys;
- (NSString *)stringRepresentationForSettingsKey:(NSString *)key;
- (NSArray<NSNumber *> *)rangeForSettingsKey:(NSString *)key;
- (NSUInteger)indexOfListView:(SBIconListView *)target;
- (NSArray<SBIconListView *> *)allRootListViews;
- (NSString *)stringIndexOfListView:(SBIconListView *)target;
- (SBIconListView *)currentListView;
- (SBIconListView *)firstIconListView;
- (void)deleteCustomForListView:(SBIconListView *)listView;
- (void)createCustomForListView:(SBIconListView *)listView;
- (BOOL)doesCustomConfigForListViewExist:(SBIconListView *)listView;
- (void)notifyDidLoad;
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
