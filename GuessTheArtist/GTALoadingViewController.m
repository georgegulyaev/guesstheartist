//
//  GTALoadingViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/4/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTALoadingViewController.h"
#import "GTAHomeScreenViewController.h"

@interface GTALoadingViewController ()

@end

@implementation GTALoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareData];
}


- (void)prepareData {
    if (self.managedObjectContext) {
        NSLog(@"Managed Object is ready");
        
        // self.importIsNeeded = true;
        if (self.importIsNeeded) {
            [Importer importData:self.managedObjectContext];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(changeLabel)
                                                         name:@"ImportNotification"
                                                       object:nil];
        } else
            [self changeLabel];
        
    }
}

- (void)changeLabel {
    NSLog(@"LOADED");
    GTAHomeScreenViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
    controller.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:controller animated:YES];
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[GTAHomeScreenViewController class]]) {
        GTAHomeScreenViewController *gtaGVC = (GTAHomeScreenViewController *)segue.destinationViewController;
        gtaGVC.managedObjectContext = self.managedObjectContext;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
