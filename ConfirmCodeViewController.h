//
//  ConfirmCodeViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-08-24.
//  Copyright (c) 2015 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmCodeViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *confirmCode;
@property (weak, nonatomic) IBOutlet UITextField *confirmationCodeField;
@property (weak, nonatomic) IBOutlet UIButton *resendCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSURLSession *session;

@end
