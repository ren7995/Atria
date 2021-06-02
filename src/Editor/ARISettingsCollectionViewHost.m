//
// Created by ren7995 on 2021-05-02 00:44:58
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/Editor/ARISettingsCollectionViewHost.h"
#import "src/Editor/ARISettingCell.h"
#import "src/Manager/ARIEditManager.h"
#import "src/UI/ARIFadeEffectView.h"

@implementation ARISettingsCollectionViewHost

- (instancetype)init {
    // This class "hosts" a UICollectionView and handles a gradient fade effect on the edges
    self = [super init];
    if(self) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *coll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        coll.backgroundColor = [UIColor clearColor];
        [coll setShowsHorizontalScrollIndicator:YES];
        [coll setShowsVerticalScrollIndicator:NO];
        [coll registerClass:[ARISettingCell class] forCellWithReuseIdentifier:@"EditCell"];
        coll.delegate = [ARIEditManager sharedInstance];
        coll.dataSource = [ARIEditManager sharedInstance];

        [self addSubview:coll];
        coll.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [coll.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [coll.heightAnchor constraintEqualToAnchor:self.heightAnchor],
            [coll.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [coll.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        ]];

        self.collectionView = coll;
    }
    return self;
}

- (void)setupGradient {
    ARIFadeEffectView *fade = [ARIFadeEffectView new];
    [self addSubview:fade];
    fade.frame = self.bounds;
    [fade setupFade];

    self.maskView = fade;
}

@end
