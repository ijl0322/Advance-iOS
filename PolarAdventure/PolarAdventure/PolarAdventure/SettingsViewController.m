//
//  SettingsViewController.m
//  PolarAdventure
//
//  Created by Isabel  Lee on 10/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *readToMeSwitch;

@end


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"readToMe"] == YES) {
        [self.readToMeSwitch setOn:YES animated:YES];
        NSLog(@"User default: is on");
    } else {
        NSLog(@"User default: is off");
        [self.readToMeSwitch setOn:NO animated:YES];
    }
}


// Toggle the values of the switch and store its values in `NSUserDefaults`.
// Dump the user defaults to the console for debugging
- (IBAction)tapSwitch:(UISwitch *)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[defaults setBool:sender.isOn forKey:@"readToMe"];
    
    if ([sender isOn]) {
        NSLog(@"is on");
        [defaults setBool:YES forKey:@"readToMe"];
    } else {
        NSLog(@"is off");
        [defaults setBool:NO forKey:@"readToMe"];
    }
}

@end
