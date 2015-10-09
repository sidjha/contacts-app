//
//  StackedViewController.h
//  StackedViewController
//


#import <UIKit/UIKit.h>

#import "TGLStackedViewController.h"
#import "EditViewController.h"
@import StoreKit;

@interface StackedViewController : TGLStackedViewController <EditViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, assign) BOOL doubleTapToClose;
@property (nonatomic, weak) NSMutableDictionary *myCard;

- (IBAction)editButtonPressed:(id)sender;
- (IBAction)socialButtonPressed:(id)sender;
- (IBAction)phoneButtonPressed:(id)sender;

@end
