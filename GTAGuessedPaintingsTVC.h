//
//  GTAGuessedPaintingsTVC.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/5/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Painting.h"
#import "Artist.h"

@interface GTAGuessedPaintingsTVC : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Artist *artist;

@end
