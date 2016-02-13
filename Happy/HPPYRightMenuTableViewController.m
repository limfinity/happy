//
//  HPPYRightMenuTableViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYRightMenuTableViewController.h"
#import "HPPYMenuTableViewCell.h"
#import "HPPYTaskContainerViewController.h"
#import "HPPYStaticTextViewController.h"
#import <iOS-Slide-Menu/SlideNavigationController.h>

@interface HPPYRightMenuTableViewController () {
    NSArray *_menu;
}

@end

@implementation HPPYRightMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeMenu];
}

- (void)initializeMenu {
    _menu = @[
              @{
                  @"id":@"home",
                  @"title":@"Home",
                  @"subTitle":@"Home is where your heart is.",
                  @"viewController":@"TaskContainerViewController"
                  },
              @{
                  @"id":@"contact",
                  @"title":@"Contact",
                  @"subTitle":@"Get in touch with us.",
                  @"viewController":@"StaticTextViewController"
                  },
              @{
                  @"id":@"imprint",
                  @"title":@"Imprint",
                  @"subTitle":@"All that legal stuff.",
                  @"viewController":@"StaticTextViewController"
                  },
              @{
                  @"id":@"settings",
                  @"title":@"Settings",
                  @"subTitle":@"Your very custom Happy App.",
                  @"viewController":@"SettingsViewController"
                  }
              ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }

    return _menu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuHeader" forIndexPath:indexPath];
        return cell;
    }
    
    HPPYMenuTableViewCell *cell = (HPPYMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"menu" forIndexPath:indexPath];
    NSDictionary *menuRowDict = _menu[indexPath.row];
    cell.titleLabel.text = NSLocalizedString(menuRowDict[@"title"], nil);
    cell.subTitleLabel.text = NSLocalizedString(menuRowDict[@"subTitle"], nil);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 110;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return;
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NSDictionary *menuRowDict = _menu[indexPath.row];
    NSString *identifier = menuRowDict[@"viewController"];
    
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    UIImage *image = [UIImage imageNamed:@"navigationHeart"];
    vc.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    if ([identifier isEqualToString:@"StaticTextViewController"]) {
        HPPYStaticTextViewController *staticVc = (HPPYStaticTextViewController *)vc;
        staticVc.identifier = menuRowDict[@"id"];
        [SlideNavigationController sharedInstance].avoidSwitchingToSameClassViewController = NO;
    } else {
        [SlideNavigationController sharedInstance].avoidSwitchingToSameClassViewController = YES;
    }
    [[SlideNavigationController sharedInstance] popAllAndSwitchToViewController:vc withCompletion:nil];

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
