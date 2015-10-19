//
//  LoginViewController.m
//  mContactApp
//
//  Created by Sid Jha on 02/09/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "StackedViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"

#import "MBProgressHUD.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.usernameField becomeFirstResponder];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    [self.loginButton setEnabled:NO];
    
    //[self.loginButton.layer setBorderColor:[UIColor blueColor].CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    // Show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    // Note: Explicitly getting a low priority queue and making the request on that,
    //       because MBProgressHUD recommends so. However, the success and failure
    //       methods are called on the main queue by AFNetworking anyway. So is
    //       this even necessary? The progress HUD works even if called on the main
    //       thread before the request. Do we need to do some garbage collection
    //       on the main queue after?
    
    // new low priority thread to make request
    
    
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    NSDictionary *parameters = @{@"username": username, @"password": password};
    NSString *URLString = @"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/users/login";
    
    // Set headers
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // Make the request
    [manager
     POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         // TODO: save the auth token more securely in Keychain
         NSString *authToken = responseObject[@"auth_token"];
         NSString *userID = responseObject[@"user_id"];
         [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"favor8AuthToken"];
         [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"favor8UserID"];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         NSString *savedVal = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8UserID"];
         
         StackedViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"card"];
         
         [self presentViewController:controller animated:YES completion:nil];
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSString *alertMsg;
         NSString *alertTitle;
         UIAlertController *alertController;
         
         if ([operation.response statusCode] == 400 || [operation.response statusCode] == 404) {
             
             alertTitle = @"No User Found";
             alertMsg = @"There is no user associated with that username.";
             
             alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 [self.usernameField becomeFirstResponder];
             }];
             
             [alertController addAction:okAction];
             
         } else if ([operation.response statusCode] == 401) {
             
             alertTitle = @"Incorrect Password";
             
             alertController = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 [self.passwordField becomeFirstResponder];
             }];
             
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
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string {
    
    // Don't allow whitespace or new line chars
    NSString *trimmedStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([textField.text isEqualToString:trimmedStr])
    {
        return NO;
    }
    
    if (textField.tag == 0) {
        
        NSMutableCharacterSet *allowedChars = [NSMutableCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789_.-"];
        
        if ([string rangeOfCharacterFromSet:[allowedChars invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        return YES;
    }
    
    return YES;
}


/** Validates text fields so that action button is never
 * enabled when text fields are empty.
 * @return YES, if both textfields are non-empty; otherwise, NO.
 */
- (IBAction)validateFields:(id)sender
{
    BOOL valid = YES;
    
    NSArray *textFieldArray = @[self.usernameField, self.passwordField];
    
    // On every press we're going to run through all the fields and get their length values. If any of them equal nil we will set our bool to NO.
    for (int i = 0; i < [textFieldArray count]; i++)
    {
        if (![[[textFieldArray objectAtIndex:i] text] length])
            valid = NO;
    }
    
    [self.loginButton setEnabled:valid];
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
