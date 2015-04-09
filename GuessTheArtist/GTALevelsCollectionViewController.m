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

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_black2"]];
    //[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"packAPisInstalled"];
    self.headersTitles = @[ @"BASE PACK", @"APPRENTICE PACK", @"MASTER PACK" ];

    //unlock 1st level of all installed packs
    self.numberOfSections = 3;
    //unlock base pack
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pack1level1cleared"] == false)
    {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"pack1level1cleared"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //unlock ApprenticePack if Installed
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"])
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pack2level1cleared"] == false)
        {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"pack2level1cleared"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisInstalled"])
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pack3level1cleared"] == false)
        {
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"pack3level1cleared"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
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
    
    for (int i = 1; i <= self.numberOfSections; i ++)
    {
        NSPredicate *predicate;
        if (i == 2) //add to Apprentice pack images from 1st pack
           predicate = [NSPredicate predicateWithFormat:@"pack = %d", i]; //to-do
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
    
    //self.collectionView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.statsDict allKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //to-do
    if ((section + 1) == 3)
        return 10;
    return [[self.statsDict objectForKey:[NSNumber numberWithInt:(int)section+1]] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellId";
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    int pack = (int)indexPath.section + 1;
    
    //re-do

    if (pack < 3) { //if pack < 3
        NSUInteger level = [[[[self.statsDict objectForKey:[NSNumber numberWithInt:pack]] objectAtIndex:indexPath.row] objectForKey:@"level"] integerValue];
        
        cell.labelLevelName.text = [NSString stringWithFormat:@"Level %d", (int)level];
        
        cell.imageFrame.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon%d-%d", pack, (int)level]];
    
        /* configure cell look depending on user progress */
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"pack%dlevel%dcleared", pack, (int)level]] == true)
        { //level cleared
            cell.imageLock.hidden = cell.userInteractionEnabled = YES;
            cell.imageStarsBg.hidden = cell.imageLight.hidden = NO;
            
            NSUInteger bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"pack%dlevel%dBestScore", pack, (int)level]];
            NSUInteger totalPaintingsNumber = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"pack%dlevel%DPaintingsTotal", pack, (int)level]];
            
            cell.labelGuessed.hidden = YES;
            if (bestScore > 0 && totalPaintingsNumber > 0)
            {
                cell.labelGuessed.hidden = NO;
                cell.labelGuessed.text = [NSString stringWithFormat:@"GUESSED: %d/%d", (int)bestScore, (int)totalPaintingsNumber];
                
            }
            cell.imageStarsBg.image = [self setStarsForGuessed:bestScore total:totalPaintingsNumber];
        } else
        { //level not cleared yet
            cell.userInteractionEnabled = cell.imageLock.hidden = NO;
            cell.imageStarsBg.hidden = cell.labelGuessed.hidden = cell.imageLight.hidden = YES;
        }
    }
    else if (pack == 3)
    { //Master Pack Coming Soon
        cell.imageFrame.image = [UIImage imageNamed:@"icon_coming_soon"];
        cell.labelLevelName.text = [NSString stringWithFormat:@"Level %d", (int)(indexPath.row + 1)];
        cell.userInteractionEnabled = NO;
        cell.imageLight.hidden = cell.labelGuessed.hidden = cell.imageLock.hidden = cell.imageStarsBg.hidden = YES;
    }
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"ZenGameLevelsToGamePlay" sender:indexPath];

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    //if ((section + 1) == 3) //Master pack coming soon
      //  return -20;
    if ((section + 1) == 1 || ((section + 1) == 2 && [[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"])) //Apprentice pack
        return 10;
    return -20;
}

#pragma mark UICollectionViewDelegateLayoutFlow

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 15, 10, 15);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableView = nil;
    //NSLog(@"%@ ,%ld, %ld", indexPath, (long)indexPath.row, (long)indexPath.section);
    if (kind == UICollectionElementKindSectionHeader)
    {
        CustomReusableHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        headerView.labelHeader.text = [self.headersTitles objectAtIndex:indexPath.section];
        
        headerView.btnPacks.hidden = YES;
        //re-do for future packs
        if ((indexPath.section + 1) == 2) //Apprentice Pack
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"] == false)
                headerView.btnPacks.hidden = NO;
        }
        
        
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
- (UIImage *)setStarsForGuessed:(float)guessed total:(float)total
{
    int starsToGive
    ;
    float guessedPercantage = (guessed * 100 / total); //because 5 stars total
    
    if (guessedPercantage == 100) //100% artworks guessed
        starsToGive = 6;
    else if (guessedPercantage >= 92 && guessedPercantage < 100)
        starsToGive = 5;
    else if (guessedPercantage >= 71 && guessedPercantage < 92)
        starsToGive = 4;
    else if (guessedPercantage >= 51 && guessedPercantage < 71)
        starsToGive = 3;
    else if (guessedPercantage >= 26 && guessedPercantage < 51)
        starsToGive = 2;
    else if (guessedPercantage >= 1 && guessedPercantage < 26)
        starsToGive = 1;
    else
        starsToGive = 0;

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_stars%d", starsToGive]];
    return image;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ZenGameLevelsToGamePlay"])
    {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        GTAGameplayViewController *gtaGamePlayVC = (GTAGameplayViewController *)segue.destinationViewController;
        gtaGamePlayVC.level = [[[[self.statsDict objectForKey:[NSNumber numberWithInteger:indexPath.section + 1]] objectAtIndex:indexPath.row] objectForKey:@"level"] integerValue];
        gtaGamePlayVC.pack = indexPath.section + 1;
        gtaGamePlayVC.gameMode = @"ZEN";
    }
}

- (IBAction)unwindToZen:(UIStoryboardSegue *)unwindSegue
{
    
}
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
