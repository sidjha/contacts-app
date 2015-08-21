//
//  cardBackViewController.h
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 12/08/15.
//  Copyright (c) 2015 Pankaj Bhardwaj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cardBackViewController : UIViewController
- (IBAction)dismissController:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *gridCollection;

@end
