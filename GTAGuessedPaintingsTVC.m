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
#import "ImageFinder.h"
#import "CustomTableViewCell.h"

@interface GTAGuessedPaintingsTVC ()

@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIImageView *artistPhoto;
@property (strong, nonatomic) IBOutlet UIImageView *artistPhotoBg;
@property (strong, nonatomic) IBOutlet UILabel *artistName;

@end

@implementation GTAGuessedPaintingsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Painting" inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"author = %@", self.artist];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"title" ascending:NO];
    
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = @[ sort ];
    fetchRequest.predicate = predicate;
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
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
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

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self.tableView removeFromSuperview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

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
    [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(CustomTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Painting *painting = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.labelTitle.text = [NSString stringWithFormat:@"%@", painting.title];
    cell.labelDetail.text = [NSString stringWithFormat:@"%@", painting.year];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ year", painting.year];
    
    
    
    //set image

    cell.image.image = [ImageFinder getImage:painting.image];
    
    
    //setting image frame and scaling image with appropriate ratio
    CGSize itemSize = CGSizeMake(80, 80);
    double scaleFactor = fmax(fmax(cell.image.image.size.width / 80, cell.image.image.size.height / 80), 1);
    double newWidth = cell.image.image.size.width / scaleFactor;
    double newHeight = cell.image.image.size.height / scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    float leftOffset = (itemSize.width - newWidth) / 2;
    float topOffset = (itemSize.height - newHeight) / 2;
    CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    
    [cell.image.image drawInRect:newRect];
    cell.image.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.backgroundColor = cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];
    
    // set selection color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:0.8];
    cell.selectedBackgroundView = myBackView;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor blackColor];
    
    //table view leading space separator bug fix
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customCellIdentifier = @"CustomTableViewCell";
    
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    // Configure the cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SubGuessedToSubGuessedInfo" sender:indexPath];
    
}

#pragma mark - fetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
