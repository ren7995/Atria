#import "ARIEditManager.h"
#import "../Editor/ARISettingCell.h"
#import "ARITweakManager.h"

#include <objc/runtime.h>

@implementation ARIEditManager {
    BOOL _isEditing;
    BOOL _queueDockLayout;
    BOOL _singleList;
    NSString *_editingLocation;
    SBIconListView *_current;
}

@synthesize isEditing = _isEditing;
@synthesize singleListMode = _singleList;
@synthesize editingLocation = _editingLocation;

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static ARIEditManager *manager;
    dispatch_once(&token, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

// Edit helper

- (void)toggleEditView:(BOOL)toggle withTargetLocation:(NSString *)targetLoc {
    if(toggle) {
        // Start edit
        if(_isEditing) return;
        _isEditing = YES;
        _editingLocation = targetLoc;

        UIViewController *iconController = (UIViewController *)[objc_getClass("SBIconController") sharedInstance];

        // Check if this list view has custom config
        _current = [[ARITweakManager sharedInstance] currentListView];
        // No per page layout for the following
        if(![targetLoc isEqualToString:@"dock"] && ![targetLoc isEqualToString:@"pagedot"]) {
            _singleList = [[ARITweakManager sharedInstance] doesCustomConfigForListViewExist:_current];
        } else {
            _singleList = NO;
        }

        ARIEditingMainView *view = [[ARIEditingMainView alloc] initWithTarget:targetLoc];
        view.alpha = 0.0F;
        view.transform = CGAffineTransformMakeScale(0.25F, 0.25F);
        [iconController.view addSubview:view];
        [NSLayoutConstraint activateConstraints:@[
            [view.centerXAnchor constraintEqualToAnchor:iconController.view.centerXAnchor],
        ]];

        [UIView animateWithDuration:0.2f
            delay:0.25f
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                view.alpha = 1.0F;
                view.transform = CGAffineTransformMakeScale(1.0F, 1.0F);
            }
            completion:^(BOOL finished) {
                [view toggleOptionsView:nil];
            }];
        self.editView = view;
    } else {
        // End edit
        if(!_isEditing) return;
        _isEditing = NO;
        _editingLocation = nil;

        // Finish layout
        if(_queueDockLayout) {
            [[ARITweakManager sharedInstance] relayoutEntireIconModel];
            _queueDockLayout = NO;
        }

        [UIView animateWithDuration:0.15f
            delay:0.0f
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                self.editView.alpha = 0.0F;
                self.editView.transform = CGAffineTransformMakeScale(0.2F, 0.2F);
            }
            completion:^(BOOL finished) {
                [self.editView removeFromSuperview];
                self.editView = nil;
            }];
    }
}

- (void)setDockLayoutQueued {
    _queueDockLayout = YES;
}

- (void)presentEditAlert {
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atria"
                                                                   message:@"What would you like to edit?"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[self _createEditAlertAction:@"Homescreen Pages" editLocation:@"hs"]];
    [alert addAction:[self _createEditAlertAction:@"Dock" editLocation:@"dock"]];
    [alert addAction:[self _createEditAlertAction:@"Page Labels" editLocation:@"label"]];
    [alert addAction:[self _createEditAlertAction:@"Page Dots" editLocation:@"pagedot"]];
    if([manager boolValueForKey:@"showBackground"]) {
        [alert addAction:[self _createEditAlertAction:@"Background Blur" editLocation:@"blur"]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action){
                                            }]];

    [[objc_getClass("SBIconController") sharedInstance] presentViewController:alert animated:YES completion:nil];
}

- (UIAlertAction *)_createEditAlertAction:(NSString *)title editLocation:(NSString *)location {
    return [UIAlertAction actionWithTitle:title
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                      [self toggleEditView:YES
                                          withTargetLocation:location];
                                  }];
}

- (NSMutableArray *)currentValidSettings {
    return self.editView.validsettingsForTarget;
}

- (void)toggleSingleListMode {
    _singleList = !_singleList;
    // Update if we just set to single list mode
    if(_singleList) _current = [[ARITweakManager sharedInstance] currentListView];

    if(_singleList && ![[ARITweakManager sharedInstance] doesCustomConfigForListViewExist:_current]) {
        // Freeze config for the page
        [[ARITweakManager sharedInstance] createCustomForListView:_current];
    } else if(!_singleList) {
        // Clear custom config
        [[ARITweakManager sharedInstance] deleteCustomForListView:_current];
    }
}

- (SBIconListView *)currentIconListViewIfSinglePage {
    return _singleList ? _current : nil;
}

// Collection view delegate and data source

- (ARISettingCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ARISettingCell *cell = (ARISettingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"EditCell" forIndexPath:indexPath];
    NSString *key = self.editView.validsettingsForTarget[indexPath.row];
    cell.opLabel.text = [[ARITweakManager sharedInstance] getSettingByKey:key].translation;

    // Turn a key like "dock_inset_left" into "inset_left"
    NSArray *components = [key componentsSeparatedByString:@"_"];
    if([components count] > 1) {
        key = [key
            stringByReplacingOccurrencesOfString:[components[0] stringByAppendingString:@"_"]
                                      withString:@""];
    }

    // Calculate path and set image
    NSString *path = [NSString stringWithFormat:@THEOS_PACKAGE_INSTALL_PREFIX "/Library/PreferenceBundles/AtriaPrefs.bundle/Editor/%@.png", key];
    cell.img.image = [[UIImage imageWithContentsOfFile:path] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ?: [UIImage systemImageNamed:@"gear"];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)numberOfItemsInSection {
    return [self.editView.validsettingsForTarget count];
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.editView.validsettingsForTarget[indexPath.row];
    [self.editView setupForSettingKey:key];
    [self.editView toggleOptionsView:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(65, 65);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 10, 10, 10); // top, left, bottom, right
}

@end
