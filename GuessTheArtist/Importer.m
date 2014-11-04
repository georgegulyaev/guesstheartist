//
//  Importer.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/28/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "Importer.h"

@implementation Importer

+(void)importData: (NSManagedObjectContext *)context {
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"all-painters2" ofType:@"json"];
    //parse JSON-file with paintings
    NSArray* paintings = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
    //import painters and artists in separate queue
    dispatch_queue_t importQueue = dispatch_queue_create("data import", NULL);
    dispatch_async(importQueue, ^{
        
        // do our long running process here
        NSMutableDictionary *artistsDictionary = [[NSMutableDictionary alloc] init];
        
        [paintings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { //going through an array made from JSON-file
            
            Painting *painting = [Painting addPainting:obj inManagedObjectContext:context]; //adding Painting object
            
            NSString *artistSetName = [obj valueForKey:@"artist"]; //getting arist name for current object
            
            if (![artistsDictionary valueForKey:artistSetName]) { //If set with selected Artist doesn't exist
                [artistsDictionary setValue:[NSSet setWithObject:painting] forKey:artistSetName]; //create it and add Painting for Key
            } else { //if exists
                NSMutableSet *setOfPaintingsByArtist = [artistsDictionary mutableSetValueForKey:artistSetName]; //then get existing paintings set for artist = artestSetName;
                [setOfPaintingsByArtist addObject:painting]; //add new painting to existing set
                [artistsDictionary setValue:[NSSet setWithSet:setOfPaintingsByArtist] forKey:artistSetName]; //update artistDictionary
            }
            //}];
            
        }];
        [Artist addArtists:artistsDictionary inManagedObjectContext:context]; //add Artists to Database
        
        NSError *err = nil;
        [context save:&err]; //save ManagedObjectContext
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Data imported");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ImportNotification"
             object:self];
        });
        
    });
    
    
}

+(void)importNewPack: (NSManagedObjectContext *)context {
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"paintings2" ofType:@"json"];
    NSArray* paintings = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
    
    dispatch_queue_t importQueue = dispatch_queue_create("data import", NULL);
    dispatch_async(importQueue, ^{
        
        // do our long running process here
        NSMutableDictionary *artistsDictionary = [[NSMutableDictionary alloc] init];
        
        [paintings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Painting *painting = [Painting addPainting:obj inManagedObjectContext:context];
            NSString *artistSetName = [obj valueForKey:@"artist"];
            if (![artistsDictionary valueForKey:artistSetName]) { //Set doesn't exist
                [artistsDictionary setValue:[NSSet setWithObject:painting] forKey:artistSetName];
            } else {
                NSMutableSet *setOfPaintingsByArtist = [artistsDictionary mutableSetValueForKey:artistSetName]; //get existing paintings set for artist = artestSetName;
                [setOfPaintingsByArtist addObject:painting]; //add new painting to this set
                [artistsDictionary setValue:[NSSet setWithSet:setOfPaintingsByArtist] forKey:artistSetName]; //update artistDictionary
            }
            //}];
            
        }];
        //[artistDictionary setValue:[NSSet setWithSet:setOfPaintings] forKey:@"paintings"];
        [Artist addArtistsPack:artistsDictionary inManagedObjectContext:context];
        
        NSError *err = nil;
        [context save:&err];
        
        // do any UI stuff on the main UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Data imported");
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"ImportNewPackNotification"
             object:self];
        });
        
    });
    
}

@end
