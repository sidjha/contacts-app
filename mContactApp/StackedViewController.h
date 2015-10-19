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

/** Card data for the authenticating user */
@property (nonatomic, weak) NSMutableDictionary *myCard;

/** A counter to keep track of number of consecutive
 * failed requests. If there is one failed
 * request for either getting user's card or friend's cards
 * from server, then the request will be made again.
 * Otherwise, the UI will show a hint to reload data
 * manually (like through a "Pull down to refresh" helper
 * text). The counter is reset every time the view re-appears.
 */
@property (assign, atomic) NSInteger failedRequestCount;

@property (nonatomic) UILabel *requestStatus;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSMutableAttributedString *attributedString;

- (IBAction)editButtonPressed:(id)sender;
- (IBAction)socialButtonPressed:(id)sender;
- (IBAction)phoneButtonPressed:(id)sender;

@end
