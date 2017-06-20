//
//  TextEditorViewController.m
//  StatUpChallange
//
//  Created by Shah Yasin on 6/9/17.
//  Copyright © 2017 Shah Yasin. All rights reserved.
//

#import "TextEditorViewController.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSSNS.h>
#import "ApiRequest.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Constants.h"

@interface TextEditorViewController ()<ApiRequestingDelegate, UITextViewDelegate>{
    ApiRequest *apiRequest;
    __weak IBOutlet UITextView *editorTextView;
    NSString *typedMsg;
}

@end

@implementation TextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    apiRequest = [[ApiRequest alloc] init];
    apiRequest.delegate = self;
    [apiRequest performWordOfTheDayFetch];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardForScreenTap)];
    [self.view addGestureRecognizer:singleFingerTap];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - KeyboardDelgates 

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        //if([text isEqualToString:@" "] || [text isEqualToString:@"\n"]){
            NSString *dayWordOne = [NSString stringWithFormat:@" %@",[[NSUserDefaults standardUserDefaults] objectForKey:WordOfTheDay]];
            if([textView.text rangeOfString:dayWordOne].location != NSNotFound){
                //typedMsg = [textView.text stringByReplacingOccurrencesOfString:[[NSUserDefaults standardUserDefaults] objectForKey:WordOfTheDay] withString:@""];
                typedMsg = textView.text;
                NSLog(@"%@",typedMsg);
                editorTextView.text = @"";
                [self sendSNSMsg];
            }
        //}
    });
    return YES;
}

- (void)hideKeyboardForScreenTap {
    if([editorTextView isFirstResponder])
    {
        [editorTextView resignFirstResponder];
    }
}

#pragma mark - ApiRequestingDelegate

- (void)wordOfTheDayFetchOperationCompleted:(NSDictionary*)data{
    if(data != nil){
        NSString *dayWord = [data objectForKey:@"word"];
        NSString *meaning = data[@"definitions"][0][@"text"];
        [[NSUserDefaults standardUserDefaults]setObject:dayWord forKey:WordOfTheDay];
        [[NSUserDefaults standardUserDefaults]setObject:meaning forKey:WordMeaning];
    }
    [self hideProgressHud];
}

- (void)serverError{
    [self hideProgressHud];
}

- (void)internetConnectivityError{
    [self hideProgressHud];
}




#pragma mark - ShakeEvent

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *dayWord = [[NSUserDefaults standardUserDefaults]objectForKey:WordOfTheDay];
            UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
            toolbar.barStyle = UIBarStyleDefault;
            [toolbar setBackgroundColor:[UIColor blueColor]];
            [toolbar setAlpha:1.0f];
            toolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:dayWord style:UIBarButtonItemStylePlain target:self action:@selector(showWordMeaning)]];
            [toolbar sizeToFit];
            editorTextView.inputAccessoryView = toolbar;
            [editorTextView reloadInputViews];
            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(removeBlueBar) userInfo:nil repeats:NO];
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showWordMeaning)];
            [toolbar addGestureRecognizer:singleFingerTap];
        });
    }
}

#pragma mark - CallBack

- (void)showWordMeaning{
    NSString *meaning = [[NSUserDefaults standardUserDefaults]objectForKey:WordMeaning];
    [self showAlertMessage:meaning forTitle:@"Meaning"];
}

- (void)removeBlueBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        editorTextView.inputAccessoryView = nil;
        [editorTextView reloadInputViews];
    });
}

- (void)hideProgressHud{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)showAlertMessage:(NSString*)msg forTitle:(NSString*)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:title
                                     message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Done"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)sendSNSMsg{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:UserName];
    NSString *apiResult = [[NSUserDefaults standardUserDefaults] objectForKey:WordnikApiResult];
    NSString *gitRepo = GITHUBRepo;
    NSString *message = [NSString stringWithFormat:@"msg:%@ apiResult:%@ gitRepo:%@",typedMsg,apiResult,gitRepo];
    if(name != nil){
        message = [NSString stringWithFormat:@"%@ name:%@",message,name];
    }
    [apiRequest awsSnsPublishMessage:message subject:@"StatUpChallange"];
}

@end
