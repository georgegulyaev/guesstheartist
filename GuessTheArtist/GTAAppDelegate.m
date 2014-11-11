//
//  GTAAppDelegate.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/4/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAAppDelegate.h"
#import "GTALoadingViewController.h"
#import "CoreDataManager.h"

@interface GTAAppDelegate ()


@property BOOL importIsNeeded;

@end

@implementation GTAAppDelegate
/*

- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"GuessTheArtist.sqlite"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]]) {
        self.importIsNeeded = true;
        NSError *error = nil;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                      initWithManagedObjectModel:[self managedObjectModel]];
        if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil URL:storeUrl options:nil error:&error]) {
            //Error for store creation should be handled in here
        }
    } else {
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                      initWithManagedObjectModel:[self managedObjectModel]];
    }
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //if (!self.managedObjectContext)
       //[self initStorage];
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    GTALoadingViewController *controller = (GTALoadingViewController *)navigationController.topViewController;
    controller.managedObjectContext = [CoreDataManager singletonInstance].managedObjectContext;
    controller.importIsNeeded = [CoreDataManager singletonInstance].importIsNeeded;
    /*self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Main"];
    GTAHomeScreenViewController *viewController = (GTAHomeScreenViewController *)self.window.rootViewController;    
    
    viewController.managedObjectContext = self.managedObjectContext;
    viewController.importIsNeeded = self.importIsNeeded;*/
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"DatabaseReady"
                                                        //object:self];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    [CoreDataManager save:[CoreDataManager singletonInstance].managedObjectContext];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [CoreDataManager save:[CoreDataManager singletonInstance].managedObjectContext];
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
    [CoreDataManager save:[CoreDataManager singletonInstance].managedObjectContext];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
