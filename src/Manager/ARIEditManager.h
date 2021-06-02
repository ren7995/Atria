//
// Created by ren7995 on 2021-04-25 16:02:02
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "src/Editor/ARIEditingView.h"
#import "src/Manager/ARITweak.h"

@interface SBHomeScreenViewController : UIViewController
@end

@interface ARIEditManager : NSObject <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) ARIEditingView *editView;
@property (nonatomic, readonly, assign) BOOL isEditing;
@property (nonatomic, readonly, strong) NSString *editingLocation;
@property (nonatomic, readonly, assign) BOOL singleListMode;
- (void)toggleEditView:(BOOL)toggle withTargetLocation:(NSString *)targetLoc;
- (NSMutableArray *)currentValidSettings;
- (void)setDockLayoutQueued;
- (void)toggleSingleListMode;
- (void)askForEdit;
- (SBIconListView *)currentIconListViewIfSinglePage;
+ (instancetype)sharedInstance;
@end
