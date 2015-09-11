//
//  StackedViewController.h
//  StackedViewController
//


#import <UIKit/UIKit.h>

#import "TGLStackedViewController.h"

@interface StackedViewController : TGLStackedViewController

@property (nonatomic, assign) BOOL doubleTapToClose;
@property (nonatomic, weak) NSDictionary *currentCard;
- (IBAction)editButtonPressed:(id)sender;
- (IBAction)socialButtonPressed:(id)sender;
- (IBAction)phoneButtonPressed:(id)sender;


@end
