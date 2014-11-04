//
//  GTAShowGuessedPaintingVC.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/6/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Painting.h"

@interface GTAShowGuessedPaintingVC : UIViewController

@property (nonatomic,strong) Painting *painting;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
