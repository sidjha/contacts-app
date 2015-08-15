//
//  ViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 12/08/15.
//  Copyright (c) 2015 Pankaj Bhardwaj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    self.view.backgroundColor = [UIColor blackColor];
    
    
    _profilePic.layer.cornerRadius = 5.0f;
    _profilePic.layer.masksToBounds = NO;
    _profilePic.layer.borderWidth = .5f;
//    _profilePic.layer.shadowColor = [UIColor orangeColor].CGColor;
//    _profilePic.layer.shadowOpacity = 0.4;
    _profilePic.layer.shadowRadius = 5.0f;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
@end
