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
#import "CoreDataManager.h"
#import "CustomTableViewCell.h"


@interface GTAGuessedArtistsTVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnMainPage;

@end

@implementation GTAGuessedArtistsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Artist" inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name" ascending:YES];
    
    
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = @[ sort ];
    fetchRequest.fetchBatchSize = 15;
    
    NSFetchedResultsController *gtaFetchResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[CoreDataManager sharedInstance].managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    gtaFetchResultsController.delegate = self;
    self.fetchedResultsController = gtaFetchResultsController;
    
    //[NSFetchedResultsController deleteCacheWithName:@"Artists"];
    NSError *error;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//exit(-1);  // Fail
	}
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    //self.tableView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];

    //buttons
    [self.btnMainPage setTitleColor:[UIColor colorWithRed:140/255.0 green:171/255.0 blue:181/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.btnMainPage.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:16]];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}


//table view leading space separator bug fix
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
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
    [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(CustomTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Artist *artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    

    cell.labelTitle.text = [[NSString stringWithFormat:@"%@", artist.name] uppercaseString];
    cell.labelDetail.text = [NSString stringWithFormat:@"%ld paintings", (unsigned long)[artist.paintings count]];
    

    //set image
    NSString *fileName = [NSString stringWithFormat: @"%@/%@.png", [[NSBundle mainBundle] resourcePath], artist.name];
    cell.image.image = [UIImage imageWithContentsOfFile:fileName];
    
    //customize fonts and colors
    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.backgroundColor = cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];

    // set selection color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:0.8];
    cell.selectedBackgroundView = myBackView;

    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor blackColor];
    
    //separator leading spacing bug fix
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customCellIdentifier = @"CustomTableViewCell";
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"GuessedToSubGuessed" sender:indexPath];
    
}

#pragma mark - fetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue");
    if ([segue.identifier isEqualToString:@"GuessedToSubGuessed"]) {
        GTAGuessedPaintingsTVC *gtaHVC = (GTAGuessedPaintingsTVC *)segue.destinationViewController;
        gtaHVC.artist = [self.fetchedResultsController objectAtIndexPath:sender];
    }
}


@end
