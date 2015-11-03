//
//  StackedCollectionViewCell.h
//  StackedCollectionViewCell
//

#import <UIKit/UIKit.h>

@interface StackedCollectionViewCell : UICollectionViewCell

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) UIColor *color;
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSURL *profileImg;
@property (copy, nonatomic) NSString *username;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *socialButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

- (void) changeBG:(UIColor *)bg;

@end
