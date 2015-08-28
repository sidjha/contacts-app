//
//  ConfirmCodeViewController.m
//  mContactApp
//
//  Created by Sid Jha on 2015-08-24.
//  Copyright (c) 2015 Mesh8. All rights reserved.
//

#import "ConfirmCodeViewController.h"
#import "TGLViewController.h"
@interface ConfirmCodeViewController ()

@end

@implementation ConfirmCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.confirmationCodeField.delegate = self;
    //[self.confirmationCodeField becomeFirstResponder];
    NSLog(@"On view controller 2, phone: %@", self.phone);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)resendConfirmCode:(id)sender {
    [self sendSMS];
}
- (IBAction)confirmCode:(id)sender {
    NSString *confirmation_code = self.confirmationCodeField.text;
    
    if ([self validateConfirmationCodeInput:confirmation_code]) {
        
        // GET from server to check if code is actually valid
        
        // TODO: convert http to https once SSL is set up
        NSString *baseUrl = @"http://favor8api.herokuapp.com/account/code-verify";
        
        NSString *urlStr = [NSString stringWithFormat:@"%@?phoneNum=%@&submitted_code=%@", baseUrl, self.phone, confirmation_code];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"GET"];
        
        // NOTE: why declare a new *session object?
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

            NSError *serializeError = nil;

            NSDictionary *json;
            @try {
                json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &serializeError];
                NSString *valueToSave = [json valueForKey:@"id_str"];
                [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"userID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                                        // TODO: Do something after request successful
                TGLViewController *objTgl = [self.storyboard instantiateViewControllerWithIdentifier:@"tglObj"];
                [self presentViewController:objTgl animated:YES completion:nil];
                                    });
            }
            @catch (NSException *exception) {
                NSLog(@"url error");
                [self customAlertFn];
            }
//            NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
//            NSInteger statusCode = [HTTPResponse statusCode];
//            if (statusCode == 200 || statusCode == 400) {
//                NSLog(@"Response: %@ %@", response, error);
//                NSError *serializeError = nil;
//                NSDictionary *jsonData = [NSJSONSerialization
//                                          JSONObjectWithData:data options:0 error:&serializeError];
//                
//                if ([jsonData[@"match"] isEqualToString:@"True"]) {
//                    NSLog(@"Codes match. True");
//                    
//                    NSString *valueToSave = @"someValue";
//                    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"preferenceName"];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        // TODO: Do something after request successful
//                        TGLViewController *objTgl = [self.storyboard instantiateViewControllerWithIdentifier:@"tglObj"];
//                        [self presentViewController:objTgl animated:YES completion:nil];
//                    });
//                    // TODO: advance to logged in view
//                    // TODO: create/update user on backend
//                } else {
//                    NSLog(@"False");
//                     [self customAlertFn];
////                    dispatch_async(dispatch_get_main_queue(), ^{
////                        [self customAlertFn];
////                    });
//                }
//                
//            }else
//            {
//                [self customAlertFn];
//            }
            // TODO: monitor verification code input independently from PhoneVerificationViewController
            
        }] resume];
    } else {
        NSLog(@"Confirmation code input invalid");
        // TODO: show error message to user
        [self customAlertFn];
    }

}
-(void)customAlertFn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO: Do something after request successful
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Incorrect code" message:@"Your verification code didn't match. Try again or tap Resend Confirmation Code." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // do stuff
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });

    
}

- (BOOL)validateConfirmationCodeInput:(NSString *)aString
{
    NSString * const confirmationCodeRegExp = @"^([0-9]{6})$";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:confirmationCodeRegExp options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"error %@", error);
    }
    
    NSUInteger numMatches = [regex numberOfMatchesInString:aString options:0 range:NSMakeRange(0, [aString length])];
    
    //NSLog(@"%lu", numMatches);
    return numMatches > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField
{

    return [self validateConfirmationCodeInput:aTextField.text];
}

- (void) sendSMS {
    // TODO: convert http to https once SSL is set up
    NSURL *url = [NSURL URLWithString:@"http://favor8api.herokuapp.com/account/sms-verify"];
    NSString *post = [NSString stringWithFormat:@"phone=%@",self.phone];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionUploadTask *uploadTask = [_session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        
        if (!error && httpResp.statusCode == 200) {
            NSLog(@"POST Request to /verify, SUCCESS");
        } else {
            NSLog(@"POST Request to /verify, FAILED. userInfo:%@", [error userInfo]);
        }
    }];
    
    [uploadTask resume];
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
