//
//  GTAShowGuessedPaintingVC.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 9/6/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAShowGuessedPaintingVC.h"
#import "GTAGuessedPaintingsTVC.h"
#import "Painting.h"
#import "CoreDataManager.h"
#import "ImageFinder.h"

#define iphone5orHigher ([UIScreen mainScreen].bounds.size.width >= 568)
#define iphone4 ([UIScreen mainScreen].bounds.size.width < 568)
#define isAtLeast61 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.1);

@interface GTAShowGuessedPaintingVC ()

@property (weak, nonatomic) IBOutlet UIImageView *rootImageView;
@property (weak, nonatomic) IBOutlet UIImageView *reflection;
@property (weak, nonatomic) IBOutlet UIImageView *paintingView;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (weak, nonatomic) IBOutlet UILabel *captionTitle;
@property (weak, nonatomic) IBOutlet UILabel *infoTitle;
@property (weak, nonatomic) IBOutlet UILabel *infoYear;
@property (weak, nonatomic) IBOutlet UILabel *infoStyle;
@property (weak, nonatomic) IBOutlet UILabel *infoLocation;
@property (weak, nonatomic) IBOutlet UITextView *infoAbout;
@property (weak, nonatomic) IBOutlet UIButton *close;
@property (weak, nonatomic) IBOutlet UIButton *open;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *lights;
@property (weak, nonatomic) IBOutletCollection(UILabel) NSMutableArray *captions;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UILabel *paintingTitle;

@property (strong, nonatomic) UIImage *image;


@end

@implementation GTAShowGuessedPaintingVC


- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.width);
    //[self.rootImageView setContentMode:UIViewContentModeScaleAspectFill];
    if (iphone4) {
        NSLog(@"iphone 4");
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone4"];
    } else if (iphone5orHigher) {
        NSLog(@"iphone 5");
        self.rootImageView.image = [UIImage imageNamed:@"bg_main_iphone5"];
    }
    
    self.infoView.hidden = YES; //•
    self.infoTitle.text = self.painting.title;
    
    self.paintingTitle.text =  [NSString stringWithFormat:@"%C• %@ • %C%C%C", 0x00A0, self.infoTitle.text, 0x00A0, 0x00A0, 0x00A0];
    
    self.infoYear.text = (self.painting.year) ? self.painting.year : @"No information.";
    self.infoStyle.text = self.painting.style;
    self.infoLocation.text = (self.painting.location) ? self.painting.location : @"No information.";
    
    self.paintingView.contentMode = UIViewContentModeScaleAspectFit;
    self.paintingView.autoresizingMask =(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
    self.image = [ImageFinder getImage:self.painting.image];
    self.paintingView.image = self.image;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:NO];
    self.view = nil;
    [self.view removeFromSuperview];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openInfo:(id)sender
{
    [UIImageView animateWithDuration:0.6 animations:^{
        [UIImageView animateWithDuration:0.2 animations:^{
            [[self.lights objectAtIndex:0] setAlpha:0.0];
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.2 animations:^{
                [[self.lights objectAtIndex:1] setAlpha:0.0];
            } completion:^(BOOL finished) {
                [UIImageView animateWithDuration:0.2 animations:^{
                    [[self.lights objectAtIndex:2] setAlpha:0.0];
                }];
            }];
        }];
        self.back.alpha = 0;
        self.paintingView.alpha = 0.3;
        self.reflection.alpha = 0;
        self.paintingTitle.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.infoView.hidden = NO;
        self.infoView.alpha = 0;
        //[[self.lights objectAtIndex:1] setAlpha:0.5];
        [UIImageView animateWithDuration:1.0 animations:^{
            self.infoView.alpha = 1.0;
            //self.paintingViewSmall.alpha = 1.0;
            //[[self.lights objectAtIndex:1] setAlpha:1.0];
        }];
    }];
}

- (IBAction)closeInfo:(id)sender
{
    
    [UIImageView animateWithDuration:1.0 animations:^{
        self.infoView.alpha = 0;
        [[self.lights objectAtIndex:1] setAlpha:0];
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:1.0 animations:^{
            self.infoView.hidden = YES;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.2 animations:^{
                self.back.alpha = 1.0;
                self.paintingTitle.alpha = 1.0;
                [[self.lights objectAtIndex:2] setAlpha:1.0];
                self.reflection.alpha = 0.5;
                self.paintingView.alpha = 0.5;
            } completion:^(BOOL finished) {
                [UIImageView animateWithDuration:0.2 animations:^{
                    [[self.lights objectAtIndex:1] setAlpha:1.0];
                    //self.rootImageView.alpha = 0.7;
                    self.reflection.alpha = 0.7;
                    self.paintingView.alpha = 0.7;
                } completion:^(BOOL finished) {
                    [UIImageView animateWithDuration:0.2 animations:^{
                        [[self.lights objectAtIndex:0] setAlpha:1.0];
                        //self.rootImageView.alpha = 1.0;
                        self.reflection.alpha = 1.0;
                        self.paintingView.alpha = 1.0;
                    }];
                }];
            }];
        }];
    }];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GuessedPaintingInfoToGuessedPaintings"]) {
        GTAGuessedPaintingsTVC  *destanationController = (GTAGuessedPaintingsTVC *)segue.destinationViewController;
        destanationController.artist = self.painting.author;
    }
}
- (IBAction)saveArtwork:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.image,
                                   self, // send the message to 'self' when calling the callback
                                   @selector(image:didFinishSavingWithError:contextInfo:), // the selector to tell the method to call on completion
                                   NULL); // you generally won't need a contextInfo here
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    if (!error)
        NSLog(@"Image saved");
    
}
- (IBAction)back:(id)sender
{
    [self performSegueWithIdentifier:@"GuessedPaintingInfoToGuessedPaintings" sender:nil];
}

@end
