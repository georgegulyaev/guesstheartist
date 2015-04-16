//
//  GTAPacksPurchase.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/13/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAPacksPurchaseViewController.h"
#import "AFDownloadRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "GTADownloadQueue.h"
#import <QuartzCore/QuartzCore.h>
#import "SSZipArchive.h"
#import "Importer.h"
#import "CoreDataManager.h"

#define PACK_APPRENTICE @"com.guesstheartist.apprenticepack"
#define PACK_MASTER @"com.guesstheartist.masterpack"
#define PACK_APPRENTICE_URL_STRING @"https://dl.dropboxusercontent.com/u/23494319/iOS_Apple_in-App_packs/GuessTheArtist/ap.zip"
#define PACK_MASTER_URL_STRING @"https://dl.dropboxusercontent.com/u/23494319/iOS_Apple_in-App_packs/GuessTheArtist/mp.zip"

NSString *const packAP = @"AP";
NSString *const packMP = @"MP";

@interface GTAPacksPurchaseViewController ()


//Fetching products UI
@property (weak, nonatomic) IBOutlet UIView *fetchingView;
@property (weak, nonatomic) IBOutlet UILabel *fetchingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//VC other UI elements
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreInfo;
@property (weak, nonatomic) IBOutlet UIView *column2View;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//Download GUI
//for Apprentice Pack UI
@property (strong, nonatomic) IBOutlet UIButton *btnDownload_AP;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy_AP;
@property (weak, nonatomic) IBOutlet UIButton *btnRestore_AP;
@property (weak, nonatomic) IBOutlet UIButton *btnInstall_AP;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice_AP;
//for Apprentice Pack Download View
@property (weak, nonatomic) IBOutlet UIView *downloadView_AP;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView_AP;
@property (weak, nonatomic) IBOutlet UIButton *btnPauseDownload_AP;
@property (weak, nonatomic) IBOutlet UIButton *btnResumeDownload_AP;
@property (weak, nonatomic) IBOutlet UILabel *labelPercantage_AP;
@property (weak, nonatomic) IBOutlet UILabel *labelDownloaded_AP;
//for Master Pack UI
@property (strong, nonatomic) IBOutlet UIButton *btnDownload_MP;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy_MP;
@property (weak, nonatomic) IBOutlet UIButton *btnRestore_MP;
@property (weak, nonatomic) IBOutlet UIButton *btnInstall_MP;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice_MP;

//for Master Pack Download View
@property (weak, nonatomic) IBOutlet UIView *downloadView_MP;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView_MP;
@property (weak, nonatomic) IBOutlet UIButton *btnResumeDownload_MP;
@property (weak, nonatomic) IBOutlet UIButton *btnPauseDownload_MP;
@property (weak, nonatomic) IBOutlet UILabel *labelPercantage_MP;
@property (weak, nonatomic) IBOutlet UILabel *labelDownloaded_MP;

//Actions for Download GUI
//for Apprentice Pack
- (IBAction)download_AP:(id)sender;
- (IBAction)buyPack_AP:(id)sender;
- (IBAction)restore_AP:(id)sender;
- (IBAction)installPack_AP:(id)sender;
//for Master Pack
- (IBAction)download_MP:(id)sender;
- (IBAction)buyPack_MP:(id)sender;
- (IBAction)restore_MP:(id)sender;
- (IBAction)installPack_MP:(id)sender;
//for Apprentice Pack Download View
- (IBAction)pauseDownload_AP:(id)sender;
- (IBAction)resumeDowload_AP:(id)sender;
//for Master Pack Download View


//VC other actions
- (IBAction)btnBack:(id)sender;
- (IBAction)scrollDown:(id)sender;


@property BOOL canActivateDownload;

@end

@implementation GTAPacksPurchaseViewController {
    NSMutableDictionary *products;
    NSString *currentProduct;
    BOOL notificationObserverIsActive;
    BOOL btnCompareClicked;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    self.view.backgroundColor = self.fetchingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_black2"]];
    
    self.btnBack.hidden = YES;
    [self.activityIndicator startAnimating];
    [self fetchAvailableProducts];
    
    
    NSLog(@"WillAppear");
    
    [self.progressView_AP setProgress:0.0];
    [self.progressView_MP setProgress:0.0];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"LOADED VIEW PACKS");
}

//Fetch products (Packs) from the App Store
- (void)fetchAvailableProducts { //request in-app purchases from App Store
    
    NSSet *productIdentifiers = [NSSet
                                 setWithObjects:PACK_APPRENTICE, PACK_MASTER,nil];
    productsRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

//When product fetch is completed hide `Fetching in progress` screen and show view with available products
- (void)fetchCompleted {
    [self.activityIndicator stopAnimating];
    [self.fetchingView removeFromSuperview];
    NSLog(@"Fetch completed");
    [self updateUI];
}

- (void)updateUI {
    //Update UI depending on pack download progress
    //User bought a pack
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisBought"]) {
        self.btnBuy_AP.hidden = self.btnRestore_AP.hidden = self.btnInstall_AP.hidden = YES;
        self.btnDownload_AP.hidden = NO;
    } else {
        self.btnBuy_AP.hidden = self.btnRestore_AP.hidden  = NO;
        self.btnDownload_AP.hidden = self.btnInstall_AP.hidden = YES;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisBought"]) {
        self.btnBuy_MP.hidden = self.btnRestore_MP.hidden = self.btnInstall_MP.hidden = YES;
        self.btnDownload_MP.hidden = NO;
    } else {
        self.btnBuy_MP.hidden = self.btnRestore_MP.hidden = NO;
        self.btnDownload_MP.hidden = self.btnInstall_MP.hidden = YES;
    }
    //Pack is downloading but might be in `isPaused` state
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisDownloading"]) {
        NSLog(@"Downloading");
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisPaused"]) {
            [self.btnDownload_AP setTitle:@"RESUME" forState:UIControlStateNormal];
            NSLog(@"Downloading but paused");
        } else {
            //[self.btnDownload_AP setTitle:@"Downloading" forState:UIControlStateNormal];
            NSLog(@"Downloading and active");
            self.btnDownload_AP.enabled = NO;
            [self initDownloadOperationForURL:PACK_APPRENTICE_URL_STRING andPackID:packAP];
            [self startGravityBehaviorForView:self.downloadView_AP withNewConstraints:YES];
        }
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisDownloading"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisPaused"])
            [self.btnDownload_MP setTitle:@"RESUME" forState:UIControlStateNormal];
        else {
            //[self.btnDownload_MP setTitle:@"Downloading" forState:UIControlStateNormal];
            self.btnDownload_MP.enabled = NO;
            [self initDownloadOperationForURL:PACK_MASTER_URL_STRING andPackID:packMP];
            [self startGravityBehaviorForView:self.downloadView_MP withNewConstraints:YES];
        }
    }
    //Pack downloaded. Show `Install pack` button
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisDownloaded"]) {
        self.btnInstall_AP.hidden = NO;
        self.btnDownload_AP.hidden = YES;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisDownloaded"]) {
        self.btnInstall_MP.hidden = NO;
        self.btnDownload_MP.hidden = YES;
    }
    //Pack installed. Change `Install` to `Installed`
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packAPisInstalled"]) {
        self.btnInstall_AP.hidden = self.btnInstall_AP.enabled = NO;
        [self.btnInstall_AP setTitle: @"INSTALLED" forState:UIControlStateNormal];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"packMPisInstalled"]) {
        self.btnInstall_MP.hidden = self.btnInstall_MP.enabled = NO;
        [self.btnInstall_MP setTitle: @"INSTALLED" forState:UIControlStateNormal];
    }
}

#pragma Pack download implementation

//When download button is pressed show notification about downloading pack size (MB)
- (void)downloadPack_AP {
    NSLog(@"init AP");
    //Show notification view only for the first time
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AlertForAPisShown"])
        [self showDownloadSizeAlertView:packAP];
    else { //or start download process animating drop-down download window
        [self startGravityBehaviorForView:self.downloadView_AP];
        [self initDownloadOperationForURL:PACK_APPRENTICE_URL_STRING andPackID:packAP];
        self.btnDownload_AP.enabled = NO;
        //[self.btnDownload_AP setTitle: @"DOWNLOADING..." forState:UIControlStateDisabled];
    }
}

- (void)downloadPack_MP {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AlertForMPisShown"])
        [self showDownloadSizeAlertView:packMP];
    else {
        [self startGravityBehaviorForView:self.downloadView_MP];
        [self initDownloadOperationForURL:PACK_MASTER_URL_STRING andPackID:packMP];
        self.btnDownload_AP.enabled = NO;
        //[self.btnDownload_MP setTitle: @"DOWNLOADING..." forState:UIControlStateDisabled];
    }
}

//Alert view in case of Download error
- (void)showErrorAlertView:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"Download failed" message:error.localizedDescription delegate:
                              self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

//Pack size (MP) notification view
- (void)showDownloadSizeAlertView: (NSString*)packID {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"Attention!" message:@"The file you are going to download is about 100Mb. Proceed?" delegate: self
                                             cancelButtonTitle:@"Later"
                                             otherButtonTitles:@"OK", nil];
    if ([packID isEqualToString:packAP])
        alertView.tag = 1;
    else if ([packID isEqualToString:packMP])
        alertView.tag = 2;
    [alertView show];
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"AlertFor%@isShown", packID]];
    
}
//Notification view protocol method implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) { //If not `cancel`
        if (alertView.tag == 1) { //AP
            [self initDownloadOperationForURL:PACK_APPRENTICE_URL_STRING andPackID:packAP];
            [self startGravityBehaviorForView:self.downloadView_AP];
            //[self.btnDownload_AP setTitle: @"DOWNLOADING..." forState:UIControlStateDisabled];
            self.btnDownload_AP.enabled = NO;
        } else if (alertView.tag == 2) { //MP
            [self initDownloadOperationForURL:PACK_MASTER_URL_STRING andPackID:packMP];
            [self startGravityBehaviorForView:self.downloadView_MP];
            //[self.btnDownload_MP setTitle:@"DOWNLOADING..." forState:UIControlStateNormal];
            self.btnDownload_AP.enabled = NO;
        }
    } else { //If canceled
        if (alertView.tag == 1) {
            //[self.btnDownload_AP setTitle: @"Download" forState:UIControlStateNormal];
            self.btnDownload_AP.enabled = YES;
        } else if (alertView.tag == 2) {
            //[self.btnDownload_MP setTitle: @"Download" forState:UIControlStateNormal];
            self.btnDownload_MP.enabled = YES;
        }
    }
}


- (IBAction)buyPack_AP:(id)sender { //buy AP button
    self.btnBuy_AP.enabled = self.btnRestore_AP.enabled = false;
    [self buyPack:PACK_APPRENTICE];
}

- (IBAction)download_AP:(id)sender { //Download AP button
    [self downloadPack_AP];
}

- (IBAction)buyPack_MP:(id)sender { //buy MP button
    self.btnBuy_MP.enabled = self.btnRestore_MP.enabled = false;
    [self buyPack:PACK_MASTER];
}

- (IBAction)download_MP:(id)sender { //Download MP button
    [self downloadPack_MP];
}

- (IBAction)installPack_AP:(id)sender { //Install AP button
    self.downloadView_AP.hidden = YES;
    [self installPack:packAP];
}

- (IBAction)installPack_MP:(id)sender { //Install MP button
    self.downloadView_MP.hidden = YES;
    [self installPack:packMP];
}

//Pack installation implementaion
- (void)installPack:(NSString *)packName {
    //update UI
    if ([packName isEqualToString:packAP]) {
        self.btnInstall_AP.enabled = NO;
        [self.btnInstall_AP setTitle:@"INSTALLING..." forState:UIControlStateDisabled];
    } else if ([packName isEqualToString:packMP]) {
        self.btnInstall_MP.enabled = NO;
        [self.btnInstall_MP setTitle:@"INSTALLING..." forState:UIControlStateDisabled];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInstallUI:) name:@"ImportNewPackNotification" object:packName];
    [Importer importNewPack:packName withContext:[CoreDataManager sharedInstance].managedObjectContext];
    
}

//Installation completion selector
- (void)updateInstallUI:(NSString *)packName {
    NSString *passedPackName = [NSString stringWithFormat:@"%@", [packName valueForKey:@"object"]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImportNewPackNotification" object:packName];
    //updating NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"pack%@isInstalled", passedPackName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([passedPackName isEqualToString:packAP]) {
        [self.btnInstall_AP setTitle:@"INSTALLED" forState:UIControlStateDisabled];
        self.btnInstall_AP.enabled = NO;
    } else if ([passedPackName isEqualToString:packMP]) {
        [self.btnInstall_MP setTitle:@"INSTALLED" forState:UIControlStateDisabled];
        self.btnInstall_MP.enabled = NO;
    }
}

//Hide `Buy/Restore` buttons enabling `Download` button
-(void)animateButtons:(NSString *)packID {
    if ([packID isEqualToString:packAP]) {
        self.btnDownload_AP.hidden = false; self.btnDownload_AP.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            self.btnBuy_AP.alpha = self.btnRestore_AP.alpha = 0;
            self.btnBuy_AP.hidden = self.btnRestore_AP.hidden = true;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.btnDownload_AP.alpha = 1.0;
            }];
        }];
    } else if ([packID isEqualToString:packMP]) {
        self.btnDownload_MP.hidden = false; self.btnDownload_MP.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            self.btnBuy_MP.alpha = self.btnRestore_MP.alpha = 0;
            self.btnBuy_MP.hidden = self.btnRestore_MP.hidden = true;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.btnDownload_MP.alpha = 1.0;
            }];
        }];
    }
}

//Restore apprentice pack button action
- (IBAction)restore_AP:(id)sender {
    if (products) {
        self.btnRestore_AP.enabled = self.btnBuy_AP.enabled = NO;
        [self restoreProduct: [products valueForKey:PACK_APPRENTICE]];
    }
}

//Restore master pack button action
- (IBAction)restore_MP:(id)sender {
    if (products) {
        self.btnRestore_MP.enabled = self.btnBuy_MP.enabled = NO;
        [self restoreProduct: [products valueForKey:PACK_MASTER]];
    }
}

//Restore selected product
-(void)restoreProduct:(SKProduct *)product {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma NSOperationQueue implementation

//Download operation implementation
-(void)initDownloadOperationForURL: (NSString *)urlString andPackID: (NSString *)packID {
    //Setting download path and download URL
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *targetPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[urlString lastPathComponent]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    GTADownloadQueue *instance = [GTADownloadQueue sharedInstance];
    
    //If download operation already exists for @param `packID`, resume it.
    BOOL operationExists = false;
    if (instance.operationCount > 0) {
        for (AFDownloadRequestOperation *op in instance.operations) {
            if ([op.tag isEqualToString:packID]) {
                operationExists = true;
                [self setHandlersForOperation:op packID:packID];
                if (!op.isExecuting && op.isPaused) {
                    [op resume];
                    [[NSUserDefaults standardUserDefaults] setBool:false forKey:[NSString stringWithFormat:@"pack%@isPaused", packID]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }
    //else create new AFDownloadRequestOpeation and add it to NSOperationQueue
    if (!operationExists) {
        AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:targetPath shouldResume:YES];
        operation.tag = packID;
        operation.shouldOverwrite = YES;
        [self setHandlersForOperation:operation packID:packID];
        [[GTADownloadQueue sharedInstance] addOperation:operation];
        
        
        //Update Download state in NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"pack%@isDownloading", packID]];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:[NSString stringWithFormat:@"pack%@isPaused", packID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    //Update UI
    if ([packID isEqualToString:packAP]) {
        //[self.btnDownload_AP setTitle:@"Downloading" forState:UIControlStateNormal];
        self.btnDownload_AP.enabled = self.btnResumeDownload_AP.enabled = NO;
        self.btnPauseDownload_AP.enabled = YES;
    } else {
        //[self.btnDownload_MP setTitle:@"Downloading" forState:UIControlStateNormal];
        self.btnDownload_MP.enabled = self.btnResumeDownload_MP.enabled = NO;
        self.btnPauseDownload_MP.enabled = YES;
    }
    
    
    NSLog(@"Executing operations: %lu", (unsigned long)[GTADownloadQueue sharedInstance].operationCount);
    
}

//Download operation completion handler implementation (download progress, download success and failure states)
-(void)setHandlersForOperation:(AFDownloadRequestOperation *)operation packID:(NSString *)packID{
    //Completion handler
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Succefully Downloaded file %@", responseObject);
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:[NSString stringWithFormat:@"pack%@isDownloading", packID]];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"pack%@isDownloaded", packID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //Unarchive downloaded pack
        [self unarchive:responseObject packID:packID];
        
        //Disable Resume/Pause buttons, show Downloaded label
        if ([packID isEqualToString:packAP]) { //for AP
            self.btnPauseDownload_AP.alpha = self.btnResumeDownload_AP.alpha = 0;
            self.labelDownloaded_AP.hidden = false;
            self.btnInstall_AP.hidden = false;
        } else if ([packID isEqualToString:packMP]) { //MP
            self.btnPauseDownload_MP.alpha = self.btnResumeDownload_MP.alpha = 0;
            self.labelDownloaded_MP.hidden = false;
            self.btnInstall_MP.hidden = false;
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { //Error handler
        NSLog(@"Error: %@", error);
        [self showErrorAlertView:error];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:[NSString stringWithFormat:@"pack%@isDownloading", packID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([packID isEqualToString:packAP]) {
            //[self.btnDownload_AP setTitle: @"Download" forState:UIControlStateNormal];
            self.btnDownload_AP.enabled = YES;
        } else {
            //[self.btnDownload_MP setTitle: @"Download" forState:UIControlStateNormal];
            self.btnDownload_MP.enabled = YES;
        }
    }];
    
    __weak GTAPacksPurchaseViewController *weakSelf = self;
    
    //Download progress handler
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        
        float percentDone = ((float)totalBytesReadForFile/(float)totalBytesExpectedToReadForFile);
        //
        //NSLog(@"Operation: %@", operation.tag);
        
        //update UIProgressView.progress updating in the main Thread
        [weakSelf performSelectorOnMainThread:@selector(updateProgressView:) withObject:[NSArray arrayWithObjects:operation.tag, [NSNumber numberWithFloat:percentDone], nil] waitUntilDone:NO];
        
    }];
};

//Progress view state update selector
//arrayOfObjects[0] = progressView, [1] = value
-(void)updateProgressView:(NSArray *)arrayOfObjects {
    NSString *packId = [arrayOfObjects objectAtIndex:0];
    float value = [[arrayOfObjects objectAtIndex:1] floatValue];
    int percantage = value * 100;
    
    if ([packId isEqualToString:packAP]) {
        self.labelPercantage_AP.text = [NSString stringWithFormat:@"%d%%", percantage];
        self.progressView_AP.progress = value;
    } else if ([packId isEqualToString:packMP]) {
        self.labelPercantage_MP.text = [NSString stringWithFormat:@"%d%%", percantage];
        self.progressView_MP.progress = value;
    }
    
    //NSLog(@"Log: %@", [NSString stringWithFormat:@"%d %% %@", percantage, @" complete"]);
}
//AP resume dowbload button action for download drop-down view
- (IBAction)resumeDowload_AP:(id)sender {
    [self resumeDownloadOperation: packAP];
}

//AP pause dowbload button action for download drop-down view
- (IBAction)pauseDownload_AP:(id)sender {
    [self pauseDownloadOperation: packAP];
    
}

//MP resume dowbload button action for download drop-down view
- (IBAction)resumeDowload_MP:(id)sender {
    [self resumeDownloadOperation: packMP];
}

//MP pause dowbload button action for download drop-down view
- (IBAction)pauseDownload_MP:(id)sender {
    [self pauseDownloadOperation: packMP];
    
}
//Resuming Download operation for selected pack
-(void)resumeDownloadOperation:(NSString *)packID {
    for (AFDownloadRequestOperation *operation in [GTADownloadQueue sharedInstance].operations) {
        if ([operation.tag isEqualToString:packID]) {
            if (operation.isPaused)
                [operation resume];
            //Update download progress status
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:[NSString stringWithFormat:@"pack%@isPaused", packID]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //Update UI
            if ([packID isEqualToString:packAP]) {
                //[self.btnDownload_AP setTitle: @"Downloading" forState:UIControlStateNormal];
                self.btnDownload_AP.enabled = self.btnResumeDownload_AP.enabled = NO;
                self.btnPauseDownload_AP.enabled = YES;
            } else {
                //[self.btnDownload_MP setTitle: @"Downloading" forState:UIControlStateNormal];
                self.btnDownload_MP.enabled = self.btnResumeDownload_MP.enabled = NO;
                self.btnPauseDownload_MP.enabled = YES;
            }
        }
    }
}

//Pausing Download operation for selected pack
-(void)pauseDownloadOperation:(NSString *)packID {
    for (AFDownloadRequestOperation *operation in [GTADownloadQueue sharedInstance].operations) {
        if ([operation.tag isEqualToString:packID])
            if (operation.isExecuting && !operation.isPaused) {
                [operation pause];
                //Update download progress status
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"pack%@isPaused", packID]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //Update UI
                if ([packID isEqualToString:packAP]) {
                    [self.btnDownload_AP setTitle: @"RESUME" forState:UIControlStateNormal];
                    self.btnDownload_AP.enabled = self.btnResumeDownload_AP.enabled = YES;
                    self.btnPauseDownload_AP.enabled = NO;
                } else {
                    [self.btnDownload_MP setTitle: @"RESUME" forState:UIControlStateNormal];
                    self.btnDownload_MP.enabled = self.btnResumeDownload_MP.enabled = YES;
                    self.btnPauseDownload_MP.enabled = NO;
                }
            }
    }
}

#pragma mark UIDynamicBehavior

//UIDynamicBehavior for Download drop-down views implementation
- (void)startGravityBehaviorForView: (UIView *)view {
    
    if (!self.animator)
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[view]];
    [self.animator addBehavior:gravityBehavior];
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[view]];
    UIDynamicItemBehavior *downloadViewBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
    downloadViewBehavior.elasticity = 0.75;
    [self.animator addBehavior:downloadViewBehavior];
    
    CGPoint point = CGPointMake(self.scrollView.frame.origin.x + self.scrollView.frame.size.width, self.scrollView.frame.origin.y);
    [collisionBehavior addBoundaryWithIdentifier:@"scrollView" fromPoint:self.scrollView.frame.origin toPoint:point];
    [self.animator addBehavior:collisionBehavior];
    
    //change View constraint from -50 to 0 to hold view within the screen
    [view.superview.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
        if (c.constant == -49.0f && c.firstItem == view)
            c.constant = 0;
    }];
}

//UIDynamicBehavior for Download drop-down views implementation withour Effect
- (void)startGravityBehaviorForView: (UIView *)view withNewConstraints:(BOOL)withNewConstraints {
    
    if (withNewConstraints)
        //change View constraint from -50 to 0 to hold view within the screen
        [view.superview.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *c, NSUInteger idx, BOOL *stop) {
            if (c.constant == -49.0f && c.firstItem == view)
                c.constant = 0;
        }];
}

//Segue to Home view controller
- (IBAction)btnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Compare button implementaion
- (IBAction)scrollDown:(id)sender {
    if (!btnCompareClicked) {
        btnCompareClicked = true;
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnMoreInfo.enabled = NO;
            scroller.contentOffset = CGPointMake(scroller.contentOffset.x, scroller.contentOffset.y + 210);
        } completion:^(BOOL finished) {
            self.btnMoreInfo.enabled = YES;
            [self.btnMoreInfo setImage:[UIImage imageNamed:@"btn_up_normal"] forState:UIControlStateNormal];
            [self.btnMoreInfo setImage:[UIImage imageNamed:@"btn_up_normal"] forState:UIControlStateHighlighted];
            [self.btnMoreInfo setImage:[UIImage imageNamed:@"btn_up_normal"] forState:UIControlStateSelected];
        }];
    } else {
        btnCompareClicked = false;
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.btnMoreInfo.enabled = NO;
            scroller.contentOffset = CGPointMake(scroller.contentOffset.x, scroller.contentOffset.y - 210);
        } completion:^(BOOL finished) {
            self.btnMoreInfo.enabled = YES;
            [self.btnMoreInfo setImage:[UIImage imageNamed:@"btn_down_normal"] forState:UIControlStateNormal];
            [self.btnMoreInfo setImage:[UIImage imageNamed:@"btn_down_normal"] forState:UIControlStateHighlighted];
            [self.btnMoreInfo setImage:[UIImage imageNamed:@"btn_down_normal"] forState:UIControlStateSelected];
        }];
    }
    
}


//Product purchase implementation

- (void)buyPack:(NSString *)product {
    NSLog(@"Buy button clicked");
    if ([SKPaymentQueue canMakePayments]) {
        if (!products) {
            UIAlertView *tmp = [[UIAlertView alloc]
                                initWithTitle:@"No products"
                                message:@"Cannot fetch in-App products from iTunes Store."
                                delegate:self
                                cancelButtonTitle:nil
                                otherButtonTitles:@"OK", nil];
            [tmp show];
            //Enable BUY button back
            if ([product isEqualToString:PACK_APPRENTICE])
                self.btnBuy_AP.enabled = self.btnRestore_AP.enabled = YES;
            else if ([product isEqualToString:PACK_MASTER])
                self.btnBuy_MP.enabled = self.btnRestore_MP.enabled = YES;
        } else {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            //
            SKPayment *payment = [SKPayment paymentWithProduct:[products valueForKey:product]];
            if (!notificationObserverIsActive) {
                notificationObserverIsActive = true;
                NSLog(@"Observer added");
            }
            
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    } else { //if parentral access is startDownloadsted
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Payment error" message:@"Payments are disabled on your iPhone." delegate:
                                  self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)provideContentForTransaction: (SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue {
    //Update UI (hide `Buy/Restore` buttons, show `Download` button) and change purchase status in NSUserDefaults
    
    if ([transaction.payment.productIdentifier isEqualToString:PACK_APPRENTICE]) {
        [self animateButtons:packAP];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"packAPisBought"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([transaction.payment.productIdentifier isEqualToString:PACK_MASTER]) {
        [self animateButtons:packMP];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"packMPisBought"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@"No downloads!");
    [queue finishTransaction:transaction];
    NSLog(@"Transaction Finished");
}


#pragma mark StoreKit Delegate


-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"Number of transactions: %lu", (unsigned long)[transactions count]);
    for (SKPaymentTransaction *transaction in transactions) {
        //NSLog(@"1 %@", transaction.payment.productIdentifier);
        //if ([transaction.payment.productIdentifier isEqualToString:self.prodID]) {
        NSLog(@"ID: %@", transaction.transactionIdentifier);
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing %@", transaction.payment.productIdentifier);
                break;
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"Purchased %@", transaction.payment.productIdentifier);
                
                [self provideContentForTransaction: transaction queue:(SKPaymentQueue *)queue];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                break;
            }
                
            case SKPaymentTransactionStateRestored: {
                NSLog(@"Same restore transaction 1/1");
                
                [self provideContentForTransaction: transaction queue:(SKPaymentQueue *)queue];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Fuck: %ld, %@", (long)[transaction.error code], transaction.error.localizedDescription);
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Payment error"
                                                                   message:transaction.error.localizedDescription delegate:
                                          self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction Finished with failure");
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                
                //update UI
                if ([transaction.payment.productIdentifier isEqualToString:PACK_APPRENTICE]) {
                    self.btnBuy_AP.enabled = self.btnRestore_AP.enabled = YES;
                } else if ([transaction.payment.productIdentifier isEqualToString:PACK_MASTER]) {
                    self.btnBuy_MP.enabled = self.btnRestore_MP.enabled = YES;
                }
                
                break;
            }
            default:
                break;
        }
    }
}

- (void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"removedTransactions");
}

- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                              @"Restore failed" message:error.localizedDescription  delegate:
                              self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    NSLog(@"RestoredTransactionFailedWithError");
    //update UI
    for (SKPaymentTransaction *transaction in queue.transactions) {
        if ([transaction.payment.productIdentifier isEqualToString:PACK_APPRENTICE]) {
            self.btnBuy_AP.enabled = self.btnRestore_AP.enabled = YES;
        } else if ([transaction.payment.productIdentifier isEqualToString:PACK_MASTER]) {
            self.btnBuy_MP.enabled = self.btnRestore_MP.enabled = YES;
        }
    }
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"request to AppStore failed");
    
    /*[[NSNotificationCenter defaultCenter] removeObserver:self
     name:@"fetchCompleted"
     object:nil];
     */
    [self.activityIndicator stopAnimating];
    NSLog(@"%@",error.localizedDescription);
    self.fetchingLabel.text = @"Cannot connect to iTunes Store";
    self.btnBack.hidden = NO;
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Payment request");
    //int count = [response.products count];
    if ([response.products count] > 0) {
        
        NSLog(@"Goods available");
        products = [[NSMutableDictionary alloc] init];
        
        for (SKProduct *product in response.products) {
            //adding in-app product to dictionary for retreiving it in buyPack method;
            [products setValue:product forKey:product.productIdentifier];
            //output product descriptions into View
            
            if ([product.productIdentifier isEqualToString:PACK_APPRENTICE]) {
                //price localization
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                self.labelPrice_AP.text = [numberFormatter stringFromNumber:product.price];
            } /*
            //Coming soon
            else if ([product.productIdentifier isEqualToString:PACK_MASTER]) {
                //price localization
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                self.labelPrice_MP.text = [numberFormatter stringFromNumber:product.price];
                
            }*/
        }
        [self fetchCompleted];
    } else {
        
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"No products"
                            message:@"Cannot fetch in-App products from iTunes Store."
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"OK", nil];
        [tmp show];
    }
}

//Unzipping downloaded pack
- (void)unarchive: (id)object packID:(NSString *)packID {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *sourcePath = object;
    
    NSString *extractPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleID];
    NSError *error;
    NSLog(@"Directory is: %@", extractPath);
    NSLog(@"Sorce file is: %@", sourcePath);
    if ([fileManager fileExistsAtPath:extractPath] == NO) {
        
        if ([fileManager createDirectoryAtPath:extractPath withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Error: Unable to create directory: %@", error);
        }
        
        NSURL *url = [NSURL fileURLWithPath:extractPath];
        // exclude downloads from iCloud backup
        if ([url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error] == NO) {
            NSLog(@"Error: Unable to exclude directory from backup: %@", error);
        }
    }
    if ([SSZipArchive unzipFileAtPath:sourcePath toDestination:extractPath]) {
        NSLog(@"Unarchived");
        [fileManager removeItemAtPath:sourcePath error:&error];
        NSLog(@"Error deleting file: %@", error.localizedDescription);
        if ([packID isEqualToString:packAP]) {
            self.btnDownload_AP.alpha = 0;
            self.btnInstall_AP.alpha = 1;
        } else if ([packID isEqualToString:packMP]) {
            self.btnDownload_MP.alpha = 0;
            self.btnInstall_MP.alpha = 1;
        }
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
