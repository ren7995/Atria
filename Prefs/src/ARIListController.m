//
// Created by ren7995 on 2023-05-25 21:53:35
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import "ARIListController.h"

@implementation ARIListController

- (void)viewWillAppear:(BOOL)animated {
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setTintColor:kPrefTintColor];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setOnTintColor:kPrefTintColor];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setTintColor:kPrefTintColor];

    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *respring = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(promptRespring:)];
    self.navigationItem.rightBarButtonItem = respring;
}

- (void)promptRespring:(id)sender {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Respring"
                         message:@"Are you sure you want to respring?"
                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction
        actionWithTitle:@"No"
                  style:UIAlertActionStyleCancel
                handler:nil];

    UIAlertAction *yes = [UIAlertAction
        actionWithTitle:@"Yes"
                  style:UIAlertActionStyleDestructive
                handler:^(UIAlertAction *action) {
                    [self respringWithAnimation];
                }];

    [alert addAction:defaultAction];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)respringWithAnimation {
    self.view.userInteractionEnabled = NO;

    UIVisualEffectView *matEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial]];
    matEffect.alpha = 0.0F;
    matEffect.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [view addSubview:matEffect];
    [NSLayoutConstraint activateConstraints:@[
        [matEffect.widthAnchor constraintEqualToAnchor:view.widthAnchor],
        [matEffect.heightAnchor constraintEqualToAnchor:view.heightAnchor],
        [matEffect.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [matEffect.centerYAnchor constraintEqualToAnchor:view.centerYAnchor]
    ]];

    [UIView animateWithDuration:1.0f
        delay:0.0f
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
            matEffect.alpha = 1.0F;
        }
        completion:^(BOOL finished) {
            // Respring
            NSTask *t = [[NSTask alloc] init];
            [t setLaunchPath:@THEOS_PACKAGE_INSTALL_PREFIX "/usr/bin/killall"];
            [t setArguments:[NSArray arrayWithObjects:@"SpringBoard", nil]];
            [t launch];

            // Kill settings app
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                exit(0);
            });
        }];
}

@end