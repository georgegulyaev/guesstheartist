//
//  GTAPacksPurchase.m
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/13/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import "GTAPacksPurchaseViewController.h"
#define pack_1_id @"com.guesstheartist.apprenticepack"
#define pack_2_id @"com.guesstheartist.masterpack"

@implementation GTAPacksPurchaseViewController {
    NSMutableDictionary *products;
    NSString *currentProduct;
    BOOL notificationObserverIsActive;
    BOOL btnCompareClicked;
}

- (void)viewDidLoad {
    notificationObserverIsActive = false;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchCompleted)
                                                 name:@"fetchCompleted"
                                               object:nil];
    self.fetchingView.hidden = NO;
    self.btnBack.hidden = YES;
    [self.activityIndicator startAnimating];
    [self fetchAvailableProducts];
    

}

- (void) fetchAvailableProducts { //request in-app purchases from App Store
    
    NSSet *productIdentifiers = [NSSet
                                 setWithObjects:pack_1_id, pack_2_id,nil];
    productsRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)fetchCompleted {
    [self.activityIndicator stopAnimating];
    self.fetchingView.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"fetchCompleted"
                                                  object:nil];
}

- (IBAction)buyPack1:(id)sender {
    [self buyPack:pack_1_id];
}

- (IBAction)buyPack2:(id)sender {
    [self buyPack:pack_2_id];
}

- (IBAction)btnBack:(id)sender {
    [self performSegueWithIdentifier:@"PacksToHome" sender:sender];
}

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


- (void)buyPack:(NSString *)product {
    NSLog(@"Buy button clicked");
    if ([SKPaymentQueue canMakePayments]) {
        if (!products) {
            UIAlertView *tmp = [[UIAlertView alloc]
                                initWithTitle:NSLocalizedString(@"oops", nil)
                                message:NSLocalizedString(@"no_access", nil)
                                delegate:self
                                cancelButtonTitle:nil
                                otherButtonTitles:@"OK", nil];
            [tmp show];
        } else {
            [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
            SKPayment *payment = [SKPayment paymentWithProduct:[products valueForKey:product]];
            if (!notificationObserverIsActive) {
                notificationObserverIsActive = true;
                NSLog(@"Observer added");
                [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            }
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    } else { //if parentral access is activated
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  NSLocalizedString(@"purchases_disabled", nil) message:nil delegate:
                                  self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)unlockProcuct {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (productID == 1) {
        [defaults setBool:YES forKey:@"Pack1_Unlocked"];
        self.pack1LabelStatus.text = @"Bought";
    } else if (productID == 2) {
        [defaults setBool:YES forKey:@"Pack2_Unlocked"];
        self.pack2LabelStatus.text = @"Bought";
    }
    //TO-DO
    //hide buy/restore buttons. enable download button
}

- (void)provideContentForTransaction: (SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue {
    
    if (transaction.downloads) {
        NSLog(@"Downloads activated");
        //srart download process
        [queue startDownloads:transaction.downloads];
    } else {
        //provide contenet here:
        //TO-DO
        NSLog(@"No downloads!");
        [queue finishTransaction:transaction];
        NSLog(@"Transaction Finished");
    }
}

- (void) showUIForTransaction: (SKPaymentTransaction *)transaction {
    
}

- (void) updateDownloadProgressUI: (NSString *)contentIdentifier progress:(float)progress timeRemaining: (NSTimeInterval)timeRemaining state: (SKDownloadState)downloadState {
    NSLog(@"Called!");
    self.pack1LabelDownloadId.text = contentIdentifier;
    self.pack1LabelDownloadTimeRemaining.text = [self formattedStringForDuration:timeRemaining];
    self.pack1LabelDownloadState.text = [NSString stringWithFormat:@"%f", progress];
    [self.pack1LabelDownloadTimeRemaining setNeedsDisplay];
}

- (void) removeDownloadProgeressFromUI: (NSString *)contentIdentifier state: (SKDownloadState)downloadState {
    
    self.pack1LabelDownloadId.text = contentIdentifier;
    self.pack1LabelDownloadTimeRemaining.text = @"Cancelled";
    self.pack1LabelDownloadState.text = [NSString stringWithFormat:@"%d", downloadState];
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration
{
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
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
                break;
            }
                
            case SKPaymentTransactionStateRestored: {
                NSLog(@"Same restore transaction 1/1");
                [self provideContentForTransaction: transaction queue:(SKPaymentQueue *)queue];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Fuck: %ld, %@", (long)[transaction.error code], transaction.error.localizedDescription);
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                 [NSString stringWithFormat:@"Payment Error: %@", transaction.error.localizedDescription] message:nil delegate:
                 self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alertView show];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction Finished");
                break;
            }
            default:
                break;
        }
    }
}

-(void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"removedTransactions");
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"Same restore transaction 1/2");
    bool messageShowed = false;
    if (queue.transactions.count > 0) {
        for (SKPaymentTransaction *transaction in queue.transactions)
        {
            if(SKPaymentTransactionStateRestored) {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                          NSLocalizedString(@"restore_failed", nil) message:nil delegate:
                                          self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                break;
                
            }
        }
    }
    if (!messageShowed) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  NSLocalizedString(@"restore_failed", nil) message:nil delegate:
                                  self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"RestoredTransactionFailedWithError");
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"fetchCompleted"
                                                  object:nil];
    [self.activityIndicator stopAnimating];
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
            
            if ([product.productIdentifier isEqualToString:pack_1_id]) {
                self.pack1LabelTitle.text = product.localizedTitle;
                self.pack1LabelInfo.text = product.localizedDescription;
                
                //price localization
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                self.pack1LabelPrice.text = [numberFormatter stringFromNumber:product.price];
            } else if ([product.productIdentifier isEqualToString:pack_2_id]) {
                self.pack2LabelTitle.text = product.localizedTitle;
                self.pack2LabelInfo.text = product.localizedDescription;
                
                //price localization
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:product.priceLocale];
                self.pack2LabelPrice.text = [numberFormatter stringFromNumber:product.price];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchCompleted"
                                                            object:self
                                                          userInfo:nil];
    } else {
        
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:NSLocalizedString(@"not_available", nil)
                            message:NSLocalizedString(@"no_products", nil)
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"OK", nil];
        [tmp show];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    for (SKDownload *download in downloads) {
        switch (download.downloadState) {
                
            case SKDownloadStateActive:
                NSLog(@"Active! Time: %f, progress: %f", download.timeRemaining, download.progress);
                break;
            case SKDownloadStateWaiting:
                
                break;
            case SKDownloadStatePaused:
                NSLog(@"Paused! Time: %f, progress: %f", download.timeRemaining, download.progress);
                //[self updateDownloadProgressUI: download.contentIdentifier progress:download.progress timeRemaining:download.timeRemaining state: download.downloadState];
                break;
            case SKDownloadStateCancelled:
                NSLog(@"Download Cancelled");
                break;
            case SKDownloadStateFailed:
                //[self removeDownloadProgeressFromUI: download.contentIdentifier state:download.downloadState];
                NSLog(@"Download Failed");
                break;
            case SKDownloadStateFinished:
                NSLog(@"Fnished! Time: %f, progress: %f", download.timeRemaining, download.progress);
                [self processDownload:download];
                //[self updateDownloadProgressUI: download.contentIdentifier progress:download.progress timeRemaining:download.timeRemaining state: download.downloadState];
                NSLog(@"Transaction Finished");
                [queue finishTransaction:download.transaction];
                
                break;
                
    
        }
    }
}

- (void) processDownload:(SKDownload*)download;
{
    // convert url to string, suitable for NSFileManager
    NSString *path = [download.contentURL path];
    
    // files are in Contents directory
    path = [path stringByAppendingPathComponent:@"Contents"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    //NSString *dir = [MyConfig downloadableContentPathForProductId:download.contentIdentifier]; // not written yet
    NSString *dir = [self downloadableContentPath]; // not written yet
    
    for (NSString *file in files) {
        NSString *fullPathSrc = [path stringByAppendingPathComponent:file];
        NSString *fullPathDst = [dir stringByAppendingPathComponent:file];
        NSLog(@"New file is %@", fullPathDst);
        
        // not allowed to overwrite files - remove destination file
        [fileManager removeItemAtPath:fullPathDst error:NULL];
        
        if ([fileManager moveItemAtPath:fullPathSrc toPath:fullPathDst error:&error] == NO) {
            NSLog(@"Error: unable to move item: %@", error);
        }
    }
    
    // NOT SHOWN: use download.contentIdentifier to tell your model that we've been downloaded
}

- (NSString *) downloadableContentPath;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    directory = [directory stringByAppendingPathComponent:@"Downloads"];
    NSLog(@"Directory is: %@", directory);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:directory] == NO) {
        
        NSError *error;
        if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"Error: Unable to create directory: %@", error);
        }
        
        NSURL *url = [NSURL fileURLWithPath:directory];
        // exclude downloads from iCloud backup
        if ([url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error] == NO) {
            NSLog(@"Error: Unable to exclude directory from backup: %@", error);
        }
    }
    
    return directory;
}
@end
