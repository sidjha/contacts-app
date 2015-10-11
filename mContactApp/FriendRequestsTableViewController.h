//
//  FriendRequestsTableViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-10-11.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendRequestsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *friendRequestsTableView;

@property (strong, nonatomic) NSMutableArray *requests;

@end
