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

#import "ManufacturingIdPopoverTableViewController.h"

@interface ManufacturingIdPopoverTableViewController ()

@end

@implementation ManufacturingIdPopoverTableViewController

const int APPLE_MANUFACTURING_ID = 76;
const int NORDIC_SEMICONDUCTOR_MANUFACTURING_ID = 89;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected Section %ld",(long)indexPath.section);
    NSLog(@"didSelectRowAtIndexPath %ld",(long)indexPath.row);
    long selectedSectionIndex = indexPath.section;
    if (selectedSectionIndex == 0) { //selected Apple Id
        NSLog(@"selected Apple ID");
        self.chosenManufacturingId = APPLE_MANUFACTURING_ID;
        [self performSegueWithIdentifier:@"ManufacturingIDSegue" sender:tableView];
    }
    else if (selectedSectionIndex == 1) { //selected Nordic Semiconductor Id
        NSLog(@"selected Nordic Semiconductor ID");
        self.chosenManufacturingId = NORDIC_SEMICONDUCTOR_MANUFACTURING_ID;
        [self performSegueWithIdentifier:@"ManufacturingIDSegue" sender:self.manufacturingIdText];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    header.textLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:15.0];
    
    // Set the background color of our header/footer.
    header.contentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.85 alpha:1.0];
    
    // You can also do this to set the background color of our header/footer,
    //    but the gradients/other effects will be retained.
    // view.tintColor = [UIColor blackColor];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue");
}


- (IBAction)doneButtonPressed:(UIButton *)sender {
    NSLog(@"doneButtonPressed");
    [self.manufacturingIdText resignFirstResponder];
    self.chosenManufacturingId = [self.manufacturingIdText.text intValue];
    [self performSegueWithIdentifier:@"ManufacturingIDSegue" sender:self.manufacturingIdText];
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
