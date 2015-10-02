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
#import "AWSS3.h"
#import "SocialLinksTableViewCell.h"

@interface EditViewController ()

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.nameField setText:_card[@"name"]];
    
    // TODO: Add a placeholder for textview instead
    
    if (![_card[@"status"] isEqualToString:@""]) {
        [self.statusField setText:_card[@"status"]];
    } else {
        [self.statusField setText:@"Type a simple status here"];
    }
    
    self.profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    if ([_card objectForKey:@"profile_img"]) {
        // TODO: no need to load this from URL, can get parent to pass actual image data in
        NSURL *imageURL = [NSURL URLWithString:_card[@"profile_img"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        self.profileImage.image = image;
    } else {
        // TODO: initialize imageView with placeholder image
    }

    
    UITapGestureRecognizer *singleTapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapDetected)];
    singleTapOnImage.numberOfTapsRequired = 1;
    self.profileImage.userInteractionEnabled = YES;
    [self.profileImage addGestureRecognizer:singleTapOnImage];
    
    
    [self.phoneField setText:_card[@"phone"]];
    
    
    _links = [[NSMutableArray alloc]initWithObjects:
              @"Facebook",@"Instagram",
              @"Twitter",@"Snapchat",@"WhatsApp",
              @"LinkedIn",@"FB Messenger", nil];
    
    
    _linkImages = [[NSMutableArray alloc]initWithObjects:
                       [UIImage imageNamed:@"linkicons/Facebook.png"],
                       [UIImage imageNamed:@"linkicons/Instagram.png"],
                       [UIImage imageNamed:@"linkicons/Twitter.png"],
                       [UIImage imageNamed:@"linkicons/Snapchat.png"],
                       [UIImage imageNamed:@"linkicons/Whatsapp.png"],
                       [UIImage imageNamed:@"linkicons/LinkedIn.png"],
                       [UIImage imageNamed:@"linkicons/Facebook.png"]
                       , nil];
    
    
    self.socialLinksTableView.separatorColor = [UIColor clearColor];
    
    //[self.socialLinksTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate editViewController:self didFinishUpdatingCard:(NSMutableDictionary *)_card];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) imageTapDetected {
    NSLog(@"Tap detected!");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    CGRect frame = self.socialLinksTableView.frame;
    frame.size = self.socialLinksTableView.contentSize;
    self.socialLinksTableView.frame = frame;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


- (IBAction)donePressed:(id)sender {
    // TODO: Make sure to update the card after each text field is updated/dirty
    _card[@"name"] = _nameField.text;
    _card[@"status"] = _statusField.text;
    _card[@"phone"] = _phoneField.text;
    
    [self updateMyCard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) uploadImage {
    NSURL *testFileURL; // TODO: initialize URL with actual image data URL
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"favor8-pp-darkhorse";
    // TODO: proper key
    uploadRequest.key = @"myTestFile.txt";
    uploadRequest.body = testFileURL;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               NSLog(@"Upload output: %@", uploadOutput);
                                                               // The file uploaded successfully.
                                                           }
                                                           return nil;
                                                       }];

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
             
             NSArray *keys = @[@"name", @"status", @"social_links", @"username", @"phone", @"profile_img"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    NSLog(@"We're here: %lu", (unsigned long)[_links count]);
    return [_links count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath {
    static NSString *cellID = @"socialLinkCell";
    SocialLinksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.socialLinkImage.image = [_linkImages objectAtIndex:indexPath.row];
    cell.socialLinkLabel.text = [_links objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
*/

@end
