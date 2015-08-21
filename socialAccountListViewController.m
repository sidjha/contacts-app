//
//  socialAccountListViewController.m
//  mContactApp
//
//  Created by Pankaj Bhardwaj on 14/08/15.
//  Copyright (c) 2015 Mesh8 Inc. All rights reserved.
//

#import "socialAccountListViewController.h"
#import "socialAccountValidationViewController.h"
#import "SAtableCell.h"
@interface socialAccountListViewController ()

@end

@implementation socialAccountListViewController
{
    NSMutableArray *myData;
    NSMutableArray *arrayLinkImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    
//    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
//    self.navigationItem.leftBarButtonItem = done;
    
    // table view data is being set here
    myData = [[NSMutableArray alloc]initWithObjects:
              @"Facebook",@"Instagram",
              @"Kik",@"Linkedin",@"Snapchat",
              @"Twitter",@"Whatsapp", nil];
    arrayLinkImages = [[NSMutableArray alloc]initWithObjects:
              [UIImage imageNamed:@"linkicons/Facebook.png"],
              [UIImage imageNamed:@"linkicons/Instagram.png"],
              [UIImage imageNamed:@"linkicons/Kik.png"],
              [UIImage imageNamed:@"linkicons/LinkedIn.png"],
              [UIImage imageNamed:@"linkicons/Snapchat.png"],
              [UIImage imageNamed:@"linkicons/Twitter.png"],
              [UIImage imageNamed:@"linkicons/Whatsapp.png"]
              , nil];
    self.socialTable.separatorColor = [UIColor clearColor];
}


#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return [myData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    
    
    static NSString *CellIdentifier = @"customCell";
    SAtableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.accImageview.image = [arrayLinkImages objectAtIndex:indexPath.row];
    cell.accTitleLabel.text = [myData objectAtIndex:indexPath.row];

    return cell;
    
//    
//    cell.imageView.image = [arrayLinkImages objectAtIndex:indexPath.row];
//    CGSize itemSize = CGSizeMake(50, 50);
//    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
//    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//    [cell.imageView.image drawInRect:imageRect];
//    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    [cell.textLabel setText:stringForCell];
//    return cell;
}


// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
//(NSInteger)section{
//    NSString *headerTitle;
//    if (section==0) {
//        headerTitle = @"Section 1 Header";
//    }
//    else{
//        headerTitle = @"Section 2 Header";
//        
//    }
//    return headerTitle;
//}
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
//(NSInteger)section{
//    NSString *footerTitle;
//    if (section==0) {
//        footerTitle = @"Section 1 Footer";
//    }
//    else{
//        footerTitle = @"Section 2 Footer";
//        
//    }
//    return footerTitle;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
#pragma mark - TableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSLog(@"selected and its data is %@",cell.textLabel.text);
//    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ Integration",cell.textLabel.text] message:@"coming soon..." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
    
//    socialAccountValidationViewController *objSc = [[socialAccountValidationViewController alloc]init];
    
    
//    saValidation
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"saValidation"]) {
        NSIndexPath *indexPath = [self.socialTable indexPathForSelectedRow];
        
        socialAccountValidationViewController *objSc = segue.destinationViewController;
        objSc.accSelectedName = [myData objectAtIndex:indexPath.row];
        objSc.indexSelected = indexPath.row;
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

- (IBAction)cancelAcion:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
