//
//  PhoneVerificationViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-08-24.
//  Copyright (c) 2015 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryCodeTableViewController.h"

@interface PhoneVerificationViewController : UIViewController <UITextFieldDelegate, CountryCodeTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UIButton *countryCodeButton;

@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *fullPhone;

@property (strong, nonatomic) NSURLSession *session;

@end
