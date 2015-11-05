//
//  ForgotPwdTableViewController.h
//  favor8
//
//  Created by Sid Jha on 2015-11-03.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPwdTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIButton *sendVerCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *vercodeField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField1;
@property (weak, nonatomic) IBOutlet UITextField *passwordField2;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;

@property (copy, nonatomic) NSString *vercode;
@property (copy, nonatomic) NSString *username;

- (IBAction)sendVerCode:(id)sender;
- (IBAction)saveNewPassword:(id)sender;

@end
