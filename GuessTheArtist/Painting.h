//
//  Painting.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/13/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist;

@interface Painting : NSManagedObject

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * pack;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSNumber * guessed;
@property (nonatomic, retain) NSNumber * andlevel;
@property (nonatomic, retain) Artist *author;

@end
