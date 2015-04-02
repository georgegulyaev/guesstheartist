//
//  GTADownloadQueue.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/20/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "AFDownloadRequestOperation.h"

@interface GTADownloadQueue : NSOperationQueue

//@property (nonatomic) NSOperationQueue *operationQueue;
+(GTADownloadQueue *)sharedInstance;

@end
