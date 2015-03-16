//
//  PopoverViewController.h
//  nRFBeacons
//
//  Created by Kamran Saleem Soomro on 29/01/15.
//  Copyright (c) 2015 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopOverWillDismissDelegate <NSObject>
-(void) popOverWillDismiss;
@end


@interface PopoverViewController : UIViewController

@property (retain)id <PopOverWillDismissDelegate> popOverDelegate;

@end
