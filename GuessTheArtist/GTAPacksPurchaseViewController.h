//
//  GTAPacksPurchase.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/13/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface GTAPacksPurchaseViewController : UIViewController <SKPaymentTransactionObserver, SKProductsRequestDelegate> {
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
    int productID;
    IBOutlet UIScrollView *scroller;
}
@property (strong, nonatomic) IBOutlet UIButton *pack1BuyBtn;
@property (strong, nonatomic) IBOutlet UILabel *pack1LabelTitle;
@property (strong, nonatomic) IBOutlet UILabel *pack1LabelInfo;
@property (strong, nonatomic) IBOutlet UILabel *pack1LabelStatus;
@property (strong, nonatomic) IBOutlet UILabel *pack1LabelPrice;
@property (strong, nonatomic) IBOutlet UILabel *pack1LabelDownloadId;
@property (strong, nonatomic) IBOutlet UILabel *pack1LabelDownloadTimeRemaining;
@property (strong, nonatomic) IBOutlet UILabel *pack1LabelDownloadState;


@property (strong, nonatomic) IBOutlet UIButton *pack2BuyBtn;
@property (strong, nonatomic) IBOutlet UILabel *pack2LabelTitle;
@property (strong, nonatomic) IBOutlet UILabel *pack2LabelInfo;
@property (strong, nonatomic) IBOutlet UILabel *pack2LabelStatus;
@property (strong, nonatomic) IBOutlet UILabel *pack2LabelPrice;

@property (weak, nonatomic) IBOutlet UIView *fetchingView;
@property (strong, nonatomic) IBOutlet UILabel *fetchingLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnMoreInfo;

- (IBAction)buyPack1:(id)sender;
- (IBAction)buyPack2:(id)sender;
- (IBAction)btnBack:(id)sender;
- (IBAction)scrollDown:(id)sender;

@end
