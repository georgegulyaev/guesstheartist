//
//  Importer.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/28/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "Importer.h"

@implementation Importer

+(void)importNativeData: (NSManagedObjectContext *)context {
    NSError* err = nil;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"packAPisInstalled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"document" ofType:@"json"];
    //parse JSON-file with paintings
    NSArray* paintings = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
    NSLog(@"Error: %@", err);

    if (!err && paintings != nil) {

        NSMutableDictionary *artistsDictionary = [[NSMutableDictionary alloc] init];
        
        [paintings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { //going through an array made from JSON-file
            //NSLog(@"Artist: %@", obj);
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
    
        if (!err)
            NSLog(@"Data imported");
        
    } else
        NSLog(@"Error: %@", err.localizedDescription);
}

+(void)importNewPack:(NSString *)packName withContext:(NSManagedObjectContext *)context {
    NSError* err = nil;
    
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dataPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:bundleID]  stringByAppendingPathComponent:[NSString stringWithFormat:@"import%@.json", packName]];

    NSArray* paintings = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
    
    if (!err && paintings != nil) {

        NSMutableDictionary *artistsDictionary = [[NSMutableDictionary alloc] init];
        
        [paintings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Painting *painting = [Painting addPainting:obj inManagedObjectContext:context];
            NSString *artistSetName = [obj valueForKey:@"artist"];
            NSLog(@"%@", artistSetName);
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
        if (!err) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ImportNewPackNotification" object:packName];
            NSLog(@"no error");
        }
    } else
        NSLog(@"Error: %@", err.localizedDescription);
    
}

@end
