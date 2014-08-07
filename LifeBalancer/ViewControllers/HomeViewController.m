//
//  HomeViewController.m
//  LifeBalancer
//
//  Created by Pradeep Kumara on 3/21/13.
//  Copyright (c) 2013 EFutures. All rights reserved.
//

#import "HomeViewController.h"
#import "DataAdapter.h"
#import "Role.h"
#import "Task.h"
#import "AppDelegate.h"
#import "WeeklyPlaningViewController.h"
#import "SetPrioritiesViewController.h"



@interface HomeViewController ()<UIAlertViewDelegate>

@end

@implementation HomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[[DataAdapter alloc]init] initialSetup];
    self.tabBarController.tabBar.hidden = YES;
	self.view.tag = 101;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES];
    self.tabBarController.tabBar.hidden = YES;
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Life Balancer";
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"Home";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //[self.navigationController setNavigationBarHidden:YES];
    WeeklyPlaningViewController *wpvc = (WeeklyPlaningViewController *)[segue destinationViewController];
    wpvc.hidesBottomBarWhenPushed = YES;
    //destination =  ((MissionViewController *)[[((UITabBarController *)segue.destinationViewController) viewControllers] objectAtIndex:0]);
    if ([segue.identifier isEqualToString:@"segueToTab1"]) {
        ((MissionViewController *)[[((UITabBarController *)segue.destinationViewController) viewControllers] objectAtIndex:0]).selectedVcIndex = selectedTab;
    }
    
    
    if ([segue.identifier isEqualToString:@"weekSegue1"] || [segue.identifier isEqualToString:@"weekSegue2"])
    {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        SetPrioritiesViewController *vc = (SetPrioritiesViewController*)[segue destinationViewController];
        
        if (indexPath.row==0) {
            vc.shouldBePresentedInEditMode = NO;
        }
//        else if(indexPath.row ==1)
//        {
//            vc.shouldBePresentedInEditMode = YES;
//        }
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            //[self.tabBarController setSelectedIndex:1];
            selectedTab = 0;
            
            
        }
        else if(indexPath.row == 1)
        {
            //[self.tabBarController setSelectedIndex:2];
            
            selectedTab = 1;
        }
        else if(indexPath.row == 2)
        {
            //[self.tabBarController setSelectedIndex:3];
            
            selectedTab =2;
        }
        [self performSegueWithIdentifier:@"segueToTab1" sender:self];
        
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            
        }
        else if (indexPath.row==1)
        {
           
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Info" message:@"Copy previous week's priorities?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
        }
    }
    
}


-(BOOL)checkforSelectedGoals{
    DataAdapter *da = [[DataAdapter alloc]init];
    NSMutableArray *availablearray = [NSMutableArray arrayWithArray:[da checkforTask]];
    if(availablearray.count >0){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"selected index %d",buttonIndex);
    if (buttonIndex==1) {
        // YES
        SetPrioritiesViewController *spVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
        
        // Reseting
        for (Role *role in [[[DataAdapter alloc]init]roles]) {
            for (Task *task in role.tasks) {
                task.isDone = 0;
                task.calendarId = nil;
            }
        }
        NSError *error;
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (![appdelegate.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        spVC.shouldBePresentedInEditMode = YES;
        [self.navigationController pushViewController:spVC animated:YES];
    }
    else{
        //NO
        if([self checkforSelectedGoals]){
            
            BOOL permission = YES;
            
            permission = [[[DataAdapter alloc]init]resetPriorities];
            
            if(permission){
                [[[DataAdapter alloc]init]reset];
                SetPrioritiesViewController *setPrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
                setPrioritiesViewController.shouldBePresentedInEditMode = YES;
                [self.navigationController pushViewController:setPrioritiesViewController animated:YES];
                
                
            }
            
            
            
            
        }else
        {
            
            
            SetPrioritiesViewController *setPrioritiesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPriorities"];
            setPrioritiesViewController.shouldBePresentedInEditMode = YES;
            [self.navigationController pushViewController:setPrioritiesViewController animated:YES];
            
            
        }
        
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
