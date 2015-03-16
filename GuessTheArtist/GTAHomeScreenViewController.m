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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnModeZen.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:17]];
    [self.btnModeFever.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-BoldIt" size:17]];

    [self.btnGuessed.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.btnPacks.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.btnAbout.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

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

@end
