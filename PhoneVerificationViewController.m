//
//  PhoneVerificationViewController.m
//  mContactApp
//
//  Created by Sid Jha on 2015-08-24.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "PhoneVerificationViewController.h"
#import "ConfirmCodeViewController.h"
#import "CountryCodeTableViewController.h"
#import "StackedViewController.h"
@interface PhoneVerificationViewController ()

@end

@implementation PhoneVerificationViewController

- (IBAction)closeScreen:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (BOOL) sendConfirmationOrNot {
    if([self validatePhoneNumberInput:self.phoneNumberField.text]) {
        NSLog(@"Phone number valid");
        [self updateFullPhone];
        [self sendSMS:self.fullPhone];
        return YES;
    } else {
        NSLog(@"Phone number not valid");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Phone # not valid" message:@"Please enter a valid phone number." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // do stuff
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
}


- (void)chooseCountryCodeViewController:(CountryCodeTableViewController *)controller didFinishChoosingCountryCode:(NSString *)countryCode
{
    NSLog(@"This was returned from CountryCodeTableViewController: %@", countryCode);
    
    // extract the digits out of the country code string
    NSString *ccDigits = [[countryCode componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    self.countryCode = [NSString stringWithFormat:@"+%@", ccDigits];
    [self.countryCodeButton setTitle:self.countryCode forState:UIControlStateNormal];
    
    [self updateFullPhone];
}

- (void)updateFullPhone {
    self.fullPhone = [NSString stringWithFormat:@"%@%@", self.countryCode, self.phoneNumber];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"userID"];
    if (savedValue) {
        StackedViewController *stackedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"card"];
        [self presentViewController:stackedVC animated:YES completion:nil];
    }
    // Do any additional setup after loading the view.
    self.phoneNumberField.delegate = self;
    
    // populate country code with default value to +1
    self.countryCode = @"+1";

   // [self.phoneNumberField becomeFirstResponder];
    
    NSLog(@"Viewdidload on PhoneVerification");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validateInputCallback:) name:@"UITextFieldTextDidChangeNotification" object:nil];
    
}

- (void)validateInputCallback:(id)sender
{
    if ([self validatePhoneNumberInput:self.phoneNumberField.text]) {
        NSLog(@"OK");
        self.phoneNumber = self.phoneNumberField.text;
    } else {
        NSLog(@"Not ok");
    }
}

- (void) sendSMS:(NSString *)fullPhone {
    // Set up session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    //[config setHTTPAdditionalHeaders:@{@"Authorization"]
    
    _session = [NSURLSession sessionWithConfiguration:config];
    
    // Make POST request to web endpoint with phone number
    
    // TODO: change this to official API URL
    // TODO: make this request more secure
    NSURL *url = [NSURL URLWithString:@"http://favor8api.herokuapp.com/account/sms-verify"];
    NSString *post = [NSString stringWithFormat:@"phone=%@",fullPhone];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionUploadTask *uploadTask = [_session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        
        if (!error && httpResp.statusCode == 200) {
            NSLog(@"POST Request to /account/sms-verify, SUCCESS");
        } else {
            NSLog(@"POST Request to /account/sms-verify, FAILED. userInfo:%@", [error userInfo]);
        }
    }];
    
    [uploadTask resume];
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField
{
    return [self validatePhoneNumberInput:aTextField.text];
}

- (BOOL)validatePhoneNumberInput:(NSString *)aString
{
    NSString * const phoneRegExp = @"[0-9]{7}([0-9]{3})?";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:phoneRegExp options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"error %@", error);
    }
    
    NSUInteger numMatches = [regex numberOfMatchesInString:aString options:0 range:NSMakeRange(0, [aString length])];
    
    //NSLog(@"%lu", numMatches);
    return numMatches > 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if([segue.identifier isEqualToString:@"allowConfirmCodeInputSegue"]) {
        
        NSLog(@"On View controller 1, phone: %@", self.phoneNumber);
        ConfirmCodeViewController *ccViewController = (ConfirmCodeViewController *)segue.destinationViewController;
        ccViewController.phone = self.fullPhone;
        ccViewController.session = self.session;
    
    } else if ([segue.identifier isEqualToString:@"countryCodeSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        CountryCodeTableViewController *countryCodeTVC = (CountryCodeTableViewController *)navController.viewControllers[0];
        countryCodeTVC.delegate = self;
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSLog(@"In shouldperformsegue");
    if ([identifier isEqualToString:@"allowConfirmCodeInputSegue"]) {
        NSLog(@"Checking whether to send confirmation or not");
        return [self sendConfirmationOrNot];
    }

    return YES;
}


@end
