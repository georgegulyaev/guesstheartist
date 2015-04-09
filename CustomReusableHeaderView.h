//
//  CustomReusableHeaderView.h
//  GuessTheArtist
//
//  Created by George Gulyaev on 3/27/15.
//  Copyright (c) 2015 Georgiy Gulyaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomReusableHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel* labelHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnPacks;

@end
