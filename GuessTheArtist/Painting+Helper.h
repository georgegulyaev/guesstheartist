//
//  Painting+Helper.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/6/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "Painting.h"

@interface Painting (Helper)

+ (Painting *)addPainting:(NSDictionary *)paintingArray inManagedObjectContext: (NSManagedObjectContext *)context;
+(NSArray *)loadPaintings:(int)step inManagedObjectContext: (NSManagedObjectContext *)context;
+ (NSMutableArray *)shuffleArray:(NSMutableArray *)array;
@end
