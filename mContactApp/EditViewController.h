//
//  EditViewController.h
//  mContactApp
//
//  Created by Sid Jha on 11/09/15.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditViewController;

@protocol EditViewControllerDelegate <NSObject>

- (void) editViewController:(EditViewController *)controller didFinishUpdatingCard:(NSMutableDictionary *)card;

@end

@interface EditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextView *statusField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITableView *socialLinksTableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *status;
@property (weak, nonatomic) NSString *phone;
@property (weak, nonatomic) NSMutableDictionary *socialLinks;
@property (weak, nonatomic) NSString *profileImgURL;
@property (strong, nonatomic) NSMutableArray *links;
@property (strong, nonatomic) NSMutableArray *linkImages;



@property (weak, nonatomic) NSMutableDictionary *card;

@property (weak, nonatomic) id <EditViewControllerDelegate> delegate;

- (IBAction)donePressed:(id)sender;

@end
