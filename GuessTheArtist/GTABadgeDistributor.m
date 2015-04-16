//
//  GTABadgeDistributor.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 4/13/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "GTABadgeDistributor.h"

/* NSUserDefaults storing values */
NSString *const k1stFact = @"b1stFact"; //unlock 1st fact (track Zen game) - to-do
NSString *const kSpeedy = @"bSpeedy"; //guess 3 artworks in 5 seconds (track number of artworks in 5 seconds)
NSString *const kArtworksWOHints = @"bAWH"; //Number of Artworks guessed w/o hints in a row. Badges for 10/25/100 artworks guessed w/o hints in a row.
NSString *const kNumberOfGames = @"bGames"; //Number of Fever Games played tracking value. Badges for 1/50/100/500 games played. 
NSString *const kFastArtworks = @"bFA"; //FastArtworksGuessed value tracking. Badges for 100 and 1000 artworks guessed in less than 2 seconds
NSString *const kBeautifulMind = @"bBM"; //unlock all facts from Apprentice pack - to-do

/*
count: 1) artworks in a row w/o hints
       2) count artworks number in less than 2 seconds 
       3) 1 game flag
       4) 1st fact unlock flag
       5) count number of fever games
       6) check that all facts were unlocked
       7) check 1 game w/ apprentice pack is played
 
*/

@interface GTABadgeDistributor()

@end

@implementation GTABadgeDistributor

@synthesize badgesInitialValues = _badgesInitialValues;
@synthesize numberOf3ArtworksIn5seconds = _numberOf3ArtworksIn5seconds;
@synthesize numberOfArtworksWOHints = _numberOfArtworksWOHints;
@synthesize numberOfFastArtworksGuessed = _numberOfFastArtworksGuessed;
@synthesize numberOfGamesPlayed = _numberOfGamesPlayed;

#pragma mark getters

- (NSUInteger)numberOfGamesPlayed
{
    return _numberOfGamesPlayed = ([[[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfGames] integerValue] > 0) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfGames] integerValue] : 0;
}

- (NSUInteger)numberOf3ArtworksIn5seconds
{
    return _numberOf3ArtworksIn5seconds = ([[[NSUserDefaults standardUserDefaults] objectForKey:kSpeedy] integerValue] > 0) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kSpeedy] integerValue] : 0;
}

- (NSUInteger)numberOfArtworksWOHints
{
    return _numberOfArtworksWOHints = ([[[NSUserDefaults standardUserDefaults] objectForKey:kArtworksWOHints] integerValue] > 0) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kArtworksWOHints] integerValue] : 0;
}

- (NSUInteger)numberOfFastArtworksGuessed
{
    return _numberOfFastArtworksGuessed = ([[[NSUserDefaults standardUserDefaults] objectForKey:kFastArtworks] integerValue] > 0) ? [[[NSUserDefaults standardUserDefaults] objectForKey:kFastArtworks] integerValue] : 0;
}

#pragma mark setters

- (void)setNumberOfGamesPlayed:(NSUInteger)numberOfGamesPlayed
{
    _numberOfGamesPlayed = numberOfGamesPlayed;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_numberOfGamesPlayed] forKey:kNumberOfGames];
}

- (void)setNumberOf3ArtworksIn5seconds:(NSUInteger)numberOf3ArtworksIn5seconds
{
    _numberOf3ArtworksIn5seconds = numberOf3ArtworksIn5seconds;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_numberOf3ArtworksIn5seconds] forKey:kSpeedy];
}

- (void)setNumberOfArtworksWOHints:(NSUInteger)numberOfArtworksWOHints
{
    _numberOfArtworksWOHints = numberOfArtworksWOHints;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_numberOfArtworksWOHints] forKey:kArtworksWOHints];
}

- (void)setNumberOfFastArtworksGuessed:(NSUInteger)numberOfFastArtworksGuessed
{
    _numberOfFastArtworksGuessed = numberOfFastArtworksGuessed;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_numberOfFastArtworksGuessed] forKey:kFastArtworks];
}

@end
