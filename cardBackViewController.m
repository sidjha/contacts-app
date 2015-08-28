//
//  cardBackViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 12/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "cardBackViewController.h"
#import <CoreData/CoreData.h>
@interface cardBackViewController ()
@property (strong) NSMutableArray *arraySocialGrid;

@end

@implementation cardBackViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SocialGrid"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    self.arraySocialGrid = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [_gridCollection reloadData];
    
   
//    NSLog(@"grid items ----------- %@", [device valueForKey:@"acName"]);
}
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
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arraySocialGrid.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"gridCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSManagedObject *device = [self.arraySocialGrid objectAtIndex:indexPath.row];

    
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"linkicons/%@.png",[NSString stringWithFormat:@"%@",[device valueForKey:@"acName"]]]];
    
    return cell;
}
- (IBAction)dismissController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
