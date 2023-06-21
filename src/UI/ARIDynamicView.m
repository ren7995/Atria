//
// Created by ren7995 on 2023-01-05 14:55:49
// Copyright (c) 2023 ren7995. All rights reserved.
//

#import "ARIDynamicView.h"

// https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromHexValue(r, a) [UIColor               \
    colorWithRed:((float)((r & 0xFF0000) >> 16)) / 255.0 \
           green:((float)((r & 0xFF00) >> 8)) / 255.0    \
            blue:((float)(r & 0xFF)) / 255.0             \
           alpha:a]

@implementation ARIDynamicView

- (instancetype)init {
    self = [super init];
    if(self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)updateView {
}

- (void)updateAnchors {
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    // On rotate or frame update
    [self updateAnchors];
}

+ (UIColor *)colorFromHexString:(NSString *)str withAlpha:(CGFloat)alpha {
    str = [str stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
    NSScanner *scanner = [NSScanner scannerWithString:str];
    unsigned int hexCode;
    [scanner scanHexInt:&hexCode];
    return UIColorFromHexValue(hexCode, alpha);
}

@end