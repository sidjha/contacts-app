//
//  StackedCollectionViewCell.m
//  StackedCollectionViewCell
//

#import <QuartzCore/QuartzCore.h>

#import "StackedCollectionViewCell.h"

@interface StackedCollectionViewCell ()

//@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation StackedCollectionViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void) changeBG:(UIColor *)bg {
    self.nameLabel.backgroundColor = bg;
    self.statusTextView.backgroundColor = bg;
}

#pragma mark - Accessors

- (void)setTitle:(NSString *)title {
    
    _title = [title copy];
    
    self.nameLabel.text = self.title;
}

- (void)setColor:(UIColor *)color {
    
    _color = [color copy];
    self.nameLabel.textColor = self.color;
    self.statusTextView.textColor = self.color;
}

- (void) setProfileImg:(NSURL *)profileImg {
    _profileImg = profileImg;
}

- (void) setStatus:(NSString *)status {
    _status = status;
    
    [self.statusTextView setText:self.status];
}

@end
