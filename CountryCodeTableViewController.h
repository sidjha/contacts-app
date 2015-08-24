//
//  CountryCodeTableViewController.h
//  mContactApp
//
//  Created by Sid Jha on 2015-03-21.
//  Copyright (c) 2015 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CountryCodeTableViewController;

@protocol CountryCodeTableViewControllerDelegate <NSObject>

- (void) chooseCountryCodeViewController:(CountryCodeTableViewController *)controller didFinishChoosingCountryCode:(NSString *)countryCode;

@end

@interface CountryCodeTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{

}

@property (nonatomic, weak) id <CountryCodeTableViewControllerDelegate> delegate;
@property (strong, nonatomic) NSDictionary *codes;

@end
