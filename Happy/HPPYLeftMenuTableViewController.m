//
//  HPPYRightMenuTableViewController.m
//  Happy
//
//  Created by Peter Pult on 16/11/15.
//  Copyright © 2015 Peter Pult. All rights reserved.
//

#import "HPPYLeftMenuTableViewController.h"
#import "SWRevealViewController.h"
#import "HPPYMenuTableViewCell.h"
#import "HPPYTaskContainerViewController.h"
#import "HPPYStaticTextViewController.h"
#import "HPPYTutorialViewController.h"

@interface HPPYLeftMenuTableViewController () {
    NSArray *_menu;
    NSString *_activeItem;
}

@end

@implementation HPPYLeftMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"navigationShadowInverse"];    
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
                  @"id":@"tutorial",
                  @"title":@"Tutorial",
                  @"subTitle":@"How Happy works.",
                  @"viewController":@"TutorialViewController"
                  },
              @{
                  @"id":@"settings",
                  @"title":@"Settings",
                  @"subTitle":@"Your very custom Happy App.",
                  @"viewController":@"SettingsViewController"
                  }
              ];
    
    
    
    
    
    _activeItem = _menu.firstObject[@"id"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _menu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HPPYMenuTableViewCell *cell = (HPPYMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"menu" forIndexPath:indexPath];
    NSDictionary *menuRowDict = _menu[indexPath.row];
    cell.titleLabel.text = NSLocalizedString(menuRowDict[@"title"], nil);
    cell.subTitleLabel.text = NSLocalizedString(menuRowDict[@"subTitle"], nil);    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SWRevealViewController *revealViewController = self.revealViewController;
    if (!revealViewController) { return; }
    
    // Close menu without reloading content when active page is selected
    NSDictionary *menuRowDict = _menu[indexPath.row];
    if ([menuRowDict[@"id"] isEqualToString:_activeItem]) {
        [revealViewController revealToggleAnimated:YES];
        return;
    }
    
    NSString *identifier = menuRowDict[@"viewController"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    // Show tutorial in modal view instead of slide menu style
    if ([identifier isEqualToString:@"TutorialViewController"]) {
        HPPYTutorialViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    _activeItem = menuRowDict[@"id"];
    
    UINavigationController* navVc = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    UIViewController *vc = [navVc childViewControllers].firstObject;
    
    // Handle static pages
    if ([identifier isEqualToString:@"StaticTextViewController"]) {
        HPPYStaticTextViewController *staticVc = (HPPYStaticTextViewController*)vc;
        staticVc.identifier = _activeItem;
    }

    [revealViewController pushFrontViewController:navVc animated:YES];
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
