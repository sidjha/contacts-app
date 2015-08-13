//
//  settingViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 12/08/15.
//  Copyright (c) 2015 Pankaj Bhardwaj. All rights reserved.
//

#import "settingViewController.h"

@interface settingViewController ()

@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)dismisView:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}
@end
