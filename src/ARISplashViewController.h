//
// Created by ren7995 on 2021-04-28 08:04:19
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARISplashViewController : UIViewController
- (void)addEntriesToStack:(NSArray *)entries;
- (instancetype)initWithEntries:(NSArray *)entries subtitle:(NSString *)subtitle;
@end
