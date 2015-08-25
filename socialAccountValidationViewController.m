//
//  socialAccountValidationViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 14/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "socialAccountValidationViewController.h"
#import <CoreData/CoreData.h>
@interface socialAccountValidationViewController ()

@end

@implementation socialAccountValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    NSLog(@"%@",_accSelectedName);
    [self selectedAccountView:_indexSelected];
    _textFieldUserData.delegate = self;
}
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
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
- (void)save{
    NSManagedObjectContext *context = [self managedObjectContext];
    
//    if (self.device) {
//        // Update existing device
//        [self.device setValue:self.nameTextField.text forKey:@"name"];
//        [self.device setValue:self.versionTextField.text forKey:@"version"];
//        [self.device setValue:self.companyTextField.text forKey:@"company"];
//        
//    } else {
//        // Create a new device
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"SocialGrid" inManagedObjectContext:context];
        [newDevice setValue:_accSelectedName forKey:@"acName"];
    NSLog(@"______________________________%@",self.textFieldUserData.text);
//        [newDevice setValue:self.versionTextField.text forKey:@"version"];
//        [newDevice setValue:self.companyTextField.text forKey:@"company"];
//    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)authenticationComplted:(id)sender {
//    NSString *message = _accSelectedName;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationMessageEvent" object:message];
    [self save];
}
@end


