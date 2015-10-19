//
//  SignupViewController.m
//  mContactApp
//
//  Created by Sid Jha on 11/09/15.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "SignupViewController.h"
#import "StackedViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"

#import "MBProgressHUD.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"By signing up, you agree to our terms and privacy policy."];
    [str addAttribute: NSLinkAttributeName value: @"http://mesh8.co/favor8/terms" range: NSMakeRange(32, 5)];
    [str addAttribute: NSLinkAttributeName value: @"http://mesh8.co/favor8/privacy" range: NSMakeRange(42, 14)];
    self.disclaimerTextView.attributedText = str;
    [self.disclaimerTextView setTextAlignment:NSTextAlignmentCenter];
    
    [self.usernameField becomeFirstResponder];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.nameField.delegate = self;
    
    [self.signupButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    // Show a progress HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    NSString *name = _nameField.text;
    NSDictionary *parameters = @{@"username": username, @"password": password, @"name": name};
    NSString *URLString = @"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/users/create";
    
    // Set headers
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // Make the request
    [manager
     POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
         
         // TODO: save the auth token more securely in Keychain
         NSString *authToken = responseObject[@"auth_token"];
         NSString *userID = responseObject[@"user_id"];
         [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"favor8AuthToken"];
         [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"favor8UserID"];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
         
         StackedViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"card"];
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self presentViewController:controller animated:YES completion:nil];
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSString *alertMsg;
         NSString *alertTitle;
         UIAlertController *alertController;
         
         if ([operation.response statusCode] == 400) {
             
             alertTitle = @"User Already Exists";
             alertMsg = @"That username is already taken. Please try something else. If you already have an account, please tap Login.";
             
             alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 [self performSegueWithIdentifier:@"loginFromSignupSegue" sender:self];
             }];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 [self.usernameField becomeFirstResponder];
             }];
             
             [alertController addAction:loginAction];
             [alertController addAction:okAction];
             
         } else {
             
             alertTitle = @"Oops";
             alertMsg = @"Sorry, something went wrong and we couldn't log-in you in.";
             
             alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         }
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self presentViewController:alertController animated:YES completion:nil];
     }];
}

# pragma mark - UITextFieldDelegate protocol methods

- (BOOL)textFieldShouldReturn:(UITextField * _Nonnull)textField
{
    
    // shift focus to next text field
    // http://stackoverflow.com/a/1351090
    
    NSInteger nextTag = textField.tag + 1;
    
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self.signupButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string {
    
    if (textField.tag == 0) {
        
        // if username, don't allow whitespaces and only allow lowercase alphanumeric with _.-
        
        NSString *trimmedStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([textField.text isEqualToString:trimmedStr]) {
            return NO;
        }
        
        NSMutableCharacterSet *allowedChars = [NSMutableCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789_.-"];
        
        if ([string rangeOfCharacterFromSet:[allowedChars invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        return YES;
        
    } else if (textField.tag == 1) {
        
        // if password, don't allow whitespaces
        
        NSString *trimmedStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([textField.text isEqualToString:trimmedStr]) {
            return NO;
        }
        
        return YES;
        
    } else {
        
        // if name, allow all characters
        
        return YES;
    }
}

/** Validates text fields so that action button is never
 * enabled when text fields are empty.
 * @return YES, if both textfields are non-empty; otherwise, NO.
 */
- (IBAction)validateFields:(id)sender
{
    BOOL valid = YES;
    
    NSArray *textFieldArray = @[self.usernameField, self.passwordField, self.nameField];
    
    // On every press we're going to run through all the fields and get their length values. If any of them equal nil we will set our bool to NO.
    for (int i = 0; i < [textFieldArray count]; i++)
    {
        if (![[[textFieldArray objectAtIndex:i] text] length])
            valid = NO;
    }
    
    [self.signupButton setEnabled:valid];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
