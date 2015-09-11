//
//  TGLViewController.m
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 07.04.14.
//  Copyright (c) 2014 Tim Gleue ( http://gleue-interactive.com )
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "StackedViewController.h"
#import "StackedCollectionViewCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "MBProgressHUD.h"

@interface UIColor (randomColor)

+ (UIColor *)randomColor;

@end

@implementation UIColor (randomColor)

+ (UIColor *)randomColor {
    
    CGFloat comps[3];
    
    for (int i = 0; i < 3; i++) {
        
        NSUInteger r = arc4random_uniform(256);
        comps[i] = (CGFloat)r/255.f;
    }
    
    return [UIColor colorWithRed:comps[0] green:comps[1] blue:comps[2] alpha:1.0];
}

@end

@interface StackedViewController ()

@property (strong, readonly, nonatomic) NSMutableArray *cards;

@end

@implementation StackedViewController

@synthesize cards = _cards;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    //CGFloat screenHeight = screenSize.height;
    
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.frame = CGRectMake(screenWidth-38, 20, 30, 30);
    plusButton.titleLabel.font = [UIFont systemFontOfSize:28.0];
    [plusButton setTitle:@"+" forState:UIControlStateNormal];
    [plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:plusButton];
    
    UIButton *favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favoritesButton.frame = CGRectMake(8, 20, 65, 30);
    favoritesButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [favoritesButton setTitle:@"Favorites" forState:UIControlStateNormal];
    [favoritesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:favoritesButton];
    
    
    // Set to NO to prevent a small number
    // of cards from filling the entire
    // view height evenly and only show
    // their -topReveal amount
    //
    //self.stackedLayout.fillHeight = NO;
    
    // Set to NO to prevent a small number
    // of cards from being scrollable and
    // bounce
    //
    self.stackedLayout.alwaysBounce = YES;
    
    //self.stackedLayout.overwriteContentOffset = YES;
    //self.stackedLayout.contentOffset = CGPointMake(screenWidth, 100);
    
    // Set to NO to prevent unexposed
    // items at top and bottom from
    // being selectable
    //
    self.unexposedItemsAreSelectable = YES;
    
    if (self.doubleTapToClose) {
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        
        recognizer.delaysTouchesBegan = YES;
        recognizer.numberOfTapsRequired = 2;
        
        [self.collectionView addGestureRecognizer:recognizer];
    }
    
    [self getMyCard];
}
- (IBAction)editButtonPressed:(id)sender {
    NSLog(@"Edit button pressed");
    
    // TODO: how to get the current card?
}

- (IBAction)socialButtonPressed:(id)sender {
    NSLog(@"Social button pressed");
    NSDictionary *card = self.cards[self.exposedItemIndexPath.item];
    
    if ([card objectForKey:@"social_links"]) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Social Links" message:@"Using the alert controller" preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            //[self dismissViewControllerAnimated:YES completion:^{
            //}];
        }]];

        for (id key in card[@"social_links"]) {
            [actionSheet addAction:[UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                // Distructive button tapped.
                //[self dismissViewControllerAnimated:YES completion:^{
                //}];
            }]];
        }
        
        // Present action sheet.
        [self presentViewController:actionSheet animated:YES completion:nil];
    } else {
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Social Links set" message:@"Your friend has not enabled any social links." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)phoneButtonPressed:(id)sender {
    NSLog(@"Phone button pressed");
    NSLog(@"Current card %@", self.cards[self.exposedItemIndexPath.item]);
}

- (void) getMyCard {
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8UserID"];
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    // make request to /users/show
    // Show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Getting cards from server..";
    
    // Note: Explicitly getting a low priority queue and making the request on that,
    //       because MBProgressHUD recommends so. However, the success and failure
    //       methods are called on the main queue by AFNetworking anyway. So is
    //       this even necessary? The progress HUD works even if called on the main
    //       thread before the request. Do we need to do some garbage collection
    //       on the main queue after?
    
    // new low priority thread to make request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString *URLString = [NSString stringWithFormat:@"http://4024ed13.ngrok.com/favor8/api/v1.0/users/show/%@", userID];
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        // Make the request
        [manager
         GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
             NSLog(@"/users/show response data: %@", responseObject);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             NSArray *keys = @[@"name", @"status", @"social_links", @"username", @"phone"];
             NSMutableArray *matchingKeys = [[NSMutableArray alloc]init];
             NSMutableArray *objects = [[NSMutableArray alloc]init];
             NSDictionary *card;
             
             for (NSInteger i = 0; i < [keys count]; i++) {
                 if ([responseObject objectForKey:keys[i]]) {
                     [matchingKeys addObject:keys[i]];
                     [objects addObject:responseObject[keys[i]]];
                 }
             }
             
             card = [NSDictionary dictionaryWithObjects:objects forKeys:matchingKeys];
             
             [_cards addObject:card];
             [self getFriendsCards];
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
    });
    
}

- (void) getFriendsCards {
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"favor8AuthToken"];
    
    // make request to /friends/list
    // Show a progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Getting friend's cards from server..";
    
    // Note: Explicitly getting a low priority queue and making the request on that,
    //       because MBProgressHUD recommends so. However, the success and failure
    //       methods are called on the main queue by AFNetworking anyway. So is
    //       this even necessary? The progress HUD works even if called on the main
    //       thread before the request. Do we need to do some garbage collection
    //       on the main queue after?
    
    // new low priority thread to make request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSString *URLString = @"http://4024ed13.ngrok.com/favor8/api/v1.0/friends/list";
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        // Make the request
        [manager
         GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
             NSLog(@"/friends/list response data: %@", responseObject);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             for (NSInteger j = 0; j < [[responseObject valueForKey:@"friends"] count]; j++) {
                 NSArray *keys = @[@"name", @"status", @"social_links", @"username", @"phone"];
                 NSMutableArray *matchingKeys = [[NSMutableArray alloc]init];
                 NSMutableArray *objects = [[NSMutableArray alloc]init];
                 NSDictionary *card;
                 
                 for (NSInteger i = 0; i < [keys count]; i++) {
                     if ([responseObject[@"friends"][j] objectForKey:keys[i]]) {
                         [matchingKeys addObject:keys[i]];
                         [objects addObject:responseObject[@"friends"][j][keys[i]]];
                     }
                 }
                 
                 card = [NSDictionary dictionaryWithObjects:objects forKeys:matchingKeys];
                 [_cards addObject:card];
             }
             [self.collectionView reloadData];
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [self.collectionView reloadData]; // if GET "/friends/list" fails, reload anyway so user's card is displayed
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }];
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

#pragma mark - Accessors

- (NSMutableArray *)cards {
    
    if (_cards == nil) {
        
        _cards = [NSMutableArray array];
        
        // Adjust the number of cards here
        /*
         for (NSInteger i = 1; i < 100; i++) {
         NSDictionary *card = @{ @"name" : [NSString stringWithFormat:@"Card #%d", (int)i], @"color" : [UIColor randomColor] };
         
         [_cards addObject:card];
         } */
    }
    return _cards;
}

#pragma mark - Actions

- (IBAction)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CollectionViewDataSource protocol

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.cards.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    StackedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cardcell" forIndexPath:indexPath];
    NSDictionary *card = self.cards[indexPath.item];

    if (indexPath.row == 0) {
        cell.editButton.hidden = false;
        //cell.socialButton.hidden = true;
        ///cell.phoneButton.hidden = true;
    } else {
        cell.editButton.hidden = true;
        //cell.socialButton.hidden = false;
        //cell.phoneButton.hidden = false;
    }
    
    cell.title = card[@"name"];
    //cell.color = card[@"color"];
    cell.backgroundColor =[UIColor whiteColor];
    
    cell.layer.cornerRadius = 15.0;
    cell.layer.masksToBounds = NO;
    UIColor *color = [UIColor blackColor];
    cell.layer.shadowColor = [color CGColor];
    cell.layer.shadowRadius = 5.0f;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowOffset = CGSizeZero;
    
    return cell;
}

#pragma mark - Overloaded methods

- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    // Update data source when moving cards around
    //
    NSDictionary *card = self.cards[fromIndexPath.item];
    
    [self.cards removeObjectAtIndex:fromIndexPath.item];
    [self.cards insertObject:card atIndex:toIndexPath.item];
}

@end
