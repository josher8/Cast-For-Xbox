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

#import "CastInstructionsViewController.h"
//#import "SemiModalAnimatedTransition.h"

@implementation CastInstructionsViewController

NSString *const kHasSeenChromecastOverlay = @"hasSeenChromecastOverlay";

+(void)showIfFirstTimeOverViewController:(UIViewController *)viewController {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  bool hasSeenChromecastOverlay = [defaults boolForKey:kHasSeenChromecastOverlay];

  // Only show it if we haven't seen it before
  if(!hasSeenChromecastOverlay) {
    CastInstructionsViewController *cvc = [[CastInstructionsViewController alloc] init];
    [viewController presentViewController:cvc animated:YES completion:^() {
      // once viewDidAppear is successfully called, mark this preference as viewed
      [defaults setBool:true forKey:kHasSeenChromecastOverlay];
      [defaults synchronize];
    }];
  }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:
                        [[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"]
                                                 bundle:[NSBundle mainBundle]];
    self = [sb instantiateViewControllerWithIdentifier:@"CastInstructions"];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

-(IBAction)dismissOverlay:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

//- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
//                                                                   presentingController:(UIViewController *)presenting
//                                                                       sourceController:(UIViewController *)source
//{
//  SemiModalAnimatedTransition *semiModalAnimatedTransition = [[SemiModalAnimatedTransition alloc] init];
//  semiModalAnimatedTransition.presenting = YES;
//  return semiModalAnimatedTransition;
//}
//
//- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//  SemiModalAnimatedTransition *semiModalAnimatedTransition = [[SemiModalAnimatedTransition alloc] init];
//  return semiModalAnimatedTransition;
//}

@end
