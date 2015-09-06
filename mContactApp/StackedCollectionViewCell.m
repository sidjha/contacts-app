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

@end
