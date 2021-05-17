#import "src/Manager/ARIEditManager.h"
#include <objc/runtime.h>
#import "src/Editor/ARISettingCell.h"
#import "src/Manager/ARITweak.h"
#import "src/UI/ARISplashViewController.h"

@implementation ARIEditManager
{
    BOOL _isEditing;
    BOOL _queueDockLayout;
    BOOL _singleList;
    NSString *_editingLocation;
    SBIconListView *_current;
}

@synthesize isEditing = _isEditing;
@synthesize singleListMode = _singleList;
@synthesize editingLocation = _editingLocation;

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
        _editingLocation = targetLoc;
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
        view.currentSettingLabel.text = @"Choose a setting";
        // Update our label
        [view updateIsSingleListView];

        [UIView animateWithDuration:0.4f
            delay:0.0f
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                view.alpha = 1;
            }
            completion:^(BOOL finished) {
                [view toggleConfig:nil];
            }];
        self.editView = view;
    }
    else
    {
        // End edit
        if(!_isEditing) return;
        _isEditing = NO;
        _editingLocation = nil;

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
    if(!info)
    {
        [self askForEdit];
    }
    else
    {
        [self toggleEditView:[[info objectForKey:@"tag"] boolValue] withTargetLocation:[info objectForKey:@"loc"]];
    }
}

- (void)askForEdit
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atria"
                                                                   message:@"What would you like to edit?"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *root = [UIAlertAction actionWithTitle:@"Homescreen Pages"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [self toggleEditView:1
                                                         withTargetLocation:@"hs"];
                                                 }];
    UIAlertAction *dock = [UIAlertAction actionWithTitle:@"Dock"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action) {
                                                     [self toggleEditView:1
                                                         withTargetLocation:@"dock"];
                                                 }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                   }];
    [alert addAction:root];
    [alert addAction:dock];
    [alert addAction:cancel];

    ARITweak *manager = [ARITweak sharedInstance];
    if([manager boolValueForKey:@"showBackground"])
    {
        UIAlertAction *background = [UIAlertAction actionWithTitle:@"Background"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [self toggleEditView:1
                                                                   withTargetLocation:@"background"];
                                                           }];
        [alert addAction:background];
    }
    if([manager boolValueForKey:@"showWelcome"])
    {
        UIAlertAction *welcome = [UIAlertAction actionWithTitle:@"Welcome"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self toggleEditView:1
                                                                withTargetLocation:@"welcome"];
                                                        }];
        [alert addAction:welcome];
    }

    [[objc_getClass("SBIconController") sharedInstance] presentViewController:alert animated:YES completion:nil];
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
