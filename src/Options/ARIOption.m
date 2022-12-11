//
// Created by ren7995 on 2022-05-16 13:30:43
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "ARIOption.h"

@implementation ARIOption {
    NSString *_settingKey;
    NSString *_settingTranslation;
    id _defaultValue;
    NSArray<NSNumber *> *_range;
    BOOL _accessibleWithEditor;
}

@synthesize settingKey = _settingKey;
@synthesize settingTranslation = _settingTranslation;
@synthesize defaultValue = _defaultValue;
@synthesize range = _range;
@synthesize accessibleWithEditor = _accessibleWithEditor;

- (instancetype)initWithKey:(NSString *)settingKey
                translation:(NSString *)settingTranslation
               defaultValue:(id)defaultValue
                      range:(NSArray<NSNumber *> *)range {
    self = [super init];
    if(self) {
        _settingKey = settingKey;
        _settingTranslation = settingTranslation;
        _defaultValue = defaultValue;
        _range = range;
        _accessibleWithEditor = _settingTranslation != nil;
    }
    return self;
}

@end