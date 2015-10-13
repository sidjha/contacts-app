//
//  LoginViewController.m
//  mContactApp
//
//  Created by Sid Jha on 02/09/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "MBProgressHUD.h"
#import "StackedViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    // make request to /users/login
    // Show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Logging in..";
    
    // Note: Explicitly getting a low priority queue and making the request on that,
    //       because MBProgressHUD recommends so. However, the success and failure
    //       methods are called on the main queue by AFNetworking anyway. So is
    //       this even necessary? The progress HUD works even if called on the main
    //       thread before the request. Do we need to do some garbage collection
    //       on the main queue after?
    
    // new low priority thread to make request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
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
             NSLog(@"/users/login response data: %@", responseObject);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             // TODO: save the auth token more securely in Keychain
             NSString *authToken = responseObject[@"auth_token"];
             NSString *userID = responseObject[@"user_id"];
             [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"favor8AuthToken"];
             [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"favor8UserID"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             NSString *savedVal = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8UserID"];
             NSLog(@"Saved value: %@", savedVal);

             StackedViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"card"];
             
            [self presentViewController:controller animated:YES completion:nil];
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             
             //dispatch_queue_t mainQueue = dispatch_get_main_queue();
             //dispatch_async(mainQueue, ^{
             [[[UIAlertView alloc] initWithTitle:@"Error" message:@"We're so sorry! Something went wrong and we couldn't log you in :(" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
             // });
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
    });

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
