//
//  SettingsViewController.m
//  StatUpChallange
//
//  Created by Shah Yasin on 6/11/17.
//  Copyright © 2017 Shah Yasin. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"

@interface SettingsViewController ()<UITextFieldDelegate>{
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UIButton *saveButton;
    NSString *name;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    name = [[NSUserDefaults standardUserDefaults]objectForKey:UserName];
    if(name != nil){
        nameField.text = name;
        [nameField setEnabled:NO];
        [saveButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else{
        [nameField setEnabled:YES];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPress:(UIButton *)sender {
    if([nameField isEnabled]){
        [[NSUserDefaults standardUserDefaults]setObject:nameField.text forKey:UserName];
        [nameField setEnabled:NO];
        [saveButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else{
        [nameField setEnabled:YES];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [nameField resignFirstResponder];
    return YES;
}


@end
