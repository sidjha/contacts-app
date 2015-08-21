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

#import "TGLViewController.h"
#import "TGLCollectionViewCell.h"
#import "cardBackViewController.h"
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

@interface TGLViewController ()

@property (strong, readonly, nonatomic) NSMutableArray *cards;

@end

@implementation TGLViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
//    UIButton *buttonEdit;
    UIButton *buttonPlus;
    UIButton *Favoritesbutton;
    BOOL isOnce;
    BOOL isOnceEdit;
}

@synthesize cards = _cards;

- (void)viewDidLoad {

    [super viewDidLoad];
    isOnce = true;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    // Set to NO to prevent a small number
    // of cards from filling the entire
    // view height evenly and only show
    // their -topReveal amount
    //
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(triggerAction:) name:@"NotificationMessageEventBig" object:nil];
    isOnceEdit = true;
    
    buttonPlus = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonPlus.frame = CGRectMake(screenWidth-38, 26, 30, 30);
    buttonPlus.titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:30];
    [buttonPlus setTitle:@"+" forState:UIControlStateNormal];
    [buttonPlus setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:buttonPlus];
    
    Favoritesbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    Favoritesbutton.frame = CGRectMake(8, 26, 65, 30);
    //    Favoritesbutton.backgroundColor = [UIColor redColor];
    Favoritesbutton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15];
    [Favoritesbutton setTitle:@"Favorites" forState:UIControlStateNormal];
    [Favoritesbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:Favoritesbutton];
    
//    buttonEdit = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-50, 5, 40, 30)];
//    [buttonEdit setTitle:@"EDIT" forState:UIControlStateNormal];
//    //        button.backgroundColor = [UIColor grayColor];
//    [buttonEdit addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
//    [buttonEdit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    self.stackedLayout.fillHeight = YES;

    // Set to NO to prevent a small number
    // of cards from being scrollable and
    // bounce
    //
    self.stackedLayout.alwaysBounce = YES;
    
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
}

- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}

#pragma mark - Accessors

- (NSMutableArray *)cards {

    NSArray  *friendList = [[NSArray alloc] initWithObjects:@"Siddharth Jha",@"Net",@"Ray",@"Kim",@"Jack",@"Bob",@"ABC",@"wep",@"foo",nil];
    if (_cards == nil) {
        
        _cards = [NSMutableArray array];
        
        // Adjust the number of cards here
        //
        for (NSInteger i = 0; i < friendList.count; i++) {
            
            NSDictionary *card = @{ @"name" : [NSString stringWithFormat:@"%@",[friendList objectAtIndex:i]], @"color" : [UIColor grayColor] };
//            NSLog(@"%@",[UIColor grayColor]);
            [_cards addObject:card];
        }
        
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
    
    TGLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    NSDictionary *card = self.cards[indexPath.item];
    
    cell.title = card[@"name"];
    cell.backgroundColor =[UIColor whiteColor];
    
    cell.layer.cornerRadius = 20.0;
    cell.layer.masksToBounds = YES;
    UIColor *color = [UIColor blackColor];
    cell.layer.shadowColor = [color CGColor];
    cell.layer.shadowRadius = 5.0f;
    cell.layer.shadowOpacity = 0.5;
    cell.layer.shadowOffset = CGSizeZero;
    cell.layer.masksToBounds = NO;
    
    if (indexPath.row == 0) {
       cell.editbbb.hidden = false;
    }else
    {
     cell.editbbb.hidden = true;
    }
    return cell;
}


#pragma mark - Notification
-(void) triggerAction:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[NSString class]])
    {
        NSString *message = [notification object];
        NSLog(@"%@",message);
        if (isOnce) {
            isOnce = false;
            buttonPlus.hidden = true;
            Favoritesbutton.hidden = true;
        }else
        {
            isOnce = true;
            buttonPlus.hidden = false;
            Favoritesbutton.hidden = false;
        }
        
        // do stuff here with your message data
    }
    else
    {
        NSLog(@"Error, object not recognised.");
    }
}
//-(void)showAlert
//{
////    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"test" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
////    [alert show];
//    
//    UIViewController *ObjcInitial = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"cardBACK"];
//    
//    ObjcInitial.modalTransitionStyle   = UIModalTransitionStyleFlipHorizontal;
//    ObjcInitial.modalPresentationStyle = UIModalTransitionStyleFlipHorizontal;
//    
//    [self presentViewController:ObjcInitial animated:YES completion:nil];    
////    cardBackViewController *objC = [[cardBackViewController alloc]init];
////    objC.modalTransitionStyle   = UIModalTransitionStyleFlipHorizontal;
////    objC.modalPresentationStyle = UIModalTransitionStyleFlipHorizontal;
////    [self presentViewController:objC animated:YES completion:nil];
//}
#pragma mark - Overloaded methods

- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    // Update data source when moving cards around
    //
    NSDictionary *card = self.cards[fromIndexPath.item];
    
    [self.cards removeObjectAtIndex:fromIndexPath.item];
    [self.cards insertObject:card atIndex:toIndexPath.item];
}

- (IBAction)alertShow:(id)sender {
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"test" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}
- (IBAction)callEditAction:(id)sender {
    
    UIViewController *ObjcInitial = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"cardBACK"];
    
    ObjcInitial.modalTransitionStyle   = UIModalTransitionStyleFlipHorizontal;
    ObjcInitial.modalPresentationStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:ObjcInitial animated:YES completion:nil];
}
@end
