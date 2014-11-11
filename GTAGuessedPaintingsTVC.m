//
//  GTAGuessedTableTableViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/5/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAGuessedPaintingsTVC.h"
#import "GTAGuessedArtistsTVC.h"
#import "GTAShowGuessedPaintingVC.h"
#import "CoreDataManager.h"

@interface GTAGuessedPaintingsTVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIImageView *artistPhoto;
@property (strong, nonatomic) IBOutlet UIImageView *artistPhotoBg;
@property (strong, nonatomic) IBOutlet UILabel *artistName;

@end

@implementation GTAGuessedPaintingsTVC

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    //buttons
    [self.btnBack setTitleColor:[UIColor colorWithRed:140/255.0 green:171/255.0 blue:181/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.btnBack.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:16]];
    //label
    [self.artistName setTextColor:[UIColor colorWithRed:255/255.0 green:245/255.0 blue:229/255.0 alpha:1.0]];
    [self.artistName setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:16]];
    self.artistName.text = [self.artist.name uppercaseString];
    
    //set image
    NSString *fileName = [NSString stringWithFormat: @"%@/%@.png", [[NSBundle mainBundle] resourcePath], self.artist.name];
    self.artistPhoto.image = [UIImage imageWithContentsOfFile:fileName];
    
    //set image frame and scale to fit
    CGSize itemSize = CGSizeMake(34, 34);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [self.artistPhoto.image drawInRect:imageRect];
    self.artistPhoto.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.artistPhoto.contentMode = UIViewContentModeCenter;
    self.artistPhoto.autoresizingMask = UIViewAutoresizingNone;

    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self.tableView removeFromSuperview];
}

/*
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Painting *painting = [_fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"%@", painting.title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ year", painting.year];
    
    //set image
    NSString *fileName = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], painting.image];
    cell.imageView.image = [UIImage imageWithContentsOfFile:fileName];
    
    //setting image frame and scaling image with appropriate ratio
    CGSize itemSize = CGSizeMake(70, 40);
    double scaleFactor = fmax(fmax(cell.imageView.image.size.width / 70, cell.imageView.image.size.height / 40), 1);
    double newWidth = cell.imageView.image.size.width / scaleFactor;
    double newHeight = cell.imageView.image.size.height / scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    float leftOffset = (itemSize.width - newWidth) / 2;
    float topOffset = (itemSize.height - newHeight) / 2;
    CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    
    [cell.imageView.image drawInRect:newRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //customize fonts and colors
    cell.contentView.backgroundColor = cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];
    // set selection color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:0.8];
    cell.selectedBackgroundView = myBackView;
    //set fonts
    cell.textLabel.textColor = [UIColor colorWithWhite:222/255.0 alpha:1.0];
    //cell.detailTextLabel.textColor = [UIColor colorWithRed:62/255.0 green:103/255.0 blue:115/255.0 alpha:1.0];
    [cell.textLabel setFont:[UIFont fontWithName:@"MyriadPro-It" size:17]];
    //[cell.detailTextLabel setFont:[UIFont fontWithName:@"MyriadPro-SemiboldIt" size:13]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [self performSegueWithIdentifier:@"SubGuessedToSubGuessedInfo" sender:indexPath];
    
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Painting" inManagedObjectContext:[CoreDataManager singletonInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"author = %@", self.artist];
    [fetchRequest setPredicate:predicate];
    
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"title" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[CoreDataManager singletonInstance].managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SubGuessedToSubGuessedInfo"]) {
        GTAShowGuessedPaintingVC  *destinationController = (GTAShowGuessedPaintingVC  *)segue.destinationViewController;
        destinationController.painting = [self.fetchedResultsController objectAtIndexPath:sender];
    }
}

@end
