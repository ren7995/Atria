//
// Created by ren7995 on 2021-04-25 12:49:18
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// AppLibrary = SBIconLocationAppLibrary
// Root = SBIconLocationRoot
// Dock = SBIconLocationDock
// AppLibraryExpandedPod = SBIconLocationAppLibraryCategoryPodExpanded
// TodayView = SBIconLocationTodayView
// Folder = SBIconLocationFolder

#define kIconListIsRoot(x) [x.iconLocation isEqualToString:@"SBIconLocationRoot"]
#define kIconListIsDock(x) [x.iconLocation isEqualToString:@"SBIconLocationDock"]
#define kIconListIsFloatingDock(x) [x.iconLocation isEqualToString:@"SBIconLocationFloatingDock"]
#define kIconListIsAppLibrary(x) [x.iconLocation isEqualToString:@"SBIconLocationAppLibrary"]
#define kIconListIsAppLibraryExpanded(x) [x.iconLocation isEqualToString:@"SBIconLocationAppLibraryCategoryPodExpanded"]
#define kIconListIsFolder(x) [x.iconLocation isEqualToString:@"SBIconLocationFolder"]

#define kIconIsInRoot(x) [x.location isEqualToString:@"SBIconLocationRoot"]
#define kIconIsInDock(x) [x.location isEqualToString:@"SBIconLocationDock"]
#define kIconIsInFloatingDock(x) [x.location isEqualToString:@"SBIconLocationFloatingDock"]
#define kIconIsInAppLibrary(x) [x.location isEqualToString:@"SBIconLocationAppLibrary"]
#define kIconIsInAppLibraryExpanded(x) [x.location isEqualToString:@"SBIconLocationAppLibraryCategoryPodExpanded"]
#define kIconIsInFolder(x) [x.location isEqualToString:@"SBIconLocationFolder"]
