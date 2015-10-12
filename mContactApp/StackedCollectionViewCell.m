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

#pragma mark - Accessors

- (void)setTitle:(NSString *)title {
    
    _title = [title copy];
    
    self.nameLabel.text = self.title;
}

- (void)setColor:(UIColor *)color {
    
    _color = [color copy];
}

- (void) setProfileImg:(NSURL *)profileImg {
    _profileImg = profileImg;
    
    // Load the image from the URL on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:self.profileImg];
        
        // Populate the image view on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imageData];
            self.profileImageView.image = image;
            
            self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
        });
    });

}

- (void) setStatus:(NSString *)status {
    _status = status;
    
    [self.statusTextView setText:self.status];
}

@end
