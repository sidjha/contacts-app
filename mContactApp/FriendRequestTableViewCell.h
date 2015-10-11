//
//  FriendRequestTableViewCell.h
//  mContactApp
//
//  Created by Sid Jha on 2015-10-11.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendRequestTableViewCell;

@protocol FriendRequestCellDelegate <NSObject>

- (void) friendRequestCell:(FriendRequestTableViewCell *)cell didApproveRequest:(NSString *)username;

- (void) friendRequestCell:(FriendRequestTableViewCell *)cell didIgnoreRequest:(NSString *)username;

@end

@interface FriendRequestTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *ignoreButton;

@property (weak, nonatomic) id <FriendRequestCellDelegate> delegate;

@end
