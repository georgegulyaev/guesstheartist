//
//  Painting+Helper.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/6/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "Painting+Helper.h"

@implementation Painting (Helper)

+ (Painting *)addPainting:(NSDictionary *)paintingArray inManagedObjectContext: (NSManagedObjectContext *)context {
    
    Painting *painting = nil;
    
    painting = [NSEntityDescription insertNewObjectForEntityForName:@"Painting" inManagedObjectContext:context];
    painting.title = [[paintingArray valueForKey:@"title"] description];
    painting.year = [[paintingArray valueForKey:@"year"] description];
    painting.style = [[paintingArray valueForKey:@"style"] description];
    painting.image = [[paintingArray valueForKey:@"image"] description];
    painting.location = [[paintingArray valueForKey:@"owner"] description];
    painting.pack = [NSNumber numberWithInteger:[[paintingArray valueForKey:@"pack"] integerValue]];
    //replace with the real value
    painting.level = [NSNumber numberWithInteger:[[paintingArray valueForKey:@"level"] integerValue]];
    //replace with the real value
    
    return painting;
}

+(NSArray *)loadPaintings:(int)step inManagedObjectContext: (NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Painting"];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"ANY pack == %d", step + 1];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *array;
    array = [context executeFetchRequest:request error:&error];
    array = (NSArray *)[self shuffleArray:[[NSMutableArray alloc] initWithArray:array]];
    return array;
}

+ (NSMutableArray *)shuffleArray:(NSMutableArray *)array {
    for (int x = 0; x < [array count]; x++) {
        int randInt = (arc4random() % ([array count] - x)) + x;
        [array exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    return array;
}

@end
