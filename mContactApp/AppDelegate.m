//
//  AppDelegate.m
//  mContactApp
//
//  Created by Sid Jha on 12/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "AppDelegate.h"

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "AFNetworkActivityIndicatorManager.h"

#import "StackedViewController.h"

#import "Flurry.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)resetWindowToInitialView
{
    for (UIView* view in self.window.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIViewController* initialScene = [_initialStoryboard instantiateInitialViewController];
    self.window.rootViewController = initialScene;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _initialStoryboard = self.window.rootViewController.storyboard;
    
    [[UIButton appearance] setTintColor:[UIColor colorWithRed:0.41 green:0.40 blue:0.85 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.41 green:0.40 blue:0.85 alpha:1.0]];
    
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:2fff4c6c-c171-4016-b8f8-3fa3bc4bb6a2"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    
    // Initialize analytics

    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8UserID"];
    
    if (username) {
        [Flurry setUserID:username];
    }
    
    [Flurry startSession:@"DCQTDGT92M6CFQQ47SHV"];
    
    // Push StackedViewController on directly if user logged in
    
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];

    if (authToken) {
        StackedViewController *controller = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"card"];
        
        [self.window setRootViewController:controller];
        
       // [self presentViewController:controller animated:YES completion:nil];

    }
    
    return YES;
}

/*
 - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
 
 [AWSS3TransferUtility interceptApplication:application
 handleEventsForBackgroundURLSession:identifier
 completionHandler:completionHandler];
 }
 
 */

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
