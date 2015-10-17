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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneAction:(id)sender {
    
    NSString *oldPassword = self.oldPasswordTextField.text;
    NSString *newPassword1 = self.updatedPasswordTextFieldFirst.text;
    NSString *newPassword2 = self.updatedPasswordTextFieldSecond.text;
    
    // TODO: check if old password valid
    if (![newPassword1 isEqualToString:newPassword2]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Passwords do not match" message:@"Passwords do not match" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving password...";
    
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
             NSLog(@"/users/change-password response data: %@", responseObject);
             
             [self.view endEditing:YES];
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             [self dismissViewControllerAnimated:YES completion:nil];
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             // show appropriate error message based on response code
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             NSLog(@"Error: %@", error);
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not save password." preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
             [self presentViewController:alertController animated:YES completion:nil];
             
         }];
    });
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
