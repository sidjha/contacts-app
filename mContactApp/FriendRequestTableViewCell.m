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
    
    [self.delegate friendRequestCell:self didApproveRequest:self.usernameLabel.text];
}

- (IBAction)ignoreAction:(id)sender {
    
    [self.delegate friendRequestCell:self didIgnoreRequest:self.usernameLabel.text];
}

@end
