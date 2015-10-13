//
//  AddFriendViewController.m
//  mContactApp
//
//  Created by Sid Jha on 2015-10-09.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "AddFriendViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "MBProgressHUD.h"
#import "FriendRequestsTableViewController.h"


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
- (IBAction)addFriendByUsername:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a person to your Favor8" message:@"Enter username of person you wish to add" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"Username", @"Username");
        textField.delegate = self;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Send Request", @"OK Action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *username = alertController.textFields.firstObject;
        
        [self sendFriendRequest:username.text];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel Action") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (IBAction)addFriendbyCodeUpload:(id)sender {
 
}

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
             NSLog(@"/friends/incoming_requests response data: %@", responseObject);
             
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


- (void) sendFriendRequest:(NSString *)username {
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    // make request to /users/show
    // Show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending friend request..";
    
    // new low priority thread to make request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
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
             NSLog(@"/friends/send_request response data: %@", responseObject);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             NSLog(@"Friend request to %@ sent!", username);
             
             NSString *msg = [NSString stringWithFormat:@"Friend request to %@ sent.", username];
             
             // show alert
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Friend request sent." message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
             [self presentViewController:alertController animated:YES completion:nil];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);
             
             NSString *msg = [NSString stringWithFormat:@"Friend request to %@ could not be sent", username];
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [alertController addAction:okAction];
             
             [self presentViewController:alertController animated:YES completion:nil];
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
    });

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
             NSLog(@"/friendships/create response data: %@", responseObject);
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);

         }];
    });

    
}


@end
