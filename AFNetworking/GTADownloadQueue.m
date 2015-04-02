//
//  GTADownloadQueue.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/20/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "GTADownloadQueue.h"

@implementation GTADownloadQueue

-(id)init {
    self = [super init];
    
    return self;
}

+(GTADownloadQueue *)sharedInstance {
    static GTADownloadQueue *sharedInstance = nil;
    static dispatch_once_t isDispatched;
    
    dispatch_once(&isDispatched, ^ {
        sharedInstance = [[GTADownloadQueue alloc] init];
    });
    
    return sharedInstance;
}

@end
