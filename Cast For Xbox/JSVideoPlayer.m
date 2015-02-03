//
//  JSVideoPlayer.m
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 2/1/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import "JSVideoPlayer.h"
#import "SimpleImageFetcher.h"
#import "AppDelegate.h"
#import "CastViewController.h"
#import "CastInstructionsViewController.h"

@interface JSVideoPlayer (){
    int lastKnownPlaybackTime;
    __weak ChromecastDeviceController *_chromecastController;
    
}

@end

@implementation JSVideoPlayer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Listen to orientation changes.
    self.navigationController.navigationBar.topItem.title = @"";
    // Store a reference to the chromecast controller.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _chromecastController = delegate.chromecastDeviceController;
    
    //Add cast button
    if (_chromecastController.deviceScanner.devices.count > 0) {
        [self showCastIcon];
    }
    self.navigationItem.title = _mediaToPlay.titleName;
    
    _videoUrl = _mediaToPlay.videoUrl;
    _thumbnailUrl = _mediaToPlay.thumbnailUrl;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [_playPauseButton setImage:[UIImage new] forState:UIControlStateSelected];
    [self createMoviePlayer];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_moviePlayer setFullscreen:YES animated:YES];
    } else {
        [_moviePlayer setFullscreen:NO animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _chromecastController.delegate = self;
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_moviePlayer) {
        _moviePlayer.view.frame = _thumbnailView.frame;
        _moviePlayer.view.hidden = YES;
    }
    [self updateControls];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // TODO Pause the player if navigating to a different view other than fullscreen movie view.
    if (_moviePlayer && +_moviePlayer.fullscreen == NO) {
        [_moviePlayer pause];
    }
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    if (_chromecastController.isConnected == YES) {
        return;
    }

    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_moviePlayer setFullscreen:YES animated:YES];
    } else {
        [_moviePlayer setFullscreen:YES animated:YES];
    }
    if (_moviePlayer) {
        _moviePlayer.view.frame = _thumbnailView.frame;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Managing the detail item

- (void)setMediaToPlay:(id)newMediaToPlay {
    if (_mediaToPlay != newMediaToPlay) {
        //Sets the JSVideo object to retrieve from chromecast
        _mediaToPlay = newMediaToPlay;
    }
}

- (void)playMovieIfExists {
 
    if (!_chromecastController.isConnected) {
        NSURL *url = _videoUrl;
        NSLog(@"Playing movie %@", url);
        _moviePlayer.contentURL = url;
        _moviePlayer.allowsAirPlay = YES;
        _moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        _moviePlayer.repeatMode = MPMovieRepeatModeNone;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        _moviePlayer.shouldAutoplay = YES;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation) &&
            [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            _moviePlayer.fullscreen = YES;
        } else {
            _moviePlayer.fullscreen = YES;
        }
        
        [_moviePlayer prepareToPlay];
        [_moviePlayer play];
    }

}

- (void)createMoviePlayer {
    //Create movie player controller and add it to the view
    if (!_moviePlayer) {
        // Next create the movie player, on top of the thumbnail view.
        _moviePlayer = [[MPMoviePlayerController alloc] init];
        _moviePlayer.view.frame = _thumbnailView.frame;
        //self.moviePlayer.view.hidden = _chromecastController.isConnected;
        _moviePlayer.view.hidden = YES;
        [self.view addSubview:_moviePlayer.view];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:_moviePlayer];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(moviePlayBackDidChange:)
         name:MPMoviePlayerPlaybackStateDidChangeNotification
         object:_moviePlayer];
    }
    if (!_thumbnailView.image) {
        

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[SimpleImageFetcher getDataFromImageURL:_thumbnailUrl]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _thumbnailView.image = image;
                NSLog(@"Thumnail: %@",_thumbnailUrl);
                
            });
        });
        
    }
    
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    NSLog(@"Looks like playback is over.");
    int reason = [[[notification userInfo]
                   valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        NSLog(@"Playback has ended normally!");
    }
    
}

- (void)moviePlayBackDidChange:(NSNotification *)notification {
    NSLog(@"Movie playback state did change %d",(int) _moviePlayer.playbackState);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - gesture delegate
// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)playPauseButtonPressed:(UIButton *)sender {
    if (_chromecastController.isConnected) {
        if (self.playPauseButton.selected == NO) {
            [_chromecastController pauseCastMedia:NO];
        }
        [self performSegueWithIdentifier:@"castMedia" sender:self];
    } else {
        [self playMovieIfExists];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"castMedia"]) {
        [(CastViewController *)[segue destinationViewController] setMediaToPlay:self.mediaToPlay                                                            withStartingTime:lastKnownPlaybackTime];
    }
}

#pragma mark - ChromecastControllerDelegate

- (void)didDiscoverDeviceOnNetwork {
    // Add the chromecast icon if not present.
    [self showCastIcon];
}

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice *)device {
    lastKnownPlaybackTime = [self.moviePlayer currentPlaybackTime];
    [self.moviePlayer stop];
    [self performSegueWithIdentifier:@"castMedia" sender:self];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [self updateControls];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
    [self updateControls];
}

/**
 * Called to display the modal device view controller from the cast icon.
 */
- (void)shouldDisplayModalDeviceController {
    [self performSegueWithIdentifier:@"listDevices" sender:self];
}

/**
 * Called to display the remote media playback view controller.
 */
- (void)shouldPresentPlaybackController {
    [self performSegueWithIdentifier:@"castMedia" sender:self];
}

// Show cast icon. If this is the first time the cast icon is appearing, show an overlay with
// instructions highlighting the cast icon.
- (void) showCastIcon {
    self.navigationItem.rightBarButtonItem = _chromecastController.chromecastBarButton;
    [CastInstructionsViewController showIfFirstTimeOverViewController:self];
}

- (void)updateControls {
    // Check if the selected media is also playing on the screen. If so display the pause button.
    NSString *title =
    [_chromecastController.mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
    self.playPauseButton.selected = (_chromecastController.isConnected &&
                                     ([title isEqualToString:self.mediaToPlay.titleName] &&
                                      (_chromecastController.playerState == GCKMediaPlayerStatePlaying ||
                                       _chromecastController.playerState == GCKMediaPlayerStateBuffering)));
    self.playPauseButton.highlighted = NO;
    
    [_chromecastController updateToolbarForViewController:self];
}


@end
