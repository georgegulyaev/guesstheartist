//
//  Artist+Helper.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/24/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "Artist.h"

@interface Artist (Helper)

+ (void)addArtists:(NSDictionary *)artistsDictionary inManagedObjectContext: (NSManagedObjectContext *)context;
+ (void)addArtistsPack:(NSDictionary *)artistsDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getArtistsForPacks:(NSMutableArray *)packs andLevel:(NSInteger)level inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSMutableArray *)getShuffledArtists:(NSMutableArray *)artistsArray excludingName:(NSString *)excludingName;
+ (NSMutableArray *)shuffleArray:(NSMutableArray *)array;

@end
