//
//  PopoverViewController.m
//  nRFBeacons
//
//  Created by Kamran Saleem Soomro on 29/01/15.
//  Copyright (c) 2015 Nordic Semiconductor. All rights reserved.
//

#import "PopoverViewController.h"
#import "ConfigTableViewController.h"

@interface PopoverViewController ()

@end

@implementation PopoverViewController

BOOL isViewLoaded;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isViewLoaded = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSLog(@"PopoverViewController.h viewWillAppear");
    NSLog(@"parentviewcontroller %@",self.parentViewController);
    NSLog(@"presentingviewcontroller %@",[self presentingViewController]);
    NSLog(@"presentedviewcontroller %@",[self presentedViewController]);
    NSLog(@"presentationviewcontroller %@",[self presentationController]);



    if (isViewLoaded) {
        isViewLoaded = NO;
    }
    else {
        [self.popOverDelegate popOverWillDismiss];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Add"]) {
        NSLog(@"Add Other Beacon Segue");
        UINavigationController *navController = segue.destinationViewController;
        ConfigTableViewController *configVC = (ConfigTableViewController *)navController.topViewController;
        configVC.isAddView = YES;
    }
}


@end
