//
//  StackedViewController.h
//  StackedViewController
//


#import <UIKit/UIKit.h>

#import "TGLStackedViewController.h"
#import "EditViewController.h"

@interface StackedViewController : TGLStackedViewController <EditViewControllerDelegate>

@property (nonatomic, assign) BOOL doubleTapToClose;
@property (nonatomic, weak) NSMutableDictionary *myCard;

- (IBAction)editButtonPressed:(id)sender;
- (IBAction)socialButtonPressed:(id)sender;
- (IBAction)phoneButtonPressed:(id)sender;

@end
