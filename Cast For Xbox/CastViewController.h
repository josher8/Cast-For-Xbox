// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import "ChromecastDeviceController.h"
#import "JSVideos.h"
#import "Media.h"

/**
 * A view that shows the media thumbnail and controls for media playing on the
 * Chromecast device.
 */
@interface CastViewController : UIViewController<ChromecastControllerDelegate>

/** The media object being played on Chromecast device. Set this before presenting the view. */
@property(strong, nonatomic) JSVideos  *mediaToPlay;

/** The volume slider control **/
@property(strong, nonatomic) IBOutlet UISlider *volumeSlider;

/** The entire volume control container, including the label **/
@property(strong, nonatomic) IBOutlet UIView *volumeControls;

@property(strong, nonatomic) NSURL *videoURL;
@property(strong, nonatomic) NSURL *thumbnailURL;
/** The media object and when to start playing on Chromecast device. Set this before presenting the view. */
- (void)setMediaToPlay:(Media*)newMedia withStartingTime:(NSTimeInterval)startTime;

/** Shows the slider for a few seconds if touched **/
- (IBAction)showVolumeSlider:(id)sender;

@end