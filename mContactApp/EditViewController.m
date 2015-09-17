//
//  EditViewController.m
//  mContactApp
//
//  Created by Sid Jha on 11/09/15.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "EditViewController.h"
#import "StackedViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "MBProgressHUD.h"

@interface EditViewController ()

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameField setText:_card[@"name"]];
    
    /* Add a placeholder for textview instead */
    if (![_card[@"status"] isEqualToString:@""]) {
        [self.statusField setText:_card[@"status"]];
    } else {
        [self.statusField setText:@"Type a simple status here"];
    }
    
    [self.phoneField setText:_card[@"phone"]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate editViewController:self didFinishUpdatingCard:(NSDictionary *)_card];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


- (IBAction)donePressed:(id)sender {
    // TODO: call a method on parent view controller reloading the cards.
  //  StackedViewController *stackedVC = (StackedViewController *) self.parentViewController;
    // TODO: Make sure to update the card after each text field is updated/dirty
    _card[@"name"] = _nameField.text;
    _card[@"status"] = _statusField.text;
    _card[@"phone"] = _phoneField.text;
    [self updateMyCard];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)updateMyCard {
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    // make request to /users/show
    // Show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving..";
    
    // new low priority thread to make request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString *URLString = [NSString stringWithFormat:@"http://4024ed13.ngrok.com/favor8/api/v1.0/users/update"];
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
        data[@"data"] = _card;
        NSLog(@"Data: %@", data);
        
        // Make the request
        [manager
         POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){
             NSLog(@"/users/update response data: %@", responseObject);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             NSArray *keys = @[@"name", @"status", @"social_links", @"username", @"phone"];
             NSMutableArray *matchingKeys = [[NSMutableArray alloc]init];
             NSMutableArray *objects = [[NSMutableArray alloc]init];
             
             for (NSInteger i = 0; i < [keys count]; i++) {
                 
                 if ([responseObject[@"user"] objectForKey:keys[i]]) {
                     
                     [matchingKeys addObject:keys[i]];
                     [objects addObject:responseObject[@"user"][keys[i]]];
                 }
             }
             
             // unnecessary? do we really need to update my card again after posting to server?
             // there needs to be some kind of feedback that the update was pushed successfully
             _card = [NSMutableDictionary dictionaryWithObjects:objects forKeys:matchingKeys];

             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
    });

}

@end
