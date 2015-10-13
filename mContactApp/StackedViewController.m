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
#import "EditViewController.h"
#import "AddFriendViewController.h"
#include <stdlib.h>
@import StoreKit;

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

- (void) viewWillAppear:(BOOL)animated {

    // Retrieve user's card and friends' cards from server
    [self getMyCard];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set TGL properties
    self.exposedPinningMode = TGLExposedLayoutPinningModeAll;
    self.exposedItemSize = self.stackedLayout.itemSize = CGSizeMake(0.0, 500.0);
    self.exposedBottomOverlap = 10.0;
    self.exposedBottomPinningCount = 5;
    self.doubleTapToClose = NO;
    self.exposedLayoutMargin = self.stackedLayout.layoutMargin = UIEdgeInsetsMake(60.0, 0.0, 0.0, 0.0);
    
    // Set to NO to prevent a small number
    // of cards from filling the entire
    // view height evenly and only show
    // their -topReveal amount
    self.stackedLayout.fillHeight = NO;
    
    // Set to NO to prevent a small number
    // of cards from being scrollable and
    // bounce
    self.stackedLayout.alwaysBounce = YES;
    
    // Set to NO to prevent unexposed
    // items at top and bottom from
    // being selectable
    self.unexposedItemsAreSelectable = YES;
    
    if (self.doubleTapToClose) {
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        
        recognizer.delaysTouchesBegan = YES;
        recognizer.numberOfTapsRequired = 2;
        
        [self.collectionView addGestureRecognizer:recognizer];
    }
    
    
    // Add a topbar consisting of "Favorites" and "+" button
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    plusButton.frame = CGRectMake(screenWidth-38, 25, 30, 30);
    //plusButton.titleLabel.font = [UIFont systemFontOfSize:28.0];
    //[plusButton setTitle:@"+" forState:UIControlStateNormal];
    [plusButton setTintColor:[UIColor whiteColor]];
    //[plusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [plusButton addTarget:self action:@selector(pushAddFriendViewController) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:plusButton];
    
    
    
    UIButton *favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    favoritesButton.frame = CGRectMake(0, 25, 90, 30);
    favoritesButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [favoritesButton setTitle:@"Favorites" forState:UIControlStateNormal];
    [favoritesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.view addSubview:favoritesButton];

}

- (void) editViewController:(EditViewController *)controller didFinishUpdatingCard:(NSMutableDictionary *)card {
    [_cards replaceObjectAtIndex:0 withObject:card];
    _myCard = card;
    [self.collectionView reloadData];
}


- (IBAction)editButtonPressed:(id)sender {

    NSLog(@"Edit button pressed");
    
}

- (IBAction)socialButtonPressed:(id)sender {
    // Get current card
    NSDictionary *card = self.cards[self.exposedItemIndexPath.item];

    NSString *name;

    if ([card objectForKey:@"name"]) {
        name = card[@"name"];
    }

    if ([card objectForKey:@"social_links"]) {
        
        NSString *msg;

        if (name != NULL) {
            msg = [NSString stringWithFormat:@"Select a channel to reach %@ on", name];
        } else {
            msg = @"Select a channel to reach on";
        }
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Social Links" message:msg preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

        for (id key in card[@"social_links"]) {
            [actionSheet addAction:[UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                NSString *stringURL;
                NSString *handle = card[@"social_links"][key];

                if ([key isEqualToString:@"Twitter"]) {
                    
                    stringURL = [NSString stringWithFormat:@"twitter://user?screen_name=%@", handle];
                
                } else if ([key isEqualToString:@"Facebook"]) {
                    
                    stringURL = @"fb://profile";
                    
                    // NOTE: fb://profile/<handle> requires handle to be facebook numeric id
                    //stringURL = [NSString stringWithFormat:@"fb://profile", handle];
                    
                } else if ([key isEqualToString:@"FB Messenger"]) {
                    
                    // NOTE: if there's no user thread with that user, an error message shows up in Messenger
                    stringURL = [NSString stringWithFormat:@"fb-messenger://user-thread/%@", handle];
                    
                } else if ([key isEqualToString:@"Instagram"]) {
                    
                    stringURL = [NSString stringWithFormat:@"instagram://user?username=%@", handle];
                    
                } else if ([key isEqualToString:@"WhatsApp"]) {
                    
                    stringURL = [NSString stringWithFormat:@"whatsapp://send?abid=%@", handle];
                    
                } else if ([key isEqualToString:@"Snapchat"]) {
                    
                    stringURL = [NSString stringWithFormat:@"snapchat://?u=%@", handle];
                    
                } else if ([key isEqualToString:@"LinkedIn"]) {
                    
                    // UPDATE: linkedin:// URL scheme does not work at all
                    stringURL = @"linkedin://";
                    
                    // UPDATE: linkedin://#profile URL scheme does not work
                    stringURL = [NSString stringWithFormat:@"linkedin://#profile/%@", handle];
                    
                } else {
                    // do nothing
                }
                
                NSURL *url = [NSURL URLWithString:stringURL];
                
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                } else {
                    
                    /*
                     iTunes IDs: 
                     
                     Instagram — 389801252
                     Facebook — 284882215
                     FB Messenger — 454638411
                     Snapchat — 447188370
                     WhatsApp — 310633997
                     Twitter — 333903271
                     LinkedIn — 288429040
                     
                     */
                    
                    NSLog(@"Couldn't open URL: %@", url);
                    
                    NSDictionary *iTunesIDs = @{
                                                @"Instagram":[NSNumber numberWithInt:389801252],
                                                @"Facebook": [NSNumber numberWithInt:284882215],
                                                @"FB Messenger": [NSNumber numberWithInt:454638411],
                                                @"Snapchat": [NSNumber numberWithInt:447188370],
                                                @"WhatsApp": [NSNumber numberWithInt:310633997],
                                                @"Twitter": [NSNumber numberWithInt:333903271],
                                                @"LinkedIn": [NSNumber numberWithInt:288429040]
                                                };
                    
                    // Set up an App Store modal to let the user download the linked 3rd-party app
                    // TODO: analytics
                    SKStoreProductViewController *storeVC = [[SKStoreProductViewController alloc]init];
                    
                    storeVC.delegate = self;
                    
                    NSDictionary *item = [NSDictionary dictionaryWithObject:iTunesIDs[key] forKey:SKStoreProductParameterITunesItemIdentifier];
                    
                    [storeVC loadProductWithParameters:item completionBlock:^(BOOL result, NSError * _Nullable error) {
                        
                        if (result) {
                            
                            [self presentViewController:storeVC animated:YES completion:nil];
                        
                        } else {
                            
                            NSLog(@"Error: %@", error);
                        }
                    }];
                }
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
    
    NSDictionary *card = self.cards[self.exposedItemIndexPath.item];
    NSString *phoneNumber;

    if ([card objectForKey:@"phone"]) {
        
        phoneNumber = [@"tel:" stringByAppendingString:card[@"phone"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
    } else {
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No phone number set" message:@"Your friend has not enabled a phone number." preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (IBAction) pushAddFriendViewController
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddFriendViewController *addFriendVC = [storyboard instantiateViewControllerWithIdentifier:@"AddFriendViewController.m"];
    
    [self presentViewController:addFriendVC animated:YES completion:nil];
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
        
        NSString *URLString = [NSString stringWithFormat:@"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/users/show/%@", userID];
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = NO;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        
        // Make the request
        [manager
         GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
             NSLog(@"/users/show response data: %@", responseObject);
             
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             NSArray *keys = @[@"name", @"status", @"social_links", @"username", @"phone", @"profile_img"];
             NSMutableArray *matchingKeys = [[NSMutableArray alloc]init];
             NSMutableArray *objects = [[NSMutableArray alloc]init];
             
             NSMutableDictionary *card;
             
             for (NSInteger i = 0; i < [keys count]; i++) {
                 
                 if ([responseObject objectForKey:keys[i]]) {
                     
                     [matchingKeys addObject:keys[i]];
                     [objects addObject:responseObject[keys[i]]];
                 }
             }
             
             card = [NSMutableDictionary dictionaryWithObjects:objects forKeys:matchingKeys];
             _myCard = card;
             
             if ([_cards count] > 0) {
                 
                 [_cards replaceObjectAtIndex:0 withObject:card];
             
             } else {
                 
                 [_cards addObject:card];
             }
             
            [self getFriendsCards];

             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

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
        
        NSString *URLString = @"https://favor8api-alpha1.herokuapp.com/favor8/api/v1.0/friends/list";
        
        // Set headers
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.securityPolicy.allowInvalidCertificates = NO;
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
        
        // Make the request
        [manager
         GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
             
             NSLog(@"/friends/list response data: %@", responseObject);
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             
             for (NSInteger j = 0; j < [[responseObject valueForKey:@"friends"] count]; j++) {
                 
                 NSArray *keys = @[@"name", @"status", @"social_links", @"username", @"phone", @"profile_img"];
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
                 
                 
                 /*
                  
                  Basically, if the friend card doesn't exist, simply add it.
                  
                  If the friend card exists, replace it.
                  
                  OK, so:
                  
                  - iterate over _cards array
                  - if card with username already there, replace that card with "card"
                  - if card with username does not exist, add "card"
                  
                  */
                 
                 bool found = 0;
                 for (NSInteger k = 0; k < [_cards count]; k++) {
                     if ([card[@"username"] isEqualToString:_cards[k][@"username"]]) {
                         
                         [_cards replaceObjectAtIndex:k withObject:card];
                         
                         found = 1;
                     }
                 }
                 
                 if (found == 0) {
                     
                     [_cards addObject:card];
                 }
             }
             
             [self.collectionView reloadData];

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error);
             
             // if GET "/friends/list" fails, reload anyway so user's card is displayed
             //[self.collectionView reloadData];

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
    // TODO: Mutable vs. Immutable dictionary
    NSDictionary *card = self.cards[indexPath.item];

    if (indexPath.row == 0) {
        
        cell.editButton.hidden = false;
        cell.socialButton.hidden = true;
        cell.phoneButton.hidden = true;
    
    } else {
        
        cell.editButton.hidden = true;
        cell.socialButton.hidden = false;
        cell.phoneButton.hidden = false;
    }
    
    cell.title = card[@"name"];
    
    if ([card objectForKey:@"status"]) {

        cell.status = card[@"status"];
    }
    
    if ([card objectForKey:@"profile_img"]) {
        
        NSURL *imageURL = [NSURL URLWithString:card[@"profile_img"]];
        cell.profileImg = imageURL;

    } else {
        // initialize imageView with placeholder image
    }
    
    
    // Color repository
    NSDictionary *colorDict = @{
        @"#95a5a6": [UIColor whiteColor], // Concrete
        @"#E74C3C": [UIColor whiteColor], // alizarin (red) .
        @"#5856D6": [UIColor whiteColor], // purple .
        @"#ecf0f1": [UIColor blackColor], // clouds .
        @"#f1c40f": [UIColor blackColor], // sunflower .
        @"#e67e22": [UIColor whiteColor], // carrot .
        @"#6a76ac": [UIColor whiteColor], // TiVo purple .
        @"#1F1F21": [UIColor whiteColor] //iOS 7 black .
        };
    
    // current color
    colorDict = @{ @"#95a5a6": [UIColor whiteColor]};
    
    NSArray *colors = [colorDict allKeys];
    
    int r = arc4random_uniform((int)[colors count]);
    
    UIColor *bg = [self colorFromHexString:colors[r]];
    
    cell.backgroundColor = bg;
    [cell changeBG: bg];
    [cell setColor:colorDict[colors[r]]];
    
    cell.layer.cornerRadius = 15.0;
    cell.layer.masksToBounds = NO;
    UIColor *color = [UIColor blackColor];
    cell.layer.shadowColor = [color CGColor];
    cell.layer.shadowRadius = 5.0f;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowOffset = CGSizeZero;
    
    return cell;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark - Overloaded methods

- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    // Update data source when moving cards around
    //
    NSDictionary *card = self.cards[fromIndexPath.item];
    
    [self.cards removeObjectAtIndex:fromIndexPath.item];
    [self.cards insertObject:card atIndex:toIndexPath.item];
}

- (BOOL)canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {

    // Don't allow moving of the first card in the stack
    //if (sourceIndexPath.row == 0) {
     //   return nil;
   // }
    
    // Don't allow moving of card to top position in the stack
    if (proposedDestinationIndexPath.row == 0) {
        return nil;
    }
    
    return proposedDestinationIndexPath;
}



#pragma mark - Navigation methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {
    
    if ([segue.identifier isEqualToString:@"editSegue"]) {
        
        EditViewController *editVC = (EditViewController *)[segue destinationViewController];
        editVC.delegate = self;
        editVC.card = _myCard;
    }
}

#pragma mark — SKStoreProductViewControllerDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)getName {
    
    NSDictionary *card = self.cards[self.exposedItemIndexPath.item];
    NSString *name;
    
    if ([card objectForKey:@"name"]) {
        name = card[@"name"];
    }
    
    if (name == NULL) {
        name = @"";
    }

    return name;
}

- (NSString *)getStatus {
    
    NSDictionary *card = self.cards[self.exposedItemIndexPath.item];
    NSString *status;
    
    if ([card objectForKey:@"status"]) {
        status = card[@"status"];
    }
    
    if (status == NULL) {
        status = @"";
    }
    
    return status;
}

- (NSString *)getPhone {
    
    NSDictionary *card = self.cards[self.exposedItemIndexPath.item];
    NSString *phone;
    
    if ([card objectForKey:@"phone"]) {
        phone = card[@"phone"];
    }
    
    if (phone == NULL) {
        phone = @"";
    }
    
    return phone;
}

- (NSString *)getProfileImgURL {
    
    NSDictionary *card = self.cards[self.exposedItemIndexPath.item];
    NSString *profileImgURL;
    
    if ([card objectForKey:@"profile_img"]) {
        profileImgURL = card[@"profile_img"];
    }
    
    if (profileImgURL == NULL) {
        profileImgURL = @"";
    }
    
    return profileImgURL;
}


@end
