//
// Created by ren7995 on 2023-05-25 21:52:05
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import "ARIChildListController.h"

@implementation ARIChildListController {
    NSString *_childName;
}

- (NSArray *)specifiers {
    if(!_specifiers && _childName) {
        _specifiers = [self loadSpecifiersFromPlistName:_childName target:self];
    }

    return _specifiers;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
    _childName = [specifier propertyForKey:@"child"];
    [self specifiers];
}

- (BOOL)shouldReloadSpecifiersOnResume {
    return NO;
}

@end
