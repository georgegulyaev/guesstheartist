//
//  GTAAudioPlayer.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 4/16/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "GTAAudioPlayer.h"

@implementation GTAAudioPlayer

+ (GTAAudioPlayer *)sharedInstance
{
    static GTAAudioPlayer *sharedInstance = nil;
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)playCover
{
    NSString *music = [[NSBundle mainBundle] pathForResource:@"cover" ofType:@"mp3"];
    GTAAudioPlayer *player = [[[self class] sharedInstance] initWithContentsOfURL:[NSURL URLWithString:music] error:nil];
    player.delegate = self;
    player.numberOfLoops = -1;
    [player play];
}



@end
