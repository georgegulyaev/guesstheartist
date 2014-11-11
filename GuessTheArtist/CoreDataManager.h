//
//  CoreDataManager.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/11/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property BOOL importIsNeeded;

+ (CoreDataManager *)singletonInstance;
+ (void)save: (NSManagedObjectContext *)managedObjectContext;

@end
