//
//  EditViewController.h
//  mContactApp
//
//  Created by Sid Jha on 11/09/15.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextView *statusField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *status;
@property (weak, nonatomic) NSString *phone;
@property (weak, nonatomic) NSMutableDictionary *socialLinks;
@property (weak, nonatomic) NSString *profileImgURL;


- (IBAction)donePressed:(id)sender;

@end
