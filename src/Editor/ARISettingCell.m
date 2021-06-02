//
// Created by ren7995 on 2021-05-02 01:38:11
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/Editor/ARISettingCell.h"

@implementation ARISettingCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];

        UILabel *label = [UILabel new];
        [self addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        [NSLayoutConstraint activateConstraints:@[
            [label.widthAnchor constraintEqualToAnchor:self.widthAnchor],
            [label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [label.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [label.heightAnchor constraintEqualToConstant:15]
        ]];
        label.adjustsFontSizeToFitWidth = YES;
        label.numberOfLines = 1;
        label.minimumFontSize = 6;
        self.opLabel = label;

        UIImageView *img = [UIImageView new];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:img];
        img.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [img.widthAnchor constraintEqualToAnchor:img.heightAnchor],
            [img.topAnchor constraintEqualToAnchor:self.topAnchor],
            [img.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [img.bottomAnchor constraintEqualToAnchor:label.topAnchor
                                             constant:-5]
        ]];
        self.img = img;
        self.img.tintColor = label.textColor;

        [self layoutIfNeeded];
    }
    return self;
}

@end
