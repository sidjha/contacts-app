//
//  socialAccountValidationViewController.h
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 14/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface socialAccountValidationViewController : UIViewController<UITextFieldDelegate>
- (IBAction)actionCancelValidation:(id)sender;
@property (nonatomic , weak) NSString *accSelectedName;
@property (nonatomic) NSInteger indexSelected;
@property (weak, nonatomic) IBOutlet UILabel *labelAccSelected;
- (IBAction)dismisVC:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

- (IBAction)authenticationComplted:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUserData;
@end
