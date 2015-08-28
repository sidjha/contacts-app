//
//  PageContentViewController.h
//  dynamic-contacts
//
//  Created by Sid Jha on 2015-01-08.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *contentText;
@property NSString *imageFile;


@end
