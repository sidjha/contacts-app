//
//  SAEditViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-10-08.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAEditViewController;

@protocol SAEditViewControllerDelegate <NSObject>

- (void) socialEditViewController:(SAEditViewController *)controller didFinishUpdatingAccount:(NSString *)accountHandle;

@end

@interface SAEditViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *accountHandleTextField;

@property (nonatomic, assign) NSInteger row;
@property (strong, nonatomic) NSMutableArray *socialLabels;
@property (strong, nonatomic) NSMutableArray *socialPlaceholders;

@property (weak, nonatomic) id <SAEditViewControllerDelegate> delegate;

@end
