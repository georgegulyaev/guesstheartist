//
//  GTAGuessedTableTableViewController.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/5/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTAGuessedArtistsTVC : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
