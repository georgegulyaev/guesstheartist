//
//  GTABadgesViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 4/11/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "GTABadgesViewController.h"
#import "BadgeCustomCell.h"
#import "CustomLabel.h"

NSString *const kkNewbie    = @"bNewbie";
NSString *const kkApprentice = @"bApprentice";
NSString *const kk1stFact    = @"b1stFact";
NSString *const kkSpeedy = @"bSpeedy";
NSString *const kk10awh = @"b10awh";
NSString *const kk25awh = @"b25awh";
NSString *const kk100awh = @"b100awh";
NSString *const kk50games = @"b50games";
NSString *const kk100games = @"b100games";
NSString *const kk500games = @"b500games";
NSString *const kk100fa = @"b100fa";
NSString *const kk1000fa = @"b1000fa";
NSString *const kkbm = @"bbm";

@interface GTABadgesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *badges;
@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UIImageView *badgeBig;
@property (weak, nonatomic) IBOutlet UILabel *badgeTitle;
@property (weak, nonatomic) IBOutlet UILabel *badgeInfo;

@end


@implementation GTABadgesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Index: 0 - key, 1 - Title, 2 - Description, 3 - Image name, 4 - points to obtain, 5 - NSUseDefaults Key
    self.badges = @[
                    @[@"bNewbie", @"Newbie", @"At least 1 game played", @"badge_newbie", @1, @"bGames"],
                    @[@"bApprentice", @"Apprentice", @"Apprentice Pack unlocked", @"badge_apprentice", @1, @"bGames"],
                    @[@"b1stFact", @"1st fact", @"At least 1 fact revealed", @"badge_fact_unlocked", @1, @"b1stFact"],
                    @[@"bSpeedy", @"Speedy", @"3 artworks in 5 seconds guessed", @"badge_speedy", @1, @"bSpeedy"],
                    @[@"b10awh", @"10 hints", @"10 artworks guessed without hints in a row", @"badge_10_hints", @10, @"bAWH"],
                    @[@"b25awh", @"25 hints", @"25 artworks guessed without hints in a row", @"badge_25_hints", @25, @"bAWH"],
                    @[@"b100awh", @"100 hints", @"100 artworks guessed without hints in a row", @"badge_100_hints", @100, @"bAWH"],
                    @[@"b50games", @"50 games", @"50 Fever games scored more than 300", @"badge_50_games", @50, @"bGames"],
                    @[@"b100games", @"100 games", @"100 Fever games scored more than 300", @"badge_100_games", @100, @"bGames"],
                    @[@"b500games", @"500 games", @"500 Fever games scored more than 300", @"badge_500_games", @500, @"bGames"],
                    @[@"b100fa", @"100 fast artworks", @"100 artworks guessed in less than 2 seconds each", @"badge_100_fast_stills", @100, @"bFA"],
                    @[@"b1000fa", @"1000 fast artworks", @"1000 artworks guessed in less than 2 seconds each", @"badge_1000_fast_stills", @1000, @"bFA"],
                    @[@"bbm", @"Beautiful mind", @"All fact from both packs unlocked", @"badge_beautiful mind", @1, @"b2ndFact"] //to-do
    ];
    
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_black2"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor blackColor];
    
    //Select 1st row by default
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.badges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BadgeCellId";
    BadgeCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray *cellDataArray = [self.badges objectAtIndex:indexPath.row];
    
    //re-do
    BOOL enabled = false;
    
    NSUInteger userDefaultsValue = [[[NSUserDefaults standardUserDefaults] objectForKey:[cellDataArray objectAtIndex:5]] integerValue];
    NSUInteger valueToUnlockBadge = [[cellDataArray objectAtIndex:4] integerValue];
    NSString *key = [cellDataArray objectAtIndex:0];
    
    //check if `Apprentice badge` is unlocked
    if (key == kkApprentice && [[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"] && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    //check of `10 artworks w/o hints` badge is unlocked
    else if (key == kk10awh && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    //check of `25 artworks w/o hints` badge is unlocked
    else if (key == kk25awh && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    //check of `100 artworks w/o hints` badge is unlocked
    else if (key == kk100awh && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    //check of `50 fever games played` badge is unlocked
    else if (key == kk50games && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    //check of `100 fever games played` badge is unlocked
    else if (key == kk100games && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    //check of `500 fever games played` badge is unlocked
    else if (key == kk500games && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    //check of `100 fast artworks` badge is unlocked
    else if (key == kk100fa && userDefaultsValue >= valueToUnlockBadge) {
        enabled = true;
    //check of `1000 fast artworks` badge is unlocked
    } else if (key == kk1000fa && userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    else if (userDefaultsValue >= valueToUnlockBadge)
        enabled = true;
    
    if (enabled) {
        cell.tag = 1;
        cell.image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_small", [cellDataArray objectAtIndex:3]]];
    } else {
        cell.tag = 0;
        cell.image.image = [UIImage imageNamed:@"badge_disabled_small"];
    }
    cell.title.text = [[cellDataArray objectAtIndex:1] uppercaseString];
    
    // set selection color
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:11/255.0 green:12/255.0 blue:20/255.0 alpha:0.5];
    cell.selectedBackgroundView = myBackView;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    BadgeCustomCell *cell = (BadgeCustomCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    self.badgeTitle.text = [[self.badges objectAtIndex:indexPath.row] objectAtIndex:1];
    self.badgeInfo.text = [[self.badges objectAtIndex:indexPath.row] objectAtIndex:2];
    self.badgeBig.image = (cell.tag == 1) ? [UIImage imageNamed:[[self.badges objectAtIndex:indexPath.row] objectAtIndex:3]] : [UIImage imageNamed:@"badge_disabled"];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
