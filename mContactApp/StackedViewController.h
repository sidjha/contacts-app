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
@property (nonatomic) UILabel *requestStatus;
//@property (nonatomic) UIButton *refreshButton;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSMutableAttributedString *attributedString;

- (IBAction)editButtonPressed:(id)sender;
- (IBAction)socialButtonPressed:(id)sender;
- (IBAction)phoneButtonPressed:(id)sender;

@end
