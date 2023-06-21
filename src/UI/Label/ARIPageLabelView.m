//
// Created by ren7995 on 2023-05-30 18:33:23
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import "ARIPageLabelView.h"
#import "../../Manager/ARITweakManager.h"

@implementation ARIPageLabelView

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSString *)loadRawText {
    SBIconListView *superv = (SBIconListView *)self.superview;
    ARITweakManager *manager = [ARITweakManager sharedInstance];
    NSString *text = [manager rawValueForKey:@"pageLabelText" forListView:superv];
    if(text) return text;
    return [NSString stringWithFormat:@"Page %d", (int)[manager indexOfListView:superv] + 1];
}

- (NSString *)processRawText:(NSString *)rawText isScheduledUpdate:(BOOL)scheduled {
    return rawText;
}

- (void)saveTextValue:(NSString *)text {
    [[ARITweakManager sharedInstance] setValue:text forKey:@"pageLabelText" forListView:(SBIconListView *)self.superview];
}

@end
