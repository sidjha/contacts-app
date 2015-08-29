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
    [self selectedAccountView:_accSelectedName];
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
-(void)selectedAccountView :(NSString*)sender
{
    // if whatsapp then ask for phone, otherwise ask for username
    if ([sender isEqualToString:@"Whatsapp"]) {
        [self setupPhoneFields];
    } else {
        [self setupUsernameFields];
    }
}

-(void)setupUsernameFields
{
    _labelAccSelected.text = [NSString stringWithFormat:@"Enter your %@ username",_accSelectedName];
    NSLog(@"%@", _accSelectedName);
}

-(void)setupPhoneFields
{
     _labelAccSelected.text = [NSString stringWithFormat:@"Enter your %@ #",_accSelectedName];
    _textFieldUserData.placeholder = @"e.g. +1 415 123 4567";
    
}

- (void)save{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SocialGrid"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"acName = %@", _accSelectedName]];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound)
    {
        // some error occurred
    }else if (count == 0){
            // no matching object
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"SocialGrid" inManagedObjectContext:context];
        [newDevice setValue:_accSelectedName forKey:@"acName"];
    }else{
                // at least one matching object exists
    }
   
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


