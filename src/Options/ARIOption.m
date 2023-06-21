//
// Created by ren7995 on 2022-05-16 13:30:43
// Copyright (c) 2022 ren7995. All rights reserved.
//

#import "ARIOption.h"

@implementation ARIOption {
    NSString *_settingKey;
    NSString *_translation;
    id _defaultValue;
    float _lowerLimit;
    float _upperLimit;
    BOOL _accessibleWithEditor;
}

@synthesize settingKey = _settingKey;
@synthesize translation = _translation;
@synthesize defaultValue = _defaultValue;
@synthesize lowerLimit = _lowerLimit;
@synthesize upperLimit = _upperLimit;
@synthesize accessibleWithEditor = _accessibleWithEditor;

- (instancetype)initWithKey:(NSString *)settingKey
                translation:(NSString *)settingTranslation
               defaultValue:(id)defaultValue
                      range:(float *)range {
    self = [super init];
    if(self) {
        _settingKey = settingKey;
        _translation = settingTranslation;
        _defaultValue = defaultValue;
        _lowerLimit = range[0];
        _upperLimit = range[1];
        _accessibleWithEditor = _translation != nil;
    }
    return self;
}

@end