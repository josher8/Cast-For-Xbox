//
//  JSVideoPlayer.m
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 2/1/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import "JSVideoPlayer.h"
#import "SimpleImageFetcher.h"

@interface JSVideoPlayer ()

@end

@implementation JSVideoPlayer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Listen to orientation changes.
    self.navigationController.navigationBar.topItem.title = @"";
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
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_moviePlayer) {
        _moviePlayer.view.frame = _thumbnailView.frame;
        _moviePlayer.view.hidden = YES;
    }
//    [self updateControls];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // TODO Pause the player if navigating to a different view other than fullscreen movie view.
    if (_moviePlayer && +_moviePlayer.fullscreen == NO) {
        [_moviePlayer pause];
    }
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {

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

- (void)playMovieIfExists {
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
    [self playMovieIfExists];
}

/* Called when connection to the device was closed.
*/
- (void)didDisconnect {
//    [self updateControls];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
//    [self updateControls];
}
@end
