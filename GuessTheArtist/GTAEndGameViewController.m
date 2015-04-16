//
//  GTAEndGameViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 4/15/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import "GTAEndGameViewController.h"

@interface GTAEndGameViewController ()

- (IBAction)back:(id)sender;

@end

@implementation GTAEndGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)back:(id)sender {

    [self performSegueWithIdentifier:@"unwindToHome" sender:self];
}
@end
