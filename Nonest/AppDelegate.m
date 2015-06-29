//
//  AppDelegate.m
//  Nonest
//
//  Created by 細田 大志 on 2014/03/14.
//  Copyright (c) 2014年 細田 大志. All rights reserved.
//

#import "AppDelegate.h"
#import "EvernoteSession.h"
#import "ENConstants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
    NSString *CONSUMER_KEY = @"bigamition";
    NSString *CONSUMER_SECRET = @"e06c80eed42f8987";
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
    // Override point for customization after application launch.
    
    [[UILabel appearance] setFont:[UIFont fontWithName:@"Helvetica-Light" size:15.0f]];
    
    //navigationbar color custom
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000];
    [UINavigationBar appearance].tintColor = [UIColor colorWithRed:0.996 green:0.996 blue:0.996 alpha:1.0];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.000]};
    //navigationbar 1px ボーダー　消す
    [[UINavigationBar appearance] setBackgroundImage: [self imageWithColor: [UIColor colorWithRed:0.349 green:1.000 blue:0.847 alpha:1.000]]
                                      forBarPosition: UIBarPositionAny
                                          barMetrics: UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage: [self imageWithColor: [UIColor clearColor]]];
    
    //statusbar white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    return YES;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    //navigationbar 1px ボーダー　消す
    UIView *__view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 1.0f, 1.0f)];
    __view.backgroundColor = color;
    UIGraphicsBeginImageContext(__view.frame.size);
    CGContextRef __context = UIGraphicsGetCurrentContext();
    [__view.layer renderInContext: __context];
    UIImage *__image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return __image;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
