//
//  FriendRequestTableViewCell.m
//  mContactApp
//
//  Created by Sid Jha on 2015-10-11.
//  Copyright © 2015 Mesh8 Inc. All rights reserved.
//

#import "FriendRequestTableViewCell.h"

@implementation FriendRequestTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)acceptAction:(id)sender {
    
    // Get current row and a reference to the parent tableView
    id view = [self superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    
    UITableView *tableView = (UITableView *)view;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    
    [self.delegate friendRequestCell:self didApproveRequest:self.usernameLabel.text indexPath:indexPath];
}

- (IBAction)ignoreAction:(id)sender {
    
    // Get current row and a reference to the parent tableView
    id view = [self superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    
    UITableView *tableView = (UITableView *)view;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableView];
    
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    
    [self.delegate friendRequestCell:self didIgnoreRequest:self.usernameLabel.text indexPath:indexPath];
}

@end
