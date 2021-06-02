//
// Created by ren7995 on 2021-04-27 22:17:01
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARITwitterCell.h"

@implementation ARITwitterCell {
    UIImageView *_icon;
    UILabel *_userLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/AtriaPrefs.bundle/ProfilePictures/%@.jpg", specifier.properties[@"name"]]]];
        [self addSubview:_icon];
        _icon.layer.masksToBounds = YES;
        _icon.layer.cornerCurve = kCACornerCurveCircular;
        _icon.layer.cornerRadius = 25;
        _icon.translatesAutoresizingMaskIntoConstraints = NO;

        [NSLayoutConstraint activateConstraints:@[
            [_icon.widthAnchor constraintEqualToConstant:50],
            [_icon.heightAnchor constraintEqualToAnchor:_icon.widthAnchor],
            [_icon.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                constant:20],
            [_icon.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];

        _userLabel = [[UILabel alloc] init];
        _userLabel.text = [NSString stringWithFormat:@"%@ - %@", specifier.properties[@"name"], specifier.properties[@"description"]];
        _userLabel.numberOfLines = 0;
        _userLabel.font = [UIFont systemFontOfSize:14];
        _userLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_userLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_userLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor
                                                      constant:-20],
            [_userLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_userLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor
                                                    constant:-10],
            [_userLabel.leadingAnchor constraintEqualToAnchor:_icon.trailingAnchor
                                                     constant:10],
        ]];
    }

    return self;
}

@end
