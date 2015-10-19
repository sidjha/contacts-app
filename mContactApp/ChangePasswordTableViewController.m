//
//  ChangePasswordTableViewController.m
//  mContactApp
//
//  Created by Sid Jha on 2015-10-16.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "ChangePasswordTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "MBProgressHUD.h"

@interface ChangePasswordTableViewController ()

@end

@implementation ChangePasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    self.oldPasswordTextField.delegate = self;
    self.updatedPasswordTextFieldFirst.delegate = self;
    self.updatedPasswordTextFieldSecond.delegate = self;
    
    self.tableView.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneAction:(id)sender {
    
    NSString *oldPassword = self.oldPasswordTextField.text;
    NSString *newPassword1 = self.updatedPasswordTextFieldFirst.text;
    NSString *newPassword2 = self.updatedPasswordTextFieldSecond.text;
    
    if (![newPassword1 isEqualToString:newPassword2]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Passwords do not match" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:nil];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        NSArray *passwords = @[oldPassword, newPassword1];
        [self savePassword:passwords];
    }
}

- (void) savePassword:(NSArray *) passwords  {
    
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    // make request to /users/show
    // Show a progress HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // new low priority thread to make request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/users/change-password"];
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = NO;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
        data[@"old_password"] = passwords[0];
        data[@"new_password"] = passwords[1];
        
        // Make the request
        [manager
         POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){
             
             [self.view endEditing:YES];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             [self dismissViewControllerAnimated:YES completion:nil];
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSString *alertMsg;
             NSString *alertTitle;
             // show appropriate error message based on response code
             if ([operation.response statusCode] == 400) {
                 
                 alertTitle = @"Incorrect Password";
                 alertMsg = @"That's not the correct current password.";
             } else {
                 
                 alertTitle = @"Oops..";
                 alertMsg = @"Sorry, we couldn't update your password because something went wrong.";
             }
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
             [self presentViewController:alertController animated:YES completion:nil];
         }];
    });
}

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
    
    return YES;
}

- (IBAction)validateFields:(id)sender
{
    BOOL valid = YES;
    
    NSArray *textFieldArray = @[self.oldPasswordTextField, self.updatedPasswordTextFieldFirst, self.updatedPasswordTextFieldSecond];
    // On every press we're going to run through all the fields and get their length values. If any of them equal nil we will set our bool to NO.
    for (int i = 0; i < [textFieldArray count]; i++)
    {
        if (![[[textFieldArray objectAtIndex:i] text] length])
            valid = NO;
    }
    
    [self.navigationItem.rightBarButtonItem setEnabled:valid];
}

#pragma mark - Table view data source

/*
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
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

@end
