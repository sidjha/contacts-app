//
//  AppDelegate.h
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 12/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *initialStoryboard;

#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

- (void)resetWindowToInitialView;

@end

