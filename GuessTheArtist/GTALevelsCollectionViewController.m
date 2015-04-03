//
//  GTALevelsCollectionViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/27/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "GTALevelsCollectionViewController.h"
#import "CustomCell.h"
#import "CustomReusableHeaderView.h"
#import "CoreDataManager.h"
#import "GTAGameplayViewController.h"

@interface GTALevelsCollectionViewController() <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property NSMutableDictionary *statsDict;
@property NSArray *statsArray;
@property int numberOfSections;
@property NSArray *headersTitles;

@end

@implementation GTALevelsCollectionViewController 

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.headersTitles = @[ @"BASE PACK", @"APPRENTICE PACK", @"Master pack" ];
    
    self.numberOfSections = 1;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"])
        self.numberOfSections += 1;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisInstalled"])
        self.numberOfSections += 1;
    
    NSLog(@"%d", self.numberOfSections);
    
    
    //setting up stats Dictionary depending in bought pack
    self.statsDict = [@{} mutableCopy];
    
    
    //setting up fetch results controller
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Painting" inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    
    fetchRequest.entity = entity;
    
    //`Level` field COUNT: Expression
    NSExpression *countExpression = [NSExpression expressionForFunction: @"count:" arguments:@[ [NSExpression expressionForKeyPath:@"level"] ]];
    
    NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
    countExpressionDescription.name = @"count";
    countExpressionDescription.expression = countExpression;
    countExpressionDescription.expressionResultType = NSInteger32AttributeType;
    
    //`Guessed` field SUM: expression
    NSExpression *sumExpression = [NSExpression expressionForFunction: @"sum:" arguments:@[ [NSExpression expressionForKeyPath:@"guessed"] ]];
    
    NSExpressionDescription *sumExpressionDescription = [[NSExpressionDescription alloc] init];
    sumExpressionDescription.name = @"guessed";
    sumExpressionDescription.expression = sumExpression;
    sumExpressionDescription.expressionResultType = NSInteger32AttributeType;
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"level" ascending:YES];

    
    fetchRequest.resultType = NSDictionaryResultType;
    [fetchRequest setReturnsDistinctResults:YES];
    fetchRequest.propertiesToFetch = @[ @"level", countExpressionDescription, sumExpressionDescription ];
    fetchRequest.propertiesToGroupBy = @[ @"level" ];
    fetchRequest.sortDescriptors = @[ sort ];
    
    for (int i = 1; i <= self.numberOfSections; i ++) {
        NSPredicate *predicate;
        if (i == 2) //add to Apprentice pack images from 1st pack
           predicate = [NSPredicate predicateWithFormat:@"pack = %d or (pack = 1 and andlevel = 1)", i];
        else
            predicate = [NSPredicate predicateWithFormat:@"pack = %d", i];
        fetchRequest.predicate = predicate;
        
        //Executing fetch request
        NSError* error = nil;
        NSArray *results = [[CoreDataManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest
                                                                             error:&error];
        [self.statsDict setObject:results forKey:[NSNumber numberWithInt:i]];
    }
    
    NSLog(@"Array of Packs: %@", self.statsDict);
    //Returns Array with params: count, level, guessed

    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //to-do
    //NSLog(@"count: %lu", (unsigned long)[[self.statsDict allKeys] count]);
    return [[self.statsDict allKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //to-do
    //NSLog(@"count: %@", 1);
    return [[self.statsDict objectForKey:[NSNumber numberWithInt:(int)section+1]] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellId";
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //cell.userInteractionEnabled = NO;

    id level = [[[self.statsDict objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]] objectAtIndex:indexPath.row] objectForKey:@"level"];
    float guessedPaintings = [[[[self.statsDict objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]] objectAtIndex:indexPath.row] objectForKey:@"guessed"] floatValue];
    float totalPaintingsInLevel = [[[[self.statsDict objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]] objectAtIndex:indexPath.row] objectForKey:@"count"] floatValue];
    
    cell.labelLevelName.text = [NSString stringWithFormat:@"Level %@", level];
    
    //re-do
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSURL *libraryURL = [fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    NSURL *folderURL = [[libraryURL URLByAppendingPathComponent:bundleID] URLByAppendingPathComponent:@"ap_icons.bundle"]
    ;
    NSLog(@"folder: %@", folderURL.path);
    //NSBundle *bundle = [NSBundle bundleWithURL:folderURL];
    //NSString *imageName = [bundle pathForResource:@"icon2-1" ofType:@"png"];
    //NSString *imageName2 = [bundle pathForResource:[NSString stringWithFormat:@"icon%d-%@", (indexPath.section + 1), level] ofType:@"png"];
    
    
    if ((indexPath.section + 1) < 3)
        cell.imageFrame.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon%d-%@", (indexPath.section + 1), level]];
    else
        cell.imageFrame.image = [UIImage imageNamed:@"frame2"];
    cell.labelGuessed.text = [NSString stringWithFormat:@"Guessed: %d / %d", (int)guessedPaintings, (int)totalPaintingsInLevel];
    
    cell.imageStarsBg.image = [self setStarsForGuessed:(int)guessedPaintings total:(int)totalPaintingsInLevel];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //[self performSegueWithIdentifier:@"ZenGameLevelsToGamePlay" sender:indexPath];

}

#pragma mark UICollectionViewDelegateLayoutFlow

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    NSLog(@"%@ ,%ld, %ld", indexPath, (long)indexPath.row, (long)indexPath.section);
    if (kind == UICollectionElementKindSectionHeader) {
        CustomReusableHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        headerView.labelHeader.text = [self.headersTitles objectAtIndex:indexPath.section];

        UIView *topBorder = [UIView new];
        topBorder.backgroundColor = [UIColor blackColor];
        topBorder.frame = CGRectMake(0, 0, headerView.frame.size.width, 1);
        [headerView addSubview:topBorder];
        UIView *bottomBorder = [UIView new];
        bottomBorder.backgroundColor = [UIColor blackColor];
        bottomBorder.frame = CGRectMake(0, headerView.frame.size.height - 1, headerView.frame.size.width, 1);
        [headerView addSubview:bottomBorder];

        reusableView = headerView;
    }
    
    return reusableView;
}
 /*
 / Takes total number of paintings and number of guessed paintings, return UIImageView with stars from 0 to 5;
 */
- (UIImage *)setStarsForGuessed:(float)guessed total:(float)total {
    
    float guessedPercantage = (guessed / total * 5); //because 5 stars total

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_stars%d", (int)guessedPercantage]];
    return image;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSIndexPath *indexPath = sender;
    //NSLog(@"section: %d", indexPath.section);
    if ([segue.identifier isEqualToString:@"ZenGameLevelsToGamePlay"]) {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        GTAGameplayViewController *gtaGamePlayVC = (GTAGameplayViewController *)segue.destinationViewController;
        gtaGamePlayVC.level = [[[[self.statsDict objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]] objectAtIndex:indexPath.row] objectForKey:@"level"] integerValue];
        gtaGamePlayVC.pack = indexPath.section + 1;
        gtaGamePlayVC.gameMode = @"ZEN";
    }
}

@end
