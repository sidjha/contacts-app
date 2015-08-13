//
//  cardListViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 13/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "cardListViewController.h"
#import "ViewController.h"
@interface cardListViewController ()

@end

@implementation cardListViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    self.view.backgroundColor = [UIColor blackColor];
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    // Do any additional setup after loading the view, typically from a nib.
    NSArray  *friendList = [[NSArray alloc] initWithObjects:@"Siddharth Jha",@"Net",@"Ray",@"Kim",@"Jack",@"Bob",nil];
    [self addDynamicFriendList:friendList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addDynamicFriendList :(NSArray*)sender
{
    UIButton *ButtonFriendCard;
    UIView *ViewFriendBg = [[UIView alloc]initWithFrame:CGRectMake(0, 45, screenWidth, screenHeight-120)];
    ViewFriendBg.backgroundColor = [UIColor clearColor];
    ViewFriendBg.clipsToBounds = NO;
    [self.view addSubview:ViewFriendBg];
    UILabel *lableFriendName;
    for (int i=1; i<=[sender count]; i++) {
        
        // friendlist view setup
        ButtonFriendCard = [[UIButton alloc]init];
        ButtonFriendCard.backgroundColor = [UIColor whiteColor];
        [ViewFriendBg addSubview:ButtonFriendCard];
        ButtonFriendCard.layer.cornerRadius = 10.0;
        ButtonFriendCard.layer.masksToBounds = YES;
        UIColor *color = [UIColor blackColor];
        ButtonFriendCard.layer.shadowColor = [color CGColor];
        ButtonFriendCard.layer.shadowRadius = 10.0f;
        ButtonFriendCard.layer.shadowOpacity = 1;
        ButtonFriendCard.layer.shadowOffset = CGSizeZero;
        ButtonFriendCard.layer.masksToBounds = NO;
        [ButtonFriendCard addTarget:self action:@selector(gotoViewController) forControlEvents:UIControlEventTouchUpInside];
        if (i==1)
        {
            ButtonFriendCard.frame = CGRectMake(0, 0, screenWidth, screenHeight-100);
//            UIButton *editButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-100, 20, 50, 25)];
//            [editButton addTarget:self action:@selector(gotoViewController) forControlEvents:UIControlEventTouchUpInside];
//            [editButton setTitle:@"EDIT" forState:UIControlStateNormal];
//            [editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [ButtonFriendCard addSubview:editButton];
        }
        else{
            ButtonFriendCard.frame = CGRectMake(0, (i-1)*90, screenWidth, screenHeight-100);
        }
        
        // friend names on the card
        lableFriendName = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, screenWidth, 25)];
        lableFriendName.text = [sender objectAtIndex:i-1];
        lableFriendName.font=[UIFont fontWithName:@"Avenir Next Medium" size:26];
        [ButtonFriendCard addSubview:lableFriendName];
        
    }
}
-(void)gotoViewController
{
    NSLog(@"abc");
    self.view.layer.contents = (id)[UIColor blackColor];
    
//    ViewController *add = [[ViewController alloc]
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"mainStory"];
//    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:loginVC animated:YES completion:nil];
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
