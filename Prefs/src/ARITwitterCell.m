//
// Created by ren7995 on 2021-04-27 22:17:01
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARITwitterCell.h"

@implementation ARITwitterCell {
    UIImageView *_icon;
    UILabel *_userLabel;
    NSString *_username;
    NSString *_displayName;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
          specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self) {
        _icon = [[UIImageView alloc] initWithImage:nil];
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

        _username = specifier.properties[@"username"];
        _displayName = specifier.properties[@"displayName"];

        _userLabel = [[UILabel alloc] init];
        _userLabel.text = [NSString stringWithFormat:@"%@ - %@", _displayName, specifier.properties[@"description"]];
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
        [self loadImage];
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
    [super refreshCellContentsWithSpecifier:specifier];
    [self.specifier setTarget:self];
    [self.specifier setButtonAction:@selector(openTwitter)];
}

- (void)loadImage {
    NSString *path = [NSString stringWithFormat:@THEOS_PACKAGE_INSTALL_PREFIX "/Library/PreferenceBundles/AtriaPrefs.bundle/ProfilePictures/%@.jpg", _displayName];
    _icon.image = [UIImage imageWithContentsOfFile:path] ?: [UIImage systemImageNamed:@"person.circle"];
}

- (void)openTwitter {
    if(!_username) return;
    UIApplication *application = [UIApplication sharedApplication];
    NSString *url = [@"https://twitter.com/" stringByAppendingString:_username];
    [application openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

@end
