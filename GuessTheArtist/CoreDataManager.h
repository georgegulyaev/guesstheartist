//
//  CoreDataManager.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/11/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)sharedInstance;
+ (void)save: (NSManagedObjectContext *)managedObjectContext;

@end
