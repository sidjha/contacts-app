//
//  SAEditViewController.m
//  mContactApp
//
//  Created by Sid Jha on 2015-10-08.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "SAEditViewController.h"

@interface SAEditViewController ()

@end

@implementation SAEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _accountHandleTextField.delegate = self;
    [_titleLabel setText:_accountLabelStr];
    
    if (_accountValueStr) {
        [_accountHandleTextField setText:_accountValueStr];
    }
    
    if([_accountLabelStr isEqualToString:@"WhatsApp"]) {
        [_accountHandleTextField setKeyboardType:UIKeyboardTypePhonePad];
    }
    
    [_accountHandleTextField becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSMutableDictionary *accountHandle = [NSMutableDictionary dictionaryWithDictionary:@{
                                            _titleLabel.text : _accountHandleTextField.text
                                            }];
    [self.delegate socialEditViewController:self didFinishUpdatingAccount:accountHandle];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    
    // hide keyboard
    [_accountHandleTextField resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL _isAllowed = YES;
    
    // Don't allow whitespace or new line chars
    NSString *trimmedStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([_accountHandleTextField.text isEqualToString:trimmedStr])
    {
        _isAllowed =  NO;
    }
    
    NSMutableCharacterSet *allowedChars;
    
    // set allowed characters for corresponding account types
    if ([_accountLabelStr isEqualToString:@"WhatsApp"]) {
        
        allowedChars = [NSMutableCharacterSet characterSetWithCharactersInString:@"01234567890+-"];
    
    } else if ([_accountLabelStr isEqualToString:@"Snapchat"]) {
        
        allowedChars = [NSMutableCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-"];
    
    } else {
        
        allowedChars = [NSMutableCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."];
    }
    
    if ([string rangeOfCharacterFromSet:[allowedChars invertedSet]].location != NSNotFound) {
        _isAllowed = NO;
    }
    
    return _isAllowed;
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
