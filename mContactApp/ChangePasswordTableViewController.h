//
//  ChangePasswordTableViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-10-16.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *updatedPasswordTextFieldFirst;
@property (weak, nonatomic) IBOutlet UITextField *updatedPasswordTextFieldSecond;

@end
