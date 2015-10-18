//
//  AddFriendViewController.m
//  mContactApp
//
//  Created by Sid Jha on 2015-10-09.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "AddFriendViewController.h"
#import "FriendRequestsTableViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"

#import "MBProgressHUD.h"


@interface AddFriendViewController ()

@end

@implementation AddFriendViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getIncomingRequests];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** Brings up a dialog to send a friend request.
 */
- (IBAction)addFriendByUsername:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Username of Person" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.placeholder = NSLocalizedString(@"username", @"Username");
        textField.delegate = self;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send Request", @"OK Action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *username = alertController.textFields.firstObject;
        
        if ([username.text length] > 0) {
            [self sendFriendRequest:username.text];
        }
        
        [self.view endEditing:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel Action") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self.view endEditing:YES];
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)addFriendbyCodeUpload:(id)sender {
 
}
/** Gets any incoming friend requests from the server
 * in the background, and updates the badge on View Friend Requests
 * button with the number of pending incoming requests.
 */
- (void) getIncomingRequests {
    
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
 
    // do this on the background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/friends/incoming_requests"];
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = NO;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        
        // Make the request
        [manager
         GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
             
             self.incomingFriendRequests = responseObject[@"incoming_requests"];
             
             if ([responseObject[@"incoming_requests"] count] > 0) {
                  [self.viewRequestsButton setTitle:[NSString stringWithFormat:@"View Friend Requests (%lu)", [responseObject[@"incoming_requests"] count]] forState:UIControlStateNormal];
             }
             
             for (NSInteger i = 0; i < [responseObject[@"incoming_requests"] count]; i++) {
                 NSLog(@"Request from: %@", responseObject[@"incoming_requests"][i]);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);
             
         }];
    });

}

/** Sends a friend request to a user
 * @param username An NSString containing the username of person to send request to.
 */
- (void) sendFriendRequest:(NSString *)username {
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    // make request to /users/show
    // Show a progress HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/friends/send_request"];
    
    // Set headers
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
    
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    data[@"target_username"] = username;
    
    // Make the request
    [manager
     POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){

         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         NSString *msg = [NSString stringWithFormat:@"Friend request to %@ sent.", username];
         
         // show alert
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sent" message:msg preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
         
         [alertController addAction:okAction];
         
         [self presentViewController:alertController animated:YES completion:nil];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSString *msg;
         UIAlertController *alertController;
         
         if ([operation.response statusCode] == 400) {
             
             if ([operation.responseObject[@"error"] isEqualToString:@"Friend request already sent."]) {
                 
                 msg = [NSString stringWithFormat:@"Friend request to %@ has already been sent and is waiting for approval.", username];
                 alertController = [UIAlertController alertControllerWithTitle:@"Already Sent" message:msg preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 
                 [alertController addAction:okAction];
             
             } else if ([operation.responseObject[@"error"] isEqualToString:@"User already a friend."]) {
                 
                 msg = [NSString stringWithFormat:@"You are already friends with %@.", username];
                 alertController = [UIAlertController alertControllerWithTitle:@"Already a Friend" message:msg preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 
                 [alertController addAction:okAction];

             } else if ([operation.responseObject[@"error"] isEqualToString:@"Cannot add yourself."]) {
                 
                 msg = @"You cannot add yourself as a friend.";
                 alertController = [UIAlertController alertControllerWithTitle:@"Not Allowed" message:msg preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 
                 [alertController addAction:okAction];
             
             } else {
                 
                 msg = @"Please Try Again.";
                 alertController = [UIAlertController alertControllerWithTitle:@"Invalid Request" message:msg preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                 
                 [alertController addAction:okAction];
             }
         
         } else if ([operation.response statusCode] == 404) {
             
             msg = [NSString stringWithFormat:@"User with that username (%@) not found.", username];
             alertController = [UIAlertController alertControllerWithTitle:@"User Not Found" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
         
         } else {
             
             msg = @"Sorry, something went wrong and the friend request couldn't be sent. Please try again.";
             alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
         
         }
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         [self presentViewController:alertController animated:YES completion:nil];
     }];
}

#pragma mark - UITextFieldDelegate protocol methods

- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string {
    
    // Don't allow whitespace or new line chars
    NSString *trimmedStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([textField.text isEqualToString:trimmedStr])
    {
        return NO;
    }
    
    NSMutableCharacterSet *allowedChars = [NSMutableCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789_.-"];
        
    if ([string rangeOfCharacterFromSet:[allowedChars invertedSet]].location != NSNotFound) {
        return NO;
    }
    
    return YES;
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"viewFriendRequestsSegue"]) {
        UINavigationController *navVC = (UINavigationController *) segue.destinationViewController;

        FriendRequestsTableViewController *friendRequestsTVC = [navVC.viewControllers objectAtIndex:0];
        
        friendRequestsTVC.requests = self.incomingFriendRequests;
        
        friendRequestsTVC.delegate = self;
    }
}

# pragma mark — FriendRequestsControllerDelegate methods

- (void) friendRequestsController:(FriendRequestsTableViewController *)controller didApproveRequest:(NSString *)username {
    
    [self addNewFriend:username];
    
}

- (void) friendRequestsController:(FriendRequestsTableViewController *)controller didIgnoreRequest:(NSString *)username {
    
    // TODO: make request to remove incoming request from server
    
}

/** Creates a friendship between current user and another user.
 * by making a request to /friendships/create.
 * @param username An NSString containing the username of friend to add
 */
- (void) addNewFriend:(NSString *)username {
    
    // Make request to approve friendship on server side
    // and get new friend's card
    
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    // new low priority thread to make request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/friendships/create"];
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = NO;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
        data[@"incoming_username"] = username;
        
        // Make the request
        [manager
         POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){
             
             // Do nothing
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

             NSString *msg = [NSString stringWithFormat:@"Sorry, something went wrong and we could not add %@.", username];
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
             [self presentViewController:alertController animated:YES completion:nil];
             
         }];
    });

    
}


@end
