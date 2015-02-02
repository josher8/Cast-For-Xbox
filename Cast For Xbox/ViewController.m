//
//  ViewController.m
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 1/29/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import "ViewController.h"
#import "JSVideoList.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Cast for Xbox One";
    
    //Dismisses keyboard when clicking out of the text fields
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Cast for Xbox One";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [_gamertagField resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //set gamertag variable in the next view controller
    if ([[segue identifier] isEqualToString:@"videoListSegue"]){
        JSVideoList *videoList = (JSVideoList *)segue.destinationViewController;
        videoList.gamertag = _gamertagField.text;
    }
}

- (IBAction)viewClipsBtnPressed:(UIButton *)sender {
    //If gamertag field has text, then segue to the next view controller, else show the alert
    if([_gamertagField hasText]){
        [self performSegueWithIdentifier:@"videoListSegue" sender:self];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You must enter in a Gamertag"
                                                        message:nil
                                                        delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [alert show];
    }
}
@end
