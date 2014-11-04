//
//  GTAGuessedTableTableViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/5/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAGuessedArtistsTVC.h"
#import "GTAGuessedPaintingsTVC.h"
#import "GTAHomeScreenViewController.h"
#import "Artist.h"

@interface GTAGuessedArtistsTVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnMainPage;

@end

@implementation GTAGuessedArtistsTVC

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
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    //self.tableView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];

    //buttons
    [self.btnMainPage setTitleColor:[UIColor colorWithRed:140/255.0 green:171/255.0 blue:181/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.btnMainPage.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:16]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self.tableView removeFromSuperview];
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
    Artist *artist = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"%@", artist.name);
    cell.textLabel.text = [[NSString stringWithFormat:@"%@", artist.name] uppercaseString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu paintings", (unsigned long)[artist.paintings count]];
    

    //set image
    NSString *fileName = [NSString stringWithFormat: @"%@/%@.png", [[NSBundle mainBundle] resourcePath], artist.name];
    cell.imageView.image = [UIImage imageWithContentsOfFile:fileName];
    
    //set frame
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //customize fonts and colors
    cell.backgroundView = nil;
    cell.contentView.backgroundColor = cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];
    // set selection color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:0.8];
    cell.selectedBackgroundView = myBackView;
    //set fonts
    cell.textLabel.textColor = [UIColor colorWithWhite:222/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:62/255.0 green:103/255.0 blue:115/255.0 alpha:1.0];
    [cell.textLabel setFont:[UIFont fontWithName:@"MyriadPro-SemiboldIt" size:17]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"MyriadPro-SemiboldIt" size:13]];

  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
    [self performSegueWithIdentifier:@"showPaintings" sender:indexPath];
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Artist" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //NSLog(@"YESSS");
    if ([segue.destinationViewController isKindOfClass:[GTAHomeScreenViewController class]]) {
        GTAHomeScreenViewController *gtaHVC = (GTAHomeScreenViewController *)segue.destinationViewController;
        gtaHVC.managedObjectContext = self.managedObjectContext;
    } else if ([segue.destinationViewController isKindOfClass:[GTAGuessedPaintingsTVC class]]) {
        if ([segue.identifier isEqualToString:@"showPaintings"]) {
            GTAGuessedPaintingsTVC *gtaHVC = (GTAGuessedPaintingsTVC *)segue.destinationViewController;
            gtaHVC.managedObjectContext = self.managedObjectContext;
            gtaHVC.artist = [self.fetchedResultsController objectAtIndexPath:sender];
            
            //[segue.destinationViewController performSelectorInBackground:@selector(setPainting:) withObject:self.managedObjectContext];
        }
    }
}


@end
