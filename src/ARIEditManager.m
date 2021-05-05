#import "src/ARIEditManager.h"
#include <objc/runtime.h>
#import "src/ARISettingCell.h"
#import "src/ARISplashViewController.h"
#import "src/ARITweak.h"

@implementation ARIEditManager
{
    BOOL _isEditing;
    BOOL _queueDockLayout;
    BOOL _singleList;
    SBIconListView *_current;
}

@synthesize isEditing = _isEditing;
@synthesize singleListMode = _singleList;

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(startEdit:)
                   name:@"me.ren7995.atria.edit"
                 object:nil];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    static ARIEditManager *manager;
    dispatch_once(&token, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

// Edit helper

- (void)toggleEditView:(BOOL)toggle withTargetLocation:(NSString *)targetLoc
{
    if(toggle)
    {
        // Start edit
        if(_isEditing) return;
        _isEditing = YES;
        UIViewController *presenter = (UIViewController *)[objc_getClass("SBIconController") sharedInstance];

        // Check if this list view has custom config
        _current = [[ARITweak sharedInstance] currentListView];
        // No per page layout for dock or welcome
        if(![targetLoc isEqualToString:@"dock"] && ![targetLoc isEqualToString:@"welcome"])
        {
            _singleList = [[ARITweak sharedInstance] doesCustomConfigForListViewExist:_current];
        }
        else
        {
            _singleList = NO;
        }

        ARIEditingView *view = [[ARIEditingView alloc] initWithTarget:targetLoc];
        view.alpha = 0;
        [presenter.view addSubview:view];
        [NSLayoutConstraint activateConstraints:@[
            [view.centerXAnchor constraintEqualToAnchor:presenter.view.centerXAnchor],
        ]];
        // Update our label
        [view updateIsSingleListView];

        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             view.alpha = 1;
                         }
                         completion:NULL];
        self.editView = view;
    }
    else
    {
        // End edit
        if(!_isEditing) return;
        _isEditing = NO;

        // Finish layout
        // This lags the device bad in some cases, so limit this as much as possible!
        if(_queueDockLayout)
        {
            [[[[objc_getClass("SBIconController") sharedInstance] iconManager] iconModel] layout];
            _queueDockLayout = NO;
        }

        [UIView animateWithDuration:0.4f
            delay:0.0f
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                self.editView.alpha = 0;
            }
            completion:^(BOOL finished) {
                [self.editView removeFromSuperview];
                self.editView = nil;
            }];
    }
}

- (void)setDockLayoutQueued
{
    _queueDockLayout = YES;
}

- (void)startEdit:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    [self toggleEditView:[[info objectForKey:@"tag"] boolValue] withTargetLocation:[info objectForKey:@"loc"]];
}

- (NSMutableArray *)currentValidSettings
{
    return self.editView.validsettingsForTarget;
}

- (void)toggleSingleListMode
{
    _singleList = !_singleList;
    // Update if we just set to single list mode
    if(_singleList) _current = [[ARITweak sharedInstance] currentListView];

    if(_singleList && ![[ARITweak sharedInstance] doesCustomConfigForListViewExist:_current])
    {
        // Freeze config for the page
        [[ARITweak sharedInstance] createCustomForListView:_current];
    }
    else if(!_singleList)
    {
        // Clear custom config
        [[ARITweak sharedInstance] deleteCustomForListView:_current];
    }
}

- (SBIconListView *)currentIconListViewIfSinglePage
{
    return _singleList ? _current : nil;
}

// Collection view delegate and data source

- (ARISettingCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ARISettingCell *cell = (ARISettingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"EditCell" forIndexPath:indexPath];
    NSString *key = self.editView.validsettingsForTarget[indexPath.row];

    NSString *string = [[ARITweak sharedInstance] stringRepresentationForSettingsKey:key];
    cell.opLabel.text = string;

    NSArray *prefixes = @[ @"hs_", @"dock_", @"welcome_", @"background_" ];
    for(NSString *prefix in prefixes)
    {
        // This is much better than having duplicate icons in the package
        key = [key stringByReplacingOccurrencesOfString:prefix withString:@""];
    }

    // Calculate path and set image
    NSString *path = [NSString stringWithFormat:@"/Library/PreferenceBundles/AtriaPrefs.bundle/Editor/%@.png", key];
    cell.img.image = [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ?: [UIImage systemImageNamed:@"gear"];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)numberOfItemsInSection
{
    return [self.editView.validsettingsForTarget count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = self.editView.validsettingsForTarget[indexPath.row];
    [self.editView setupForSettingKey:key];
    [self.editView toggleConfig:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(65, 65);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 10, 10, 10); // top, left, bottom, right
}

@end
