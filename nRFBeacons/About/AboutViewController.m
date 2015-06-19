/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.AboutText.text = [NSString stringWithFormat:@"        nRF Beacons Version %@\n\n The app has two main features:\n 1. Monitoring Beacons: The Beacon Tab in the app provides Beacon's monitoring. User can add Nordic Semiconductor Beacon or other Beacon by tapping [+] sign on Beacons view. Nordic Semiconductor Beacons are connectable and the app can retrieve Beacon UUID, Major and Minor. For other Beacon user must select correct Beacon UUID, Major and Minor values.\n\n The Monitoring of Beacons feature supports:\n1.i- Beacons with one of four given UUIDs.\n 1.ii- Monitoring of multiple Beacons simultaneously.\n 1.iii- Adding and removing Beacons.\n 1.iv- Disabling Beacons monitoring.\n 1.v- Monitoring one of the four given Events at a time.\n 1.vi- Performing one of three given Actions on relevant Event.\n 1.vii- user can change name of Beacon. \n\n 2. Update Beacon Device: The Update Tab in the app provides this feature and only Nordic Semiconductor Beacons are supported. Here User can update Beacon's UUID, Major, Minor and Calibrated RSSI values and Manufacturing Id, Advertising Interval and Enable/Disable Beacon LED.\n\n Updating Beacon device:\n 2.i- Beacon device must be switched to Beacon Config mode and this can be done by pressing relevant button on Beacon device.\n 2.ii- User can scan and connect to Nordic Semiconductor Beacon.\n 2.iii- After successful connection to Beacon, the Update view will show Beacon UUID, Major, Minor and Calibrated RSSI values and other values.\n 2.iv- User can change all these values and new values will automatically updated in Beacon device.\n 2.v- Now disconnect to the Beacon device and then it will start advertising as a Beacon.",version];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
