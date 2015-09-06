//
//  StackedCollectionViewCell.h
//  StackedCollectionViewCell
//

#import <UIKit/UIKit.h>

@interface StackedCollectionViewCell : UICollectionViewCell

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) UIColor *color;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *statusLabel;

@end
