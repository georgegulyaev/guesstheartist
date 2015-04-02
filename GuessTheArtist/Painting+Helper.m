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
    if ([NSNumber numberWithInteger:[[paintingArray valueForKey:@"andlevel"] integerValue]])
        painting.andlevel = [NSNumber numberWithInteger:[[paintingArray valueForKey:@"andlevel"] integerValue]];
    painting.guessed = [NSNumber numberWithInteger:0];
    painting.pack = [NSNumber numberWithInteger:[[paintingArray valueForKey:@"pack"] integerValue]];
    if (painting.pack == [NSNumber numberWithInt:1]) {
        painting.level = [NSNumber numberWithInt:1];
    } else
        painting.level = [NSNumber numberWithInteger:[[paintingArray valueForKey:@"level"] integerValue]];
    
    return painting;
}

+(NSArray *)loadPaintingsForPacks:(NSMutableArray *)packs andLevel:(NSInteger)level inManagedObjectContext: (NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Painting"];
    NSPredicate *predicate  = (level) ? [NSPredicate predicateWithFormat:@"ANY pack in %@ and ANY level = %d", packs, level] : [NSPredicate predicateWithFormat:@"ANY pack in %@", packs];
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
