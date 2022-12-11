//
// Created by ren7995 on 2022-05-16 13:30:44
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARIOption : NSObject
@property (nonatomic, readonly, strong) NSString *settingKey;
@property (nonatomic, readonly, strong) NSString *settingTranslation;
@property (nonatomic, readonly, strong) id defaultValue;
@property (nonatomic, readonly, strong) NSArray<NSNumber *> *range;
@property (nonatomic, readonly, assign) BOOL accessibleWithEditor;
- (instancetype)initWithKey:(NSString *)settingKey
                translation:(NSString *)settingTranslation
               defaultValue:(id)defaultValue
                      range:(NSArray<NSNumber *> *)range;
@end