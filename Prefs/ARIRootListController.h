//
// Created by ren7995 on 2021-04-17 13:45:46
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSliderTableCell.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

@interface ARIRootListController : PSListController
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@end

@interface NSTask : NSObject
@property (copy) NSArray *arguments;
@property (copy) NSString *launchPath;
- (id)init;
- (void)waitUntilExit;
- (void)launch;
@end
