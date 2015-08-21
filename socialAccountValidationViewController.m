//
//  socialAccountValidationViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 14/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "socialAccountValidationViewController.h"

@interface socialAccountValidationViewController ()

@end

@implementation socialAccountValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    NSLog(@"%@",_accSelectedName);
    [self selectedAccountView:_indexSelected];
    
}
-(void)selectedAccountView :(NSInteger)sender
{
    switch (sender) {
        case 0:
            _labelAccSelected.text = [NSString stringWithFormat:@"Selected %@",_accSelectedName];
            NSLog(@"facebook");
            break;
        case 1:
            _labelAccSelected.text = [NSString stringWithFormat:@"Selected %@",_accSelectedName];
            NSLog(@"Instagram");
            break;
        case 2:
//            _labelAccSelected.text = [NSString stringWithFormat:@"Selected %@",_accSelectedName];
            [self kiKViewSetup];
            NSLog(@"Kik");
            break;
        case 3:
            _labelAccSelected.text = [NSString stringWithFormat:@"Selected %@",_accSelectedName];
            NSLog(@"Linkedin");
            break;
        case 4:
            _labelAccSelected.text = [NSString stringWithFormat:@"Selected %@",_accSelectedName];
            NSLog(@"Snapchat");
            break;
        case 5:
            _labelAccSelected.text = [NSString stringWithFormat:@"Selected %@",_accSelectedName];
            NSLog(@"Twitter");
            break;
        case 6:
            NSLog(@"Whatsapp");
            [self whatsappViewSetup];
            break;
        default:
            break;
    }
}
-(void)whatsappViewSetup
{
     _labelAccSelected.text = [NSString stringWithFormat:@"Enter %@ #",_accSelectedName];
    _textFieldUserData.placeholder = @"e.g. +91 9812345678";
    
}

-(void)kiKViewSetup
{
    _labelAccSelected.text = [NSString stringWithFormat:@"Enter %@ username",_accSelectedName];
    _textFieldUserData.placeholder = @"Kik username";
        //
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionCancelValidation:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)dismisVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)authenticationComplted:(id)sender {
    NSString *message = _accSelectedName;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMessageEvent" object:message];
}
@end
