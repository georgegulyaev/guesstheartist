//
//  GTALoadingViewController.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/4/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Importer.h"

@interface GTALoadingViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL importIsNeeded;

@end
