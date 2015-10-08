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
    
    NSLog(@"Received row: %ld", _row);

    _socialLabels = [[NSMutableArray alloc]initWithObjects: @"Facebook", @"Instagram", @"Twitter", @"Snapchat", @"WhatsApp", @"LinkedIn", @"Facebook Messenger", nil];
    
    [_titleLabel setText:_socialLabels[_row]];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate socialEditViewController:self didFinishUpdatingAccount:_accountHandleTextField.text];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
