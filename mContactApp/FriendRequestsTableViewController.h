//
//  FriendRequestsTableViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-10-11.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendRequestTableViewCell.h"

@class FriendRequestsTableViewController;

@protocol FriendRequestsControllerDelegate <NSObject>

- (void) friendRequestsController:(FriendRequestsTableViewController *)controller didApproveRequest:(NSString *)username;

- (void) friendRequestsController:(FriendRequestsTableViewController *)controller didIgnoreRequest:(NSString *)username;

@end

@interface FriendRequestsTableViewController : UITableViewController <FriendRequestCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *friendRequestsTableView;

@property (strong, nonatomic) NSMutableArray *requests;

@property (weak, nonatomic) id <FriendRequestsControllerDelegate> delegate;

@end
