//
//  CoreDataManager.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/11/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "CoreDataManager.h"
#import "Importer.h"

NSString *const kSQLiteStoreName = @"Paintings";
NSString *const kSQLiteStoreExtension = @"sqlite";

@interface CoreDataManager ()
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation CoreDataManager

#pragma mark - Core Data stack

+ (CoreDataManager *)sharedInstance {
    static CoreDataManager *coreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        coreDataManager = [[self alloc] init];
    });
    return coreDataManager;
}


- (id)init {
    self = [super init];
    if (self) {
        NSError *error;
        
        //setting up ManagedObjectModel
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kSQLiteStoreName withExtension:@"momd"];
        self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        
        //setting up Persistance Store Coordinator
        NSURL *storeURL = [[self createApplicationStoreCoordinatorDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kSQLiteStoreName, kSQLiteStoreExtension]];
        
        BOOL importNeeded = false;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[storeURL path]]) {
            NSLog(@"No file");
            importNeeded = true;
        }
            
        /*
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // If the expected store doesn't exist, copy the default store.
        if (![fileManager fileExistsAtPath:[storeURL path]]) {
            NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:kSQLiteStoreName withExtension:kSQLiteStoreExtension];
            if (defaultStoreURL) {
                [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:&error];
                if (error)
                    NSLog(@"Error %@", error.localizedDescription);
            }
        }
         */
        

        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
        // NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" } for removing sqlite-wal file
        //initializing coordinator with ObjectModel
        self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
        
        if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSLog(@"Error %@", error.localizedDescription);
            //abort();
        }
        
        
        
        //setting up Managed Object Context
        if (self.persistentStoreCoordinator) {
            self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [self.managedObjectContext setPersistentStoreCoordinator: self.persistentStoreCoordinator];
        }
        
        if (![fileManager fileExistsAtPath:[storeURL path]]) {
            NSLog(@"Still no file");
            importNeeded = true;
        }
        
        if (importNeeded)
            [Importer importNativeData:self.managedObjectContext];
        
        /* prepopulating Paintinfs.sqlite
         
         1. Change kSQLiteStoreName to @"Empty" in defaultStoreUrl to create Paintings.sqlite file
         
          NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:@"Empty" withExtension:kSQLiteStoreExtension];
        
         2. Use NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" } in options to generate
         Paintings.sqlite instead of Paintings.sqlite + Paintings-wal.sqlite
         
         3. Prepopulate Paintings.sqlite with all-painters.json file with the method call below
        if (!error)
            [Importer importNativeData:self.managedObjectContext];
         
         4. Drag and drop Paintings.sqlite from App Folder to Rsources folder
        
         */
        
    }
    return self;
}

#pragma mark - Application's documents directory

// Returns the URL to the application's Documents directory. 
- (NSURL *)createApplicationStoreCoordinatorDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *storeStringURL = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleID];
    //NSLog(@"%@", storeStringURL);
    NSError *error;
    if ([fileManager fileExistsAtPath:storeStringURL] == NO) {
        
        if ([fileManager createDirectoryAtPath:storeStringURL withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Error: Unable to create directory: %@", error);
        }
        
        NSURL *url = [NSURL fileURLWithPath:storeStringURL];
        // exclude downloads from iCloud backup
        if ([url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error] == NO) {
            NSLog(@"Error: Unable to exclude directory from backup: %@", error);
        }
    }
    
    return [NSURL fileURLWithPath:storeStringURL];
}

+ (void)save: (NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}


@end
