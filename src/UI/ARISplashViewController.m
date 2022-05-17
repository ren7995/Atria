//
// Created by ren7995 on 2021-04-28 08:04:44
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARISplashViewController.h"

// RGB: 81, 8, 126
#define kTintColor [UIColor colorWithRed:0.32 green:0.03 blue:0.49 alpha:1.0]

@implementation ARISplashViewController {
    UIVisualEffectView *_matEffect;
    UIImageView *_tweakIcon;
    UILabel *_tweakLabel;
    UILabel *_description;
    UILabel *_ren;
    UIButton *_dismiss;
    UIStackView *_infoStack;
    NSArray *_entries;
    NSString *_subtitle;
}

- (instancetype)initWithEntries:(NSArray *)entries subtitle:(NSString *)subtitle {
    self = [super init];
    if(self) {
        _entries = entries;
        _subtitle = subtitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalInPresentation = YES;

    // Blur addiction
    _matEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial]];
    [self.view addSubview:_matEffect];
    _matEffect.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_matEffect.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [_matEffect.heightAnchor constraintEqualToAnchor:self.view.heightAnchor],
        [_matEffect.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_matEffect.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];

    // Tweak icon
    _tweakIcon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AtriaPrefs.bundle/glyph.png"] ?: [UIImage systemImageNamed:@"gearshape"]];
    [self.view addSubview:_tweakIcon];
    _tweakIcon.layer.masksToBounds = YES;
    _tweakIcon.layer.cornerCurve = kCACornerCurveContinuous;
    _tweakIcon.layer.cornerRadius = 12;
    _tweakIcon.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [_tweakIcon.widthAnchor constraintEqualToConstant:UIScreen.mainScreen.bounds.size.width < 375 ? 60 : 90],
        [_tweakIcon.heightAnchor constraintEqualToAnchor:_tweakIcon.widthAnchor],
        [_tweakIcon.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_tweakIcon.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                             constant:40],
    ]];

    _tweakLabel = [[UILabel alloc] init];
    _tweakLabel.text = @"Atria";
    _tweakLabel.numberOfLines = 0;
    _tweakLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightBold];
    _tweakLabel.textAlignment = NSTextAlignmentCenter;
    _tweakLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tweakLabel];
    [NSLayoutConstraint activateConstraints:@[
        [_tweakLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                constant:-50],
        [_tweakLabel.heightAnchor constraintEqualToConstant:40],
        [_tweakLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_tweakLabel.topAnchor constraintEqualToAnchor:_tweakIcon.bottomAnchor
                                              constant:5],
    ]];

    _description = [[UILabel alloc] init];
    _description.text = _subtitle;
    _description.numberOfLines = 0;
    //_description.adjustsFontSizeToFitWidth = YES;
    //_description.minimumFontSize = 9;
    _description.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    _description.textAlignment = NSTextAlignmentCenter;
    _description.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_description];
    [NSLayoutConstraint activateConstraints:@[
        [_description.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                 constant:-50],
        [_description.heightAnchor constraintEqualToConstant:35],
        [_description.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_description.topAnchor constraintEqualToAnchor:_tweakLabel.bottomAnchor
                                               constant:5],
    ]];

    // Dismiss button
    _dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    [_dismiss addTarget:self
                  action:@selector(dismissSelf:)
        forControlEvents:UIControlEventTouchUpInside];
    [_dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    _dismiss.layer.cornerRadius = 20;
    _dismiss.layer.masksToBounds = YES;
    _dismiss.layer.cornerCurve = kCACornerCurveContinuous;
    _dismiss.backgroundColor = kTintColor;

    [self.view addSubview:_dismiss];
    _dismiss.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_dismiss.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                             constant:-100],
        [_dismiss.heightAnchor constraintEqualToConstant:60],
        [_dismiss.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_dismiss.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                              constant:-50],
    ]];

    // My label
    _ren = [[UILabel alloc] init];
    _ren.text = @"made with love by ren7995";
    _ren.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    _ren.textAlignment = NSTextAlignmentCenter;
    _ren.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_ren];
    [NSLayoutConstraint activateConstraints:@[
        [_ren.widthAnchor constraintEqualToAnchor:_dismiss.widthAnchor],
        [_ren.heightAnchor constraintEqualToConstant:20],
        [_ren.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_ren.bottomAnchor constraintEqualToAnchor:_dismiss.topAnchor
                                          constant:-10],
    ]];

    // Info stack
    _infoStack = [[UIStackView alloc] init];
    _infoStack.alignment = UIStackViewAlignmentTop;
    _infoStack.axis = UILayoutConstraintAxisVertical;
    _infoStack.distribution = UIStackViewDistributionFillEqually;
    _infoStack.spacing = 10;
    _infoStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_infoStack];
    [NSLayoutConstraint activateConstraints:@[
        [_infoStack.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                               constant:-40],
        [_infoStack.topAnchor constraintEqualToAnchor:_description.bottomAnchor
                                             constant:5],
        [_infoStack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_infoStack.bottomAnchor constraintEqualToAnchor:_ren.topAnchor
                                                constant:-10],
    ]];

    [self addEntriesToStack:_entries];
}

- (void)addEntriesToStack:(NSArray *)entries {
    if(!_infoStack) return;

    // Entries
    // We use an NSArray of dicts so we have defined order. Just one NSDictionary would not
    // have defined order when enumerating -allKeys
    for(NSDictionary *dict in entries) {
        // NSDictionary<NSString *, UIImage *> *

        NSString *text = [dict allKeys][0];
        UIImage *image = dict[text];

        UILabel *label = [[UILabel alloc] init];
        UIView *entryView = [UIView new];

        entryView.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoStack addArrangedSubview:entryView];
        [entryView.heightAnchor constraintEqualToConstant:75].active = YES;
        [entryView.widthAnchor constraintEqualToAnchor:_infoStack.widthAnchor].active = YES;

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.contentMode = UIViewContentModeCenter;
        if(50 > image.size.width && 50 > image.size.height) {
            imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        imageView.tintColor = label.textColor; // Use the label's adaptive coloring
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [entryView addSubview:imageView];
        [entryView addSubview:label];
        [NSLayoutConstraint activateConstraints:@[
            [imageView.widthAnchor constraintEqualToAnchor:imageView.heightAnchor],
            [imageView.heightAnchor constraintEqualToConstant:UIScreen.mainScreen.bounds.size.width < 375 ? 25 : 40],
            [imageView.leadingAnchor constraintEqualToAnchor:entryView.leadingAnchor
                                                    constant:5],
            [imageView.centerYAnchor constraintEqualToAnchor:entryView.centerYAnchor],
        ]];

        label.text = text;
        label.font = [UIFont systemFontOfSize:UIScreen.mainScreen.bounds.size.width < 375 ? 8 : 12];
        label.numberOfLines = 0;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [label sizeToFit];
        [NSLayoutConstraint activateConstraints:@[
            [label.trailingAnchor constraintEqualToAnchor:entryView.trailingAnchor],
            [label.heightAnchor constraintEqualToAnchor:entryView.heightAnchor],
            [label.leadingAnchor constraintEqualToAnchor:imageView.trailingAnchor
                                                constant:10],
            [label.centerYAnchor constraintEqualToAnchor:entryView.centerYAnchor],
        ]];
    }
}

- (void)dismissSelf:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end