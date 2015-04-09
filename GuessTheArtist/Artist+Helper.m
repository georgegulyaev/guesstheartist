//
//  Artist+Helper.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/24/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "Artist+Helper.h"

@implementation Artist (Helper)

+ (void)addArtists:(NSDictionary *)artistsDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Artist *artist = nil;
    
    for (NSString *artistName in artistsDictionary) {
        artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
        artist.name = artistName;
        NSSet *paintings = [artistsDictionary objectForKey:artistName];
        artist.paintings = paintings;
    }
    
    /*artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
    artist.name = [[artistArray valueForKey:@"name"] description];
    artist.paintings = [artistArray valueForKey:@"paintings"];*/
}

+ (void)addArtistsPack:(NSDictionary *)artistsDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    //[request2 setReturnsObjectsAsFaults:NO];
    //[request2 setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"paintings", nil]];
    NSError *error2 = nil;
    NSArray *results2 = [context executeFetchRequest:request2 error:&error2];
    
    Artist *artist = nil;
    
    for (NSString *artistName in artistsDictionary) {
        if ([[results2 valueForKey:@"name"] containsObject:artistName]) { //check whether fetched results already contain the artist with artistName
            for (Artist *artistObj in results2) { //loop throught the fetched results
                if ([[artistObj valueForKey:@"name"] isEqualToString:artistName]) { //check if results.artist == artistName
                    NSSet *paintings = [artistObj valueForKey:@"paintings"];
                    NSSet *combinedPaintingsSet = [paintings setByAddingObjectsFromSet:[artistsDictionary objectForKey:artistName]];
                    artistObj.paintings = combinedPaintingsSet;
                }
            }
        } else { //if not, add new artist
            artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
            artist.name = artistName;
            NSSet *paintings = [artistsDictionary objectForKey:artistName];
            artist.paintings = paintings;
        }
    }
}

//get artists list for packs: 0 - base pack, 1 - apprentice pack, 2 - master pack
+ (NSMutableArray *)getArtistsForPacks:(NSMutableArray *)pack andLevel:(NSInteger)level inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    NSLog(@"Level: %d",(int)level);
    //request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    /* if level exists - include it into predicate
    /  if level exists and there's only 1 pack, then if this pack = 2 
    /  (Apprentice pack) add paintings from Pack 1 for this level
    */
    
    NSPredicate *predicate  = (level) ?
        ([pack count] == 1 && [[pack objectAtIndex:0] integerValue] == 2) ?
        [NSPredicate predicateWithFormat:@"SUBQUERY(paintings, $p, $p.pack in %@ AND $p.level = %d or $p.andlevel = %d).@count > 0", pack, level, level]
                                                                         :
        [NSPredicate predicateWithFormat:@"SUBQUERY(paintings, $p, $p.pack in %@ AND $p.level = %d).@count > 0", pack, level]
                                       :
        [NSPredicate predicateWithFormat:@"SUBQUERY(paintings, $p, $p.pack in %@).@count > 0", pack];
    //NSPredicate *predicate  = (level) ? ([pack count] > 1) ? [NSPredicate predicateWithFormat:@"ANY paintings.pack in %@ && ANY paintings.level == %d", pack, level] : [NSPredicate predicateWithFormat:@"SUBQUERY(paintings, $p, $p.pack = %d AND $p.level = %d).@count > 0", [pack objectAtIndex:0], level] : [NSPredicate predicateWithFormat:@"ANY paintings.pack in %@", pack];
    //original NSPredicate *predicate  = (level) ? [NSPredicate predicateWithFormat:@"ANY paintings.pack in %@ && ANY paintings.level == %d", pack, level] : [NSPredicate predicateWithFormat:@"ANY paintings.pack in %@", pack];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];

    NSMutableArray *artistsArray = [[NSMutableArray alloc] init];
    if (results) {
        for (NSManagedObject *obj in results) {
            [artistsArray addObject:[obj valueForKey:@"name"]];
        }
    }
    NSLog(@"Artists: %@", artistsArray);
    return artistsArray;
}
//shuffle artists list, returning only 4 values, including correct answer
+ (NSMutableArray *)getShuffledArtists:(NSMutableArray *)artistsArray excludingName:(NSString *)excludingName {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [artistsArray enumerateObjectsUsingBlock:^(NSString *obj,NSUInteger idx,BOOL *stop) {
        if (![obj isEqualToString:excludingName]) {
            [tempArray addObject:obj];
        }
    }];
    tempArray = [self shuffleArray:tempArray]; //shuffle artists array
    [tempArray insertObject:excludingName atIndex:0]; //insert correct answer in it
    
    NSArray *slicedArray = [tempArray subarrayWithRange:NSMakeRange(0, 4)]; //slice 4 artists
    tempArray = [self shuffleArray:[NSMutableArray arrayWithArray:slicedArray]]; //shuffle them again
    return tempArray;
}

+ (NSMutableArray *)shuffleArray:(NSMutableArray *)array {
    for (int x = 0; x < [array count]; x++) {
        int randInt = (arc4random() % ([array count] - x)) + x;
        [array exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    return array;
}



@end
