//
//  GTAHomeScreenViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/2/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAHomeScreenViewController.h"
#import "GTAChooseGameViewController.h"
#import "GTAGuessedArtistsTVC.h"
#import "GTAPacksPurchaseViewController.h"


@interface GTAHomeScreenViewController ()
@property (strong, nonatomic) IBOutlet UIButton *btnModeZen;
@property (strong, nonatomic) IBOutlet UIButton *btnModeFever;

@end

@implementation GTAHomeScreenViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.btnGuessed.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.btnPacks.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.btnAbout.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showGuessedArtists:(id)sender {
    [self performSegueWithIdentifier:@"HomeToGuessed" sender:nil];
}

- (IBAction)showPacks:(id)sender {
    [self performSegueWithIdentifier:@"HomeToPacks" sender:nil];
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[GTAChooseGameViewController class]]) {
        GTAChooseGameViewController *destanationController = (GTAChooseGameViewController *)segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"HomeToChooseGameZenMode"])
            destanationController.gameMode = @"ZEN";
        else if ([segue.identifier isEqualToString:@"HomeToChooseGameFeverMode"])
            destanationController.gameMode = @"FEVER";
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue
{

}

@end
