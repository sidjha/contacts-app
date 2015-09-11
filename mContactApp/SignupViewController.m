//
//  SignupViewController.m
//  mContactApp
//
//  Created by Sid Jha on 11/09/15.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "SignupViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "MBProgressHUD.h"
#import "StackedViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupButtonPressed:(id)sender {
    // make request to /users/create
    // Show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Signing you up...";
    
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
        NSString *name = _nameField.text;
        NSDictionary *parameters = @{@"username": username, @"password": password, @"name": name};
        NSString *URLString = @"http://4024ed13.ngrok.com/favor8/api/v1.0/users/create";
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        [policy setValidatesDomainName:NO];
        [policy setAllowInvalidCertificates:YES];
        manager.securityPolicy = policy;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        // Make the request
        [manager
         POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
             NSLog(@"/users/create response data: %@", responseObject);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             // TODO: save the auth token more securely in Keychain
             NSString *authToken = responseObject[@"auth_token"];
             NSString *userID = responseObject[@"user_id"];
             [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:@"favor8AuthToken"];
             [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"favor8UserID"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             NSString *savedVal = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
             NSLog(@"Saved value: %@", savedVal);
             
             StackedViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"card"];
             
             [self presentViewController:controller animated:YES completion:nil];
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             
             //dispatch_queue_t mainQueue = dispatch_get_main_queue();
             //dispatch_async(mainQueue, ^{
             [[[UIAlertView alloc] initWithTitle:@"Error" message:@"We're so sorry! Something went wrong in trying to sign you up :(" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
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
