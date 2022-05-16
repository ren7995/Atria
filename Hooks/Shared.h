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

#define IconListIsRoot(x) [x.iconLocation isEqualToString:@"SBIconLocationRoot"]
#define IconListIsDock(x) [x.iconLocation isEqualToString:@"SBIconLocationDock"]
#define IconListIsFloatingDock(x) [x.iconLocation isEqualToString:@"SBIconLocationFloatingDock"]
#define IconListIsAppLibrary(x) [x.iconLocation isEqualToString:@"SBIconLocationAppLibrary"]
#define IconListIsAppLibraryExpanded(x) [x.iconLocation isEqualToString:@"SBIconLocationAppLibraryCategoryPodExpanded"]
#define IconListIsFolder(x) [x.iconLocation isEqualToString:@"SBIconLocationFolder"]

#define IconIsInRoot(x) [x.location isEqualToString:@"SBIconLocationRoot"]
#define IconIsInDock(x) [x.location isEqualToString:@"SBIconLocationDock"]
#define IconIsInFloatingDock(x) [x.location isEqualToString:@"SBIconLocationFloatingDock"]
#define IconIsInAppLibrary(x) [x.location isEqualToString:@"SBIconLocationAppLibrary"]
#define IconIsInAppLibraryExpanded(x) [x.location isEqualToString:@"SBIconLocationAppLibraryCategoryPodExpanded"]
#define IconIsInFolder(x) [x.location isEqualToString:@"SBIconLocationFolder"]
