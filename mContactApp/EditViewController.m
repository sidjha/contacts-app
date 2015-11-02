//
//  EditViewController.m
//  mContactApp
//
//  Created by Sid Jha on 11/09/15.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "EditViewController.h"
#import "StackedViewController.h"
#import "SocialLinksTableViewCell.h"
#import "SAEditViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "AWSS3.h"

#import "MBProgressHUD.h"

@interface EditViewController ()

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameField setText:_card[@"name"]];
    
    self.nameField.delegate = self;
    
    if (![_card[@"status"] isEqualToString:@""]) {
        [self.statusPlaceholder setHidden:YES];
        [self.statusField setText:_card[@"status"]];
    } else {
        [self.statusPlaceholder setHidden:NO];
    }
    
    self.statusField.delegate = self;
    
    self.profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.profileImage.clipsToBounds = YES;
    
    if ([_card objectForKey:@"profile_img"]) {
        // TODO: no need to load this from URL, can get parent to pass actual image data in
        
        NSURL *imageURL = [NSURL URLWithString:_card[@"profile_img"]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        self.profileImage.image = image;
        
    } else {
        self.profileImage.image = [UIImage imageNamed:@"profile_img_placeholder"];
    }
    
    UITapGestureRecognizer *singleTapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapDetected)];
    singleTapOnImage.numberOfTapsRequired = 1;
    self.profileImage.userInteractionEnabled = YES;
    [self.profileImage addGestureRecognizer:singleTapOnImage];
    
    [self.phoneField setText:_card[@"phone"]];
    self.phoneField.delegate = self;
    
    self.socialLinks = [[NSMutableDictionary alloc] initWithDictionary:_card[@"social_links"] copyItems:YES];
    
    self.links = [[NSMutableArray alloc]initWithObjects:
                  @"FB Messenger",@"Instagram",
                  @"Twitter",@"Snapchat",@"WhatsApp",
                  @"LinkedIn", nil];
    
    
    self.linkImages = [[NSMutableArray alloc]initWithObjects:
                       [UIImage imageNamed:@"linkicons/Facebook.png"],
                       [UIImage imageNamed:@"linkicons/Instagram.png"],
                       [UIImage imageNamed:@"linkicons/Twitter.png"],
                       [UIImage imageNamed:@"linkicons/Snapchat.png"],
                       [UIImage imageNamed:@"linkicons/Whatsapp.png"],
                       [UIImage imageNamed:@"linkicons/LinkedIn.png"]
                       , nil];
    
    self.socialLinksTableView.separatorColor = [UIColor clearColor];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isDismiss]) {
        [self.delegate editViewController:self didFinishUpdatingCard:(NSMutableDictionary *)_card];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** What happens after image area is tapped.
 * Presents an action sheet to allow a user to choose
 * between taking a picture or choosing from Photo Library.
 */
- (void) imageTapDetected {
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Change Profile Image" message:@"Take a photo or upload your own" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imgPicker.modalPresentationStyle = UIModalPresentationPopover;
            imgPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;

            [self presentViewController:imgPicker animated:YES completion:nil];
        }]];
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

/** Readjusts table view size based on its content
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    CGRect frame = self.socialLinksTableView.frame;
    frame.size = self.socialLinksTableView.contentSize;
    self.socialLinksTableView.frame = frame;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = chosenImage;
    self.profileImage.clipsToBounds = YES;
    
    NSData *imgData = UIImageJPEGRepresentation(self.profileImage.image, 0.9);
    
    [self uploadImage:imgData];
    
    //UIImageWriteToSavedPhotosAlbum (chosenImage, nil, nil , nil);
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/** Uploads the image to Amazon S3.
 * @param imageData NSData representation of the image
 */
- (void) uploadImage:(NSData *)imageData {
    // Upload image to S3 and get a URL back
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeDeterminate];
    [hud setLabelText:@"Uploading"];
    
    // Generate name for image
    
    NSString *objectKey = [[NSProcessInfo processInfo] globallyUniqueString];
    objectKey = [objectKey stringByAppendingString:@".jpg"];
    
    // Create a temp local file for the image
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:objectKey];
    
    [imageData writeToFile:path atomically:YES];
    
    NSURL *localFileURL = [[NSURL alloc] initFileURLWithPath:path];
    
    // Set up S3 upload
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    uploadRequest.bucket = @"favor8-bucket-2";
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    uploadRequest.key = objectKey;
    uploadRequest.contentType = @"image/jpeg";
    uploadRequest.body = localFileURL;
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        
        if (task.error) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Upload Failed" message:@"Sorry, something went wrong and we couldn't upload your image. Please try again." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alertController addAction:okAction];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            
            _updatedProfileImgURL = [NSString stringWithFormat:@"http://s3.amazonaws.com/favor8-bucket-2/%@", objectKey];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        return nil;
    }];
}

- (void) uploadToS3UsingTransferUtility {
    
    /*
     AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
     expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
     dispatch_async(dispatch_get_main_queue(), ^{
     // Do something e.g. Update a progress bar.
     });
     };
     
     [expression setValue:@"AWSS3ObjectCannedACLPublicRead" forRequestParameter:@"ACL"];
     
     
     AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
     dispatch_async(dispatch_get_main_queue(), ^{
     if (error) {
     
     } else {
     
     _updatedProfileImgURL = [NSString stringWithFormat:@"http://s3.amazonaws.com/favor8-bucket-2/%@", objectKey];
     
     }
     });
     };
     
     AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
     
     
     [[transferUtility uploadData:imageData bucket:@"favor8-bucket-2" key:objectKey contentType:@"image/jpeg" expression:expression completionHander:completionHandler] continueWithBlock:^id(AWSTask *task) {
     if (task.error) {
     
     }
     if (task.exception) {
     
     }
     if (task.result) {
     AWSS3TransferUtilityUploadTask *uploadTask = task.result;
     // Do something with uploadTask.
     }
     
     return nil;
     }];
     */
}

/** Handle tap on Done button.
 *
 */
- (IBAction)donePressed:(id)sender {
    
    BOOL changed = NO;
    _dismiss = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving";
    
    // only update card if changed fields
    
    if (![self.nameField.text isEqualToString:_card[@"name"]]) {
        changed = YES;
        _card[@"name"] = self.nameField.text;
    }
    
    if (![self.statusField.text isEqualToString:_card[@"status"]]) {
        changed = YES;
        _card[@"status"] = self.statusField.text;
    }
    
    if (![self.phoneField.text isEqualToString:_card[@"phone"]]) {
        changed = YES;
        _card[@"phone"] = self.phoneField.text;
    }
    
    if (self.updatedProfileImgURL) {
        changed = YES;
        _card[@"profile_img"] = self.updatedProfileImgURL;
    }
    
    if (![self.socialLinks isEqualToDictionary:_card[@"social_links"]]) {
        changed = YES;
        _card[@"social_links"] = self.socialLinks;
    }
    
    if (changed) {
        [self updateMyCard];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

/** Update user's card data to server
 * by making a request to /users/update.
 */
- (void)updateMyCard {
    
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/users/update"];
    
    // Set headers
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    data[@"data"] = _card;
    
    // Make the request
    [manager
     POST:URLString parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject){
         
         NSArray *keys = @[@"name", @"status", @"social_links", @"username", @"phone", @"profile_img"];
         NSMutableArray *matchingKeys = [[NSMutableArray alloc]init];
         NSMutableArray *objects = [[NSMutableArray alloc]init];
         
         for (NSInteger i = 0; i < [keys count]; i++) {
             
             if ([responseObject[@"user"] objectForKey:keys[i]]) {
                 
                 [matchingKeys addObject:keys[i]];
                 [objects addObject:responseObject[@"user"][keys[i]]];
             }
         }
         
         _card = [NSMutableDictionary dictionaryWithObjects:objects forKeys:matchingKeys];
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         [self dismissViewControllerAnimated:YES completion:nil];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         // TODO: show an error message
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section {
    
    return [_links count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"socialLinkCell";
    SocialLinksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.socialLinkImage.image = [_linkImages objectAtIndex:indexPath.row];
    cell.socialLinkLabel.text = [_links objectAtIndex:indexPath.row];
    
    cell.socialLinkImage.image = [_linkImages objectAtIndex:indexPath.row];
    
    // Set up ON/OFF label
    cell.onOffLabel.clipsToBounds = YES;
    cell.onOffLabel.layer.cornerRadius = 5;
    
    if ([self.socialLinks objectForKey:[_links objectAtIndex:indexPath.row]]) {
        cell.onOffLabel.text = @"ON";
        cell.onOffLabel.backgroundColor = [self colorFromHexString:@"#2ecc71"];
        cell.onOffLabel.textColor = [UIColor whiteColor];
    } else {
        cell.onOffLabel.text = @"OFF";
        cell.onOffLabel.backgroundColor = [self colorFromHexString:@"#CCCCCC"];
        cell.onOffLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)socialEditViewController:(SAEditViewController *)controller didFinishUpdatingAccount:(NSMutableDictionary *)accountHandle {
    
    NSString *key = [accountHandle allKeys][0];
    NSString *value = [accountHandle allValues][0];
    
    // initialize dictionary if no existing social links
    if (!self.socialLinks) {
        if ([value length] > 0) {
            self.socialLinks = [NSMutableDictionary
                                dictionaryWithDictionary:@{ key : value }];
        }
    } else {
        // check if key exists
        if ([self.socialLinks objectForKey:key]) {
            if ([value length] > 0) {
                [self.socialLinks setObject:value forKey:key];
            } else {
                [self.socialLinks removeObjectForKey:key];
            }
        } else {
            // an empty social link has no effect if key does not exist
            if ([value length] > 0) {
                self.socialLinks[key] = value;
            }
        }
    }
    
    [self.socialLinksTableView reloadData];
}

# pragma mark — UITextFieldDelegate methods

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    
    if (textField.tag == 0) {
        // Limit name entry to 50 characters
        // http://stackoverflow.com/a/12944946
        NSUInteger MAXLENGTH = 50;
        
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= MAXLENGTH || returnKey;
        
    } else {
        // Limit phone number entry to only phone numbers
        NSMutableCharacterSet *allowedChars = [NSMutableCharacterSet characterSetWithCharactersInString:@"+-1234567890 "];
        if ([string rangeOfCharacterFromSet:[allowedChars invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        return YES;
    }
}

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
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.statusPlaceholder setHidden:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [self.statusPlaceholder setHidden:NO];
    } else {
        [self.statusPlaceholder setHidden:YES];
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // http://stackoverflow.com/posts/32889628/revisions
    
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSDictionary *textAttributes = @{NSFontAttributeName : textView.font};
    
    CGFloat textWidth = CGRectGetWidth(UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset));
    textWidth -= 2.0f * textView.textContainer.lineFragmentPadding;
    CGRect boundingRect = [newText boundingRectWithSize:CGSizeMake(textWidth, 0)
                                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:textAttributes
                                                context:nil];
    
    NSUInteger numberOfLines = CGRectGetHeight(boundingRect) / textView.font.lineHeight;
    
    return numberOfLines <= 3;
}


- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"socialAccountEditSegue"]) {
        
        NSIndexPath *indexPath = [self.socialLinksTableView indexPathForCell:sender];
        
        NSString *s = [NSString stringWithFormat:@"Row: %d", indexPath.row];
        
        SAEditViewController *detailVC = (SAEditViewController *) segue.destinationViewController;
        
        NSMutableArray *socialLabels = [[NSMutableArray alloc]initWithObjects: @"FB Messenger", @"Instagram", @"Twitter", @"Snapchat", @"WhatsApp", @"LinkedIn", nil];
        
        [detailVC.titleLabel setText:s];
        
        detailVC.accountLabelStr = socialLabels[indexPath.row];
        
        if ([self.socialLinks objectForKey:socialLabels[indexPath.row]]) {
            detailVC.accountValueStr = self.socialLinks[socialLabels[indexPath.row]];
        }
        
        detailVC.delegate = self;
        
    }
}


@end
