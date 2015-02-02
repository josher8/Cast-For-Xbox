//
//  JSVideoPlayer.h
//  Cast For Xbox
//
//  Created by Josher Slebodnik on 2/1/15.
//  Copyright (c) 2015 Josher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface JSVideoPlayer : UIViewController

@property (strong, nonatomic)NSURL *videoUrl;
@property (strong, nonatomic)NSURL *thumbnailUrl;
@property (strong, nonatomic)NSString *videoTitle;


@property MPMoviePlayerController *moviePlayer;
@property UITapGestureRecognizer *tap;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;


@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
- (IBAction)playPauseButtonPressed:(UIButton *)sender;


@end
