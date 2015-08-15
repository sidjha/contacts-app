//
//  socialAccountValidationViewController.h
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 14/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface socialAccountValidationViewController : UIViewController
- (IBAction)actionCancelValidation:(id)sender;
@property (nonatomic , weak) NSString *accSelectedName;
@property (nonatomic) NSInteger indexSelected;
@property (weak, nonatomic) IBOutlet UILabel *labelAccSelected;

@end
