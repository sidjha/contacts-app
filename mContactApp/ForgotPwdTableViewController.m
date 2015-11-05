//
//  ForgotPwdTableViewController.m
//  favor8
//
//  Created by Sid Jha on 2015-11-03.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "ForgotPwdTableViewController.h"

#import "AFHTTPRequestOperationManager.h"

#import "MBProgressHUD.h"


@interface ForgotPwdTableViewController ()

@end

@implementation ForgotPwdTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    self.usernameField.delegate = self;
    self.vercodeField.delegate = self;
    self.passwordField1.delegate = self;
    self.passwordField2.delegate = self;
    
    self.tableView.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) donePressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendVerCode:(id)sender {
    NSString *username = self.usernameField.text;
    
    [self.vercodeField setText:@""];
    [self sendVerificationCode:username];
}

- (IBAction)saveNewPassword:(id)sender {
    if (![self.passwordField1.text isEqualToString:self.passwordField2.text]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Passwords do not match" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self resetPassword:self.passwordField1.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


/*
 
 How this should work —
 
 1. Enable Send Verification Code once username field != @""
 2. Once Send is tapped, make request, and move to next field or show error
 3. Once you hit 6 characters in Ver code field, don't let allow more characters and make request to check code, while activating spinner
 4. If code is correct, move to next field, otherwise show error and reset ver code field
 5. Only enable "Save" button if password1 = password2
 
 */

# pragma mark - UITextFieldDelegate protocol methods

- (BOOL)textFieldShouldReturn:(UITextField * _Nonnull)textField
{
    
    // shift focus to next text field
    // http://stackoverflow.com/a/1351090
    
    NSInteger nextTag = textField.tag + 1;
    
    // Try to find next responder
    UIResponder* nextResponder = [self.tableView viewWithTag:nextTag];
    
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
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

- (IBAction)validateUsernameField:(id)sender
{
    BOOL valid = YES;
    
    if ([self.usernameField.text length] == 0) {
        [self.sendVerCodeButton setEnabled:NO];
        valid = NO;
    } else {
        [self.sendVerCodeButton setEnabled:YES];
    }
}

- (IBAction)validateVerificationField:(id)sender
{
    BOOL valid = YES;
    
    if ([self.vercodeField.text length] < 6) {
        valid = NO;
    } else {
        [self.vercodeField setEnabled:NO];
        self.vercode = self.vercodeField.text;
        self.username = self.usernameField.text;
        [self checkVerCode:self.vercode];
    }
}

- (IBAction)validatePasswordField:(id)sender
{
    BOOL valid = YES;
    
    if ([self.passwordField1.text length] == 0 || [self.passwordField2.text length] == 0) {
        valid = NO;
    }
    
    [self.resetPasswordButton setEnabled:valid];
}

- (void) sendVerificationCode:(NSString *)username {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/ver-codes/generate"];
    
    // Set headers
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    data[@"username"] = username;
    
    // Make the request
    [manager
     POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         // [self.sendVerCodeButton setTitle:@"Re-send Verification Code" forState:UIControlStateNormal];
         
         [self.vercodeField becomeFirstResponder];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSString *msg;
         UIAlertController *alertController;
         
         if ([operation.response statusCode] == 404) {
             
             alertController = [UIAlertController alertControllerWithTitle:@"User Not Found" message:nil preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         } else {
             
             msg = @"Sorry, something went wrong. Please try again.";
             alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         }
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         [self presentViewController:alertController animated:YES completion:nil];
         
         [self.vercodeField becomeFirstResponder];
     }];
}

- (void) checkVerCode:(NSString *)code {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/ver-codes/verify"];
    
    // Set headers
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    data[@"username"] = self.username;
    data[@"code"] = self.vercode;
    
    // Make the request
    [manager
     POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         [self.passwordField1 setEnabled:YES];
         [self.passwordField2 setEnabled:YES];

         [self.passwordField1 becomeFirstResponder];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [self.vercodeField setText:@""];
         [self.vercodeField setEnabled:YES];
         
         [self.passwordField1 setEnabled:NO];
         [self.passwordField2 setEnabled:NO];
         
         NSString *msg;
         UIAlertController *alertController;
         
         if ([operation.response statusCode] == 404) {
             
             alertController = [UIAlertController alertControllerWithTitle:@"User Not Found" message:nil preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         } else if ([operation.response statusCode] == 400) {
             NSString *msg = @"The verification code you entered is incorrect. Please try again or tap Send Verification Code again to get a new code by SMS.";
             alertController = [UIAlertController alertControllerWithTitle:@"Incorrect Verification Code" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
         
         } else {
             
             msg = @"Sorry, something went wrong. Please try again.";
             alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         }
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         [self presentViewController:alertController animated:YES completion:nil];
     }];
}

- (void) resetPassword:(NSString *)password {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/users/reset-password"];
    
    // Set headers
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    data[@"username"] = self.username;
    data[@"code"] = self.vercode;
    data[@"new_password"] = password;
    
    // Make the request
    [manager
     POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         UIAlertController *alertController;
         
         alertController = [UIAlertController alertControllerWithTitle:@"Password Reset" message:@"Your password has been successfully reset. You can now log-in!" preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self donePressed:self];
         }];
         
         [alertController addAction:okAction];
         
         [self presentViewController:alertController animated:YES completion:nil];
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         NSString *msg;
         UIAlertController *alertController;
         
         if ([operation.response statusCode] == 404) {
             
             alertController = [UIAlertController alertControllerWithTitle:@"User Not Found" message:nil preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         } else if ([operation.response statusCode] == 400) {
             NSString *msg = @"The verification code you entered is incorrect or expired. Please try again or tap Send Verification Code again to get a new code by SMS.";
             alertController = [UIAlertController alertControllerWithTitle:@"Incorrect Verification Code" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         } else {
             
             msg = @"Sorry, something went wrong. Please try again.";
             alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
         }
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         [self presentViewController:alertController animated:YES completion:nil];
     }];
}




@end
