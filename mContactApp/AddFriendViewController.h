//
//  AddFriendViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-10-09.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestsTableViewController.h"

@interface AddFriendViewController : UIViewController <FriendRequestsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *addByUsernameButton;
@property (weak, nonatomic) IBOutlet UIButton *addByCodeUploadButton;
@property (weak, nonatomic) IBOutlet UIButton *viewRequestsButton;

@property (strong, nonatomic) NSMutableArray *incomingFriendRequests;

@end
