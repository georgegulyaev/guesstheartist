//
//  GTAHomeScreenViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/2/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAHomeScreenViewController.h"
#import "GTAGameplayViewController.h"
#import "GTAGuessedArtistsTVC.h"
#import "GTAPacksViewController.h"

@interface GTAHomeScreenViewController ()
@property (strong, nonatomic) IBOutlet UIButton *btnModeZen;
@property (strong, nonatomic) IBOutlet UIButton *btnModeFever;

@end

@implementation GTAHomeScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnModeZen.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:17]];
    [self.btnModeFever.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:17]];
}


/*
- (void)prepareData {
    if (self.managedObjectContext) {
        NSLog(@"Managed Object is ready");
        
        // self.importIsNeeded = true;
        if (self.importIsNeeded) {
            [Importer importData:self.managedObjectContext];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(startGame:)
                                                         name:@"ImportNotification"
                                                       object:nil];
        } else
            [self startGame:0];
        
    }
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[GTAGameplayViewController class]]) {
        GTAGameplayViewController *destanationController = (GTAGameplayViewController *)segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"HomeToGameplayZenMode"])
            destanationController.gameMode = @"Zen";
        else if ([segue.identifier isEqualToString:@"HomeToGameplayFeverMode"])
            destanationController.gameMode = @"Fever";
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
