//
//  ViewController.m
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 1/29/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import "ViewController.h"
#import "JSVideoList.h"
#import "AppDelegate.h"
#import "CastInstructionsViewController.h"

@interface ViewController (){
    __weak ChromecastDeviceController *_chromecastController;
}

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
    
    //Store a reference to the chromecast controller.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _chromecastController = delegate.chromecastDeviceController;
    
    //Show cast icon if there is any chromecasts avaialble
    if (_chromecastController.deviceScanner.devices.count > 0) {
        [self showCastIcon];
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Cast for Xbox One";
    
    _chromecastController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_chromecastController updateToolbarForViewController:self];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// instructions highlighting the cast icon.
- (void) showCastIcon {
    self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    [CastInstructionsViewController showIfFirstTimeOverViewController:self];
}
-(void)dismissKeyboard {
    [_gamertagField resignFirstResponder];
}
- (void)didDiscoverDeviceOnNetwork {
    // Add the chromecast icon if not present.
    [self showCastIcon];
}
- (void)shouldDisplayModalDeviceController {
    [self performSegueWithIdentifier:@"listDevices" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //set gamertag variable in the next view controller
    if ([[segue identifier] isEqualToString:@"videoListSegue"]){
        JSVideoList *videoList = (JSVideoList *)segue.destinationViewController;
        videoList.gamertag = _gamertagField.text;
    }
}

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice *)device {
    [_chromecastController updateToolbarForViewController:self];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [_chromecastController updateToolbarForViewController:self];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
    [_chromecastController updateToolbarForViewController:self];
}

- (void)shouldPresentPlaybackController {
    // Select the item being played in the table, so prepareForSegue can find the
    // associated Media object.
    [_chromecastController.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
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
