//
// Created by ren7995 on 2021-04-27 19:44:31
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARIHeaderCell.h"

@implementation ARIHeaderCell {
    UIImageView *_icon;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@THEOS_PACKAGE_INSTALL_PREFIX "/Library/PreferenceBundles/AtriaPrefs.bundle/full.png"]];
        [self addSubview:_icon];
        _icon.layer.masksToBounds = YES;
        _icon.layer.cornerCurve = kCACornerCurveContinuous;
        _icon.layer.cornerRadius = 12;
        _icon.translatesAutoresizingMaskIntoConstraints = NO;

        [NSLayoutConstraint activateConstraints:@[
            [_icon.widthAnchor constraintEqualToConstant:60],
            [_icon.heightAnchor constraintEqualToConstant:60],
            [_icon.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_icon.topAnchor constraintEqualToAnchor:self.topAnchor
                                            constant:10],
        ]];

        UILabel *label = [[UILabel alloc] init];
        label.text = @"Version " PACKAGE_VERSION " (" PACKAGE_TYPE ")";
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:label];
        [NSLayoutConstraint activateConstraints:@[
            [label.widthAnchor constraintEqualToAnchor:self.widthAnchor
                                              constant:-50],
            [label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                               constant:-10],
            [label.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [label.topAnchor constraintEqualToAnchor:_icon.bottomAnchor
                                            constant:10],
        ]];
    }

    return self;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)style {
    [super setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)setBackgroundColor:(UIColor *)color {
    [super setBackgroundColor:[UIColor clearColor]];
}

@end
