//
//  GTABadgeDistributor.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 4/13/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTABadgeDistributor : NSObject

@property (nonatomic, strong) NSMutableDictionary *badgesInitialValues;

@property (nonatomic, assign) NSUInteger numberOfGamesPlayed; //Number of Fever Games played tracking value. Badges for 1/50/100/500 games played.
@property (nonatomic, assign) NSUInteger numberOf3ArtworksIn5seconds; //guess 3 artworks in 5 seconds (track number of artworks in 5 seconds)
@property (nonatomic, assign) NSUInteger numberOfArtworksWOHints; //Number of Artworks guessed w/o hints in a row. Badges for 10/25/100 artworks guessed w/o hints in a row.
@property (nonatomic, assign) NSUInteger numberOfFastArtworksGuessed; //FastArtworksGuessed value tracking. Badges for 100 and 1000 artworks guessed in less than 2 seconds

extern NSString *const k1stFact; //unlock 1st fact (track Zen game)
extern NSString *const kSpeedy; //guess 3 artworks in 5 seconds (track number of artworks in 5 seconds)
extern NSString *const kArtworksWOHints; //Number of Artworks guessed w/o hints in a row. Badges for 10/25/100 artworks guessed w/o hints in a row.
extern NSString *const kNumberOfGames; //Number of Fever Games played tracking value. Badges for 1/50/100/500 games played.
extern NSString *const kFastArtworks; //FastArtworksGuessed value tracking. Badges for 100 and 1000 artworks guessed in less than 2 seconds
extern NSString *const kBeautifulMind; //unlock all facts from Apprentice pack

@end
