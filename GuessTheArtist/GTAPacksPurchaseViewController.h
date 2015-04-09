//
//  GTAPacksPurchase.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 11/13/14.
//  Copyright (c) 2014 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface GTAPacksPurchaseViewController : UIViewController <SKPaymentTransactionObserver, SKProductsRequestDelegate, UIAlertViewDelegate> {
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
    int productID;
    IBOutlet UIScrollView *scroller;
}

@end
