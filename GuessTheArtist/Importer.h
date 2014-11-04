//
//  Importer.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 8/28/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Painting.h"
#import "Painting+Helper.h"
#import "Artist.h"
#import "Artist+Helper.h"

@interface Importer : NSObject
+(void)importData: (NSManagedObjectContext *)context;
+(void)importNewPack: (NSManagedObjectContext *)context;
@end
