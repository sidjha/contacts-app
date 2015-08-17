//
//  cardBackViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 12/08/15.
//  Copyright (c) 2015 Pankaj Bhardwaj. All rights reserved.
//

#import "cardBackViewController.h"

@interface cardBackViewController ()

@end

@implementation cardBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.view.layer.contents = (id)[UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(triggerAction:) name:@"NotificationMessageEvent" object:nil];

}
#pragma mark - Notification
-(void) triggerAction:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSString class]])
    {
        NSString *message = [notification object];
        NSLog(@"%@",message);
        // do stuff here with your message data
    }
    else
    {
        NSLog(@"Error, object not recognised.");
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
