//
// Created by ren7995 on 2021-04-27 18:20:41
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "../ARIDynamicView.h"

static NSString *const ARIUpdateLabelVisibilityNotification = @"me.lau.Atria/UpdateLabelVisibility";

@interface ARILabelView : ARIDynamicView <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) CGPoint portraitOrigin;
@property (nonatomic, assign) CGPoint landscapeOrigin;
- (instancetype)init;
- (void)setupTextField:(UITextField *)textField;
- (NSString *)loadRawText;
- (NSString *)processRawText:(NSString *)rawText isScheduledUpdate:(BOOL)scheduled;
- (void)saveTextValue:(NSString *)text;
@end
