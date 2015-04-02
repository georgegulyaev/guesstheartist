//
//  GTALoadingViewController.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/4/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTALoadingViewController.h"
#import "GTAHomeScreenViewController.h"
#import "CoreDataManager.h"

@interface GTALoadingViewController ()

@end

@implementation GTALoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
}

- (void)loadData {
    if ([CoreDataManager sharedInstance].managedObjectContext) {
        NSLog(@"Managed Object is ready");
        
        if (self.importIsNeeded) {
            [Importer importNativeData:[CoreDataManager sharedInstance].managedObjectContext];
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
    [self.navigationController pushViewController:controller animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImportNotofication" object:nil];
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
