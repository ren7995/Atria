//
// Created by ren7995 on 2021-04-27 22:17:01
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARITwitterCell.h"

@implementation ARITwitterCell {
    UIImageView *_icon;
    UILabel *_userLabel;
    NSString *_username;
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

        _userLabel = [[UILabel alloc] init];
        _userLabel.text = [NSString stringWithFormat:@"%@ - %@", specifier.properties[@"displayName"], specifier.properties[@"description"]];
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [NSString stringWithFormat:@"/Library/PreferenceBundles/AtriaPrefs.bundle/ProfilePictures/%@.dat", _username];
        UIImage *savedImage = [UIImage imageWithContentsOfFile:path];
        if(savedImage) {
            // Set saved image on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                _icon.image = savedImage;
            });
        } else {
            // Set temporary image while loading
            dispatch_async(dispatch_get_main_queue(), ^{
                _icon.image = [UIImage systemImageNamed:@"person.circle"];
            });

            // Find twitter avatar
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://unavatar.io/twitter/%@", _username]];
            NSData *data = [[NSData alloc] initWithContentsOfURL:url];
            // Save avatar
            [data writeToFile:path atomically:YES];

            // Go back to main thread to set to new avatar
            dispatch_async(dispatch_get_main_queue(), ^{
                _icon.image = [UIImage imageWithData:data];
            });
        }
    });
}

- (void)openTwitter {
    UIApplication *application = [UIApplication sharedApplication];
    NSString *url = [@"https://twitter.com/" stringByAppendingString:_username];
    [application openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

@end
