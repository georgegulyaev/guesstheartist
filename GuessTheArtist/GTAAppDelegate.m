//
//  GTAAppDelegate.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/4/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAAppDelegate.h"
#import "CoreDataManager.h"
//#import "GTAHomeScreenViewController.h"

@interface GTAAppDelegate ()

@property BOOL importIsNeeded;

@end

@implementation GTAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CoreDataManager sharedInstance];
    //[[GTAAudioPlayer sharedInstance] playCover];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [CoreDataManager save:[CoreDataManager sharedInstance].managedObjectContext];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [CoreDataManager save:[CoreDataManager sharedInstance].managedObjectContext];
    NSLog(@"Background mode");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[GTAAudioPlayer sharedInstance] pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"Active!");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appIsActive" object:nil];
    //if (![GTAAudioPlayer sharedInstance].isPlaying)
        //[[GTAAudioPlayer sharedInstance] play];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [CoreDataManager save:[CoreDataManager sharedInstance].managedObjectContext];

    //[[SKPaymentQueue defaultQueue] addTransactionObserver:[GTAPacksPurchaseViewController sharedInstance]];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}



@end
