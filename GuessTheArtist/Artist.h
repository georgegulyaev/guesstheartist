//
//  Artist.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/13/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Painting;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *paintings;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addPaintingsObject:(Painting *)value;
- (void)removePaintingsObject:(Painting *)value;
- (void)addPaintings:(NSSet *)values;
- (void)removePaintings:(NSSet *)values;

@end
